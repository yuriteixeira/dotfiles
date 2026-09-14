import { readdir, readFile, realpath, stat } from "node:fs/promises";
import { join, relative } from "node:path";
import type { KnowledgeFile, ProjectKnowledge } from "./types.ts";

const MAX_AGENTS_CHARS = 50_000;
const MAX_SKILL_CHARS = 30_000;
const MAX_SKILLS_TOTAL_CHARS = 150_000;
const INSTRUCTION_FILENAMES = ["AGENTS.override.md", "AGENTS.md", "CLAUDE.md"];

export async function loadProjectKnowledge(projectRoot: string, agentDir: string): Promise<ProjectKnowledge> {
	const agentsPath = join(projectRoot, "AGENTS.md");
	const agentsContent = await readOptionalFile(agentsPath, MAX_AGENTS_CHARS);
	const referenceInstructions = await loadReferenceInstructions(projectRoot, agentDir, agentsContent.length > 0);
	const skills = await loadSkills(projectRoot, agentDir);

	return {
		agentsPath: "AGENTS.md",
		agentsContent,
		referenceInstructions,
		skills,
	};
}

async function loadReferenceInstructions(
	projectRoot: string,
	agentDir: string,
	projectAgentsExists: boolean,
): Promise<KnowledgeFile[]> {
	const files: KnowledgeFile[] = [];
	const globalInstruction = await findInstructionFile(agentDir);
	if (globalInstruction) {
		files.push({
			path: `~/.pi/agent/${globalInstruction.name}`,
			scope: "global",
			content: globalInstruction.content,
		});
	}

	if (!projectAgentsExists) {
		const projectInstruction = await findInstructionFile(projectRoot);
		if (projectInstruction) {
			files.push({ path: projectInstruction.name, scope: "project", content: projectInstruction.content });
		}
	}
	return files;
}

async function findInstructionFile(directory: string): Promise<{ name: string; content: string } | undefined> {
	for (const name of INSTRUCTION_FILENAMES) {
		const content = await readOptionalFile(join(directory, name), MAX_AGENTS_CHARS);
		if (content) return { name, content };
	}
	return undefined;
}

async function loadSkills(projectRoot: string, agentDir: string): Promise<KnowledgeFile[]> {
	const sources = [
		{ root: join(agentDir, "skills"), scope: "global" as const, prefix: "~/.pi/agent/skills" },
		{ root: join(projectRoot, ".pi", "skills"), scope: "project" as const, prefix: ".pi/skills" },
		{ root: join(projectRoot, ".agents", "skills"), scope: "project" as const, prefix: ".agents/skills" },
	];
	const skills: KnowledgeFile[] = [];
	let remainingChars = MAX_SKILLS_TOTAL_CHARS;

	for (const source of sources) {
		for (const skillPath of await findSkillFiles(source.root)) {
			if (remainingChars <= 0) return skills;
			const content = await readOptionalFile(skillPath, Math.min(MAX_SKILL_CHARS, remainingChars));
			remainingChars -= content.length;
			skills.push({
				path: join(source.prefix, relative(source.root, skillPath)),
				scope: source.scope,
				content,
			});
		}
	}
	return skills;
}

async function findSkillFiles(directory: string, visited = new Set<string>()): Promise<string[]> {
	let canonicalDirectory: string;
	let entries;
	try {
		canonicalDirectory = await realpath(directory);
		if (visited.has(canonicalDirectory)) return [];
		visited.add(canonicalDirectory);
		entries = await readdir(directory, { withFileTypes: true });
	} catch (error) {
		if (isMissingFileError(error)) return [];
		throw error;
	}

	const paths: string[] = [];
	for (const entry of entries.sort((left, right) => left.name.localeCompare(right.name))) {
		const path = join(directory, entry.name);
		if (entry.isDirectory() || (entry.isSymbolicLink() && (await isDirectory(path)))) {
			paths.push(...(await findSkillFiles(path, visited)));
		}
		if (entry.isFile() && entry.name === "SKILL.md") paths.push(path);
	}
	return paths;
}

async function isDirectory(path: string): Promise<boolean> {
	try {
		return (await stat(path)).isDirectory();
	} catch (error) {
		if (isMissingFileError(error)) return false;
		throw error;
	}
}

async function readOptionalFile(path: string, maxChars: number): Promise<string> {
	try {
		const content = await readFile(path, "utf8");
		if (content.length <= maxChars) return content;
		return `${content.slice(0, maxChars)}\n[truncated]`;
	} catch (error) {
		if (isMissingFileError(error)) return "";
		throw error;
	}
}

function isMissingFileError(error: unknown): boolean {
	return error instanceof Error && "code" in error && error.code === "ENOENT";
}
