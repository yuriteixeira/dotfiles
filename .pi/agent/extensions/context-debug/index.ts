import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { join } from "node:path";

const DEBUG_DIR = "/home/yuriteixeira/.pi/agent/debug-payloads";
const FULL_DUMP_ENV = "PI_DEBUG_FULL_PAYLOAD";

type DebugCapture = {
  id: string;
  prompt: string;
  requestedAt: number;
  summaryPath?: string;
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

let pendingDebug: DebugCapture | null = null;
let activeDebug: DebugCapture | null = null;

export default function (pi: ExtensionAPI) {
  mkdirSync(DEBUG_DIR, { recursive: true });

  pi.registerCommand("context-debug", {
    description: "Send a prompt and show the provider payload/context-size breakdown for that prompt",
    handler: async (args, ctx) => {
      const prompt = args.trim();
      if (!prompt) {
        ctx.ui.notify("Usage: /debug <prompt>", "warning");
        return;
      }

      if (!ctx.isIdle()) {
        ctx.ui.notify("Agent is busy. Wait until it is idle before using /debug.", "warning");
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
    const summary = buildPayloadSummary(payload, capture);
    const summaryPath = join(DEBUG_DIR, `${capture.id}.summary.md`);
    writeFileSync(summaryPath, summary, "utf8");
    capture.summaryPath = summaryPath;

    if (process.env[FULL_DUMP_ENV] === "1") {
      const fullPayloadPath = join(DEBUG_DIR, `${capture.id}.payload.json`);
      writeFileSync(fullPayloadPath, JSON.stringify(payload, null, 2), "utf8");
      capture.fullPayloadPath = fullPayloadPath;
    }

    ctx.ui.notify(`Debug payload summary written: ${summaryPath}`, "info");
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
    const payloadSummary = capture.summaryPath
      ? readSummaryHint(capture.summaryPath)
      : "Payload summary was not written.";
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
    `# /debug payload report`,
    ``,
    `Prompt: ${JSON.stringify(capture.prompt)}`,
    `Model: ${String(payload.model ?? "unknown")}`,
    `Payload chars: ${payloadChars} (~${estimateTokens(payloadChars)} rough tokens by chars/4)` ,
    `Message content chars: ${messageChars} (~${estimateTokens(messageChars)} rough tokens)`,
    `Tool schema chars: ${toolChars} (~${estimateTokens(toolChars)} rough tokens)`,
    `Messages: ${messages.length}`,
    `Tools: ${tools.length}`,
    ``,
    `## Messages`,
    messageLines.length ? messageLines.join("\n") : `(none)`,
    ``,
    `## Tool schema sizes`,
    toolLines.length ? toolLines.join("\n") : `(none)`,
    ``,
    `Summary file: ${join(DEBUG_DIR, `${capture.id}.summary.md`)}`,
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
    `# /debug completion report`,
    ``,
    `Prompt: ${JSON.stringify(capture.prompt)}`,
    `Elapsed wall time: ${(elapsedMs / 1000).toFixed(2)}s`,
    `Provider usage:`,
    codeBlock(JSON.stringify(usage ?? null, null, 2)),
    `Current pi context usage:`,
    codeBlock(JSON.stringify(contextUsage ?? null, null, 2)),
    `Summary file: ${capture.summaryPath ?? "not written"}`,
  ].join("\n");
}

function formatMessageLine(message: { role?: string; content?: unknown }, index: number) {
  const text = getContentText(message.content);
  return `- #${index} role=${message.role ?? "unknown"} chars=${text.length} (~${estimateTokens(text.length)} rough tokens)`;
}

function summarizeTools(tools: unknown[]) {
  return tools.map((tool, index) => {
    const toolRecord = asRecord(tool);
    const fn = asRecord(toolRecord.function);
    const name = typeof fn.name === "string" ? fn.name : `tool_${index}`;
    const description = typeof fn.description === "string" ? fn.description : "";

    return {
      index,
      name,
      chars: compactJsonLength(tool),
      descriptionChars: description.length,
    };
  }).sort((a, b) => b.chars - a.chars);
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

function safeGetContextUsage(ctx: { getContextUsage?: () => unknown }) {
  try {
    return ctx.getContextUsage?.() ?? null;
  } catch (error) {
    return { error: error instanceof Error ? error.message : String(error) };
  }
}

function readSummaryHint(path: string) {
  try {
    return readFileSync(path, "utf8");
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    return `Could not read payload summary at ${path}: ${message}`;
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
