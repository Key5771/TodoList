//
//  CategoryViewController.swift
//  TodoList
//
//  Created by 김기현 on 2020/10/17.
//

import UIKit
import CoreData
import SnapKit

class CategoryViewController: UIViewController {
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "close"), for: .normal)
        button.addTarget(self, action: #selector(touchClose), for: .touchUpInside)
        return button
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "check"), for: .normal)
        button.addTarget(self, action: #selector(touchSave), for: .touchUpInside)
        return button
    }()
    
    private let categoryTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Category"
        textField.addLeftPadding()
        textField.layer.cornerRadius = 8
        textField.layer.borderColor = UIColor.gray.cgColor
        textField.layer.borderWidth = 1
        return textField
    }()
    
    var todoCateogry: TodoCategory?
    var viewModel: ViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        viewModel = ViewModel()
        setup()
    }
    
    private func setup() {
        view.addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.top.left.equalTo(view.safeAreaLayoutGuide).inset(24)
            make.width.height.equalTo(24)
        }
        
        view.addSubview(saveButton)
        saveButton.snp.makeConstraints { make in
            make.top.right.equalTo(view.safeAreaLayoutGuide).inset(24)
            make.width.height.equalTo(24)
        }
        
        view.addSubview(categoryTextField)
        categoryTextField.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.right.equalToSuperview().inset(12)
            make.height.equalTo(44)
        }
    }
    
    @objc private func touchClose() {
        self.dismiss(animated: true)
    }
    
    @objc private func touchSave() {
        guard let category = categoryTextField.text else { return }
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
