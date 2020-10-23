//
//  ContentViewController.swift
//  TodoList
//
//  Created by 김기현 on 2020/10/22.
//

import UIKit

class ContentViewController: UIViewController {
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet var swipeGesture: UISwipeGestureRecognizer!
    
    var categoryName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        categoryLabel.text = categoryName
    }

    @IBAction func leftSwipe(_ sender: Any) {
        if swipeGesture.direction == .right {
            self.navigationController?.popViewController(animated: true)
        }
    }

}
