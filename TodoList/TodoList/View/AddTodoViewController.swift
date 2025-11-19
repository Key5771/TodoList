//
//  AddTodoViewController.swift
//  TodoList
//
//  Created by 김기현 on 2020/10/29.
//

import UIKit
import CoreData
import SnapKit
import WidgetKit

class AddTodoViewController: UIViewController {
    // MARK: - UI Components
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.backgroundColor = .systemGroupedBackground
        tableView.keyboardDismissMode = .onDrag
        return tableView
    }()
    
    private let todoTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "예: 프로젝트 완료하기, 운동하기"
        textField.font = .systemFont(ofSize: 17)
        textField.clearButtonMode = .whileEditing
        textField.backgroundColor = .clear
        return textField
    }()
    
    private let datePickerCell: UITableViewCell = {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.selectionStyle = .none
        cell.backgroundColor = .clear
        return cell
    }()
    
    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.minimumDate = Date()
        return picker
    }()
    
    // MARK: - Properties
    var categoryName: String?
    var viewModel: ViewModel?
    private var selectedDueDate: Date?
    
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
        todoTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }
    
    // MARK: - Setup Methods
    private func setupNavigationBar() {
        title = "새 할 일"
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
        todoTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        todoTextField.delegate = self
        
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        
        datePickerCell.contentView.addSubview(datePicker)
        datePicker.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(8)
            make.centerY.equalToSuperview()
        }
    }
    
    // MARK: - Actions
    @objc private func cancelButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func saveButtonTapped() {
        guard let todoName = todoTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !todoName.isEmpty,
              let categoryName = categoryName else { return }
        
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        let date = Date()
        
        viewModel?.saveData(entityName: "Todo", categoryName: categoryName, todoName: todoName, date: date, dueDate: selectedDueDate, isCompleted: false) { [weak self] success, errorMessage in
            DispatchQueue.main.async {
                if success {
                    // 위젯 새로고침
                    WidgetCenter.shared.reloadTimelines(ofKind: "TodoListWidget")
                    print("✅ Widget refreshed after adding todo")

                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                    self?.navigationController?.popViewController(animated: true)
                } else {
                    self?.navigationItem.rightBarButtonItem?.isEnabled = true
                    self?.showCautionAlert(message: errorMessage ?? "알 수 없는 오류가 발생했습니다.")
                }
            }
        }
    }
    
    @objc private func textFieldDidChange() {
        updateSaveButtonState()
    }
    
    @objc private func datePickerValueChanged() {
        selectedDueDate = datePicker.date
    }
    
    // MARK: - Helper Methods
    private func updateSaveButtonState() {
        let hasText = !(todoTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        navigationItem.rightBarButtonItem?.isEnabled = hasText
    }
}

// MARK: - UITableViewDataSource
extension AddTodoViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldCell", for: indexPath)
            cell.selectionStyle = .none
            
            todoTextField.removeFromSuperview()
            cell.contentView.addSubview(todoTextField)
            
            todoTextField.snp.makeConstraints { make in
                make.leading.equalToSuperview().offset(16)
                make.trailing.equalToSuperview().offset(-16)
                make.centerY.equalToSuperview()
            }
            
            return cell
        } else {
            return datePickerCell
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "할 일 내용"
        } else {
            return "마감일"
        }
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 {
            return nil
        } else {
            return "마감일을 설정하지 않으면 오늘로 설정됩니다"
        }
    }
}

// MARK: - UITableViewDelegate
extension AddTodoViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
}

// MARK: - UITextFieldDelegate
extension AddTodoViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if navigationItem.rightBarButtonItem?.isEnabled == true {
            saveButtonTapped()
        }
        return true
    }
}

// MARK: - Alert Methods
extension AddTodoViewController {
    private func showCautionAlert(message: String = "할 일을 입력해주세요") {
        let alert = UIAlertController(title: "오류", message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "확인", style: .default, handler: nil)
        
        alert.addAction(okButton)
        present(alert, animated: true, completion: nil)
    }
}
