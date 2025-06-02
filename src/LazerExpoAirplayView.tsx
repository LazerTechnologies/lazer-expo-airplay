import { requireNativeView } from 'expo';
import * as React from 'react';

import { LazerExpoAirplayViewProps } from './LazerExpoAirplay.types';

const NativeView: React.ComponentType<LazerExpoAirplayViewProps> =
  requireNativeView('LazerExpoAirplay');

export default function LazerExpoAirplayView(props: LazerExpoAirplayViewProps) {
  return <NativeView {...props} />;
}
