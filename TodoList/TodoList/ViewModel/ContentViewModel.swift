//
//  ContentViewModel.swift
//  TodoList
//
//  Created by 김기현 on 2024/12/09.
//

import Foundation
import CoreData
import UIKit

protocol ContentViewModelDelegate: AnyObject {
    func didDeleteCategorySuccessfully()
    func didFailToDeleteCategory(error: String)
    func didUpdateTaskCount(_ count: Int)
}

class ContentViewModel {
    
    // MARK: - Properties
    weak var delegate: ContentViewModelDelegate?
    var categoryName: String?
    private var controller: NSFetchedResultsController<NSManagedObject>?
    
    // MARK: - Initializer
    init(categoryName: String?) {
        self.categoryName = categoryName
    }
    
    // MARK: - Public Methods
    func loadData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
              let categoryName = categoryName else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        managedContext.automaticallyMergesChangesFromParent = true
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Todo")
        fetchRequest.predicate = NSPredicate(format: "categoryName == %@", categoryName)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createDate", ascending: false)]
        
        controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: managedContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        do {
            try controller?.performFetch()
        } catch let error as NSError {
            print("Could not Content Fetch. \(error), \(error.userInfo)")
        }
    }
    
    func getFetchedResultsController() -> NSFetchedResultsController<NSManagedObject>? {
        return controller
    }
    
    func getTaskCount() -> Int {
        guard let sections = controller?.sections else { return 0 }
        let sectionInfo = sections[0]
        return sectionInfo.numberOfObjects
    }
    
    func deleteCategory() {
        guard let categoryName = self.categoryName,
              let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            delegate?.didFailToDeleteCategory(error: "카테고리 이름이 없거나 AppDelegate를 가져올 수 없습니다.")
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        
        // 1. 해당 카테고리의 모든 Todo 삭제
        let todoFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Todo")
        todoFetchRequest.predicate = NSPredicate(format: "categoryName == %@", categoryName)
        
        do {
            let todos = try context.fetch(todoFetchRequest)
            for todo in todos {
                context.delete(todo)
            }
            print("카테고리 '\(categoryName)'의 할 일 \(todos.count)개가 삭제되었습니다.")
        } catch let error as NSError {
            delegate?.didFailToDeleteCategory(error: "Todo 삭제 중 오류 발생: \(error.localizedDescription)")
            return
        }
        
        // 2. TodoCategory 엔티티에서 카테고리 삭제
        let categoryFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "TodoCategory")
        categoryFetchRequest.predicate = NSPredicate(format: "categoryName == %@", categoryName)
        
        do {
            let categories = try context.fetch(categoryFetchRequest)
            for category in categories {
                context.delete(category)
            }
            print("카테고리 '\(categoryName)'가 삭제되었습니다.")
        } catch let error as NSError {
            delegate?.didFailToDeleteCategory(error: "카테고리 삭제 중 오류 발생: \(error.localizedDescription)")
            return
        }
        
        // 3. 변경사항 저장
        do {
            try context.save()
            print("카테고리 삭제가 완료되었습니다.")
            delegate?.didDeleteCategorySuccessfully()
        } catch let error as NSError {
            delegate?.didFailToDeleteCategory(error: "카테고리 삭제 저장 중 오류 발생: \(error.localizedDescription)")
        }
    }
    
    func deleteTodo(at indexPath: IndexPath) -> Bool {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return false }
        
        let context = appDelegate.persistentContainer.viewContext
        guard let todo = controller?.object(at: indexPath) else { return false }
        
        do {
            context.delete(todo)
            try context.save()
            return true
        } catch let error as NSError {
            print("Could not Delete Todo. \(error), \(error.userInfo)")
            return false
        }
    }
}
