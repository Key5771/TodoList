import Foundation
import AppIntents
import WidgetKit

struct RefreshIntent: AppIntent {
    static var title: LocalizedStringResource = "위젯 새로고침"
    static var description = IntentDescription("할 일 위젯을 새로고침합니다")

    func perform() async throws -> some IntentResult {
        print("🔄 RefreshIntent: 새로고침 버튼 클릭됨")

        // 위젯 새로고침
        WidgetCenter.shared.reloadTimelines(ofKind: "TodoListWidget")

        return .result()
    }
}