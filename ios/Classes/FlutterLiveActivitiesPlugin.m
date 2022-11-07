#import "FlutterLiveActivitiesPlugin.h"
#if __has_include(<flutter_live_activities/flutter_live_activities-Swift.h>)
#import <flutter_live_activities/flutter_live_activities-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_live_activities-Swift.h"
#endif

@implementation FlutterLiveActivitiesPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterLiveActivitiesPlugin registerWithRegistrar:registrar];
}
@end
