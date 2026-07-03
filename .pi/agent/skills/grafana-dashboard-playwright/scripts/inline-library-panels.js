async page => {
  const [dashboardUid, panelIdsCsv, message = 'Inline library panels'] = process.argv.slice(2);
  if (!dashboardUid || !panelIdsCsv) {
    throw new Error('Usage: inline-library-panels.js <dashboardUid> <panelIdsCsv> [message]');
  }
  const panelIds = panelIdsCsv.split(',').map(value => Number(value.trim())).filter(Number.isFinite);

  return await page.evaluate(async ({ dashboardUid, panelIds, message }) => {
    const clone = value => JSON.parse(JSON.stringify(value));
    const allPanels = panels => panels.flatMap(panel => panel.panels ? [panel, ...allPanels(panel.panels)] : [panel]);

    const dashboardResponse = await fetch(`/api/dashboards/uid/${dashboardUid}`);
    if (!dashboardResponse.ok) throw new Error(`Dashboard fetch failed: ${dashboardResponse.status}`);
    const dashboardPayload = await dashboardResponse.json();
    const dashboard = dashboardPayload.dashboard;
    const panelsById = new Map(allPanels(dashboard.panels).map(panel => [panel.id, panel]));

    const results = [];
    for (const id of panelIds) {
      const panel = panelsById.get(id);
      if (!panel) throw new Error(`Panel ${id} not found`);
      if (!panel.libraryPanel?.uid) {
        results.push({ id, status: 'already-local' });
        continue;
      }

      const libraryResponse = await fetch(`/api/library-elements/${panel.libraryPanel.uid}`);
      if (!libraryResponse.ok) throw new Error(`Library fetch failed for panel ${id}: ${libraryResponse.status}`);
      const libraryPayload = await libraryResponse.json();
      const libraryModel = clone(libraryPayload.result.model);

      const inlinedPanel = {
        ...libraryModel,
        id: panel.id,
        gridPos: panel.gridPos,
        title: panel.title || libraryModel.title,
      };
      delete inlinedPanel.libraryPanel;

      Object.keys(panel).forEach(key => delete panel[key]);
      Object.assign(panel, inlinedPanel);
      results.push({ id, status: 'inlined', hasTargets: !!inlinedPanel.targets?.length });
    }

    const saveResponse = await fetch('/api/dashboards/db', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        dashboard,
        folderUid: dashboardPayload.meta.folderUid,
        message,
        overwrite: true,
      }),
    });
    const savePayload = await saveResponse.json().catch(() => ({}));
    if (!saveResponse.ok) {
      throw new Error(`Dashboard save failed: ${saveResponse.status} ${JSON.stringify(savePayload)}`);
    }

    const verifyPayload = await (await fetch(`/api/dashboards/uid/${dashboardUid}`)).json();
    const verifiedPanels = allPanels(verifyPayload.dashboard.panels);
    const verified = panelIds.map(id => {
      const panel = verifiedPanels.find(item => item.id === id);
      return { id, local: !!panel && !panel.libraryPanel, hasTargets: !!panel?.targets?.length };
    });

    return JSON.stringify({ saved: savePayload, results, verified }, null, 2);
  }, { dashboardUid, panelIds, message });
}
