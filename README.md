# @lazer/expo-airplay

Expo module for controlling AirPlay and audio output devices on iOS.

> ⚠️ **Platform Support**: This package is iOS-only and will not work on
> Android, web, or any other platform.

## Features

- Get current audio route information (including AirPlay detection)
- Show native AirPlay device picker
- Listen to audio route change events

## API Documentation

### Functions

#### `getCurrentRoute()`

Returns information about the currently active audio route, including whether
it's an AirPlay device.

```typescript
const result = await LazerExpoAirplay.getCurrentRoute();
if (result.success) {
  console.log("Current audio route:", result.data);
  // result.data: { route_id: string, route_name: string, port_type: string, is_airplay: boolean }
} else {
  console.log("No audio route available:", result.error);
}
```

#### `show()`

Shows the native iOS AirPlay device picker.

```typescript
const result = await LazerExpoAirplay.show();
if (result.success) {
  console.log("AirPlay picker shown");
}
```

### Events

#### `onRouteChange`

Fired when audio route changes occur (switching between speakers, headphones,
Bluetooth, AirPlay, etc.).

```typescript
import { useEvent } from "expo";

const onRouteChange = useEvent(LazerExpoAirplay, "onRouteChange");

useEffect(() => {
  if (onRouteChange) {
    console.log("Route changed:", onRouteChange);
    // { current_route: AirplayRoute, state: ConnectionState }

    // Check if it's an AirPlay device
    if (onRouteChange.current_route?.is_airplay) {
      console.log(
        "AirPlay device connected:",
        onRouteChange.current_route.route_name,
      );
    }
  }
}, [onRouteChange]);
```

### Types

```typescript
export type AirplayRoute = {
  route_id: string;
  route_name: string;
  port_type: string;
  is_airplay: boolean;
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
import LazerExpoAirplay, { AirplayRoute } from "@lazer/expo-airplay";

export default function AirPlayExample() {
  const [currentRoute, setCurrentRoute] = useState<AirplayRoute | null>(null);

  const onRouteChange = useEvent(LazerExpoAirplay, "onRouteChange");

  useEffect(() => {
    loadCurrentRoute();
  }, []);

  useEffect(() => {
    if (onRouteChange) {
      console.log("Audio route changed:", onRouteChange);
      setCurrentRoute(onRouteChange.current_route);
    }
  }, [onRouteChange]);

  const loadCurrentRoute = async () => {
    const result = await LazerExpoAirplay.getCurrentRoute();
    if (result.success) {
      setCurrentRoute(result.data);
    } else {
      setCurrentRoute(null);
    }
  };

  const showAirPlayPicker = async () => {
    await LazerExpoAirplay.show();
  };

  return (
    <View style={{ padding: 20 }}>
      <Text>Current Audio Route:</Text>
      <Text>
        {currentRoute ? currentRoute.route_name : "No route available"}
      </Text>
      <Text>Type: {currentRoute?.port_type}</Text>
      <Text>AirPlay: {currentRoute?.is_airplay ? "Yes" : "No"}</Text>

      <Button title="Show AirPlay Picker" onPress={showAirPlayPicker} />
      <Button title="Refresh Route" onPress={loadCurrentRoute} />
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
