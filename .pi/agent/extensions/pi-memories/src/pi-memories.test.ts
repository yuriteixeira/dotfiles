import assert from "node:assert/strict";
import { mkdir, mkdtemp, rm, symlink, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";
import test from "node:test";
import type { SessionEntry } from "@earendil-works/pi-coding-agent";
import { formatReflectionDraft, reflectionDraftFilename } from "./reflection/draft.ts";
import { loadProjectKnowledge } from "./reflection/knowledge.ts";
import { parseExtractionResponse, parseReviewResponse } from "./reflection/response-validation.ts";
import { isPathWithin, selectRecentProjectSessions } from "./sessions/selection.ts";
import { normalizeSessionEntries, redactSecrets } from "./sessions/transcript.ts";

const userEntry = (text: string): SessionEntry =>
	({
		type: "message",
		id: "user0001",
		parentId: null,
		timestamp: "2026-09-14T10:00:00.000Z",
		message: { role: "user", content: text, timestamp: Date.now() },
	}) as SessionEntry;

const assistantEntry = (): SessionEntry =>
	({
		type: "message",
		id: "asst0001",
		parentId: "user0001",
		timestamp: "2026-09-14T10:00:01.000Z",
		message: {
			role: "assistant",
			content: [
				{ type: "thinking", thinking: "private reasoning" },
				{ type: "text", text: "I will update it." },
				{ type: "toolCall", id: "call-1", name: "write", arguments: { path: "a.ts", content: "secret body" } },
			],
			api: "test",
			provider: "test",
			model: "test",
			usage: {},
			stopReason: "stop",
			timestamp: Date.now(),
		},
	}) as SessionEntry;

test("project path matching accepts the root and descendants only", () => {
	assert.equal(isPathWithin("/work/repo", "/work/repo"), true);
	assert.equal(isPathWithin("/work/repo", "/work/repo/src"), true);
	assert.equal(isPathWithin("/work/repo", "/work/repository"), false);
	assert.equal(isPathWithin("/work/repo", "/work/other"), false);
});

test("session selection sorts newest first and applies the limit", () => {
	const selected = selectRecentProjectSessions(
		[
			{ id: "outside", cwd: "/work/other", modified: new Date("2026-09-14T13:00:00Z") },
			{ id: "older", cwd: "/work/repo", modified: new Date("2026-09-14T11:00:00Z") },
			{ id: "newer", cwd: "/work/repo/src", modified: new Date("2026-09-14T12:00:00Z") },
		],
		"/work/repo",
		1,
	);

	assert.deepEqual(selected.map((session) => session.id), ["newer"]);
});

test("knowledge loading follows symlinked global skill directories", async () => {
	const root = await mkdtemp(join(tmpdir(), "pi-memories-test-"));
	const projectRoot = join(root, "project");
	const agentDir = join(root, "agent");
	const externalSkill = join(root, "external", "commit");

	try {
		await mkdir(projectRoot, { recursive: true });
		await mkdir(join(agentDir, "skills"), { recursive: true });
		await mkdir(externalSkill, { recursive: true });
		await writeFile(join(externalSkill, "SKILL.md"), "---\nname: commit\ndescription: Commit safely.\n---\n", "utf8");
		await symlink(externalSkill, join(agentDir, "skills", "commit"), process.platform === "win32" ? "junction" : "dir");

		const knowledge = await loadProjectKnowledge(projectRoot, agentDir);
		assert.equal(knowledge.skills.length, 1);
		assert.equal(knowledge.skills[0]?.scope, "global");
		assert.equal(knowledge.skills[0]?.path, join("~/.pi/agent/skills", "commit", "SKILL.md"));
	} finally {
		await rm(root, { recursive: true, force: true });
	}
});

test("session normalization omits thinking and bulk content while redacting secrets", () => {
	const text = normalizeSessionEntries(
		[
			userEntry("Use token=abc123 and remember pnpm."),
			assistantEntry(),
			{
				type: "message",
				id: "tool0001",
				parentId: "asst0001",
				timestamp: "2026-09-14T10:00:02.000Z",
				message: {
					role: "toolResult",
					toolCallId: "call-1",
					toolName: "write",
					content: [{ type: "text", text: "entire file body" }],
					isError: false,
					timestamp: Date.now(),
				},
			} as SessionEntry,
		],
		20_000,
	);

	assert.match(text, /token=\[REDACTED\]/u);
	assert.match(text, /"contentChars":11/u);
	assert.match(text, /content omitted/u);
	assert.doesNotMatch(text, /private reasoning|secret body|entire file body/u);
});

test("secret redaction covers bearer credentials and common key names", () => {
	assert.equal(redactSecrets("Authorization: Bearer abc.def token=qwerty"), "Authorization: Bearer [REDACTED] token=[REDACTED]");
});

test("structured responses are parsed and provenance is validated", () => {
	const extraction = parseExtractionResponse(
		JSON.stringify({
			evidence: [
				{
					id: "E1",
					kind: "explicit_correction",
					observation: "Use pnpm",
					durabilityReason: "Explicit correction",
					references: [{ sessionId: "session-1", quote: "Use pnpm" }],
				},
			],
		}),
		new Set(["session-1"]),
	);
	const review = parseReviewResponse(
		JSON.stringify({
			proposals: [
				{
					title: "Document pnpm",
					target: "agents",
					path: "AGENTS.md",
					action: "add",
					confidence: "high",
					reason: "Explicit correction",
					evidenceIds: ["E1"],
					proposedChange: "+ Use pnpm.",
				},
			],
			discarded: [],
		}),
		new Set(extraction.evidence.map((item) => item.id)),
	);

	assert.equal(review.proposals[0]?.path, "AGENTS.md");
	assert.throws(
		() =>
			parseReviewResponse(
				JSON.stringify({
					proposals: [
						{
							title: "Escape",
							target: "project_skill",
							path: "../../SKILL.md",
							action: "create",
							confidence: "high",
							reason: "bad",
							evidenceIds: ["E1"],
							proposedChange: "bad",
						},
					],
					discarded: [],
				}),
				new Set(["E1"]),
			),
		/Invalid project skill proposal path/u,
	);
});

test("repeated evidence requires independent sessions", () => {
	assert.throws(
		() =>
			parseExtractionResponse(
				JSON.stringify({
					evidence: [
						{
							id: "E1",
							kind: "repeated_friction",
							observation: "Repeated issue",
							durabilityReason: "Repeated",
							references: [{ sessionId: "session-1", quote: "again" }],
						},
					],
				}),
				new Set(["session-1"]),
			),
		/requires at least two independent sessions/u,
	);
});

test("draft formatting clearly marks output as review-only", () => {
	const generatedAt = new Date("2026-09-14T12:34:56.000Z");
	const draft = formatReflectionDraft({
		generatedAt,
		projectRoot: "/work/repo",
		model: "provider/model",
		transcripts: [],
		evidence: [],
		review: { proposals: [], discarded: [] },
	});

	assert.match(draft, /Review artifact only/u);
	assert.match(draft, /No durable knowledge was recommended/u);
	assert.equal(reflectionDraftFilename(generatedAt), "2026-09-14T12-34-56-000Z.md");
});
