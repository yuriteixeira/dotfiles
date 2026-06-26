import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { mkdirSync, writeFileSync } from "node:fs";
import { join } from "node:path";

const DEBUG_DIR = "/home/yuriteixeira/.pi/agent/debug-payloads";
const FULL_DUMP_ENV = "PI_DEBUG_FULL_PAYLOAD";

type DebugCapture = {
  id: string;
  prompt: string;
  requestedAt: number;
  payloadSummary?: string;
  fullPayloadPath?: string;
};

type ProviderPayload = {
  model?: string;
  messages?: Array<{ role?: string; content?: unknown }>;
  tools?: unknown[];
  [key: string]: unknown;
};

type ToolSummary = {
  index: number;
  name: string;
  chars: number;
  descriptionChars: number;
};

type ToolDeclaration = {
  index: number;
  value: unknown;
};

let pendingDebug: DebugCapture | null = null;
let activeDebug: DebugCapture | null = null;

export default function (pi: ExtensionAPI) {
  pi.registerCommand("context-debug", {
    description: "Send a prompt and show the provider payload/context-size breakdown for that prompt",
    handler: async (args, ctx) => {
      const prompt = args.trim();
      if (!prompt) {
        ctx.ui.notify("Usage: /context-debug <prompt>", "warning");
        return;
      }

      if (!ctx.isIdle()) {
        ctx.ui.notify("Agent is busy. Wait until it is idle before using /context-debug.", "warning");
        return;
      }

      pendingDebug = {
        id: createDebugId(),
        prompt,
        requestedAt: Date.now(),
      };

      ctx.ui.notify(`Debugging next prompt payload: ${prompt.slice(0, 80)}`, "info");
      pi.sendUserMessage(prompt);
    },
  });

  pi.on("before_provider_request", (event, ctx) => {
    if (!pendingDebug) return;

    const capture = pendingDebug;
    pendingDebug = null;
    activeDebug = capture;

    const payload = event.payload as ProviderPayload;
    capture.payloadSummary = buildPayloadSummary(payload, capture);

    if (process.env[FULL_DUMP_ENV] === "1") {
      mkdirSync(DEBUG_DIR, { recursive: true });
      const fullPayloadPath = join(DEBUG_DIR, `${capture.id}.payload.json`);
      writeFileSync(fullPayloadPath, JSON.stringify(payload, null, 2), "utf8");
      capture.fullPayloadPath = fullPayloadPath;
    }

    ctx.ui.notify("Debug payload summary captured; it will appear in the assistant response.", "info");
  });

  pi.on("message_end", (event, ctx) => {
    if (!activeDebug) return;
    if (event.message.role !== "assistant") return;

    const capture = activeDebug;
    activeDebug = null;

    const usage = (event.message as { usage?: unknown }).usage;
    const contextUsage = safeGetContextUsage(ctx);
    const elapsedMs = Date.now() - capture.requestedAt;
    const completionSummary = buildCompletionSummary(capture, usage, contextUsage, elapsedMs);
    const payloadSummary = capture.payloadSummary ?? "Payload summary was not captured.";
    const debugReport = `${payloadSummary}\n\n---\n\n${completionSummary}\n\n---\n\n`;

    return {
      message: {
        ...event.message,
        content: prependTextContent((event.message as { content?: unknown }).content, debugReport),
      },
    };
  });
}

function createDebugId() {
  const timestamp = new Date().toISOString().replace(/[:.]/g, "-");
  const random = Math.random().toString(16).slice(2, 8);
  return `${timestamp}-${random}`;
}

function buildPayloadSummary(payload: ProviderPayload, capture: DebugCapture) {
  const messages = Array.isArray(payload.messages) ? payload.messages : [];
  const tools = Array.isArray(payload.tools) ? payload.tools : [];
  const messageLines = messages.map(formatMessageLine);
  const toolSummaries = summarizeTools(tools);
  const toolLines = toolSummaries.map(formatToolLine);
  const payloadChars = compactJsonLength(payload);
  const messageChars = messages.reduce((total, message) => total + getContentText(message.content).length, 0);
  const toolChars = toolSummaries.reduce((total, tool) => total + tool.chars, 0);
  const fullDumpNote = process.env[FULL_DUMP_ENV] === "1"
    ? `Full payload JSON: ${join(DEBUG_DIR, `${capture.id}.payload.json`)}`
    : `Full payload JSON: disabled (rerun pi with ${FULL_DUMP_ENV}=1 to enable)`;

  return [
    `# /context-debug payload report`,
    ``,
    `Prompt: ${JSON.stringify(capture.prompt)}`,
    `Model: ${String(payload.model ?? "unknown")}`,
    `Payload chars: ${payloadChars} (~${estimateTokens(payloadChars)} rough tokens by chars/4)` ,
    `Message content chars: ${messageChars} (~${estimateTokens(messageChars)} rough tokens)`,
    `Tool schema chars: ${toolChars} (~${estimateTokens(toolChars)} rough tokens)`,
    `Messages: ${messages.length}`,
    `Tools: ${toolSummaries.length}`,
    ``,
    `## Messages`,
    messageLines.length ? messageLines.join("\n") : `(none)`,
    ``,
    `## Tool schema sizes`,
    toolLines.length ? toolLines.join("\n") : `(none)`,
    ``,
    fullDumpNote,
  ].join("\n");
}

