import { test, expect } from "@playwright/test";

if (process.env.E2E_SKIP === "1") {
  test.skip(true, "E2E SKIPPED by E2E_SKIP=1");
}

const ADMIN_USER = "admin";
const ADMIN_PASS = process.env.ADMIN_PASSWORD || "admin123"; // autoseed par defaut

test("KO: mauvais login affiche une erreur", async ({ page }) => {
  await page.goto("/");
  await expect(page.getByText("Connexion")).toBeVisible();
  await page.getByLabel("Nom d utilisateur").fill(ADMIN_USER);
  await page.getByLabel("Mot de passe").fill("badpassword");
  await page.getByRole("button", { name: "Se connecter" }).click();
  await expect(page.getByText(/Echec login|Echec \/auth\/token/i)).toBeVisible();
});

test("OK: login admin puis section Admin Users visible", async ({ page }) => {
  await page.goto("/");
  await page.getByLabel("Nom d utilisateur").fill(ADMIN_USER);
  await page.getByLabel("Mot de passe").fill(ADMIN_PASS);
  await page.getByRole("button", { name: "Se connecter" }).click();
  await expect(page.getByText(/Connecte en tant que/i)).toBeVisible();
  await expect(page.getByText(/admin\s*admin/i)).toBeVisible();
  await expect(page.getByText("Admin Users")).toBeVisible();
});
