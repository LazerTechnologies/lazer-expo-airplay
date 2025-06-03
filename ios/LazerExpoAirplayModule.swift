import AVFoundation
import AVKit
import ExpoModulesCore

public class LazerExpoAirplayModule: Module {

  private enum ErrorCode: Int {
    case audioSessionNotInitialized = 1001
    case noAudioOutputAvailable = 1002
    case routePickerNotInitialized = 1003
    case routePickerSetupFailed = 1004
  }

  private static let errorDomain = "LazerExpoAirplay"
  private static let debugLogging = true  // Set to true for debug logging

  private var routeObserver: NSObjectProtocol?
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
      self.setupRoutePickerView()
      self.setupAirPlayObserver()
    }

    OnDestroy {
      self.cleanup()
    }
  }

  private func setupRoutePickerView() {
    self.routePickerView = AVRoutePickerView(frame: .zero)

    DispatchQueue.main.async { [weak self] in
      guard let routePickerView = self?.routePickerView,
        let windowScene = UIApplication.shared.connectedScenes.first
          as? UIWindowScene,
        let window = windowScene.windows.first,
        let rootViewController = window.rootViewController
      else {
        self?.logDebug("Failed to add route picker to view hierarchy")
        return
      }

      // Add as hidden subview to ensure it works properly
      routePickerView.alpha = 0
      routePickerView.isHidden = true
      rootViewController.view.addSubview(routePickerView)
    }
  }

  private func setupAirPlayObserver() {
    if let observer = routeObserver {
      NotificationCenter.default.removeObserver(observer)
      routeObserver = nil
    }

    routeObserver = NotificationCenter.default.addObserver(
      forName: AVAudioSession.routeChangeNotification,
      object: nil,
      queue: .main
    ) { [weak self] notification in
      self?.audioRouteChanged(notification: notification)
    }
  }

  @objc private func audioRouteChanged(notification: Notification) {
    self.logDebug("audioRouteChanged: \(notification.userInfo ?? [:])")

    // Already on main queue due to observer setup
    guard let userInfo = notification.userInfo,
      let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
      let previousRoute = userInfo[AVAudioSessionRouteChangePreviousRouteKey]
        as? AVAudioSessionRouteDescription,
      let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue)
    else {
      return
    }

    guard let audioSession = self.audioSession else { return }
    let currentRoute = audioSession.currentRoute
    let connectionState = self.mapRouteChangeReason(reason)

    self.logDebug("Audio route changed: \(connectionState)")

    self.sendEvent(
      "onRouteChange",
      [
        "current_route": routeDescriptionToDictionary(currentRoute),
        "previous_route": routeDescriptionToDictionary(previousRoute),
        "state": connectionState,
      ])
  }

  private func mapRouteChangeReason(
    _ reason: AVAudioSession.RouteChangeReason
  ) -> String {
    switch reason {
    case .newDeviceAvailable:
      return "device_available"
    case .oldDeviceUnavailable:
      return "device_unavailable"
    case .categoryChange:
      return "category_changed"
    case .override:
      return "override"
    case .wakeFromSleep:
      return "wake_from_sleep"
    case .noSuitableRouteForCategory:
      return "no_suitable_route"
    case .routeConfigurationChange:
      return "configuration_changed"
    default:
      return "unknown"
    }
  }

  private func routeDescriptionToDictionary(_ route: AVAudioSessionRouteDescription) -> [String:
    Any]
  {
    if let primaryOutput = route.outputs.first {
      let isAirPlay = primaryOutput.portType == .airPlay
      return [
        "route_id": primaryOutput.uid,
        "route_name": primaryOutput.portName,
        "port_type": primaryOutput.portType.rawValue,
        "is_airplay": isAirPlay,
      ]
    }

    // Default to built-in route if no output is available
    return [
      "route_id": "Speaker",
      "route_name": "Speaker",
      "port_type": AVAudioSession.Port.builtInSpeaker.rawValue,
      "is_airplay": false,
    ]
  }

  private func getCurrentRoute() -> LazerResult<[String: Any], Error> {
    guard let audioSession = self.audioSession else {
      return .failure(
        self.createError(
          .audioSessionNotInitialized, "Audio session not initialized"
        ))
    }

    let currentRoute = audioSession.currentRoute
    let routeDict = routeDescriptionToDictionary(currentRoute)
      
    return .success(routeDict)
  }

  private func showAirPlayPicker() -> LazerResult<Void, Error> {
    guard self.routePickerView != nil else {
      return .failure(
        self.createError(
          .routePickerNotInitialized, "Route picker not initialized"))
    }

    let workItem = DispatchWorkItem { [weak self] in
      // Give the route picker a moment to ensure subviews are populated
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        guard let self = self,
          let routePickerView = self.routePickerView
        else { return }

        // Find the route picker button and simulate a tap
        for subview in routePickerView.subviews {
          if let button = subview as? UIButton {
            self.logDebug("Triggering AirPlay picker")
            button.sendActions(for: .touchUpInside)
            return
          }
        }

        self.logDebug(
          "Warning: No button found in AVRoutePickerView subviews")
      }
    }

    DispatchQueue.main.async(execute: workItem)
    return .success(())
  }

  private func cleanup() {
    DispatchQueue.main.async { [weak self] in
      // Remove notification observer with proper cleanup
      if let observer = self?.routeObserver {
        NotificationCenter.default.removeObserver(observer)
        self?.routeObserver = nil
      }

      self?.routePickerView?.removeFromSuperview()
      self?.routePickerView = nil

      self?.audioSession = nil
    }
  }

  private func createError(_ code: ErrorCode, _ description: String)
    -> NSError
  {
    return NSError(
      domain: Self.errorDomain,
      code: code.rawValue,
      userInfo: [NSLocalizedDescriptionKey: description]
    )
  }

  private func logDebug(_ message: String) {
    if Self.debugLogging {
      print("[LazerExpoAirplay] \(message)")
    }
  }
}
