#!/usr/bin/env node
import net from "node:net";
import { createHash } from "node:crypto";
import { spawn } from "node:child_process";
import { setTimeout as sleep } from "node:timers/promises";

// A listening socket is an OS-owned lock: crashes cannot leave stale lock files.
const endpoint = `${process.env.BROWSER_DEBUG_HOST || "localhost"}:${process.env.BROWSER_DEBUG_PORT || 9222}`;
const port = Number(process.env.BROWSER_ACTION_LOCK_PORT ||
  (20000 + createHash("sha256").update(endpoint).digest().readUInt16BE(0) % 40000));
let child;
let cancelled = false;
for (const signal of ["SIGINT", "SIGTERM", "SIGHUP"]) {
  process.on(signal, () => {
    cancelled = true;
    if (child) child.kill(signal);
    else process.exit(1);
  });
}
const deadline = Date.now() + 120000;
let lock;
try {
  while (!lock) {
    const server = net.createServer(socket => socket.destroy());
    try {
      await new Promise((resolve, reject) => {
        server.once("error", reject);
        server.listen({ host: "127.0.0.1", port, exclusive: true }, resolve);
      });
      lock = server;
    } catch (error) {
      server.close();
      if (error.code !== "EADDRINUSE") throw error;
      if (Date.now() >= deadline) throw new Error("Timed out waiting for browser action lock");
      await sleep(50);
    }
  }
  child = spawn(process.execPath, process.argv.slice(2), { stdio: "inherit" });
  const code = await new Promise((resolve, reject) => {
    child.once("error", reject);
    child.once("exit", code => resolve(code ?? 1));
  });
  process.exitCode = cancelled ? 1 : code;
} catch (error) {
  console.error(error.message);
  process.exitCode = 1;
} finally {
  lock?.close();
}
