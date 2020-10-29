//
//  AddTodoViewController.swift
//  TodoList
//
//  Created by 김기현 on 2020/10/29.
//

import UIKit
import CoreData

class AddTodoViewController: UIViewController {
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var todoTextField: UITextField!
    
    var categoryName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func closeClick(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveClick(_ sender: Any) {
        guard let todoName = todoTextField.text, let categoryName = categoryName else { return }
        let date = Date()
        
        if todoName == "" {
            cautionAlert()
        } else {
            saveAlert(categoryName: categoryName, todoName: todoName, date: date)
        }
    }
    
    private func saveData(categoryName: String, todoName: String, date: Date) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        managedContext.automaticallyMergesChangesFromParent = true
        
        guard let entity = NSEntityDescription.entity(forEntityName: "Todo", in: managedContext) else { return }
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
    
    private func cautionAlert() {
        let alert = UIAlertController(title: "오류", message: "할 일을 입력해주세요", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "확인", style: .default, handler: nil)
        
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    private func saveAlert(categoryName: String, todoName: String, date: Date) {
        let alert = UIAlertController(title: "저장", message: "저장하시겠습니까?", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "확인", style: .default) { _ in
            self.saveData(categoryName: categoryName, todoName: todoName, date: date)
            self.navigationController?.popViewController(animated: true)
        }
        let cancelButton = UIAlertAction(title: "취소", style: .default, handler: nil)
        
        alert.addAction(cancelButton)
        alert.addAction(okButton)
        
        self.present(alert, animated: true, completion: nil)
    }
}
