#!/usr/bin/env node
import { connect } from "./cdp.js";
import { applyActiveEmulation } from "./emulation-state.js";
import { setTimeout as sleep } from "node:timers/promises";

const [action, selector, value] = process.argv.slice(2);
let cdp;
const timeout = setTimeout(() => {
  console.error("Browser interaction timed out (30s)");
  process.exit(1);
}, 30000);
try {
  if (!["click", "fill"].includes(action) || !selector || (action === "fill" && value === undefined)) {
    throw new Error("Usage: click.js <css-selector> | fill.js <css-selector> <value>");
  }
  cdp = await connect();
  const page = (await cdp.getPages()).at(-1);
  if (!page) throw new Error("No active tab found");
  const session = await cdp.attachToPage(page.targetId);
  await applyActiveEmulation(cdp, session);
  let previous;
  let point;
  const deadline = Date.now() + 25000;
  while (Date.now() < deadline) {
    point = await cdp.evaluate(session, `(() => {
      const matches = document.querySelectorAll(${JSON.stringify(selector)});
      if (matches.length > 1) throw new Error('Selector matches multiple elements');
      const el = matches[0];
      if (!el || el.matches(':disabled') || el.closest('[inert]')) return null;
      if (${JSON.stringify(action)} === 'fill' &&
          (!(el instanceof HTMLInputElement || el instanceof HTMLTextAreaElement) || el.readOnly)) {
        throw new Error('Fill requires an editable input or textarea');
      }
      if (${JSON.stringify(action)} === 'fill' && el instanceof HTMLInputElement &&
          !['text', 'search', 'email', 'url', 'tel', 'password', 'number'].includes(el.type)) {
        throw new Error('Unsupported input type: ' + el.type);
      }
      el.scrollIntoView({block: 'center', inline: 'center'});
      const r = el.getBoundingClientRect();
      const style = getComputedStyle(el);
      if (!r.width || !r.height || style.visibility !== 'visible' || style.display === 'none') return null;
      const x = (Math.max(0, r.left) + Math.min(innerWidth, r.right)) / 2;
      const y = (Math.max(0, r.top) + Math.min(innerHeight, r.bottom)) / 2;
      const hit = document.elementFromPoint(x, y);
      if (!hit || !(hit === el || el.contains(hit))) return null;
      return {x, y};
    })()`);
    if (point && previous && Math.abs(point.x - previous.x) < 0.5 && Math.abs(point.y - previous.y) < 0.5) break;
    previous = point;
    point = null;
    await sleep(100);
  }
  if (!point) throw new Error("Element did not become visible, stable and unobstructed");
  await cdp.send("Input.dispatchMouseEvent", { type: "mouseMoved", ...point }, session);
  await cdp.send("Input.dispatchMouseEvent", { type: "mousePressed", button: "left", clickCount: 1, ...point }, session);
  await cdp.send("Input.dispatchMouseEvent", { type: "mouseReleased", button: "left", clickCount: 1, ...point }, session);
  if (action === "fill") {
    await cdp.evaluate(session, `(() => {
      const el = document.querySelector(${JSON.stringify(selector)});
      if (!el || document.activeElement !== el) throw new Error('Input did not receive focus');
    })()`);
    await cdp.send("Input.dispatchKeyEvent", { type: "keyDown", key: "a", code: "KeyA", commands: ["selectAll"] }, session);
    await cdp.send("Input.dispatchKeyEvent", { type: "keyUp", key: "a", code: "KeyA" }, session);
    if (value) {
      await cdp.send("Input.insertText", { text: value }, session);
    } else {
      await cdp.send("Input.dispatchKeyEvent", { type: "keyDown", key: "Backspace", code: "Backspace", windowsVirtualKeyCode: 8 }, session);
      await cdp.send("Input.dispatchKeyEvent", { type: "keyUp", key: "Backspace", code: "Backspace", windowsVirtualKeyCode: 8 }, session);
    }
    await cdp.evaluate(session, `(() => {
      const el = document.querySelector(${JSON.stringify(selector)});
      if (!el || el.value !== ${JSON.stringify(value)}) throw new Error('Input value did not match after filling');
      el.blur();
    })()`);
  }
  console.log(`${action === "fill" ? "Filled" : "Clicked"} ${selector}`);
} catch (error) {
  console.error(error.message);
  process.exitCode = 1;
} finally {
  clearTimeout(timeout);
  cdp?.close();
}
