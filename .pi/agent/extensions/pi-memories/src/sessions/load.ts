import { stat } from "node:fs/promises";
import { buildContextEntries, SessionManager, type SessionEntry } from "@earendil-works/pi-coding-agent";
import type { SessionTranscript } from "../reflection/types.ts";
import { selectRecentProjectSessions } from "./selection.ts";
import { MAX_SESSION_CHARS, normalizeSessionEntries } from "./transcript.ts";

export const DEFAULT_SESSION_LIMIT = 20;

interface SessionReader {
	getSessionFile(): string | undefined;
	buildContextEntries(): SessionEntry[];
}

export async function loadRecentProjectTranscripts(
	projectRoot: string,
	currentSession: SessionReader,
	limit = DEFAULT_SESSION_LIMIT,
): Promise<SessionTranscript[]> {
	const sessions = selectRecentProjectSessions(await SessionManager.listAll(), projectRoot, limit);
	const currentSessionFile = currentSession.getSessionFile();
	const transcripts: SessionTranscript[] = [];

	for (const session of sessions) {
		const manager = currentSessionFile === session.path ? currentSession : SessionManager.open(session.path);
		const text = normalizeSessionEntries(manager.buildContextEntries(), MAX_SESSION_CHARS);
		if (!text.trim()) continue;

		transcripts.push({
			id: session.id,
			path: session.path,
			cwd: session.cwd,
			modified: session.modified,
			text,
		});
	}

	return transcripts;
}

export async function loadSessionTranscript(sessionFile: string, leafId?: string): Promise<SessionTranscript> {
	const manager = SessionManager.open(sessionFile);
	const header = manager.getHeader();
	if (!header) throw new Error(`Session header is missing: ${sessionFile}`);
	const entries = leafId
		? buildContextEntries(manager.getEntries(), leafId)
		: manager.buildContextEntries();
	const text = normalizeSessionEntries(entries, MAX_SESSION_CHARS);
	if (!text.trim()) throw new Error(`Session has no readable transcript: ${sessionFile}`);
	const fileStats = await stat(sessionFile);

	return {
		id: header.id,
		path: sessionFile,
		cwd: header.cwd,
		modified: fileStats.mtime,
		text,
	};
}
