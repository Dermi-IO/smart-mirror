import { z } from 'zod';

export const MirrorConfigSchema = z.object({
    name: z.string(),
    rotateInterfaceDegrees: z.number().optional(),
    showGrid: z.boolean().default(false),
    tilesX: z.number(),
    tilesY: z.number(),
    mirrorPadding: z.number().optional(),
});

export type MirrorConfig = z.infer<typeof MirrorConfigSchema>;