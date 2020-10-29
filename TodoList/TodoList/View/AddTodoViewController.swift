//
//  AddTodoViewController.swift
//  TodoList
//
//  Created by 김기현 on 2020/10/29.
//

import UIKit

class AddTodoViewController: UIViewController {
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var createButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func closeClick(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveClick(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    

}
