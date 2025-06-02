import { registerWebModule, NativeModule } from 'expo';

import { LazerExpoAirplayModuleEvents } from './LazerExpoAirplay.types';

class LazerExpoAirplayModule extends NativeModule<LazerExpoAirplayModuleEvents> {
  PI = Math.PI;
  async setValueAsync(value: string): Promise<void> {
    this.emit('onChange', { value });
  }
  hello() {
    return 'Hello world! 👋';
  }
}

export default registerWebModule(LazerExpoAirplayModule, 'LazerExpoAirplayModule');
