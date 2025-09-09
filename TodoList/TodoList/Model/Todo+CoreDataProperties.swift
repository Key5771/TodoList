//
//  Todo+CoreDataProperties.swift
//  TodoList
//
//  Created by AI Assistant on 2025/09/09.
//

import Foundation
import CoreData

extension Todo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Todo> {
        return NSFetchRequest<Todo>(entityName: "Todo")
    }

    @NSManaged public var categoryName: String?
    @NSManaged public var createDate: Date?
    @NSManaged public var todoName: String?
    @NSManaged public var isCompleted: Bool
    @NSManaged public var completedDate: Date?

    // Computed properties for better organization
    public var displayName: String {
        return todoName ?? "Untitled Task"
    }
    
    public var formattedCreateDate: String {
        guard let createDate = createDate else { return "" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: createDate)
    }
    
    public var isOverdue: Bool {
        // TODO: Add due date functionality later
        return false
    }
}

// MARK: - Generated accessors for relationships
extension Todo : Identifiable {
    // Core Data generated identifier
}
