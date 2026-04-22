import type { z } from "zod";

export interface ToolContext {
  readonly worktree?: string | undefined;
  readonly directory?: string | undefined;
  readonly [key: string]: unknown;
}

export type ToolArgs = Record<string, z.ZodTypeAny>;

export interface ToolConfig<A extends ToolArgs, R> {
  description: string;
  args: A;
  execute(args: z.infer<z.ZodObject<A>>, context: ToolContext): Promise<R>;
}

export function tool<A extends ToolArgs, R>(config: ToolConfig<A, R>): ToolConfig<A, R>;
