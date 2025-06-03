import AVFoundation
import AVKit
import ExpoModulesCore

public class LazerExpoAirplayModule: Module {
  private var routeObserver: NSKeyValueObservation?
  private var audioSession: AVAudioSession?
  private var routePickerView: AVRoutePickerView?

  public func definition() -> ModuleDefinition {
    Name("LazerExpoAirplay")

    Events("onRouteChange")

    AsyncFunction("getCurrentRoute") { () -> [String: Any] in
      let result = self.getCurrentRoute()
      return result.toDictionary()
    }

    AsyncFunction("show") { () -> [String: Any] in
      let result = self.showAirPlayPicker()
      return result.toDictionary()
    }

    OnCreate {
      self.audioSession = AVAudioSession.sharedInstance()
      self.routePickerView = AVRoutePickerView()
      self.setupAirPlayObserver()
    }

    OnDestroy {
      self.cleanup()
    }
  }

  private func setupAirPlayObserver() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(audioRouteChanged),
      name: AVAudioSession.routeChangeNotification,
      object: nil
    )
  }

  @objc private func audioRouteChanged(notification: Notification) {
    DispatchQueue.main.async {
      if let userInfo = notification.userInfo,
        let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
        let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue)
      {
        let routeInfo = self.getCurrentRoute()
        var connectionState: String = "unknown"

        switch reason {
        case .newDeviceAvailable:
          connectionState = "device_available"
        case .oldDeviceUnavailable:
          connectionState = "device_unavailable"
        case .categoryChange:
          connectionState = "category_changed"
        case .override:
          connectionState = "override"
        case .wakeFromSleep:
          connectionState = "wake_from_sleep"
        case .noSuitableRouteForCategory:
          connectionState = "no_suitable_route"
        case .routeConfigurationChange:
          connectionState = "configuration_changed"
        default:
          connectionState = "unknown"
        }

        if let routeInfo = routeInfo.data {
          // Send general route change event
          self.sendEvent(
            "onRouteChange",
            [
              "current_route": routeInfo,
              "state": connectionState,
            ])
        }
      }
    }
  }

  private func getCurrentRoute() -> LazerResult<[String: Any], Error> {
    guard let audioSession = self.audioSession else {
      return .failure(
        NSError(
          domain: "LazerExpoAirplay", code: -1,
          userInfo: [NSLocalizedDescriptionKey: "Audio session not initialized"]))
    }

    let currentRoute = audioSession.currentRoute
    let outputs = currentRoute.outputs

    print("outputs: \(outputs)")

    // Get the primary output (usually the first one)
    guard let primaryOutput = outputs.first else {
      return .failure(
        NSError(
          domain: "LazerExpoAirplay", code: -2,
          userInfo: [NSLocalizedDescriptionKey: "No audio output available"]))
    }

    let isAirPlay = primaryOutput.portType == .airPlay
    print(
      "Primary output: \(primaryOutput.portName) with type: \(primaryOutput.portType), isAirPlay: \(isAirPlay)"
    )

    return .success([
      "route_id": primaryOutput.uid,
      "route_name": primaryOutput.portName,
      "port_type": primaryOutput.portType.rawValue,
      "is_airplay": isAirPlay,
    ])
  }

  private func showAirPlayPicker() -> LazerResult<Void, Error> {
    guard let routePickerView = self.routePickerView else {
      return .failure(
        NSError(
          domain: "LazerExpoAirplay", code: -1,
          userInfo: [NSLocalizedDescriptionKey: "Route picker not initialized"]))
    }

    let workItem = DispatchWorkItem {
      // Find the route picker button and simulate a tap
      for subview in routePickerView.subviews {
        if let button = subview as? UIButton {
          button.sendActions(for: .touchUpInside)
          break
        }
      }
    }
    DispatchQueue.main.async(execute: workItem)
    return .success(())
  }

  private func cleanup() {
    // Remove notification observer
    NotificationCenter.default.removeObserver(self)
  }
}
