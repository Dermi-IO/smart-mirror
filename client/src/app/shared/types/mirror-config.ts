import { z } from 'zod';

export const MirrorConfigSchema = z.object({
    name: z.string(),
    rotateInterfaceDegrees: z.number().optional(),
    tilesX: z.number(),
    tilesY: z.number(),
});

export type MirrorConfig = z.infer<typeof MirrorConfigSchema>;