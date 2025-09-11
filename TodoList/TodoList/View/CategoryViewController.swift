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
    // MARK: - UI Components
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.backgroundColor = .systemGroupedBackground
        tableView.keyboardDismissMode = .onDrag
        return tableView
    }()
    
    private let categoryNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "예: 업무, 개인, 공부"
        textField.font = .systemFont(ofSize: 17)
        textField.clearButtonMode = .whileEditing
        textField.backgroundColor = .clear
        return textField
    }()
    
    // MARK: - Properties
    var todoCateogry: TodoCategory?
    var viewModel: ViewModel?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableView()
        setupActions()
        viewModel = ViewModel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        categoryNameTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }
    
    // MARK: - Setup Methods
    private func setupNavigationBar() {
        title = "새 카테고리"
        navigationController?.navigationBar.prefersLargeTitles = false
        
        let cancelButton = UIBarButtonItem(
            title: "취소",
            style: .plain,
            target: self,
            action: #selector(cancelButtonTapped)
        )
        navigationItem.leftBarButtonItem = cancelButton
        
        let saveButton = UIBarButtonItem(
            title: "저장",
            style: .done,
            target: self,
            action: #selector(saveButtonTapped)
        )
        saveButton.isEnabled = false
        navigationItem.rightBarButtonItem = saveButton
    }
    
    private func setupTableView() {
        view.backgroundColor = .systemGroupedBackground
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TextFieldCell")
    }
    
    private func setupActions() {
        categoryNameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        categoryNameTextField.delegate = self
    }
    
    // MARK: - Actions
    @objc private func cancelButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func saveButtonTapped() {
        guard let category = categoryNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !category.isEmpty else { return }
        
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        let date = Date()
        
        viewModel?.saveData(entityName: "TodoCategory", categoryName: category, date: date, dueDate: nil) { [weak self] success, errorMessage in
            DispatchQueue.main.async {
                if success {
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                    self?.navigationController?.popViewController(animated: true)
                } else {
                    self?.navigationItem.rightBarButtonItem?.isEnabled = true
                    self?.showErrorAlert(message: errorMessage ?? "알 수 없는 오류가 발생했습니다.")
                }
            }
        }
    }
    
    @objc private func textFieldDidChange() {
        updateSaveButtonState()
    }
    
    // MARK: - Helper Methods
    private func updateSaveButtonState() {
        let hasText = !(categoryNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        navigationItem.rightBarButtonItem?.isEnabled = hasText
    }
}

// MARK: - UITableViewDataSource
extension CategoryViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldCell", for: indexPath)
        cell.selectionStyle = .none
        
        categoryNameTextField.removeFromSuperview()
        cell.contentView.addSubview(categoryNameTextField)
        
        categoryNameTextField.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "카테고리 이름"
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "할 일을 분류할 새로운 카테고리를 만들어보세요"
    }
}

// MARK: - UITableViewDelegate
extension CategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
}

// MARK: - UITextFieldDelegate
extension CategoryViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if navigationItem.rightBarButtonItem?.isEnabled == true {
            saveButtonTapped()
        }
        return true
    }
}

// MARK: - Alert Methods
extension CategoryViewController {
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "오류", message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "확인", style: .default, handler: nil)
        alert.addAction(okButton)
        present(alert, animated: true, completion: nil)
    }
}
