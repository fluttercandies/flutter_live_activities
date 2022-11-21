<img src="https://raw.githubusercontent.com/xSILENCEx/project_images/main/flutter_live_activities/live_activities.png" height=100>

# Flutter Live Activities

Live Activities 的 Flutter 插件。用于创建、更新和处理 [DynamicIsland UI] 和 [Lock screen/banner UI] 的动作

[English](README.md) | 中文说明

[![pub package](https://img.shields.io/pub/v/flutter_live_activities?logo=dart&label=stable&style=flat-square)](https://pub.dev/packages/flutter_live_activities)
[![GitHub stars](https://img.shields.io/github/stars/fluttercandies/flutter_live_activities?logo=github&style=flat-square)](https://github.com/fluttercandies/flutter_live_activities/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/fluttercandies/flutter_live_activities?logo=github&style=flat-square)](https://github.com/fluttercandies/flutter_live_activities/network/members)
<a target="_blank" href="https://jq.qq.com/?_wv=1027&k=5bcc0gy"><img border="0" src="https://pub.idqqimg.com/wpa/images/group.png" alt="FlutterCandies" title="FlutterCandies"></a>

> 此插件需要通知权限

<img src="https://raw.githubusercontent.com/xSILENCEx/project_images/main/flutter_live_activities/pre.gif" width=200><img src="https://raw.githubusercontent.com/xSILENCEx/project_images/main/flutter_live_activities/pre2.gif" width=200><img src="https://raw.githubusercontent.com/xSILENCEx/project_images/main/flutter_live_activities/img.png" width=200>

#### 1. 在iOS项目中添加 Widget


<img src="https://raw.githubusercontent.com/xSILENCEx/project_images/main/flutter_live_activities/new.png" height=400>

<img src="https://raw.githubusercontent.com/xSILENCEx/project_images/main/flutter_live_activities/we.png" height=300>

<img src="https://raw.githubusercontent.com/xSILENCEx/project_images/main/flutter_live_activities/config.png" height=300> 

* 创建成功后的目录结构

<img src="https://raw.githubusercontent.com/xSILENCEx/project_images/main/flutter_live_activities/finish.png" height=400>

#### 2. 编辑 `Runner/Info.plist` 和 `live_activity_test/Info.plist`

两个文件中都添加以下内容:
```xml
<plist version="1.0">
<dict>
    ...
	<key>NSSupportsLiveActivities</key>
	<true/>
    ...
</dict>
</plist>
```

#### 3. 在小部件 swift 文件中创建数据通道

[live_activity_test/live_activity_testLiveActivity.swift](https://github.com/fluttercandies/flutter_live_activities/blob/main/example/ios/live_activity_test/live_activity_testLiveActivity.swift)

```swift
import ActivityKit
import SwiftUI
import WidgetKit

// 自定义Model
struct TestData {
    var text: String

    init?(JSONData data: [String: String]) {
        self.text = data["text"] ?? ""
    }

    init(text: String) {
        self.text = text
    }
}

// 数据通道  <-  必要！不能更改任何内容
struct FlutterLiveActivities: ActivityAttributes, Identifiable {
    public typealias LiveData = ContentState

    public struct ContentState: Codable, Hashable {
        var data: [String: String]
    }

    var id = UUID()
}

@available(iOSApplicationExtension 16.1, *)
struct live_activity_testLiveActivity: Widget {
    var body: some WidgetConfiguration {
        // 绑定通道
        ActivityConfiguration(for: FlutterLiveActivities.self) { context in

            // 锁屏上显示的内容

            // Json to model
            let data = TestData(JSONData: context.state.data)

            // UI
            VStack {
                Text(data?.text ?? "")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)
        } dynamicIsland: { context in
            // Json to model
            let data = TestData(JSONData: context.state.data)

            // 灵动岛
            return DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    // 显示 Flutter 传递过来的数据
                    Text(data?.text ?? "")
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T")
            } minimal: {
                Text("Min")
            }
            .keylineTint(Color.red)
        }
    }
}
```

更多布局信息，请参考: [live activities](https://developer.apple.com/documentation/activitykit/displaying-live-data-with-live-activities)

#### 4. APIs

```dart
import 'package:flutter_live_activities/flutter_live_activities.dart';

...

final FlutterLiveActivities _liveActivities = FlutterLiveActivities();

String? _activityId;
```

* 检查设备是否开启此功能
```dart
await _liveActivities.areActivitiesEnabled();
```

* 获取启动Link
```dart
await _liveActivities.getInitUri()
```

* 创建一个 Live Activity
```dart
_activityId = await _liveActivities.createActivity(<String, String>{'text': 'Hello World'});
```

* 更新 Live Activity
```dart
if(_activityId != null) {
    await _liveActivities.updateActivity(_activityId!, <String, String>{'text': 'Update Hello World'});
}
```

> ActivityKit 更新和远程推送通知更新的更新动态数据大小不能超过 4KB。 [相关文档](https://developer.apple.com/documentation/activitykit/displaying-live-data-with-live-activities)

<img src="https://raw.githubusercontent.com/xSILENCEx/project_images/main/flutter_live_activities/4k.png" height=300>

> 其它解决方案请参考 [live_activities](https://pub.dev/packages/live_activities)

* 结束 Live Activity
```dart
if(_activityId != null) {
    await _liveActivities.endActivity(_activityId!);
}
```

* 结束全部 Live Activities
```dart
await _liveActivities.endAllActivities();
```

* 获取全部 Live Activities id
```dart
await _liveActivities.getAllActivities()
```

#### 5. Deeplink(点击动作)

* 默认 urlScheme 为 `fla`

> `FlutterLiveActivities({this.urlScheme = 'fla'})`

* 在项目中添加 urlScheme

<img src="https://raw.githubusercontent.com/xSILENCEx/project_images/main/flutter_live_activities/scheme.png" height=400>

* Swift 代码:

```swift
@available(iOSApplicationExtension 16.1, *)
struct live_activity_testLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: FlutterLiveActivities.self) { context in
            let data = TestData(JSONData: context.state.data)

            // Lock screen/banner UI goes here

            VStack(alignment: .leading) {
                Text(data?.text ?? "")
                HStack {
                    // 通过 `Link` 创建一个动作
                    Link(destination: URL(string: "fla://xx.xx/tap/A")!) {
                        Text("A")
                            .frame(width: 40, height: 40)
                            .background(.blue)
                    }
                    // 通过 `Link` 创建一个动作
                    Link(destination: URL(string: "fla://xx.xx/tap/B")!) {
                        Text("B")
                            .frame(width: 40, height: 40)
                            .background(.blue)
                    }
                    // 通过 `Link` 创建一个动作
                    Link(destination: URL(string: "fla://xx.xx/tap/C")!) {
                        Text("C")
                            .frame(width: 40, height: 40)
                            .background(.blue)
                    }
                }
                .frame(width: .infinity, height: .infinity)
            }
            .padding(20)
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in

            let data = TestData(JSONData: context.state.data)

            return DynamicIsland {
                DynamicIslandExpandedRegion(.bottom) {
                    // 通过 `Link` 创建一个动作
                    Link(destination: URL(string: "fla://xxxxxxx.xxxxxx")!) {
                        Text(data?.text ?? "")
                            .background(.red)
                    }
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T")
            } minimal: {
                Text("Min")
            }
            .widgetURL(URL(string: "fla://www.apple.com")) // 或使用 widgetURL
            .keylineTint(Color.red)
        }
    }
}
```

* Dart 代码:

```dart
_subscription ??= _liveActivities.uriStream().listen((String? uri) {
    dev.log('deeplink uri: $uri');
});
```

#### 6. Display image

> 由于数据块大小的限制。我们无法向LiveActivities发送图片元数据  

> LiveActivities不支持异步加载，所以我们不能使用AsyncImage或读取本地文件

> 开发者论坛的解决方案: [716902](https://developer.apple.com/forums/thread/716902)

* 添加 AppGroup (此操作需要付费Apple账户)

<img src="https://raw.githubusercontent.com/xSILENCEx/project_images/main/flutter_live_activities/group.png" height=300>

* 在 Runner 和 Widget 中创建/选择同样的 groupId

<img src="https://raw.githubusercontent.com/xSILENCEx/project_images/main/flutter_live_activities/groupId.png" height=300>

* 发送图片到 group:

Dart代码:
```dart
Future<void> _sendImageToGroup() async {
    const String url = 'https://cdn.iconscout.com/icon/free/png-256/flutter-2752187-2285004.png';

    final String? path = await ImageHelper.getFilePathFromUrl(url);

    if (path != null) {
        _liveActivities.sendImageToGroup(
            id: 'test-img',
            filePath: path,
            groupId: 'group.live_example',
        );
    }
}
```

Swift代码:
```swift
DynamicIslandExpandedRegion(.leading) {
    if let imageContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.live_example")?.appendingPathComponent("test-img"), /// Use id here
        let uiImage = UIImage(contentsOfFile: imageContainer.path())
    {
        Image(uiImage: uiImage)
            .resizable()
            .frame(width: 53, height: 53)
            .cornerRadius(13)
    } else {
        Text("Leading")
    }
}
```