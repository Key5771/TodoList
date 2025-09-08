//
//  ContentTableViewCell.swift
//  TodoList
//
//  Created by 김기현 on 2020/10/23.
//

import UIKit
import SnapKit

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
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        let image = UIImage(systemName: "circle", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .systemGray3
        button.isUserInteractionEnabled = false
        return button
    }()
    
    private var isCompleted: Bool = false {
        didSet {
            updateCompletionState()
        }
    }
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            animateSelection()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        todoLabel.text = nil
        isCompleted = false
        
        // 애니메이션 상태 초기화
        transform = .identity
        alpha = 1.0
    }
    
    // MARK: - Setup Methods
    private func setupCell() {
        backgroundColor = .clear
        selectionStyle = .none
        contentView.addSubview(todoLabel)
    }
    
    private func setupConstraints() {
        todoLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
        }
    }
    
    // MARK: - Public Methods
    func configure(with todoText: String, isCompleted: Bool = false, priority: TaskPriority = .normal) {
        todoLabel.text = todoText
        self.isCompleted = isCompleted
    }
    
    func toggleCompletion() {
        isCompleted.toggle()
        animateCompletionToggle()
    }
    
    // MARK: - Private Methods
    private func updateCompletionState() {
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        
        if isCompleted {
            let image = UIImage(systemName: "checkmark.circle.fill", withConfiguration: config)
            checkButton.setImage(image, for: .normal)
            checkButton.tintColor = .systemGreen
            
            todoLabel.textColor = .secondaryLabel
            todoLabel.attributedText = NSAttributedString(
                string: todoLabel.text ?? "",
                attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue]
            )
        } else {
            let image = UIImage(systemName: "circle", withConfiguration: config)
            checkButton.setImage(image, for: .normal)
            checkButton.tintColor = .systemGray3
            
            todoLabel.textColor = .label
            todoLabel.attributedText = NSAttributedString(string: todoLabel.text ?? "")
        }
    }
    
    private func animateSelection() {
        UIView.animate(withDuration: 0.1, animations: {
            self.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.transform = .identity
            }
        }
    }
    
    private func animateCompletionToggle() {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [.curveEaseInOut], animations: {
            self.checkButton.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                self.checkButton.transform = .identity
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
