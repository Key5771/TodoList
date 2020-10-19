//
//  CategoryViewController.swift
//  TodoList
//
//  Created by 김기현 on 2020/10/17.
//

import UIKit
import CoreData

class CategoryViewController: UIViewController {
    @IBOutlet weak var categoryNameTextField: UITextField!
    
    var todoCateogry: TodoCategory?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func closeButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButton(_ sender: Any) {
        guard let category = categoryNameTextField.text else { return }
        let date = Date()
        
        if category == "" {
            let alert = UIAlertController(title: "오류", message: "카테고리를 입력해주세요.", preferredStyle: .alert)
            let okButton = UIAlertAction(title: "확인", style: .default, handler: nil)
            alert.addAction(okButton)
            present(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "저장", message: "저장하시겠습니까?", preferredStyle: .alert)
            let okButton = UIAlertAction(title: "확인", style: .default) { (_) in
                if self.todoCateogry != nil {
                    
                } else {
                    self.save(name: category, date: date)
                }
                self.dismiss(animated: true, completion: nil)
            }
            
            let cancelButton = UIAlertAction(title: "취소", style: .default, handler: nil)
            
            alert.addAction(cancelButton)
            alert.addAction(okButton)
            present(alert, animated: true, completion: nil)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    private func save(name: String, date: Date) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        managedContext.automaticallyMergesChangesFromParent = true
        
        guard let entity = NSEntityDescription.entity(forEntityName: "TodoCategory", in: managedContext) else { return }
        let category = NSManagedObject(entity: entity, insertInto: managedContext)
        
        category.setValue(name, forKey: "name")
        category.setValue(date, forKey: "createDate")
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
