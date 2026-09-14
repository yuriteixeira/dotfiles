import { mkdir, writeFile } from "node:fs/promises";
import { join } from "node:path";
import type { Api, Model, UserMessage } from "@earendil-works/pi-ai";
import {
	CONFIG_DIR_NAME,
	type ExtensionAPI,
	getAgentDir,
	type ExtensionCommandContext,
	withFileMutationQueue,
} from "@earendil-works/pi-coding-agent";
import { formatReflectionDraft, reflectionDraftFilename } from "./draft.ts";
import { loadProjectKnowledge } from "./knowledge.ts";
import { buildExtractionPrompt, buildReviewPrompt, EXTRACTION_SYSTEM_PROMPT, REVIEW_SYSTEM_PROMPT } from "./prompts.ts";
import { parseExtractionResponse, parseReviewResponse } from "./response-validation.ts";
import { loadRecentProjectTranscripts, loadSessionTranscript } from "../sessions/load.ts";
import { isPathWithin } from "../sessions/selection.ts";
import type { PromotionReview, ReflectionResult, SessionTranscript } from "./types.ts";

export type ReflectionProgress = (message: string) => void;

export interface ReflectionOptions {
	sessionFile?: string;
	leafId?: string;
}

export const REFLECTION_PROVIDER = "openai-codex";
export const REFLECTION_MODEL_ID = "gpt-5.6-sol";
export const REFLECTION_THINKING_LEVEL = "high";

export async function runReflection(
	pi: ExtensionAPI,
	ctx: ExtensionCommandContext,
	onProgress: ReflectionProgress = () => {},
	options: ReflectionOptions = {},
): Promise<ReflectionResult> {
	if (!ctx.isProjectTrusted()) throw new Error("Reflection requires a trusted project");
	const model = ctx.modelRegistry.find(REFLECTION_PROVIDER, REFLECTION_MODEL_ID);
	if (!model) throw new Error(`Reflection model not found: ${REFLECTION_PROVIDER}/${REFLECTION_MODEL_ID}`);
	if (!ctx.modelRegistry.hasConfiguredAuth(model)) {
		throw new Error(`No authentication configured for ${REFLECTION_PROVIDER}/${REFLECTION_MODEL_ID}`);
	}

	onProgress("Resolving project root...");
	const projectRoot = await resolveProjectRoot(pi, ctx.cwd);
	const transcripts = await loadReflectionTranscripts(projectRoot, ctx, options, onProgress);
	if (transcripts.length === 0) throw new Error("No readable project session transcripts were found");

	onProgress(`Extracting evidence from ${transcripts.length} sessions...`);
	const extractionText = await completeReflectionPass(
		ctx,
		model,
		EXTRACTION_SYSTEM_PROMPT,
		buildExtractionPrompt(projectRoot, transcripts),
	);
	const extraction = parseExtractionResponse(extractionText, new Set(transcripts.map((transcript) => transcript.id)));

	const knowledge = await loadProjectKnowledge(projectRoot, getAgentDir());
	let review: PromotionReview = { proposals: [], discarded: [] };
	if (extraction.evidence.length > 0) {
		onProgress(`Reviewing ${extraction.evidence.length} evidence items for promotion...`);
		const reviewText = await completeReflectionPass(
			ctx,
			model,
			REVIEW_SYSTEM_PROMPT,
			buildReviewPrompt(extraction.evidence, knowledge),
		);
		review = parseReviewResponse(reviewText, new Set(extraction.evidence.map((item) => item.id)));
	}

	onProgress("Writing review draft...");
	const generatedAt = new Date();
	const draft = formatReflectionDraft({
		generatedAt,
		projectRoot,
		model: `${REFLECTION_PROVIDER}/${REFLECTION_MODEL_ID}:${REFLECTION_THINKING_LEVEL}`,
		transcripts,
		evidence: extraction.evidence,
		review,
	});
	const draftDirectory = join(projectRoot, CONFIG_DIR_NAME, "reflections");
	const draftPath = join(draftDirectory, reflectionDraftFilename(generatedAt));
	await withFileMutationQueue(draftPath, async () => {
		await mkdir(draftDirectory, { recursive: true });
		await writeFile(draftPath, draft, "utf8");
	});

	return {
		draftPath,
		sessionCount: transcripts.length,
		evidenceCount: extraction.evidence.length,
		proposalCount: review.proposals.length,
	};
}

async function loadReflectionTranscripts(
	projectRoot: string,
	ctx: ExtensionCommandContext,
	options: ReflectionOptions,
	onProgress: ReflectionProgress,
): Promise<SessionTranscript[]> {
	if (!options.sessionFile) {
		onProgress("Selecting the 20 most recent project sessions...");
		return loadRecentProjectTranscripts(projectRoot, ctx.sessionManager);
	}

	onProgress("Loading the departing session...");
	const transcript = await loadSessionTranscript(options.sessionFile, options.leafId);
	if (!isPathWithin(projectRoot, transcript.cwd)) {
		throw new Error(`Session cwd is outside the current project: ${transcript.cwd}`);
	}
	return [transcript];
}

export async function resolveProjectRoot(pi: ExtensionAPI, cwd: string): Promise<string> {
	const result = await pi.exec("git", ["-C", cwd, "rev-parse", "--show-toplevel"], { timeout: 5_000 });
	if (result.code !== 0) return cwd;
	return result.stdout.trim() || cwd;
}

async function completeReflectionPass(
	ctx: ExtensionCommandContext,
	model: Model<Api>,
	systemPrompt: string,
	prompt: string,
): Promise<string> {
	const message: UserMessage = {
		role: "user",
		content: [{ type: "text", text: prompt }],
		timestamp: Date.now(),
	};
	const response = await ctx.modelRegistry.complete(
		model,
		{ systemPrompt, messages: [message] },
		{ reasoningEffort: REFLECTION_THINKING_LEVEL, cacheRetention: "none" },
	);
	if (response.stopReason === "error" || response.stopReason === "aborted") {
		throw new Error(response.errorMessage || `Reflection model stopped with ${response.stopReason}`);
	}

	const text = response.content
		.filter((block): block is { type: "text"; text: string } => block.type === "text")
		.map((block) => block.text)
		.join("\n")
		.trim();
	if (!text) throw new Error("Reflection model returned no text");
	return text;
}
