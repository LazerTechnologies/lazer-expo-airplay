import { NativeModule, requireNativeModule } from 'expo';

import { AirplayRoute, LazerExpoAirplayModuleEvents, LazerExpoAirplayModuleResult } from './LazerExpoAirplay.types';

declare class LazerExpoAirplayModule extends NativeModule<LazerExpoAirplayModuleEvents> {
  getCurrentRoute(): LazerExpoAirplayModuleResult<AirplayRoute | null>;
  show(): LazerExpoAirplayModuleResult<void>;
}

// This call loads the native module object from the JSI.
export default requireNativeModule<LazerExpoAirplayModule>('LazerExpoAirplay');
