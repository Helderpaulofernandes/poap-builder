// Runs tests.html in headless Chromium and fails if any test fails. Used by .github/workflows/test-and-publish.yml.
// Locally: serve this folder (e.g. on port 8773), then: node tools/run-tests.mjs http://localhost:8773/tests.html
import { chromium } from "playwright";

const url = process.argv[2] || "http://localhost:8773/tests.html";
const browser = await chromium.launch();
const page = await browser.newPage({ viewport: { width: 1400, height: 1000 } });
page.on("pageerror", e => console.log("page error:", e.message));
await page.goto(url);
await page.waitForFunction(() => / of \d+$/.test(document.getElementById("sum").textContent), null, { timeout: 10 * 60e3, polling: 1000 });
const sum = (await page.textContent("#sum")).trim();
const failed = await page.$$eval("li.bad", ls => ls.map(l => l.innerText.trim()));
console.log(sum);
for (const f of failed) console.log("\n✗ " + f);
await browser.close();
process.exit(failed.length || /failed/.test(sum) ? 1 : 0);
