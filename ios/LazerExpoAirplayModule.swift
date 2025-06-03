import AVFoundation
import AVKit
import ExpoModulesCore

public class LazerExpoAirplayModule: Module {
  private var routeObserver: NSKeyValueObservation?

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

    AsyncFunction("selectRoute") { (routeId: String) -> [String: Any] in
      let result = self.selectRoute(routeId: routeId)
      return result.toDictionary()
    }

    OnCreate {
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
    let audioSession = AVAudioSession.sharedInstance()

    let currentRoute = audioSession.currentRoute
    let outputs = currentRoute.outputs

    print("outputs: \(outputs)")

    // Check if there's an AirPlay output
    let airPlayOutput = outputs.first { output in
      print("Checking output: \(output.portName) with type: \(output.portType)")
      return output.portType == .airPlay
    }

    if let airPlayOutput = airPlayOutput {
      print("airPlayOutput: \(airPlayOutput)")
      return .success([
        "route_id": airPlayOutput.uid,
        "route_name": airPlayOutput.portName,
        "port_type": airPlayOutput.portType.rawValue,
        "is_airplay": true,
      ])
    }

    // If no AirPlay, return the first available output
    if let firstOutput = outputs.first {
      return .success([
        "route_id": firstOutput.uid,
        "route_name": firstOutput.portName,
        "port_type": firstOutput.portType.rawValue,
        "is_airplay": false,
      ])
    }

    return .failure(
      NSError(
        domain: "LazerExpoAirplay", code: -2,
        userInfo: [NSLocalizedDescriptionKey: "No route available"]))
  }

  private func showAirPlayPicker() -> LazerResult<Void, Error> {
    let routePickerView = AVRoutePickerView()

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

  private func selectRoute(routeId: String) -> LazerResult<Bool, Error> {
    let audioSession = AVAudioSession.sharedInstance()
    do {
      // Get available routes
      let routes = audioSession.availableInputs ?? []

      print("routes: \(routes)")

      // Find the matching route
      if let matchingRoute = routes.first(where: { $0.uid == routeId }) {
        try audioSession.setPreferredInput(matchingRoute)
        return .success(true)
      }
      return .failure(
        NSError(
          domain: "LazerExpoAirplay", code: -4,
          userInfo: [NSLocalizedDescriptionKey: "Route not found"]))
    } catch {
      return .failure(error)
    }
  }

  private func cleanup() {
    // Remove notification observer
    NotificationCenter.default.removeObserver(self)
  }
}
