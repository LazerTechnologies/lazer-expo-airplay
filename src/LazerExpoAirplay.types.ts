export type AirplayRoute = {
  route_id: string;
  route_name: string;
  port_type: string;
  is_airplay: boolean;
};

export type ConnectionState =
  | 'device_available'
  | 'device_unavailable'
  | 'category_changed'
  | 'override'
  | 'wake_from_sleep'
  | 'no_suitable_route'
  | 'configuration_changed'
  | 'unknown';

export type LazerExpoAirplayModuleResult<T> = Promise<{
  success: true
  data: T
} | {
  success: false
  error: string
}>

export type OnRouteChangeEventPayload = {
  current_route: AirplayRoute;
  previous_route: AirplayRoute;
  state: ConnectionState;
};

export type LazerExpoAirplayModuleEvents = {
  onRouteChange: (payload: OnRouteChangeEventPayload) => void;
};