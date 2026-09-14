import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { registerReflectCommand } from "./runtime/reflect-command.ts";
import { registerReflectOnShutdown } from "./runtime/reflect-on-shutdown.ts";

export default function piMemoriesExtension(pi: ExtensionAPI) {
	registerReflectCommand(pi);
	registerReflectOnShutdown(pi);
}
