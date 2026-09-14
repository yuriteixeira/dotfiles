import type { ExtensionAPI, ExtensionCommandContext } from "@earendil-works/pi-coding-agent";
import { runReflection } from "../reflection/run.ts";

const STATUS_KEY = "pi-memories";
const COMMAND_DESCRIPTION = "Draft durable project knowledge from the 20 most recent sessions";

export function registerReflectCommand(pi: ExtensionAPI): void {
	pi.registerCommand("reflect", {
		description: COMMAND_DESCRIPTION,
		handler: handleReflectCommand.bind(undefined, pi),
	});
}

async function handleReflectCommand(
	pi: ExtensionAPI,
	_args: string,
	ctx: ExtensionCommandContext,
): Promise<void> {
	await ctx.waitForIdle();
	try {
		const result = await runReflection(
			pi,
			ctx,
			updateReflectionStatus.bind(undefined, ctx),
			reflectionOptionsFromEnvironment(),
		);
		const summary = `Reflection draft: ${result.draftPath}\n${result.proposalCount} proposals from ${result.evidenceCount} evidence items across ${result.sessionCount} sessions.`;
		if (ctx.hasUI) ctx.ui.notify(summary, "info");
		else process.stdout.write(`${summary}\n`);
	} catch (error) {
		const message = `Reflection failed: ${formatError(error)}`;
		if (ctx.hasUI) ctx.ui.notify(message, "error");
		else {
			process.stderr.write(`${message}\n`);
			process.exitCode = 1;
		}
	} finally {
		if (ctx.hasUI) ctx.ui.setStatus(STATUS_KEY, undefined);
	}
}

function updateReflectionStatus(ctx: ExtensionCommandContext, message: string): void {
	if (ctx.hasUI) ctx.ui.setStatus(STATUS_KEY, message);
}

function reflectionOptionsFromEnvironment(): { sessionFile?: string; leafId?: string } {
	return {
		sessionFile: process.env.PI_MEMORIES_SESSION_FILE || undefined,
		leafId: process.env.PI_MEMORIES_LEAF_ID || undefined,
	};
}

function formatError(error: unknown): string {
	return error instanceof Error ? error.message : String(error);
}
