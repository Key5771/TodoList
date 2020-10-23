//
//  ContentTableViewFooter.swift
//  TodoList
//
//  Created by 김기현 on 2020/10/23.
//

import UIKit

class ContentTableViewFooter: UITableViewHeaderFooterView {
    @IBOutlet weak var createTodoButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        self.createTodoButton.layer.cornerRadius = 20
        self.createTodoButton.layer.borderWidth = 1
        self.createTodoButton.layer.borderColor = UIColor.clear.cgColor
        self.createTodoButton.layer.masksToBounds = true
        self.createTodoButton.layer.backgroundColor = UIColor.white.cgColor
    }
    
}
