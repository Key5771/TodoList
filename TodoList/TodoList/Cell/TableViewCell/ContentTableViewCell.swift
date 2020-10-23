//
//  ContentTableViewCell.swift
//  TodoList
//
//  Created by 김기현 on 2020/10/23.
//

import UIKit

class ContentTableViewCell: UITableViewCell {
    @IBOutlet weak var todoLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
