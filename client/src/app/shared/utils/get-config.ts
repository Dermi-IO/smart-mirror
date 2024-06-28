import mirrorConfig from '../../default_configs/mirror_config';
import { MirrorConfigSchema, type MirrorConfig } from '../types/mirror-config';

const validateMirrorConfig = (config: object): boolean => {
    return MirrorConfigSchema.safeParse(config).success;
}

export const getMirrorConfig = (): MirrorConfig => {
    if (!validateMirrorConfig(mirrorConfig)) {
        throw new Error('Invalid mirror config');
    }

    return mirrorConfig as MirrorConfig;
};