/**
 * Local development/CI stub for @opencode-ai/plugin.
 *
 * In a real OpenCode session, this module is provided by the OpenCode host.
 * This stub is used only during local builds and CI validation.
 */

/**
 * Registers a tool definition.
 * @param {object} config - Tool configuration with description, args, and execute function.
 * @returns {object} The tool definition as-is.
 */
export function tool(config) {
  return config;
}
