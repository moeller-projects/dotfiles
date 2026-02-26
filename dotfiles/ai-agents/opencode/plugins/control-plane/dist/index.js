import { tool } from "@opencode-ai/plugin";
import { analysisCacheLookup, analysisCacheStore, analysisCacheInvalidate, analysisCacheStats } from "./cache.js";
import { validatePatch } from "./patchValidator.js";
export const ControlPlane = async ({ client }) => {
    // Structured logging per docs (prefer this over console.log)
    await client.app.log({
        body: {
            service: "control-plane",
            level: "info",
            message: "control-plane plugin initialized",
        },
    });
    return {
        /**
         * Optional enforcement hook:
         * Only validates when the executed tool provides a unified diff patch in output.args.patch.
         * (Conservative: if no patch is present, it does nothing.)
         */
        "tool.execute.before": async (input, output) => {
            const toolName = input?.tool;
            if (toolName !== "edit")
                return;
            const patch = output?.args?.patch;
            if (typeof patch !== "string" || patch.length === 0)
                return;
            const max = Number(output?.args?.max_change_percent ?? 30);
            const strict = Boolean(output?.args?.strict ?? true);
            const result = validatePatch(patch, { maxChangePercent: max, strict });
            if (!result.valid) {
                throw new Error(`Mutation contract violated: ${JSON.stringify(result.violations)}`);
            }
        },
        /**
         * Custom tools exposed to OpenCode (appear alongside built-in tools).
         */
        tool: {
            "analysis-cache": tool({
                description: "Deterministic structural artifact cache (lookup/store/invalidate/stats).",
                args: {
                    action: tool.schema.enum(["lookup", "store", "invalidate", "stats"]),
                    namespace: tool.schema.string().optional(),
                    key: tool.schema.string().optional(),
                    key_extra: tool.schema.any().optional(),
                    ttl_sec: tool.schema.number().optional(),
                    max_bytes: tool.schema.number().optional(),
                    artifact: tool.schema.string().optional(),
                    metadata: tool.schema.any().optional(),
                    invalidate_prefix: tool.schema.string().optional(),
                },
                async execute(args, context) {
                    const ctx = { worktree: context.worktree, directory: context.directory };
                    switch (args.action) {
                        case "lookup":
                            return JSON.stringify(await analysisCacheLookup({ namespace: args.namespace, key: args.key, key_extra: args.key_extra }, ctx), null, 2);
                        case "store":
                            return JSON.stringify(await analysisCacheStore({
                                namespace: args.namespace,
                                key: args.key,
                                key_extra: args.key_extra,
                                ttl_sec: args.ttl_sec,
                                max_bytes: args.max_bytes,
                                artifact: args.artifact,
                                metadata: args.metadata,
                            }, ctx), null, 2);
                        case "invalidate":
                            return JSON.stringify(await analysisCacheInvalidate({ namespace: args.namespace, invalidate_prefix: args.invalidate_prefix }, ctx), null, 2);
                        case "stats":
                            return JSON.stringify(await analysisCacheStats({ namespace: args.namespace }, ctx), null, 2);
                    }
                },
            }),
            "patch-validator": tool({
                description: "Validates unified diff against strict mutation contract (threshold, rewrite detection, whitespace/import drift).",
                args: {
                    patch: tool.schema.string(),
                    max_change_percent: tool.schema.number().optional(),
                    strict: tool.schema.boolean().optional(),
                },
                async execute(args) {
                    const result = validatePatch(args.patch, {
                        maxChangePercent: args.max_change_percent ?? 30,
                        strict: args.strict ?? true,
                    });
                    return JSON.stringify(result, null, 2);
                },
            }),
        },
    };
};
