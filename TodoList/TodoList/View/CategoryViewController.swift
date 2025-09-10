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
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "새 카테고리 추가"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .center
        label.textColor = .label
        return label
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .medium)
        let image = UIImage(systemName: "folder.badge.plus", withConfiguration: config)
        imageView.image = image
        imageView.tintColor = .systemBlue
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("닫기", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        return button
    }()
    
    private let saveButton: UIButton = {
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
    
    private let categoryNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "카테고리 이름을 입력하세요"
        textField.borderStyle = .none
        textField.font = .systemFont(ofSize: 16)
        textField.clearButtonMode = .whileEditing
        textField.backgroundColor = .tertiarySystemBackground
        textField.layer.cornerRadius = 8
        
        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 44))
        textField.leftView = leftPaddingView
        textField.leftViewMode = .always
        
        return textField
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "새로운 할 일 카테고리를 생성합니다"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    // MARK: - Properties
    var todoCateogry: TodoCategory?
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
        categoryNameTextField.becomeFirstResponder()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(containerView)
        containerView.addSubview(iconImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(closeButton)
        containerView.addSubview(saveButton)
        containerView.addSubview(categoryNameTextField)
        containerView.addSubview(descriptionLabel)
    }
    
    private func setupConstraints() {
        containerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(280)
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
        
        saveButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(48)
        }
        
        categoryNameTextField.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(48)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(categoryNameTextField.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(20)
        }
    }
    
    private func setupActions() {
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        
        // 실시간 텍스트 검증
        categoryNameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        // Keyboard dismiss
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Actions
    @objc private func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func saveButtonTapped() {
        guard let category = categoryNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !category.isEmpty else { return }
        
        // 저장 중 상태로 변경
        saveButton.isEnabled = false
        saveButton.setTitle("저장 중...", for: .normal)
        
        let date = Date()
        
        viewModel?.saveData(entityName: "TodoCategory", categoryName: category, date: date) { [weak self] success, errorMessage in
            DispatchQueue.main.async {
                if success {
                    // 성공 피드백
                    self?.showSuccessFeedback {
                        self?.dismiss(animated: true)
                    }
                } else {
                    // 에러 처리
                    self?.saveButton.isEnabled = true
                    self?.saveButton.setTitle("저장", for: .normal)
                    self?.showErrorAlert(message: errorMessage ?? "알 수 없는 오류가 발생했습니다.")
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
        let hasText = !(categoryNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        
        UIView.animate(withDuration: 0.2) {
            self.saveButton.isEnabled = hasText
            self.saveButton.alpha = hasText ? 1.0 : 0.6
        }
    }
    
    private func showSuccessFeedback(completion: @escaping () -> Void) {
        // 성공 아이콘으로 변경
        saveButton.setTitle("완료!", for: .normal)
        saveButton.backgroundColor = .systemGreen
        
        // 0.8초 후 완료
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            completion()
        }
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
