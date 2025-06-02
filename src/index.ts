// Reexport the native module. On web, it will be resolved to LazerExpoAirplayModule.web.ts
// and on native platforms to LazerExpoAirplayModule.ts
export { default } from './LazerExpoAirplayModule';
export { default as LazerExpoAirplayView } from './LazerExpoAirplayView';
export * from  './LazerExpoAirplay.types';
