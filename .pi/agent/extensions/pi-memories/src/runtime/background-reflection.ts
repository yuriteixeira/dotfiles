import { access } from "node:fs/promises";
import { constants } from "node:fs";
import { spawn } from "node:child_process";

interface BackgroundReflectionInput {
	executable: string;
	cwd: string;
	sessionFile: string;
	leafId?: string;
}

export async function launchBackgroundReflection(input: BackgroundReflectionInput): Promise<void> {
	await access(input.executable, constants.X_OK);
	const args = ["--session-file", input.sessionFile];
	if (input.leafId) args.push("--leaf-id", input.leafId);
	args.push(input.cwd);

	const child = spawn(input.executable, args, {
		cwd: input.cwd,
		detached: true,
		stdio: "ignore",
		env: process.env,
	});
	await waitForSpawn(child);
	child.unref();
}

function waitForSpawn(child: ReturnType<typeof spawn>): Promise<void> {
	return new Promise((resolve, reject) => {
		child.once("spawn", resolve);
		child.once("error", reject);
	});
}
