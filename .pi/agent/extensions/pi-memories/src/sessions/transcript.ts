import type { SessionEntry } from "@earendil-works/pi-coding-agent";

export const MAX_SESSION_CHARS = 8_000;

const MAX_MESSAGE_CHARS = 1_500;
const MAX_ARGUMENT_CHARS = 600;
const MAX_RESULT_CHARS = 600;
const SECRET_VALUE = "[REDACTED]";
const BULK_RESULT_TOOLS = new Set(["read", "write", "edit"]);

interface ContentBlock {
	type?: string;
	text?: string;
	name?: string;
	arguments?: Record<string, unknown>;
}

interface MessageLike {
	role?: string;
	content?: unknown;
	toolName?: string;
	isError?: boolean;
}

export function normalizeSessionEntries(entries: readonly SessionEntry[], maxChars = MAX_SESSION_CHARS): string {
	const sections = entries.flatMap(formatEntry).filter((section) => section.trim().length > 0);
	return keepHeadAndTail(sections.join("\n\n"), maxChars);
}

function formatEntry(entry: SessionEntry): string[] {
	if (entry.type === "compaction") {
		return [`Session summary: ${limitAndRedact(entry.summary, MAX_MESSAGE_CHARS)}`];
	}
	if (entry.type === "branch_summary") {
		return [`Branch summary: ${limitAndRedact(entry.summary, MAX_MESSAGE_CHARS)}`];
	}
	if (entry.type !== "message") return [];

	const message = entry.message as MessageLike;
	if (message.role === "user") return formatConversationalMessage("User", message.content);
	if (message.role === "assistant") return formatAssistantMessage(message.content);
	if (message.role === "toolResult") return formatToolResult(message);
	return [];
}

function formatConversationalMessage(label: string, content: unknown): string[] {
	const text = extractText(content);
	return text ? [`${label}: ${limitAndRedact(text, MAX_MESSAGE_CHARS)}`] : [];
}

function formatAssistantMessage(content: unknown): string[] {
	const sections = formatConversationalMessage("Assistant", content);
	if (!Array.isArray(content)) return sections;

	for (const part of content) {
		if (!isRecord(part)) continue;
		const block = part as ContentBlock;
		if (block.type !== "toolCall" || typeof block.name !== "string") continue;
		sections.push(`Tool call: ${block.name} ${summarizeToolArguments(block.name, block.arguments ?? {})}`);
	}
	return sections;
}

function formatToolResult(message: MessageLike): string[] {
	const toolName = message.toolName ?? "unknown";
	const status = message.isError ? "error" : "success";
	if (!message.isError && BULK_RESULT_TOOLS.has(toolName)) {
		return [`Tool result: ${toolName} (${status}; content omitted)`];
	}

	const text = extractText(message.content);
	const excerpt = text ? `: ${limitAndRedact(text, MAX_RESULT_CHARS)}` : "";
	return [`Tool result: ${toolName} (${status})${excerpt}`];
}

function summarizeToolArguments(toolName: string, args: Record<string, unknown>): string {
	const safeSummary = summarizeKnownToolArguments(toolName, args);
	return limitAndRedact(JSON.stringify(safeSummary), MAX_ARGUMENT_CHARS);
}

function summarizeKnownToolArguments(toolName: string, args: Record<string, unknown>): Record<string, unknown> {
	const path = firstString(args.path, args.file_path);

	switch (toolName) {
		case "read":
			return compactRecord({ path, offset: args.offset, limit: args.limit });
		case "write":
			return compactRecord({ path, contentChars: stringLength(args.content) });
		case "edit":
			return compactRecord({ path, editCount: Array.isArray(args.edits) ? args.edits.length : undefined });
		case "bash":
			return compactRecord({ command: args.command, timeout: args.timeout });
		case "grep":
			return compactRecord({ pattern: args.pattern, path, glob: args.glob });
		case "find":
			return compactRecord({ pattern: args.pattern, path });
		default:
			return Object.fromEntries(
				Object.entries(args).map(([key, value]) => [key, summarizeUnknownValue(key, value)]),
			);
	}
}

function summarizeUnknownValue(key: string, value: unknown): unknown {
	if (/content|data|image|base64|oldtext|newtext/i.test(key)) {
		return typeof value === "string" ? `[omitted ${value.length} chars]` : "[omitted]";
	}
	if (typeof value === "string") return limitAndRedact(value, 300);
	if (typeof value === "number" || typeof value === "boolean" || value === null) return value;
	if (Array.isArray(value)) return `[${value.length} items]`;
	return "[object]";
}

function extractText(content: unknown): string {
	if (typeof content === "string") return content.trim();
	if (!Array.isArray(content)) return "";

	return content
		.filter((part): part is ContentBlock => isRecord(part) && part.type === "text" && typeof part.text === "string")
		.map((part) => part.text?.trim() ?? "")
		.filter(Boolean)
		.join("\n");
}

function limitAndRedact(value: string, maxChars: number): string {
	return truncate(redactSecrets(value), maxChars);
}

export function redactSecrets(value: string): string {
	return value
		.replace(/\b(authorization)(\s*:\s*)(bearer)\s+[a-z0-9._~+/=-]+/giu, `$1$2$3 ${SECRET_VALUE}`)
		.replace(/\b(bearer)\s+[a-z0-9._~+/=-]+/giu, `$1 ${SECRET_VALUE}`)
		.replace(
			/\b(api[_-]?key|access[_-]?token|auth(?!orization)|password|passwd|secret|token)\b(\s*[:=]\s*)([^\s,;]+)/giu,
			`$1$2${SECRET_VALUE}`,
		);
}

function keepHeadAndTail(value: string, maxChars: number): string {
	if (value.length <= maxChars) return value;
	const marker = "\n\n[... middle of session omitted ...]\n\n";
	const available = Math.max(0, maxChars - marker.length);
	const headChars = Math.ceil(available / 2);
	const tailChars = Math.floor(available / 2);
	return value.slice(0, headChars) + marker + value.slice(value.length - tailChars);
}

function truncate(value: string, maxChars: number): string {
	if (value.length <= maxChars) return value;
	return `${value.slice(0, Math.max(0, maxChars - 16))}... [truncated]`;
}

function firstString(...values: unknown[]): string | undefined {
	return values.find((value): value is string => typeof value === "string");
}

function stringLength(value: unknown): number | undefined {
	return typeof value === "string" ? value.length : undefined;
}

function compactRecord(record: Record<string, unknown>): Record<string, unknown> {
	return Object.fromEntries(Object.entries(record).filter(([, value]) => value !== undefined));
}

function isRecord(value: unknown): value is Record<string, unknown> {
	return typeof value === "object" && value !== null && !Array.isArray(value);
}
