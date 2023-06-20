//
//  CategoryViewController.swift
//  TodoList
//
//  Created by 김기현 on 2020/10/17.
//

import UIKit
import CoreData

class CategoryViewController: UIViewController {
    @IBOutlet private weak var categoryNameTextField: UITextField!
    
    var todoCateogry: TodoCategory?
    var viewModel: ViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel = ViewModel()
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
//                    self.save(name: category, date: date)
                    self.viewModel?.saveData(entityName: "TodoCategory", categoryName: category, date: date)
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
}
