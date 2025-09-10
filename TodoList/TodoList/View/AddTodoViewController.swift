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
    // MARK: - UI Components
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("닫기", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        return button
    }()
    
    private let createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("저장", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.white.withAlphaComponent(0.6), for: .disabled)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.layer.cornerRadius = 8
        button.isEnabled = false
        button.alpha = 0.6
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "새 할 일 추가"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .center
        label.textColor = .label
        return label
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .medium)
        let image = UIImage(systemName: "plus.circle", withConfiguration: config)
        imageView.image = image
        imageView.tintColor = .systemBlue
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let todoTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "할 일을 입력하세요"
        textField.borderStyle = .none
        textField.font = .systemFont(ofSize: 16)
        textField.clearButtonMode = .whileEditing
        textField.backgroundColor = .tertiarySystemBackground
        textField.layer.cornerRadius = 8
        
        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 48))
        textField.leftView = leftPaddingView
        textField.leftViewMode = .always
        
        return textField
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        return view
    }()
    
    // MARK: - Properties
    var categoryName: String?
    var viewModel: ViewModel?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
        viewModel = ViewModel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        todoTextField.becomeFirstResponder()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(containerView)
        containerView.addSubview(iconImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(closeButton)
        containerView.addSubview(createButton)
        containerView.addSubview(todoTextField)
    }
    
    private func setupConstraints() {
        containerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(240)
        }
        
        iconImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(50)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(iconImageView.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
        }
        
        closeButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(32)
        }
        
        createButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(48)
        }
        
        todoTextField.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(48)
        }
    }
    
    private func setupActions() {
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        createButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        
        // 실시간 텍스트 검증
        todoTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        // Keyboard dismiss
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Actions
    @objc private func closeButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func saveButtonTapped() {
        guard let todoName = todoTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !todoName.isEmpty,
              let categoryName = categoryName else { return }
        
        // 저장 중 상태로 변경
        createButton.isEnabled = false
        createButton.setTitle("저장 중...", for: .normal)
        
        let date = Date()
        
        viewModel?.saveData(entityName: "Todo", categoryName: categoryName, todoName: todoName, date: date, isCompleted: false) { [weak self] success, errorMessage in
            DispatchQueue.main.async {
                if success {
                    // 성공 피드백
                    self?.showSuccessFeedback {
                        self?.navigationController?.popViewController(animated: true)
                    }
                } else {
                    // 에러 처리
                    self?.createButton.isEnabled = true
                    self?.createButton.setTitle("저장", for: .normal)
                    self?.showCautionAlert(message: errorMessage ?? "알 수 없는 오류가 발생했습니다.")
                }
            }
        }
    }
    
    @objc private func textFieldDidChange() {
        updateSaveButtonState()
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Helper Methods
    private func updateSaveButtonState() {
        let hasText = !(todoTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        
        UIView.animate(withDuration: 0.2) {
            self.createButton.isEnabled = hasText
            self.createButton.alpha = hasText ? 1.0 : 0.6
        }
    }
    
    private func showSuccessFeedback(completion: @escaping () -> Void) {
        // 성공 아이콘으로 변경
        createButton.setTitle("완료!", for: .normal)
        createButton.backgroundColor = .systemGreen
        
        // 0.8초 후 완료
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            completion()
        }
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
