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
    func saveData(entityName: String, categoryName: String, todoName: String, date: Date)
    func save(name: String, date: Date)
}

class ViewModel {
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
}

extension ViewModel: ViewModelDelegate {
    func saveData(entityName: String, categoryName: String, todoName: String, date: Date) {
        guard let appDelegate = appDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        managedContext.automaticallyMergesChangesFromParent = true
        
        guard let entity = NSEntityDescription.entity(forEntityName: entityName, in: managedContext) else { return }
        let todo = NSManagedObject(entity: entity, insertInto: managedContext)
        
        todo.setValue(categoryName, forKey: "categoryName")
        todo.setValue(todoName, forKey: "todoName")
        todo.setValue(date, forKey: "createDate")
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save Todo. \(error), \(error.userInfo)")
        }
    }
    
    func save(name: String, date: Date) {
        print("save")
    }
}
