//
//  ContentTableViewCell.swift
//  TodoList
//
//  Created by 김기현 on 2020/10/23.
//

import UIKit
import SnapKit
import CoreData

protocol ContentTableViewCellDelegate: AnyObject {
    func didToggleCompletion(for cell: ContentTableViewCell)
}

class ContentTableViewCell: UITableViewCell {
    // MARK: - UI Components
    let todoLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private let checkButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
        let image = UIImage(systemName: "circle", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .systemGray3
        return button
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .tertiaryLabel
        label.numberOfLines = 1
        return label
    }()
    
    // MARK: - Properties
    weak var delegate: ContentTableViewCellDelegate?
    private var isCompleted: Bool = false {
        didSet {
            updateCompletionState()
        }
    }
    
    private var todo: Todo?
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
        setupConstraints()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // 선택 시에는 아무 액션하지 않음 (체크박스 터치로만 완료 상태 변경)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        todoLabel.attributedText = nil
        dateLabel.text = nil
        isCompleted = false
        todo = nil
        
        // 애니메이션 상태 초기화
        transform = .identity
        alpha = 1.0
    }
    
    // MARK: - Setup Methods
    private func setupCell() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(todoLabel)
        contentView.addSubview(checkButton)
        contentView.addSubview(dateLabel)
    }
    
    private func setupConstraints() {
        checkButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(30)
        }
        
        todoLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.trailing.equalTo(checkButton.snp.leading).offset(-12)
            make.top.equalToSuperview().inset(8)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.leading.equalTo(todoLabel)
            make.trailing.equalTo(checkButton.snp.leading).offset(-12)
            make.top.equalTo(todoLabel.snp.bottom).offset(2)
            make.bottom.equalToSuperview().inset(8)
        }
    }
    
    private func setupActions() {
        checkButton.addTarget(self, action: #selector(checkButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Public Methods
    func configure(with todo: Todo) {
        self.todo = todo
        
        // 먼저 plain text로 설정 (취소선 제거)
        let todoText = todo.todoName ?? "Untitled Task"
        todoLabel.attributedText = NSAttributedString(string: todoText)
        
        isCompleted = todo.isCompleted
        
        // 날짜 표시
        if let createDate = todo.createDate {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            dateLabel.text = "Created: \(formatter.string(from: createDate))"
        } else {
            dateLabel.text = ""
        }
        
        updateCompletionState()
    }
    
    @available(*, deprecated, message: "Use configure(with: Todo) instead")
    func configure(with todoText: String, isCompleted: Bool = false, priority: TaskPriority = .normal) {
        todoLabel.text = todoText
        self.isCompleted = isCompleted
        dateLabel.text = ""
    }
    
    // MARK: - Private Methods
    @objc private func checkButtonTapped() {
        // 애니메이션 효과
        animateCheckButton()
        
        // 완료 상태 토글
        isCompleted.toggle()
        
        // Core Data 업데이트
        if let todo = todo {
            todo.isCompleted = isCompleted
            todo.completedDate = isCompleted ? Date() : nil
        }
        
        // Delegate에 변경사항 알림
        delegate?.didToggleCompletion(for: self)
    }
    
    private func updateCompletionState() {
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
        
        if isCompleted {
            // 완료 상태
            let image = UIImage(systemName: "checkmark.circle.fill", withConfiguration: config)
            checkButton.setImage(image, for: .normal)
            checkButton.tintColor = .systemGreen
            
            // 텍스트 스타일링
            todoLabel.textColor = .secondaryLabel
            dateLabel.textColor = .quaternaryLabel
            
            // 취소선 적용
            if let currentText = todoLabel.attributedText?.string {
                let attributedText = NSMutableAttributedString(string: currentText)
                attributedText.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: attributedText.length))
                todoLabel.attributedText = attributedText
            }
            
        } else {
            // 미완료 상태
            let image = UIImage(systemName: "circle", withConfiguration: config)
            checkButton.setImage(image, for: .normal)
            checkButton.tintColor = .systemGray3
            
            // 텍스트 스타일링
            todoLabel.textColor = .label
            dateLabel.textColor = .tertiaryLabel
            
            // 취소선 제거 - 현재 텍스트를 가져와서 새로운 plain AttributedString 생성
            if let currentText = todoLabel.attributedText?.string {
                todoLabel.attributedText = NSAttributedString(string: currentText)
            }
        }
    }
    
    private func animateCheckButton() {
        UIView.animate(withDuration: 0.1, animations: {
            self.checkButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: [.curveEaseInOut], animations: {
                self.checkButton.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            }) { _ in
                UIView.animate(withDuration: 0.2) {
                    self.checkButton.transform = .identity
                }
            }
        }
    }
    
    func animateAppearance(delay: TimeInterval = 0) {
        alpha = 0
        transform = CGAffineTransform(translationX: -50, y: 0)
        
        UIView.animate(withDuration: 0.5, delay: delay, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [.curveEaseInOut], animations: {
            self.alpha = 1
            self.transform = .identity
        })
    }
    
    // MARK: - Getters
    var currentTodo: Todo? {
        return todo
    }
}

// MARK: - Task Priority Enum
enum TaskPriority {
    case high
    case medium
    case normal
}

// MARK: - Legacy Support for XIB-based code
extension ContentTableViewCell {
    // XIB에서 사용하던 메서드들을 지원하기 위한 호환성 extension
    var todoText: String? {
        get { todoLabel.text }
        set { todoLabel.text = newValue }
    }
}
