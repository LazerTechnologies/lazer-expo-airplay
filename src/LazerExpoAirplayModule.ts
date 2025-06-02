import { NativeModule, requireNativeModule } from 'expo';

import { LazerExpoAirplayModuleEvents } from './LazerExpoAirplay.types';

declare class LazerExpoAirplayModule extends NativeModule<LazerExpoAirplayModuleEvents> {
  PI: number;
  hello(): string;
  setValueAsync(value: string): Promise<void>;
}

// This call loads the native module object from the JSI.
export default requireNativeModule<LazerExpoAirplayModule>('LazerExpoAirplay');
