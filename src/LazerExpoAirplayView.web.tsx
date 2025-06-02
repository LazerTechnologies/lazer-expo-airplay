import * as React from 'react';

import { LazerExpoAirplayViewProps } from './LazerExpoAirplay.types';

export default function LazerExpoAirplayView(props: LazerExpoAirplayViewProps) {
  return (
    <div>
      <iframe
        style={{ flex: 1 }}
        src={props.url}
        onLoad={() => props.onLoad({ nativeEvent: { url: props.url } })}
      />
    </div>
  );
}
