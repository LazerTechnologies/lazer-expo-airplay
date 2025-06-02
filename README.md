# @lazer/expo-airplay

Expo module for controller airpaly streaming

# API documentation

- [Documentation for the latest stable release](https://docs.expo.dev/versions/latest/sdk/google.com#readme/)
- [Documentation for the main branch](https://docs.expo.dev/versions/unversioned/sdk/google.com#readme/)

# Installation in managed Expo projects

For [managed](https://docs.expo.dev/archive/managed-vs-bare/) Expo projects,
please follow the installation instructions in the
[API documentation for the latest stable release](#api-documentation). If you
follow the link and there is no documentation available then this library is not
yet usable within managed projects &mdash; it is likely to be included in an
upcoming Expo SDK release.

# Installation in bare React Native projects

For bare React Native projects, you must ensure that you have
[installed and configured the `expo` package](https://docs.expo.dev/bare/installing-expo-modules/)
before continuing.

### Add the package to your npm dependencies

```
npm install @lazer/expo-airplay
```

### Configure for Android

### Configure for iOS

Run `npx pod-install` after installing the npm package.

# Contributing

Contributions are very welcome! Please refer to guidelines described in the
[contributing guide](https://github.com/expo/expo#contributing).

# Development

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
