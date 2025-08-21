import { defineConfig, devices } from "@playwright/test";

const useSystemChrome = !!process.env.CHROMIUM_EXECUTABLE;

export default defineConfig({
  testDir: "e2e",
  timeout: 60_000,
  use: {
    baseURL: "http://localhost:5173",
    trace: "on-first-retry",
    headless: true,
    launchOptions: useSystemChrome
      ? { executablePath: process.env.CHROMIUM_EXECUTABLE }
      : {},
  },
  webServer: {
    command: "npm run preview",
    port: 5173,
    reuseExistingServer: true,
    timeout: 60_000,
  },
  projects: [
    { name: "chromium", use: { ...devices["Desktop Chrome"] } },
  ],
});
