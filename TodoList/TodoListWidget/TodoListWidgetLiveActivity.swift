//
//  TodoListWidgetLiveActivity.swift
//  TodoListWidget
//
//  Created by 김기현 on 10/30/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct TodoListWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct TodoListWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TodoListWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension TodoListWidgetAttributes {
    fileprivate static var preview: TodoListWidgetAttributes {
        TodoListWidgetAttributes(name: "World")
    }
}

extension TodoListWidgetAttributes.ContentState {
    fileprivate static var smiley: TodoListWidgetAttributes.ContentState {
        TodoListWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: TodoListWidgetAttributes.ContentState {
         TodoListWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: TodoListWidgetAttributes.preview) {
   TodoListWidgetLiveActivity()
} contentStates: {
    TodoListWidgetAttributes.ContentState.smiley
    TodoListWidgetAttributes.ContentState.starEyes
}
