//
//  MainCollectionViewCell.swift
//  TodoList
//
//  Created by 김기현 on 2020/10/16.
//

import UIKit

class MainCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var taskLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        self.layer.cornerRadius = 20
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.clear.cgColor
        self.layer.masksToBounds = true
        
        self.contentView.layer.cornerRadius = 15
        self.contentView.layer.borderColor = UIColor.clear.cgColor
        self.contentView.layer.borderWidth = 1
        self.contentView.layer.backgroundColor = UIColor.white.cgColor
        self.contentView.layer.masksToBounds = true
        
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0.0)
        self.layer.shadowRadius = 6.0
        self.layer.shadowOpacity = 0.6
        self.layer.cornerRadius = 15.0
        self.layer.masksToBounds = false
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath
    }

}
