//
//  AddTodoViewController.swift
//  TodoList
//
//  Created by 김기현 on 2020/10/23.
//

import UIKit
import CoreData

class AddTodoViewController: UIViewController {
    @IBOutlet weak var todoTextField: UITextField!
    
    var todoList: Todo?
    var category: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let category = category {
            print("AddTodoViewController: \(category)")
        }
    }

    @IBAction func closeClick(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveClick(_ sender: Any) {
        guard let todoName = todoTextField.text, let category = category else { return }
        let date = Date()
        
        if todoName == "" {
            let alert = UIAlertController(title: "오류", message: "할 일을 입력해주세요.", preferredStyle: .alert)
            let okButton = UIAlertAction(title: "확인", style: .default, handler: nil)
            
            alert.addAction(okButton)
            self.present(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "저장", message: "저장하시겠습니까?", preferredStyle: .alert)
            let okButton = UIAlertAction(title: "확인", style: .default) { _ in
                print("ok")
                if self.todoList != nil {
                    
                } else {
                    print("okok")
                    self.save(category: category, todoName: todoName, date: date)
                    
                    print("############")
                }
                
                print("okokok")
                self.dismiss(animated: true, completion: nil)
            }
            
            let cancelButton = UIAlertAction(title: "취소", style: .default, handler: nil)
            
            alert.addAction(cancelButton)
            alert.addAction(okButton)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func save(category: String, todoName: String, date: Date) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        managedContext.automaticallyMergesChangesFromParent = true
        
        guard let entity = NSEntityDescription.entity(forEntityName: "Todo", in: managedContext) else { return }
        let todo = NSManagedObject(entity: entity, insertInto: managedContext)
        
        todo.setValue(category, forKey: "categoryName")
        todo.setValue(todoName, forKey: "todoName")
        todo.setValue(date, forKey: "createDate")
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save at Todo. \(error), \(error.userInfo)")
        }
    }
}
