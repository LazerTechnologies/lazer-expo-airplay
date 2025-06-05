import { NativeModule, requireNativeModule } from 'expo';

import { Platform } from 'react-native';
import { AirplayRoute, LazerExpoAirplayModuleEvents, LazerExpoAirplayModuleResult } from './LazerExpoAirplay.types';

declare class LazerExpoAirplayModule extends NativeModule<LazerExpoAirplayModuleEvents> {
  getCurrentRoute(): LazerExpoAirplayModuleResult<AirplayRoute | null>;
  show(): LazerExpoAirplayModuleResult<void>;
}

const MockAirplayModule: LazerExpoAirplayModule = {
  name: 'LazerExpoAirplay',
  getCurrentRoute: async () => {
    return {
      success: false,
      error: `Not implemented on ${Platform.OS}`,
    };
  },
  show: async () => {
    return {
      success: false,
      error: `Not implemented on ${Platform.OS}`,
    };
  },
  addListener: () => {
    return {
      remove: () => {
        // noop
      }
    }
  },
  removeListener: (): void => {
    // noop
  },
  removeAllListeners: (): void => {
    // noop
  },
  emit: () => {
    // noop
  },
  listenerCount: () => {
    return 0;
  }
}

export default (Platform.OS === 'ios' ? requireNativeModule<LazerExpoAirplayModule>('LazerExpoAirplay') : MockAirplayModule);
