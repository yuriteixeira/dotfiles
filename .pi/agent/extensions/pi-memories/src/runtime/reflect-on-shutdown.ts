import { fileURLToPath } from "node:url";
import { dirname, resolve } from "node:path";
import type {
	ExtensionAPI,
	ExtensionContext,
	SessionEntry,
	SessionShutdownEvent,
} from "@earendil-works/pi-coding-agent";
import { launchBackgroundReflection } from "./background-reflection.ts";

const REFLECT_EXECUTABLE = resolve(dirname(fileURLToPath(import.meta.url)), "..", "..", "bin", "reflect");

export function registerReflectOnShutdown(pi: ExtensionAPI): void {
	pi.on("session_shutdown", handleReflectOnShutdown);
}

async function handleReflectOnShutdown(event: SessionShutdownEvent, ctx: ExtensionContext): Promise<void> {
	if ((event.reason !== "quit" && event.reason !== "new") || ctx.mode !== "tui") return;
	const sessionFile = ctx.sessionManager.getSessionFile();
	if (!sessionFile || !hasReflectableConversation(ctx.sessionManager.getBranch())) return;

	const confirmed = await ctx.ui.confirm(
		"Reflect on this session?",
		"Run a background reflection for this session only after Pi exits?",
	);
	if (!confirmed) return;

	try {
		await launchBackgroundReflection({
			executable: REFLECT_EXECUTABLE,
			cwd: ctx.cwd,
			sessionFile,
			leafId: ctx.sessionManager.getLeafId() ?? undefined,
		});
		ctx.ui.notify("Background session reflection started", "info");
	} catch (error) {
		ctx.ui.notify(`Could not start background reflection: ${formatError(error)}`, "error");
	}
}

function hasReflectableConversation(entries: readonly SessionEntry[]): boolean {
	let hasUser = false;
	let hasAssistant = false;
	for (const entry of entries) {
		if (entry.type !== "message") continue;
		if (entry.message.role === "user") hasUser = true;
		if (entry.message.role === "assistant") hasAssistant = true;
	}
	return hasUser && hasAssistant;
}

function formatError(error: unknown): string {
	return error instanceof Error ? error.message : String(error);
}
