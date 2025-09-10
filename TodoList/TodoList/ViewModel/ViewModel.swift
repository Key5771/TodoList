//
//  ViewModel.swift
//  TodoList
//
//  Created by 김기현 on 2020/11/19.
//

import Foundation
import UIKit
import CoreData

protocol ViewModelDelegate {
    func saveData(entityName: String, categoryName: String, todoName: String?, date: Date, isCompleted: Bool?)
}

class ViewModel {
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
}

extension ViewModel: ViewModelDelegate {
    func saveData(entityName: String, categoryName: String, todoName: String? = nil, date: Date, isCompleted: Bool? = nil) {
        guard let appDelegate = appDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        managedContext.automaticallyMergesChangesFromParent = true
        
        guard let entity = NSEntityDescription.entity(forEntityName: entityName, in: managedContext) else { return }
        let todo = NSManagedObject(entity: entity, insertInto: managedContext)
        
        todo.setValue(categoryName, forKey: "categoryName")
        todo.setValue(date, forKey: "createDate")
        
        if let todoName = todoName {
            todo.setValue(todoName, forKey: "todoName")
        }
        
        // isCompleted 속성 설정 (기본값: false)
        let completedValue = isCompleted ?? false
        todo.setValue(completedValue, forKey: "isCompleted")
        
        // 완료된 할 일의 경우 completedDate도 설정
        if completedValue {
            todo.setValue(date, forKey: "completedDate")
        }
        
        do {
            try managedContext.save()
            print("✅ Todo saved successfully: \(todoName ?? "Untitled"), completed: \(completedValue)")
        } catch let error as NSError {
            print("❌ Could not save Todo. \(error), \(error.userInfo)")
        }
    }
    
    // MARK: - Completion State Management
    func toggleTodoCompletion(todo: Todo) {
        guard let appDelegate = appDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // 완료 상태 토글
        todo.isCompleted.toggle()
        
        // 완료 날짜 업데이트
        if todo.isCompleted {
            todo.completedDate = Date()
        } else {
            todo.completedDate = nil
        }
        
        do {
            try managedContext.save()
            print("✅ Todo completion toggled: \(todo.todoName ?? "Untitled"), completed: \(todo.isCompleted)")
        } catch let error as NSError {
            print("❌ Could not toggle Todo completion. \(error), \(error.userInfo)")
            
            // 실패 시 상태 되돌리기
            todo.isCompleted.toggle()
            if todo.isCompleted {
                todo.completedDate = Date()
            } else {
                todo.completedDate = nil
            }
        }
    }
    
    // MARK: - Data Fetching
    func fetchTodos(for categoryName: String) -> [Todo] {
        guard let appDelegate = appDelegate else { return [] }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Todo>(entityName: "Todo")
        fetchRequest.predicate = NSPredicate(format: "categoryName == %@", categoryName)
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "isCompleted", ascending: true), // 미완료 먼저
            NSSortDescriptor(key: "createDate", ascending: false)   // 최신순
        ]
        
        do {
            let todos = try managedContext.fetch(fetchRequest)
            return todos
        } catch let error as NSError {
            print("❌ Could not fetch todos. \(error), \(error.userInfo)")
            return []
        }
    }
    
    func fetchPendingTodos(for categoryName: String) -> [Todo] {
        return fetchTodos(for: categoryName).filter { !$0.isCompleted }
    }
    
    func fetchCompletedTodos(for categoryName: String) -> [Todo] {
        return fetchTodos(for: categoryName).filter { $0.isCompleted }
    }
    
    // MARK: - Statistics
    func getTodoStatistics(for categoryName: String) -> (total: Int, pending: Int, completed: Int) {
        let todos = fetchTodos(for: categoryName)
        let pending = todos.filter { !$0.isCompleted }.count
        let completed = todos.filter { $0.isCompleted }.count
        
        return (total: todos.count, pending: pending, completed: completed)
    }
}
