async page => {
  const dashboardUid = process.argv[2];
  if (!dashboardUid) throw new Error('Usage: export-dashboard.js <dashboardUid>');
  return await page.evaluate(async uid => {
    const response = await fetch(`/api/dashboards/uid/${uid}`);
    if (!response.ok) throw new Error(`Dashboard fetch failed: ${response.status}`);
    const payload = await response.json();
    return JSON.stringify(payload.dashboard, null, 2);
  }, dashboardUid);
}
