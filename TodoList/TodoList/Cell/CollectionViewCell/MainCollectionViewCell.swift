//
//  MainCollectionViewCell.swift
//  TodoList
//
//  Created by 김기현 on 2020/10/16.
//

import UIKit
import SnapKit

class MainCollectionViewCell: UICollectionViewCell {
    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 20
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.15
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 12
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .medium)
        let image = UIImage(systemName: "folder.fill", withConfiguration: config)
        imageView.image = image
        imageView.tintColor = .systemBlue
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        return label
    }()
    
    let taskLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()
    
    private let gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor.systemBlue.withAlphaComponent(0.1).cgColor,
            UIColor.systemBlue.withAlphaComponent(0.05).cgColor
        ]
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 1, y: 1)
        return layer
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = containerView.bounds
        gradientLayer.cornerRadius = containerView.layer.cornerRadius
        
        // 셀 선택 효과 업데이트
        updateSelectionState()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        taskLabel.text = nil
        
        // 애니메이션 상태 초기화
        transform = .identity
        alpha = 1.0
    }
    
    // MARK: - Setup Methods
    private func setupCell() {
        contentView.addSubview(containerView)
        containerView.layer.insertSublayer(gradientLayer, at: 0)
        
        containerView.addSubview(iconImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(taskLabel)
        
        // 터치 애니메이션 설정
        setupTouchAnimation()
    }
    
    private func setupConstraints() {
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(4)
        }
        
        iconImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(36)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(iconImageView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(12)
        }
        
        taskLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(12)
            make.bottom.lessThanOrEqualToSuperview().offset(-16)
        }
    }
    
    private func setupTouchAnimation() {
        // 터치 시작 시 애니메이션
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGesture.minimumPressDuration = 0
        longPressGesture.cancelsTouchesInView = false
        addGestureRecognizer(longPressGesture)
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            animateTouchDown()
        case .ended, .cancelled:
            animateTouchUp()
        default:
            break
        }
    }
    
    private func animateTouchDown() {
        UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseInOut], animations: {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            self.containerView.layer.shadowOpacity = 0.25
        })
    }
    
    private func animateTouchUp() {
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut], animations: {
            self.transform = .identity
            self.containerView.layer.shadowOpacity = 0.15
        })
    }
    
    private func updateSelectionState() {
        if isSelected {
            containerView.layer.borderWidth = 2
            containerView.layer.borderColor = UIColor.systemBlue.cgColor
            iconImageView.tintColor = .systemBlue
        } else {
            containerView.layer.borderWidth = 0
            containerView.layer.borderColor = UIColor.clear.cgColor
            iconImageView.tintColor = .systemBlue
        }
    }
    
    // MARK: - Public Methods
    func configure(with category: CategoryModel) {
        titleLabel.text = category.categoryName
        
        if let date = category.createDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy.MM.dd"
            taskLabel.text = "생성일: \(dateFormatter.string(from: date))"
        } else {
            taskLabel.text = "새 카테고리"
        }
        
        // 카테고리별 아이콘 색상 다양화
        let colors: [UIColor] = [.systemBlue, .systemGreen, .systemOrange, .systemRed, .systemPurple, .systemTeal]
        let randomColor = colors.randomElement() ?? .systemBlue
        iconImageView.tintColor = randomColor
        
        // 그라데이션 색상도 동일하게 맞춤
        gradientLayer.colors = [
            randomColor.withAlphaComponent(0.1).cgColor,
            randomColor.withAlphaComponent(0.05).cgColor
        ]
    }
    
    func updateTaskCount(_ count: Int) {
        taskLabel.text = "\(count) task\(count != 1 ? "s" : "")"
    }
    
    // MARK: - Animation Methods
    func animateAppearance() {
        alpha = 0
        transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [.curveEaseInOut], animations: {
            self.alpha = 1
            self.transform = .identity
        })
    }
}

// MARK: - Legacy Support
extension MainCollectionViewCell {
    func setupDataFromCategoryModel(categoryModel: CategoryModel) {
        configure(with: categoryModel)
    }
}
