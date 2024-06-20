import { z } from 'zod';

export const TileConfigSchema = z.object({
    cols: z.object({
        min: z.number(),
        max: z.number().optional()
    }),
    rows: z.object({
        min: z.number(),
        max: z.number().optional()
    })
});

export type TileConfig = z.infer<typeof TileConfigSchema>;

export interface Tile {
    cols: number;
    rows: number;
}