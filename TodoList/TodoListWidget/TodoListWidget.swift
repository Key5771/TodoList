//
//  TodoListWidget.swift
//  TodoListWidget
//
//  Created by 김기현 on 10/30/25.
//

import WidgetKit
import SwiftUI
import CoreData
import AppIntents

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> TodoEntry {
        print("🔄 Widget: placeholder called")
        return TodoEntry(date: Date(), totalTasks: 0, completedTasks: 0)
    }

    func getSnapshot(in context: Context, completion: @escaping (TodoEntry) -> ()) {
        print("📸 Widget: getSnapshot called")
        let (totalTasks, completedTasks) = fetchTodoData()
        let entry = TodoEntry(date: Date(), totalTasks: totalTasks, completedTasks: completedTasks)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        print("⏰ Widget: getTimeline called - START")
        let currentDate = Date()

        // Core Data에서 실제 데이터 가져오기
        let (totalTasks, completedTasks) = fetchTodoData()

        let entry = TodoEntry(
            date: currentDate,
            totalTasks: totalTasks,
            completedTasks: completedTasks
        )

        print("📊 Widget timeline: \(entry.completedTasks)/\(entry.totalTasks) at \(currentDate)")

        // 매시간 새로고침
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        print("⏰ Widget: getTimeline called - END")
        completion(timeline)
    }

    private func fetchTodoData() -> (total: Int, completed: Int) {
        print("🔍 Widget: fetchTodoData started")

        // App Group 컨테이너 확인
        guard let storeURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.key.TodoList") else {
            print("❌ Widget: Failed to get App Group container")
            return (0, 0)
        }

        let finalStoreURL = storeURL.appendingPathComponent("TodoList.sqlite")
        print("🔍 Widget: Looking for database at: \(finalStoreURL.path)")

        // 파일 존재 확인
        if !FileManager.default.fileExists(atPath: finalStoreURL.path) {
            print("❌ Widget: Database file does not exist")

            // 앱 그룹 디렉토리 내용 확인
            do {
                let contents = try FileManager.default.contentsOfDirectory(atPath: storeURL.path)
                print("📁 Widget: App Group contents: \(contents)")
            } catch {
                print("❌ Widget: Cannot read App Group directory: \(error)")
            }

            return (0, 0)
        }

        // 간단한 Core Data 설정
        let container = NSPersistentContainer(name: "TodoList")
        let storeDescription = NSPersistentStoreDescription(url: finalStoreURL)
        storeDescription.setOption(true as NSNumber, forKey: NSReadOnlyPersistentStoreOption)
        container.persistentStoreDescriptions = [storeDescription]

        var loadError: Error?
        container.loadPersistentStores { description, error in
            loadError = error
            if let error = error {
                print("❌ Widget: Core Data error: \(error)")
            } else {
                print("✅ Widget: Core Data loaded from \(description.url?.path ?? "unknown")")
            }
        }

        guard loadError == nil else {
            print("❌ Widget: Failed to load persistent stores")
            return (0, 0)
        }

        let context = container.viewContext
        let request = NSFetchRequest<NSManagedObject>(entityName: "Todo")

        do {
            let todos = try context.fetch(request)
            let totalTasks = todos.count
            let completedTasks = todos.filter { todo in
                return (todo.value(forKey: "isCompleted") as? Bool) ?? false
            }.count

            print("✅ Widget: Found \(totalTasks) total, \(completedTasks) completed")
            return (totalTasks, completedTasks)
        } catch {
            print("❌ Widget: Fetch error: \(error)")
            return (0, 0)
        }
    }
}

struct TodoEntry: TimelineEntry {
    let date: Date
    let totalTasks: Int
    let completedTasks: Int

    var completionPercentage: Double {
        guard totalTasks > 0 else { return 0 }
        return Double(completedTasks) / Double(totalTasks)
    }
}

struct TodoListWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack(spacing: 6) {
            // 제목
            HStack {
                Image(systemName: "checklist")
                    .foregroundColor(.blue)
                    .font(.system(size: 14))
                Text("할 일")
                    .font(.system(size: 14, weight: .semibold))
                Spacer()
            }

            // 진행률 정보
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("\(entry.completedTasks)/\(entry.totalTasks)")
                        .font(.title2)
                        .fontWeight(.bold)
                    Spacer()
                    Text("\(Int(entry.completionPercentage * 100))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                // 진행률 바
                ProgressView(value: entry.completionPercentage)
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
            }

            // 완료 상태 텍스트
            HStack {
                if entry.totalTasks == 0 {
                    Text("할 일이 없습니다")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else if entry.completedTasks == entry.totalTasks {
                    Text("모든 할 일 완료! 🎉")
                        .font(.caption)
                        .foregroundColor(.green)
                } else {
                    Text("\(entry.totalTasks - entry.completedTasks)개 남음")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            
            Spacer()

            // 업데이트 시간 및 새로고침 버튼
            HStack {
                Spacer()
                Text(entry.date, style: .time)
                    .font(.caption2)
                    .foregroundColor(.secondary)

                Button(intent: RefreshIntent()) {
                    Image(systemName: "arrow.clockwise")
                        .font(.caption2)
                        .foregroundColor(.blue)
                }
                .buttonStyle(.plain)
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

struct TodoListWidget: Widget {
    let kind: String = "TodoListWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            TodoListWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("할 일 진행률")
        .description("할 일의 완료 진행률을 확인하세요.")
        .supportedFamilies([.systemSmall])
    }
}

#Preview(as: .systemSmall) {
    TodoListWidget()
} timeline: {
    TodoEntry(date: Date(), totalTasks: 8, completedTasks: 5)
    TodoEntry(date: Date(), totalTasks: 3, completedTasks: 3)
}
