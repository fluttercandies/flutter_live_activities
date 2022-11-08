//
//  live_activity_testLiveActivity.swift
//  live_activity_test
//
//  Created by Mike on 2022/11/4.
//

import ActivityKit
import SwiftUI
import WidgetKit

// TestData
struct TestData {
    var text: String

    init?(JSONData data: [String: String]) {
        self.text = data["text"] ?? ""
    }

    init(text: String) {
        self.text = text
    }
}

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
        ActivityConfiguration(for: FlutterLiveActivities.self) { context in
            let data = TestData(JSONData: context.state.data)

            // Lock screen/banner UI goes here

            VStack(alignment: .leading) {
                Text(data?.text ?? "")
                HStack {
                    Link(destination: URL(string: "fla://xx.xx/tap/A")!) {
                        Text("A")
                            .frame(width: 40, height: 40)
                            .background(.blue)
                    }

                    Link(destination: URL(string: "fla://xx.xx/tap/B")!) {
                        Text("B")
                            .frame(width: 40, height: 40)
                            .background(.blue)
                    }

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
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Link(destination: URL(string: "fla://xx.xx/tap/HelloWorld")!) {
                        Text(data?.text ?? "")
                            .background(.red)
                    }
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T")
            } minimal: {
                Text("Min")
            }
            .widgetURL(URL(string: "fla://xx.xx/tap/DynamicIsland"))
            .keylineTint(Color.red)
        }
    }
}
