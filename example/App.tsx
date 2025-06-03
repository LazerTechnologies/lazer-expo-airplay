import LazerExpoAirplay, { OnRouteChangeEventPayload, useCurrentRoute } from '@lazer-tech/expo-airplay';
import { useEventListener } from 'expo';
import { useVideoPlayer, VideoView } from 'expo-video';
import React, { useState } from 'react';
import { ActivityIndicator, Button, SafeAreaView, ScrollView, StyleSheet, Text, View } from 'react-native';

export default function App() {
  const { currentRoute, isLoading, error, refresh } = useCurrentRoute();
  const [eventHistory, setEventHistory] = useState<OnRouteChangeEventPayload[]>([]);

  useEventListener(LazerExpoAirplay, 'onRouteChange', (event) => {
    console.log('Route changed:', event);
    setEventHistory(prev => [...prev, event]);
  });

  const player = useVideoPlayer({
    uri: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
  });

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView style={styles.container}>
        <Text style={styles.header}>React Native Airplay API Example</Text>

        <Group name="Current Audio Route">
          {isLoading ? (
            <ActivityIndicator size="small" color="#0000ff" />
          ) : error ? (
            <Text style={styles.errorText}>{error}</Text>
          ) : (
            <Text style={styles.routeInfo}>
              {currentRoute ? JSON.stringify(currentRoute, null, 2) : 'No audio route available'}
            </Text>
          )}
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
            onPress={refresh}
          />
        </Group>

        <Group name="Event History">
          {eventHistory.map((event, index) => (
            <View key={index} style={styles.eventItem}>
              <Text style={styles.eventText}>Event {index + 1}:</Text>
              <Text style={styles.eventData}>{JSON.stringify(event, null, 2)}</Text>
            </View>
          ))}
        </Group>

        <VideoView style={styles.view} player={player} />
      </ScrollView>
    </SafeAreaView>
  );
}

const Group = ({ name, children }: { name: string; children: React.ReactNode }) => (
  <View style={styles.group}>
    <Text style={styles.groupTitle}>{name}</Text>
    {children}
  </View>
);

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
  },
  header: {
    fontSize: 24,
    fontWeight: 'bold',
    textAlign: 'center',
    marginVertical: 20,
  },
  group: {
    padding: 15,
    borderBottomWidth: 1,
    borderBottomColor: '#eee',
  },
  groupTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    marginBottom: 10,
  },
  routeInfo: {
    fontFamily: 'monospace',
  },
  errorText: {
    color: 'red',
    fontFamily: 'monospace',
  },
  buttonSpacer: {
    height: 10,
  },
  eventItem: {
    marginBottom: 15,
    padding: 10,
    backgroundColor: '#f5f5f5',
    borderRadius: 5,
  },
  eventText: {
    fontWeight: 'bold',
    marginBottom: 5,
  },
  eventData: {
    fontFamily: 'monospace',
  },
  view: {
    width: '100%',
    height: 300,
    marginTop: 20,
  },
});
