//
//  FlutterLiveActivities.swift
//  flutter_live_activities
//
//  Created by Mike on 2022/11/4.
//

import ActivityKit

struct FlutterLiveActivities: ActivityAttributes, Identifiable {
    public typealias LiveData = ContentState
    
    public struct ContentState: Codable, Hashable {
        var data: [String: String]
    }
    
    var id = UUID()
}
