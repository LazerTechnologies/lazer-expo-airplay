# @lazer/expo-airplay

Expo module for controlling AirPlay and audio output devices on iOS.

> ⚠️ **Platform Support**: This package is iOS-only and will not work on
> Android, web, or any other platform.

## Features

- Get current AirPlay device connection status
- List all available audio output devices
- **Detect AirPlay device availability** - Know when AirPlay devices are
  discoverable
- Show native AirPlay device picker
- Listen to route change events (general and AirPlay-specific)
- Programmatically trigger device selection via picker

## API Documentation

### Functions

#### `getCurrentAirplayDevice()`

Returns the currently connected AirPlay device, or null if no AirPlay device is
connected.

```typescript
const result = await LazerExpoAirplay.getCurrentAirplayDevice();
if (result.success) {
  console.log("Current AirPlay device:", result.data);
  // result.data: { route_id: string, route_name: string, port_type: string, is_airplay: true }
} else {
  console.log("No AirPlay device connected:", result.error);
}
```

#### `getOutputs()`

Returns all available audio output devices.

```typescript
const result = await LazerExpoAirplay.getOutputs();
if (result.success) {
  console.log("Available outputs:", result.data);
  // result.data: Array<{ route_id: string, route_name: string, port_type: string, is_airplay: boolean }>
}
```

#### `getAvailableAirplayDevices()`

Detects if AirPlay devices are available for connection. Due to iOS privacy
restrictions, this doesn't return specific device names but provides
availability status.

```typescript
const result = await LazerExpoAirplay.getAvailableAirplayDevices();
if (result.success) {
  console.log("AirPlay availability:", result.data);
  // result.data: {
  //   route_detection_enabled: boolean,
  //   multiple_routes_detected: boolean,
  //   airplay_available: boolean,
  //   current_category: string,
  //   supports_airplay_category: boolean,
  //   current_route_supports_airplay: boolean,
  //   category_options: number
  // }
}
```

#### `show()`

Shows the native iOS AirPlay device picker.

```typescript
await LazerExpoAirplay.show();
```

#### `selectOutputDevice(routeId: string)`

Triggers the native device picker for the user to select an output device. Due
to iOS limitations, this cannot programmatically select a specific device but
will open the picker.

```typescript
const result = await LazerExpoAirplay.selectOutputDevice("device-route-id");
if (result.success) {
  console.log("Device picker triggered");
}
```

### Events

#### `onRouteChange`

Fired when any audio route changes occur.

```typescript
import { useEvent } from "expo";

const onRouteChange = useEvent(LazerExpoAirplay, "onRouteChange");

useEffect(() => {
  if (onRouteChange) {
    console.log("Route changed:", onRouteChange);
    // { current_route: AirplayRoute, state: ConnectionState }
  }
}, [onRouteChange]);
```

#### `onAirplayChange`

Fired specifically when AirPlay device connections change.

```typescript
import { useEvent } from "expo";

const onAirplayChange = useEvent(LazerExpoAirplay, "onAirplayChange");

useEffect(() => {
  if (onAirplayChange) {
    console.log("AirPlay device changed:", onAirplayChange);
    // { current_route: AirplayRoute, state: ConnectionState }
  }
}, [onAirplayChange]);
```

### Types

```typescript
export type AirplayRoute = {
  route_id: string;
  route_name: string;
  port_type: string;
  is_airplay: boolean;
};

export type AirplayAvailabilityInfo = {
  route_detection_enabled: boolean; // Is route detection active
  multiple_routes_detected: boolean; // Are multiple routes detected
  current_route_supports_airplay: boolean; // Does current route support AirPlay
  airplay_available: boolean; // Are AirPlay devices likely available
  current_category: string; // Current audio session category
  supports_airplay_category: boolean; // Does category support AirPlay
  category_options: number; // Audio session category options
};

export type ConnectionState =
  | "device_available"
  | "device_unavailable"
  | "category_changed"
  | "override"
  | "wake_from_sleep"
  | "no_suitable_route"
  | "configuration_changed"
  | "unknown";
```

## Installation

### Installation in managed Expo projects

For [managed](https://docs.expo.dev/archive/managed-vs-bare/) Expo projects,
please follow the installation instructions in the
[API documentation for the latest stable release](#api-documentation). If you
follow the link and there is no documentation available then this library is not
yet usable within managed projects &mdash; it is likely to be included in an
upcoming Expo SDK release.

> Note: This package is iOS-only and will not work on Android or web platforms.

### Installation in bare React Native projects

For bare React Native projects, you must ensure that you have
[installed and configured the `expo` package](https://docs.expo.dev/bare/installing-expo-modules/)
before continuing.

#### Add the package to your npm dependencies

```
npm install @lazer/expo-airplay
```

#### Configure for iOS

Run `npx pod-install` after installing the npm package.

> Note: This package is iOS-only and does not require any Android configuration.

## Usage Example

```typescript
import React, { useEffect, useState } from "react";
import { Button, Text, View } from "react-native";
import { useEvent } from "expo";
import LazerExpoAirplay, {
  AirplayAvailabilityInfo,
  AirplayRoute,
} from "@lazer/expo-airplay";

export default function AirPlayExample() {
  const [currentDevice, setCurrentDevice] = useState<AirplayRoute | null>(null);
  const [outputs, setOutputs] = useState<AirplayRoute[]>([]);
  const [availability, setAvailability] = useState<
    AirplayAvailabilityInfo | null
  >(null);

  const onAirplayChange = useEvent(LazerExpoAirplay, "onAirplayChange");

  useEffect(() => {
    loadDevices();
  }, []);

  useEffect(() => {
    if (onAirplayChange) {
      console.log("AirPlay device changed:", onAirplayChange);
      loadDevices(); // Refresh on change
    }
  }, [onAirplayChange]);

  const loadDevices = async () => {
    // Get current AirPlay device
    const currentResult = await LazerExpoAirplay.getCurrentAirplayDevice();
    if (currentResult.success) {
      setCurrentDevice(currentResult.data);
    }

    // Get all outputs
    const outputsResult = await LazerExpoAirplay.getOutputs();
    if (outputsResult.success) {
      setOutputs(outputsResult.data);
    }

    // Check AirPlay availability
    const availabilityResult = await LazerExpoAirplay
      .getAvailableAirplayDevices();
    if (availabilityResult.success) {
      setAvailability(availabilityResult.data);
    }
  };

  const showPicker = async () => {
    await LazerExpoAirplay.show();
  };

  return (
    <View style={{ padding: 20 }}>
      <Text>Current AirPlay Device:</Text>
      <Text>{currentDevice ? currentDevice.route_name : "None connected"}</Text>

      <Text>AirPlay Available:</Text>
      <Text>{availability?.airplay_available ? "Yes" : "No"}</Text>

      <Text>Available Outputs:</Text>
      {outputs.map((output) => (
        <Text key={output.route_id}>
          {output.route_name} {output.is_airplay ? "(AirPlay)" : ""}
        </Text>
      ))}

      <Button title="Show AirPlay Picker" onPress={showPicker} />
    </View>
  );
}
```

## Contributing

Contributions are very welcome! Please refer to guidelines described in the
[contributing guide](https://github.com/expo/expo#contributing).

## Development

To start the development environment:

1. Make sure you have [Bun](https://bun.sh) installed
2. Run the development script:

```bash
bun run dev
```

This will:

- Build the module
- Start the iOS development environment

For Android development, you can run:

```bash
bun run dev:android
```
