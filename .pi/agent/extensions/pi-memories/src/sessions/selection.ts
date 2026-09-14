import { isAbsolute, relative, resolve } from "node:path";

export interface SessionCandidate {
	cwd: string;
	modified: Date;
}

export function selectRecentProjectSessions<T extends SessionCandidate>(
	sessions: readonly T[],
	projectRoot: string,
	limit: number,
): T[] {
	return sessions
		.filter((session) => session.cwd.length > 0 && isPathWithin(projectRoot, session.cwd))
		.sort((left, right) => right.modified.getTime() - left.modified.getTime())
		.slice(0, limit);
}

export function isPathWithin(root: string, candidate: string): boolean {
	const pathFromRoot = relative(resolve(root), resolve(candidate));
	return pathFromRoot === "" || (!pathFromRoot.startsWith("..") && !isAbsolute(pathFromRoot));
}
