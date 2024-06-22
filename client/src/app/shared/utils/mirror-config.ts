import mirrorConfig from '../../mirror_config.json';
import { MirrorConfigSchema, type MirrorConfig } from '../types/mirror-config';

const validateMirrorConfig = (config: object) => {
    return MirrorConfigSchema.safeParse(config).success;
}

export const getMirrorConfig = () => {
    if (!validateMirrorConfig(mirrorConfig)) {
        throw new Error('Invalid mirror config');
    }

    return mirrorConfig as MirrorConfig;
};