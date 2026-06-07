type BeforeAgentStartEvent = {
	systemPrompt: string;
};

type BeforeAgentStartResult = {
	systemPrompt?: string;
};

type PiLike = {
	on(event: "before_agent_start", handler: (event: BeforeAgentStartEvent) => BeforeAgentStartResult | void): void;
};

const CURRENT_DATE_LINE = /\nCurrent date: \d{4}-\d{2}-\d{2}(?=\nCurrent working directory: [^\n]+$)/;

function stripCurrentDateLine(systemPrompt: string): string {
	return systemPrompt.replace(CURRENT_DATE_LINE, "");
}

export default function (pi: PiLike) {
	pi.on("before_agent_start", (event) => {
		const systemPrompt = stripCurrentDateLine(event.systemPrompt);

		if (systemPrompt === event.systemPrompt) {
			return;
		}

		return { systemPrompt };
	});
}
