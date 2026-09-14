import type {
	Confidence,
	DiscardedEvidence,
	EvidenceItem,
	EvidenceKind,
	ExtractionResult,
	PromotionProposal,
	PromotionReview,
} from "./types.ts";

const EVIDENCE_KINDS = new Set<EvidenceKind>([
	"explicit_correction",
	"repeated_friction",
	"successful_procedure",
	"stated_convention",
]);
const CONFIDENCE_LEVELS = new Set<Confidence>(["medium", "high"]);
const ACTIONS = new Set(["add", "replace", "create", "update"] as const);
const PROJECT_SKILL_PATH = /^\.pi\/skills\/[a-z0-9]+(?:-[a-z0-9]+)*\/SKILL\.md$/u;

export function parseExtractionResponse(text: string, knownSessionIds: ReadonlySet<string>): ExtractionResult {
	const root = parseJsonObject(text);
	if (!Array.isArray(root.evidence)) throw new Error("Extraction response is missing an evidence array");

	const evidence = root.evidence.map((value, index) => parseEvidence(value, index, knownSessionIds));
	const ids = new Set(evidence.map((item) => item.id));
	if (ids.size !== evidence.length) throw new Error("Extraction response contains duplicate evidence ids");
	return { evidence };
}

export function parseReviewResponse(text: string, knownEvidenceIds: ReadonlySet<string>): PromotionReview {
	const root = parseJsonObject(text);
	if (!Array.isArray(root.proposals)) throw new Error("Review response is missing a proposals array");
	if (!Array.isArray(root.discarded)) throw new Error("Review response is missing a discarded array");

	return {
		proposals: root.proposals.map((value, index) => parseProposal(value, index, knownEvidenceIds)),
		discarded: root.discarded.map((value, index) => parseDiscarded(value, index, knownEvidenceIds)),
	};
}

function parseEvidence(value: unknown, index: number, knownSessionIds: ReadonlySet<string>): EvidenceItem {
	const item = requireRecord(value, `evidence[${index}]`);
	const kind = requireString(item.kind, `evidence[${index}].kind`) as EvidenceKind;
	if (!EVIDENCE_KINDS.has(kind)) throw new Error(`Unsupported evidence kind: ${kind}`);

	const references = requireArray(item.references, `evidence[${index}].references`).map((reference, refIndex) => {
		const parsed = requireRecord(reference, `evidence[${index}].references[${refIndex}]`);
		const sessionId = requireString(parsed.sessionId, `evidence[${index}].references[${refIndex}].sessionId`);
		if (!knownSessionIds.has(sessionId)) throw new Error(`Evidence references unknown session: ${sessionId}`);
		return {
			sessionId,
			quote: requireString(parsed.quote, `evidence[${index}].references[${refIndex}].quote`),
		};
	});
	if (references.length === 0) throw new Error(`evidence[${index}] has no references`);
	const independentSessionCount = new Set(references.map((reference) => reference.sessionId)).size;
	if ((kind === "repeated_friction" || kind === "successful_procedure") && independentSessionCount < 2) {
		throw new Error(`evidence[${index}] requires at least two independent sessions`);
	}

	return {
		id: requireString(item.id, `evidence[${index}].id`),
		kind,
		observation: requireString(item.observation, `evidence[${index}].observation`),
		durabilityReason: requireString(item.durabilityReason, `evidence[${index}].durabilityReason`),
		references,
	};
}

function parseProposal(value: unknown, index: number, knownEvidenceIds: ReadonlySet<string>): PromotionProposal {
	const item = requireRecord(value, `proposals[${index}]`);
	const target = requireString(item.target, `proposals[${index}].target`);
	if (target !== "agents" && target !== "project_skill") throw new Error(`Unsupported proposal target: ${target}`);

	const path = requireString(item.path, `proposals[${index}].path`);
	if (target === "agents" && path !== "AGENTS.md") throw new Error(`Invalid AGENTS.md proposal path: ${path}`);
	if (target === "project_skill" && !PROJECT_SKILL_PATH.test(path)) {
		throw new Error(`Invalid project skill proposal path: ${path}`);
	}

	const action = requireString(item.action, `proposals[${index}].action`) as PromotionProposal["action"];
	if (!ACTIONS.has(action)) throw new Error(`Unsupported proposal action: ${action}`);
	const confidence = requireString(item.confidence, `proposals[${index}].confidence`) as Confidence;
	if (!CONFIDENCE_LEVELS.has(confidence)) throw new Error(`Unsupported confidence: ${confidence}`);

	return {
		title: requireString(item.title, `proposals[${index}].title`),
		target,
		path,
		action,
		confidence,
		reason: requireString(item.reason, `proposals[${index}].reason`),
		evidenceIds: parseEvidenceIds(item.evidenceIds, `proposals[${index}].evidenceIds`, knownEvidenceIds),
		proposedChange: requireString(item.proposedChange, `proposals[${index}].proposedChange`),
	};
}

function parseDiscarded(value: unknown, index: number, knownEvidenceIds: ReadonlySet<string>): DiscardedEvidence {
	const item = requireRecord(value, `discarded[${index}]`);
	return {
		evidenceIds: parseEvidenceIds(item.evidenceIds, `discarded[${index}].evidenceIds`, knownEvidenceIds),
		reason: requireString(item.reason, `discarded[${index}].reason`),
	};
}

function parseEvidenceIds(value: unknown, label: string, knownEvidenceIds: ReadonlySet<string>): string[] {
	const ids = requireArray(value, label).map((id, index) => requireString(id, `${label}[${index}]`));
	if (ids.length === 0) throw new Error(`${label} must not be empty`);
	for (const id of ids) {
		if (!knownEvidenceIds.has(id)) throw new Error(`${label} references unknown evidence: ${id}`);
	}
	return ids;
}

function parseJsonObject(text: string): Record<string, unknown> {
	const unfenced = text.trim().replace(/^```(?:json)?\s*/iu, "").replace(/\s*```$/u, "");
	const start = unfenced.indexOf("{");
	const end = unfenced.lastIndexOf("}");
	if (start < 0 || end < start) throw new Error("Model response did not contain a JSON object");

	let parsed: unknown;
	try {
		parsed = JSON.parse(unfenced.slice(start, end + 1));
	} catch (error) {
		throw new Error(`Model returned invalid JSON: ${formatError(error)}`);
	}
	return requireRecord(parsed, "response");
}

function requireRecord(value: unknown, label: string): Record<string, unknown> {
	if (typeof value !== "object" || value === null || Array.isArray(value)) {
		throw new Error(`${label} must be an object`);
	}
	return value as Record<string, unknown>;
}

function requireArray(value: unknown, label: string): unknown[] {
	if (!Array.isArray(value)) throw new Error(`${label} must be an array`);
	return value;
}

function requireString(value: unknown, label: string): string {
	if (typeof value !== "string" || value.trim().length === 0) throw new Error(`${label} must be a non-empty string`);
	return value.trim();
}

function formatError(error: unknown): string {
	return error instanceof Error ? error.message : String(error);
}
