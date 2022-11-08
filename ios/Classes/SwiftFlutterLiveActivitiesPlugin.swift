import ActivityKit
import Flutter
import UIKit

public class SwiftFlutterLiveActivitiesPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?
    private var urlSchemeList: [String] = []
    
    private var initialUrl: URL?
    private var latestUrl: URL? {
        didSet {
            if latestUrl != nil {
                eventSink?.self(latestUrl?.absoluteString)
            }
        }
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_live_activities", binaryMessenger: registrar.messenger())
        let eventChannel = FlutterEventChannel(name: "flutter_live_activities/event", binaryMessenger: registrar.messenger())
        
        let instance = SwiftFlutterLiveActivitiesPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        eventChannel.setStreamHandler(instance)
        registrar.addApplicationDelegate(instance)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if #available(iOS 16.1, *) {
            switch call.method {
            case "getInitUri":
                result(initialUrl?.absoluteString)
            case "createActivity":
                guard let args = call.arguments as? [String: Any] else {
                    return
                }
                if let data = args["data"] as? [String: String] {
                    createActivity(data: data, result: result)
                } else {
                    result(FlutterError(code: "DATA_ERROR", message: "'data' is invalid", details: nil))
                }
            case "updateActivity":
                guard let args = call.arguments as? [String: Any] else {
                    return
                }
                if let liveId = args["liveId"] as? String, let data = args["data"] as? [String: String] {
                    updateActivity(liveId: liveId, data: data, result: result)
                } else {
                    result(FlutterError(code: "DATA_ERROR", message: "'data' or 'liveId' is invalid", details: nil))
                }
            case "endActivity":
                guard let args = call.arguments as? [String: Any] else {
                    return
                }
                if let liveId = args["liveId"] as? String {
                    endActivity(liveId: liveId, result: result)
                } else {
                    result(FlutterError(code: "DATA_ERROR", message: "'liveId' is invalid", details: nil))
                }
            case "getAllActivities":
                result(getAllActivities())
            case "endAllActivities":
                endAllActivities()
            case "areActivitiesEnabled":
                result(areActivitiesEnabled(result: result))
            default:
                break
            }
        } else {
            print("This iOS version is not supported")
            result(nil)
        }
    }
    
    @available(iOS 16.1, *)
    func createActivity(data: [String: String], result: @escaping FlutterResult) {
        let attributes = FlutterLiveActivities()
        let contentState = FlutterLiveActivities.LiveData(data: data)
        
        do {
            let activity = try Activity<FlutterLiveActivities>.request(
                attributes: attributes,
                contentState: contentState,
                pushType: nil)
            result(activity.id)
        } catch {
            result(FlutterError(code: "LIVE_ACTIVITY_LAUNCH_ERROR", message: "launch live activity error", details: error.localizedDescription))
        }
    }
    
    @available(iOS 16.1, *)
    func updateActivity(liveId: String, data: [String: String], result: @escaping FlutterResult) {
        Task {
            for activity in Activity<FlutterLiveActivities>.activities {
                if liveId == activity.id {
                    let updatedStatus: FlutterLiveActivities.LiveData = .init(data: data)
                    await activity.update(using: updatedStatus)
                    break
                }
            }
        }
    }
    
    @available(iOS 16.1, *)
    func endActivity(liveId: String, result: @escaping FlutterResult) {
        Task {
            for activity in Activity<FlutterLiveActivities>.activities {
                if liveId == activity.id {
                    await activity.end(dismissalPolicy: .immediate)
                    break
                }
            }
        }
    }
    
    @available(iOS 16.1, *)
    func getAllActivities() -> String {
        var list: [String] = []
        for activity in Activity<FlutterLiveActivities>.activities {
            list.append(activity.id)
        }
        return list.joined(separator: ",")
    }
    
    @available(iOS 16.1, *)
    func endAllActivities() {
        Task {
            for activity in Activity<FlutterLiveActivities>.activities {
                await activity.end(dismissalPolicy: .immediate)
            }
        }
    }
    
    @available(iOS 16.1, *)
    func areActivitiesEnabled(result: @escaping FlutterResult) -> Bool {
        var hasAuthorization = true
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { _, error in
            if let error = error {
                hasAuthorization = false
                result(FlutterError(code: "AUTHORIZATION_ERROR", message: "authorization error", details: error.localizedDescription))
            }
        }
        
        return ActivityAuthorizationInfo().areActivitiesEnabled && hasAuthorization
    }
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        if arguments != nil {
            urlSchemeList.append(arguments as! String)
        }
        return nil
    }
     
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        if eventSink != nil {
            eventSink!(FlutterEndOfEventStream)
        }
        eventSink = nil
        if arguments != nil {
            if let index = urlSchemeList.firstIndex(of: arguments as! String) {
                urlSchemeList.remove(at: index)
            }
        }
       
        return nil
    }

    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [AnyHashable: Any] = [:]) -> Bool {
        let launchUrl = (launchOptions[UIApplication.LaunchOptionsKey.url] as? NSURL)?.absoluteURL
        if launchUrl != nil, isLiveActivitiesUrl(url: launchUrl!) {
            initialUrl = launchUrl?.absoluteURL
            latestUrl = initialUrl
        }
        return true
    }
     
    public func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        if isLiveActivitiesUrl(url: url) {
            latestUrl = url
            if eventSink != nil {
                eventSink!(latestUrl?.absoluteString)
            }
            return true
        }
        return false
    }
    
    private func isLiveActivitiesUrl(url: URL) -> Bool {
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        
        if components?.scheme == nil { return false }
            
        return urlSchemeList.contains(components!.scheme!)
    }
}
