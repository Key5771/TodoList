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
    func saveData(entityName: String, categoryName: String, todoName: String?, date: Date, isCompleted: Bool?, completion: ((Bool, String?) -> Void)?)
}

class ViewModel {
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
}

extension ViewModel: ViewModelDelegate {
    func saveData(entityName: String, categoryName: String, todoName: String? = nil, date: Date, isCompleted: Bool? = nil, completion: ((Bool, String?) -> Void)? = nil) {
        guard let appDelegate = appDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        managedContext.automaticallyMergesChangesFromParent = true
        
        // 카테고리 엔터티인 경우 중복 체크 수행
        if entityName == "TodoCategory" {
            let trimmedCategoryName = categoryName.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmedCategoryName.isEmpty {
                print("❌ Category name cannot be empty")
                completion?(false, "카테고리 이름을 입력해주세요.")
                return
            }
            
            if categoryExists(trimmedCategoryName) {
                print("❌ Category '\(trimmedCategoryName)' already exists")
                completion?(false, "'\(trimmedCategoryName)' 카테고리가 이미 존재합니다.\n다른 이름을 입력해주세요.")
                return
            }
        }
        
        guard let entity = NSEntityDescription.entity(forEntityName: entityName, in: managedContext) else { return }
        let todo = NSManagedObject(entity: entity, insertInto: managedContext)
        
        todo.setValue(categoryName.trimmingCharacters(in: .whitespacesAndNewlines), forKey: "categoryName")
        todo.setValue(date, forKey: "createDate")
        
        if let todoName = todoName {
            todo.setValue(todoName, forKey: "todoName")
        }
        
        // Todo 엔티티인 경우에만 isCompleted 속성 설정
        if entityName == "Todo" {
            let completedValue = isCompleted ?? false
            todo.setValue(completedValue, forKey: "isCompleted")
            
            // 완료된 할 일의 경우 completedDate도 설정
            if completedValue {
                todo.setValue(date, forKey: "completedDate")
            }
        }
        
        do {
            try managedContext.save()
            if entityName == "Todo" {
                let completedValue = isCompleted ?? false
                print("✅ Todo saved successfully: \(todoName ?? "Untitled"), completed: \(completedValue)")
            } else {
                print("✅ \(entityName) saved successfully: \(categoryName)")
            }
            completion?(true, nil)
        } catch let error as NSError {
            print("❌ Could not save \(entityName). \(error), \(error.userInfo)")
            completion?(false, "저장 중 오류가 발생했습니다: \(error.localizedDescription)")
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
    
    // MARK: - Category Duplicate Check
    func categoryExists(_ categoryName: String) -> Bool {
        guard let appDelegate = appDelegate else { return false }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<TodoCategory>(entityName: "TodoCategory")
        
        // 대소문자를 구분하여 완전히 일치하는지 검사 및 공백 제거
        let trimmedCategoryName = categoryName.trimmingCharacters(in: .whitespacesAndNewlines)
        fetchRequest.predicate = NSPredicate(format: "categoryName == %@", trimmedCategoryName)
        
        do {
            let results = try managedContext.fetch(fetchRequest)
            return !results.isEmpty
        } catch let error as NSError {
            print("❌ Could not fetch categories for duplicate check. \(error), \(error.userInfo)")
            return false
        }
    }
}
