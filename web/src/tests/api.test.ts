import { describe, it, expect } from "vitest";
import { makeAuthHeader } from "../api";

describe("api helpers", () => {
  it("makeAuthHeader OK", () => {
    expect(makeAuthHeader("abc").Authorization).toBe("Bearer abc");
  });
  it("makeAuthHeader KO (chaine vide)", () => {
    expect(makeAuthHeader("").Authorization).toBe("Bearer ");
  });
});
