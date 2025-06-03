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
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEventListener(LazerExpoAirplay, 'onRouteChange', (event: OnRouteChangeEventPayload) => {
    setCurrentRoute(event.current_route);
    setError(null);
  });

  const refresh = async () => {
    setIsLoading(true);
    setError(null);
    
    try {
      const result = await LazerExpoAirplay.getCurrentRoute();
      if (result.success) {
        setCurrentRoute(result.data);
      } else {
        setCurrentRoute(null);
        setError(result.error);
      }
    } catch (err) {
      setCurrentRoute(null);
      setError(err instanceof Error ? err.message : 'Unknown error occurred');
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    refresh();
  }, []);

  return {
    currentRoute,
    isLoading,
    error,
    refresh,
  };
}; 