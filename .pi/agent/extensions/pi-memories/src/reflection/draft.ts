import type { EvidenceItem, PromotionReview, SessionTranscript } from "./types.ts";

interface DraftInput {
	generatedAt: Date;
	projectRoot: string;
	model: string;
	transcripts: SessionTranscript[];
	evidence: EvidenceItem[];
	review: PromotionReview;
}

export function formatReflectionDraft(input: DraftInput): string {
	const lines = [
		"# Pi Reflection Draft",
		"",
		"> Review artifact only. No `AGENTS.md` or skill files were modified.",
		"",
		"## Run metadata",
		"",
		`- Generated: ${input.generatedAt.toISOString()}`,
		`- Project: \`${input.projectRoot}\``,
		`- Model: \`${input.model}\``,
		`- Sessions analyzed: ${input.transcripts.length}`,
		`- Evidence items: ${input.evidence.length}`,
		`- Promotion proposals: ${input.review.proposals.length}`,
		"",
		"## Proposals",
		"",
	];

	if (input.review.proposals.length === 0) {
		lines.push("No durable knowledge was recommended for promotion.", "");
	}

	for (const [index, proposal] of input.review.proposals.entries()) {
		lines.push(
			`### ${index + 1}. ${proposal.title}`,
			"",
			`- Target: \`${proposal.path}\``,
			`- Type: ${proposal.target}`,
			`- Action: ${proposal.action}`,
			`- Confidence: ${proposal.confidence}`,
			`- Evidence: ${proposal.evidenceIds.map((id) => `\`${id}\``).join(", ")}`,
			"",
			"**Reason**",
			"",
			proposal.reason,
			"",
			"**Proposed change**",
			"",
			"````text",
			proposal.proposedChange,
			"````",
			"",
		);
	}

	lines.push("## Evidence", "");
	if (input.evidence.length === 0) lines.push("No durable evidence was extracted.", "");
	for (const item of input.evidence) {
		lines.push(
			`### ${item.id}: ${item.observation}`,
			"",
			`- Kind: ${item.kind}`,
			`- Durability: ${item.durabilityReason}`,
			"- Sources:",
		);
		for (const reference of item.references) {
			lines.push(`  - \`${reference.sessionId}\`: “${singleLine(reference.quote)}”`);
		}
		lines.push("");
	}

	lines.push("## Discarded during promotion review", "");
	if (input.review.discarded.length === 0) lines.push("None.", "");
	for (const discarded of input.review.discarded) {
		lines.push(`- ${discarded.evidenceIds.map((id) => `\`${id}\``).join(", ")}: ${discarded.reason}`);
	}
	lines.push("", "## Session index", "");
	for (const transcript of input.transcripts) {
		lines.push(`- \`${transcript.id}\` — ${transcript.modified.toISOString()} — \`${transcript.cwd}\``);
	}
	lines.push("");
	return lines.join("\n");
}

export function reflectionDraftFilename(generatedAt: Date): string {
	return `${generatedAt.toISOString().replace(/[:.]/gu, "-")}.md`;
}

function singleLine(value: string): string {
	return value.replace(/\s+/gu, " ").trim();
}
