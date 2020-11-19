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
    func saveData<T: Codable>(entityName: T, categoryName: T, todoName: T?, date: Date)
}

class ViewModel {
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
}

extension ViewModel: ViewModelDelegate {
    func saveData<T>(entityName: T, categoryName: T, todoName: T? = nil, date: Date) where T : Decodable, T : Encodable {
        guard let appDelegate = appDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        managedContext.automaticallyMergesChangesFromParent = true
        
        guard let entityName = entityName as? String else { return }
        guard let entity = NSEntityDescription.entity(forEntityName: entityName, in: managedContext) else { return }
        let todo = NSManagedObject(entity: entity, insertInto: managedContext)
        
        todo.setValue(categoryName, forKey: "categoryName")
        todo.setValue(date, forKey: "createDate")
        if let todoName = todoName {
            todo.setValue(todoName, forKey: "todoName")
        }
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save Todo. \(error), \(error.userInfo)")
        }
    }
}
