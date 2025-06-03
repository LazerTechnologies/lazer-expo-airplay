import { useEvent } from 'expo';
import LazerExpoAirplay, { AirplayRoute } from 'lazer-expo-airplay';
import React, { useEffect, useState } from 'react';
import { Alert, Button, SafeAreaView, ScrollView, StyleSheet, Text, TouchableOpacity, View } from 'react-native';
import { useVideoPlayer, VideoView } from 'expo-video';

export default function App() {
  const [currentRoute, setCurrentRoute] = useState<AirplayRoute | null>(null);

  const onRouteChangePayload = useEvent(LazerExpoAirplay, 'onRouteChange');

  useEffect(() => {
    // Initial load of routes
    loadCurrentRoute();
  }, []);

  const loadCurrentRoute = async () => {
    try {
      const current = await LazerExpoAirplay.getCurrentRoute();
      if (current.success) {
        setCurrentRoute(current.data);
      } else {
        setCurrentRoute(null);
        console.log('No audio route available:', current.error);
      }
    } catch (error) {
      console.error('Error loading current route:', error);
      setCurrentRoute(null);
    }
  };

  const player = useVideoPlayer({
    uri: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
  });

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView style={styles.container}>
        <Text style={styles.header}>React Native Airplay API Example</Text>

        <Group name="Current Audio Route">
          <Text style={styles.routeInfo}>
            {currentRoute ? JSON.stringify(currentRoute, null, 2) : 'No audio route available'}
          </Text>
        </Group>

        <Group name="Controls">
          <Button
            title="Show AirPlay Picker"
            onPress={async () => {
              await LazerExpoAirplay.show();
            }}
          />

          <View style={styles.buttonSpacer} />

          <Button
            title="Refresh Current Route"
            onPress={loadCurrentRoute}
          />
        </Group>

        <Group name="Events">
          <Text style={styles.eventText}>Route Change:</Text>
          <Text style={styles.eventData}>{JSON.stringify(onRouteChangePayload, null, 2)}</Text>
        </Group>

        <VideoView style={styles.view} player={player} />
      </ScrollView>
    </SafeAreaView>
  );
}

function Group(props: { name: string; children: React.ReactNode }) {
  return (
    <View style={styles.group}>
      <Text style={styles.groupHeader}>{props.name}</Text>
      {props.children}
    </View>
  );
}

const styles = StyleSheet.create({
  header: {
    fontSize: 30,
    margin: 20,
  },
  groupHeader: {
    fontSize: 20,
    marginBottom: 20,
  },
  group: {
    margin: 20,
    backgroundColor: '#fff',
    borderRadius: 10,
    padding: 20,
  },
  container: {
    flex: 1,
    backgroundColor: '#eee',
  },
  view: {
    flex: 1,
    width: '100%',
    height: 200,
  },
  routeButton: {
    padding: 15,
    backgroundColor: '#f0f0f0',
    borderRadius: 8,
    marginBottom: 10,
  },
  selectedRoute: {
    backgroundColor: '#e3f2fd',
    borderColor: '#2196f3',
    borderWidth: 1,
  },
  airplayRoute: {
    backgroundColor: '#f3e5f5',
    borderColor: '#9c27b0',
    borderWidth: 1,
  },
  routeName: {
    fontSize: 16,
    fontWeight: 'bold',
  },
  routeType: {
    fontSize: 14,
    color: '#666',
    marginTop: 4,
  },
  routeId: {
    fontSize: 12,
    color: '#999',
    marginTop: 2,
  },
  routeInfo: {
    fontSize: 14,
    color: '#333',
  },
  noRoutesText: {
    fontSize: 14,
    color: '#666',
    fontStyle: 'italic',
  },
  eventText: {
    fontSize: 16,
    fontWeight: 'bold',
    marginTop: 10,
  },
  eventData: {
    fontSize: 14,
    color: '#666',
    marginTop: 5,
  },
  buttonSpacer: {
    height: 10,
  },
});
