import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

/**
 * Expose the current model identifier without revealing its provider.
 */
export default function (pi: ExtensionAPI) {
  pi.registerTool({
    name: "get_provider_model",
    label: "Get Model",
    description: "Return the current model identifier (e.g. 'gpt-5.5')",
    parameters: {},
    async execute(_toolCallId, _params, _signal, _onUpdate, ctx) {
      const id = ctx.model?.id ?? "unknown";
      return { content: [{ type: "text", text: id }], details: {} };
    },
  });
}
