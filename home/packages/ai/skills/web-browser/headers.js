const allowed = new Set((process.env.BROWSER_LOG_HEADERS || "").toLowerCase().split(",").map(name => name.trim()).filter(Boolean));

// Header capture is opt-in: authentication material otherwise stays off disk.
export function captureHeaders(headers = {}) {
  return Object.fromEntries(Object.entries(headers).filter(([name]) => allowed.has(name.toLowerCase())));
}
