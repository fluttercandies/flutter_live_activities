import ActivityKit
import Flutter
import UIKit

public class SwiftFlutterLiveActivitiesPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?
    private var urlScheme: String?
    
    private var initialUrl: URL?
    private var removeWhenAppIsKilled: Bool = false
    
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
            case "init":
                guard let args = call.arguments as? [String: Any] else {
                    return
                }
                if let scheme = args["urlScheme"] as? String {
                    urlScheme = scheme
                } else {
                    result(FlutterError(code: "DATA_ERROR", message: "'liveId' is invalid", details: nil))
                }
            case "getInitUri":
                result(initialUrl?.absoluteString)
            case "createActivity":
                guard let args = call.arguments as? [String: Any] else {
                    return
                }
                if let data = args["data"] as? [String: String] {
                    removeWhenAppIsKilled = args["removeWhenAppIsKilled"] as? Bool ?? false
                    createActivity(data: data,removeWhenAppIsKilled:removeWhenAppIsKilled, result: result)
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
                getAllActivities(result: result)
            case "endAllActivities":
                endAllActivities(result: result)
            case "getActivityState":
                guard let args = call.arguments as? [String: Any] else {
                    return
                }
                
                if let liveId = args["liveId"] as? String {
                    getActivityState(liveId: liveId, result: result)
                } else {
                    result(FlutterError(code: "DATA_ERROR", message: "'liveId' is invalid", details: nil))
                }
                
            case "areActivitiesEnabled":
                areActivitiesEnabled(result: result)
            case "sendImageToGroup":
                guard let args = call.arguments as? [String: Any] else {
                    result(FlutterError(code: "DATA_ERROR", message: "parameter is invalid", details: nil))
                    return
                }
                
                if let data = args as? [String: String] {
                    receiveImage(data: data, result: result)
                } else {
                    result(FlutterError(code: "DATA_ERROR", message: "parameter is invalid", details: nil))
                }
                            
            default:
                break
            }
        } else {
            print("This iOS version is not supported")
            result(nil)
        }
    }
    
    @available(iOS 16.1, *)
    func createActivity(data: [String: String],removeWhenAppIsKilled: Bool, result: @escaping FlutterResult) {
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
                    result(true)
                    return
                }
            }
            
            result(false)
        }
    }
    
    @available(iOS 16.1, *)
    func endActivity(liveId: String, result: @escaping FlutterResult) {
        Task {
            for activity in Activity<FlutterLiveActivities>.activities {
                if liveId == activity.id {
                    await activity.end(dismissalPolicy: .immediate)
                    result(true)
                    return
                }
            }
            
            result(false)
        }
    }
    
    @available(iOS 16.1, *)
    func getActivityState(liveId: String, result: @escaping FlutterResult) {
        Task {
            for activity in Activity<FlutterLiveActivities>.activities {
                if liveId == activity.id {
                    switch activity.activityState {
                    case .active:
                        result(0)
                    case .ended:
                        result(1)
                    case .dismissed:
                        result(2)
                    @unknown default:
                        result(3)
                    }
                    break
                }
            }
        }
    }
    
    @available(iOS 16.1, *)
    func getAllActivities(result: @escaping FlutterResult) {
        var list: [String] = []
        for activity in Activity<FlutterLiveActivities>.activities {
            list.append(activity.id)
        }
        result(list.joined(separator: ","))
    }
    
    @available(iOS 16.1, *)
    func endAllActivities(result: @escaping FlutterResult) {
        Task {
            for activity in Activity<FlutterLiveActivities>.activities {
                await activity.end(dismissalPolicy: .immediate)
            }
            
            result(true)
        }
    }
    
    @available(iOS 16.1, *)
    func areActivitiesEnabled(result: @escaping FlutterResult) {
        var hasAuthorization = true
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert, .sound, .badge]) { _, error in
            if let error = error {
                hasAuthorization = false
                result(FlutterError(code: "AUTHORIZATION_ERROR", message: "authorization error", details: error.localizedDescription))
            }
        }
        
        result(ActivityAuthorizationInfo().areActivitiesEnabled && hasAuthorization)
    }
    
    @available(iOS 16.0, *)
    private func receiveImage(data: [String: String], result: @escaping FlutterResult) {
        guard var groupId = data["groupId"]
        else {
            result(FlutterError(code: "DATA_ERROR", message: "no groupId", details: nil))
            return
        }
        
        guard var destination = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: groupId)
        else {
            result(FlutterError(code: "DATA_ERROR", message: "no group", details: nil))
            return
        }
        
        do {
            if let id = data["id"], let path = data["filePath"] {
                destination = destination.appendingPathComponent(id)
                
                do {
                    try FileManager.default.removeItem(at: destination)
                } catch {
                    print(error.localizedDescription)
                }
                
                try FileManager.default.moveItem(at: URL(filePath: path), to: destination)
                
                result(true)
            }
        } catch {
            result(FlutterError(code: "OP_ERROR", message: "receiveImage error", details: error.localizedDescription))
            return
        }
    }
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        return nil
    }
     
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }

    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [AnyHashable: Any] = [:]) -> Bool {
        let launchUrl = (launchOptions[UIApplication.LaunchOptionsKey.url] as? NSURL)?.absoluteURL
        
        if launchUrl != nil {
            initialUrl = launchUrl?.absoluteURL
        }
        
        return true
    }
    
    public func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        if isLiveActivitiesUrl(url: url) {
            eventSink?.self(url.absoluteString)
            return true
        }
        return false
    }
    
    private func isLiveActivitiesUrl(url: URL) -> Bool {
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        
        if components?.scheme == nil { return false }
        
        return urlScheme == components?.scheme
    }

    public func applicationWillTerminate(_ application: UIApplication) {
    if #available(iOS 16.1, *) {
        if(removeWhenAppIsKilled){
            Task {
                for activity in Activity<FlutterLiveActivities>.activities {
                    await activity.end(dismissalPolicy: .immediate)
                }
            }
        }
    }
}
}