function buildCompletionSummary(
  capture: DebugCapture,
  usage: unknown,
  contextUsage: unknown,
  elapsedMs: number,
) {
  return [
    `# /context-debug completion report`,
    ``,
    `Prompt: ${JSON.stringify(capture.prompt)}`,
    `Elapsed wall time: ${(elapsedMs / 1000).toFixed(2)}s`,
    `Provider usage:`,
    codeBlock(JSON.stringify(usage ?? null, null, 2)),
    `Current pi context usage:`,
    codeBlock(JSON.stringify(contextUsage ?? null, null, 2)),
  ].join("\n");
}

function formatMessageLine(message: { role?: string; content?: unknown }, index: number) {
  const text = getContentText(message.content);
  return `- #${index} role=${message.role ?? "unknown"} chars=${text.length} (~${estimateTokens(text.length)} rough tokens)`;
}

function summarizeTools(tools: unknown[]) {
  return flattenToolDeclarations(tools).map(({ value, index }) => {
    const name = getToolName(value) ?? `tool_${index}`;
    const description = getToolDescription(value) ?? "";

    return {
      index,
      name,
      chars: compactJsonLength(value),
      descriptionChars: description.length,
    };
  }).sort((a, b) => b.chars - a.chars);
}

function flattenToolDeclarations(tools: unknown[]): ToolDeclaration[] {
  const declarations: ToolDeclaration[] = [];

  for (const tool of tools) {
    const toolRecord = asRecord(tool);
    const nestedDeclarations = getArrayProperty(toolRecord, "functionDeclarations")
      ?? getArrayProperty(toolRecord, "function_declarations");
    const values = nestedDeclarations ?? [tool];

    for (const value of values) {
      declarations.push({ index: declarations.length, value });
    }
  }

  return declarations;
}

function getToolName(tool: unknown): string | undefined {
  const record = asRecord(tool);
  return getStringProperty(record, "name")
    ?? getStringProperty(asRecord(record.function), "name")
    ?? getStringProperty(asRecord(record.toolSpec), "name")
    ?? getStringProperty(asRecord(record.tool_spec), "name")
    ?? getSingleStringKey(record);
}

function getToolDescription(tool: unknown): string | undefined {
  const record = asRecord(tool);
  return getStringProperty(record, "description")
    ?? getStringProperty(asRecord(record.function), "description")
    ?? getStringProperty(asRecord(record.toolSpec), "description")
    ?? getStringProperty(asRecord(record.tool_spec), "description");
}

function formatToolLine(tool: ToolSummary) {
  return `- #${tool.index} ${tool.name}: ${tool.chars} chars (~${estimateTokens(tool.chars)} rough tokens), description=${tool.descriptionChars} chars`;
}

function getContentText(content: unknown): string {
  if (typeof content === "string") return content;
  if (content == null) return "";
  return JSON.stringify(content);
}

function compactJsonLength(value: unknown) {
  return JSON.stringify(value, null, 0).length;
}

function estimateTokens(chars: number) {
  return Math.ceil(chars / 4);
}

function asRecord(value: unknown): Record<string, unknown> {
  if (typeof value !== "object" || value === null) return {};
  return value as Record<string, unknown>;
}

function getStringProperty(record: Record<string, unknown>, key: string) {
  const value = record[key];
  return typeof value === "string" ? value : undefined;
}

function getArrayProperty(record: Record<string, unknown>, key: string) {
  const value = record[key];
  return Array.isArray(value) ? value : undefined;
}

function getSingleStringKey(record: Record<string, unknown>) {
  const keys = Object.keys(record);
  return keys.length === 1 && isLikelyToolName(keys[0]) ? keys[0] : undefined;
}

function isLikelyToolName(value: string) {
  return /^[a-zA-Z][a-zA-Z0-9_-]{1,63}$/.test(value);
}

function safeGetContextUsage(ctx: { getContextUsage?: () => unknown }) {
  try {
    return ctx.getContextUsage?.() ?? null;
  } catch (error) {
    return { error: error instanceof Error ? error.message : String(error) };
  }
}

function prependTextContent(content: unknown, prefix: string) {
  if (typeof content === "string") return `${prefix}${content}`;
  if (Array.isArray(content)) return [{ type: "text", text: prefix }, ...content];
  if (content == null) return prefix;
  return [{ type: "text", text: prefix }, { type: "text", text: JSON.stringify(content) }];
}

function codeBlock(value: string) {
  return ["```json", value, "```"].join("\n");
}
