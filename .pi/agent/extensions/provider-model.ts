import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

/**
 * Expose the current provider/model via a tool so skills and other
 * extensions can fill attribution lines dynamically.
 */
export default function (pi: ExtensionAPI) {
  pi.registerTool({
    name: "get_provider_model",
    label: "Get Provider/Model",
    description: "Return the current provider and model identifier (e.g. 'google/gemini-2.5-flash')",
    parameters: {},
    async execute(_toolCallId, _params, _signal, _onUpdate, ctx) {
      const model = ctx.model;
      const id = model ? `${model.provider}/${model.id}` : "unknown/unknown";
      return { content: [{ type: "text", text: id }], details: {} };
    },
  });
}
