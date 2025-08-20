import js from "@eslint/js";
import tsParser from "@typescript-eslint/parser";
import tsPlugin from "@typescript-eslint/eslint-plugin";
import reactPlugin from "eslint-plugin-react";
import globals from "globals";

export default [
  js.configs.recommended,
  {
    files: ["src/**/*.{ts,tsx}"],
    languageOptions: {
      parser: tsParser,
      parserOptions: { ecmaVersion: "latest", sourceType: "module" },
      globals: { ...globals.browser, ...globals.node }
    },
    plugins: { "@typescript-eslint": tsPlugin, react: reactPlugin },
    settings: { react: { version: "detect" } },
    rules: {
      ...tsPlugin.configs.recommended.rules,
      "react/prop-types": "off",
      "@typescript-eslint/no-explicit-any": "off"
    }
  }
];
