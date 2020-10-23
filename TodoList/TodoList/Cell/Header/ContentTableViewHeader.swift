//
//  ContentTableViewHeader.swift
//  TodoList
//
//  Created by 김기현 on 2020/10/23.
//

import UIKit

class ContentTableViewHeader: UITableViewHeaderFooterView {
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var taskLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        self.layer.backgroundColor = UIColor.clear.cgColor
    }
}
