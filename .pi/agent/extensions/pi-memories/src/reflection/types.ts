export type EvidenceKind =
	| "explicit_correction"
	| "repeated_friction"
	| "successful_procedure"
	| "stated_convention";

export type Confidence = "medium" | "high";

export interface SessionReference {
	sessionId: string;
	quote: string;
}

export interface EvidenceItem {
	id: string;
	kind: EvidenceKind;
	observation: string;
	durabilityReason: string;
	references: SessionReference[];
}

export interface ExtractionResult {
	evidence: EvidenceItem[];
}

export interface PromotionProposal {
	title: string;
	target: "agents" | "project_skill";
	path: string;
	action: "add" | "replace" | "create" | "update";
	confidence: Confidence;
	reason: string;
	evidenceIds: string[];
	proposedChange: string;
}

export interface DiscardedEvidence {
	evidenceIds: string[];
	reason: string;
}

export interface PromotionReview {
	proposals: PromotionProposal[];
	discarded: DiscardedEvidence[];
}

export interface SessionTranscript {
	id: string;
	path: string;
	cwd: string;
	modified: Date;
	text: string;
}

export interface KnowledgeFile {
	path: string;
	scope: "global" | "project";
	content: string;
}

export interface ProjectKnowledge {
	agentsPath: string;
	agentsContent: string;
	referenceInstructions: KnowledgeFile[];
	skills: KnowledgeFile[];
}

export interface ReflectionResult {
	draftPath: string;
	sessionCount: number;
	evidenceCount: number;
	proposalCount: number;
}
