//
//  ContentTableViewCell.swift
//  TodoList
//
//  Created by 김기현 on 2020/10/23.
//

import UIKit
import SnapKit

class ContentTableViewCell: UITableViewCell {
    static let identifier = "ContentTableViewCell"
    
    private let todoLabel = UILabel()
    private let leftView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        contentView.addSubview(leftView)
        leftView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(16)
            make.width.equalTo(24)
            make.height.equalTo(2)
        }
        
        contentView.addSubview(todoLabel)
        todoLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(leftView.snp.right).offset(16)
            make.right.equalToSuperview().inset(16)
        }
    }
    
    func configure(with item: Todo) {
        todoLabel.font = UIFont.boldSystemFont(ofSize: 14)
        todoLabel.text = item.todoName
    }
}
