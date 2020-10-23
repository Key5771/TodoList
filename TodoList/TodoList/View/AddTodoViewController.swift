//
//  AddTodoViewController.swift
//  TodoList
//
//  Created by 김기현 on 2020/10/23.
//

import UIKit

class AddTodoViewController: UIViewController {
    var category: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }

    @IBAction func closeClick(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveClick(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
