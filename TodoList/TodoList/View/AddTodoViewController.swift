//
//  AddTodoViewController.swift
//  TodoList
//
//  Created by 김기현 on 2020/10/29.
//

import UIKit
import CoreData
import SnapKit

class AddTodoViewController: UIViewController {
    private lazy var createButton: UIButton = {
        let button = UIButton()
        button.clipsToBounds = true
        button.setTitle("저장하기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(touchSave), for: .touchUpInside)
        return button
    }()
    private let todoTextField = UITextField()
    
    var categoryName: String?
    var viewModel: ViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        viewModel = ViewModel()
    }
    
    private func setup() {
        view.backgroundColor = .white
        view.addSubview(todoTextField)
        todoTextField.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(32)
            make.left.right.equalToSuperview().inset(64)
        }
        
        view.addSubview(createButton)
        createButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(64)
            make.bottom.equalToSuperview().offset(32)
            make.height.equalTo(56)
        }
    }
    
    @objc private func touchSave() {
        guard let todoName = todoTextField.text, let categoryName = categoryName else { return }
        let date = Date()
        
        if todoName == "" {
            cautionAlert()
        } else {
            saveAlert(categoryName: categoryName, todoName: todoName, date: date)
        }
    }
}

// MARK: - Alert
extension AddTodoViewController {
    private func cautionAlert() {
        let alert = UIAlertController(title: "오류", message: "할 일을 입력해주세요", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "확인", style: .default, handler: nil)
        
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    private func saveAlert(categoryName: String, todoName: String, date: Date) {
        let alert = UIAlertController(title: "저장", message: "저장하시겠습니까?", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "확인", style: .default) { _ in
            guard let viewModel = self.viewModel else { return }
            viewModel.saveData(entityName: "Todo", categoryName: categoryName, todoName: todoName, date: date)
            self.navigationController?.popViewController(animated: true)
        }
        let cancelButton = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alert.addAction(cancelButton)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
}
