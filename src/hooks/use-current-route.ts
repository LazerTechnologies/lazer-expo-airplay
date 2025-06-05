import { useEventListener } from 'expo';
import { useEffect, useState } from 'react';
import { AirplayRoute, OnRouteChangeEventPayload } from '../LazerExpoAirplay.types';
import LazerExpoAirplay from '../LazerExpoAirplayModule';

interface UseCurrentRouteResult {
  currentRoute: AirplayRoute | null;
  isLoading: boolean;
  error: string | null;
  refresh: () => Promise<void>;
}

export const useCurrentRoute = (): UseCurrentRouteResult => {
  const [currentRoute, setCurrentRoute] = useState<AirplayRoute | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEventListener(LazerExpoAirplay, 'onRouteChange', (event: OnRouteChangeEventPayload) => {
    setCurrentRoute(event.current_route);
    setError(null);
  });

  const refresh = async () => {
    await LazerExpoAirplay.getCurrentRoute().then((result) => {
      if (result.success) {
        setCurrentRoute(result.data);
      } else {
        setCurrentRoute(null);
        setError(result.error);
      }
    });
  };

  useEffect(() => {
    LazerExpoAirplay.getCurrentRoute().then((result) => {
      if (result.success) {
        setCurrentRoute(result.data);
      } else {
        setCurrentRoute(null);
        setError(result.error);
      }
    });
  }, []);

  const isLoading = currentRoute == null && error == null;

  return {
    currentRoute,
    isLoading,
    error,
    refresh,
  };
}; 