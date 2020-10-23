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
        self.layer.cornerRadius = 20
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.clear.cgColor
        self.layer.masksToBounds = true
        self.layer.backgroundColor = UIColor.white.cgColor
    }
    
}
