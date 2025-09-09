//
//  ContentViewController.swift
//  TodoList
//
//  Created by 김기현 on 2020/10/22.
//

import UIKit
import CoreData
import SnapKit

class ContentViewController: UIViewController {
    // MARK: - UI Components
    private let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        return view
    }()
    
    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .label
        label.numberOfLines = 1
        return label
    }()
    
    private let taskLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .secondaryLabel
        label.text = "0 task"
        return label
    }()
    
    private let settingButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        let image = UIImage(systemName: "ellipsis.circle", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .systemBlue
        return button
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .systemBackground
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.tableFooterView = UIView()
        return tableView
    }()
    
    private let createButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .systemBlue
        button.setTitle("새 할 일 추가", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.layer.cornerRadius = 25
        button.layer.shadowColor = UIColor.systemBlue.cgColor
        button.layer.shadowOpacity = 0.3
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 8
        return button
    }()
    
    private let emptyStateView: UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()
    
    private let emptyStateImageView: UIImageView = {
        let imageView = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 60, weight: .light)
        let image = UIImage(systemName: "checklist", withConfiguration: config)
        imageView.image = image
        imageView.tintColor = .tertiaryLabel
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "아직 할 일이 없습니다\n새로운 할 일을 추가해보세요"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .tertiaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    // MARK: - Properties
    var categoryName: String?
    private var taskCount: Int = 0
    private var viewModel: ContentViewModel!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = ContentViewModel(categoryName: categoryName)
        viewModel.delegate = self
        setupUI()
        setupConstraints()
        setupTableView()
        setupActions()
        setupSwipeGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadData()
        categoryLabel.text = categoryName
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(headerView)
        headerView.addSubview(categoryLabel)
        headerView.addSubview(taskLabel)
        headerView.addSubview(settingButton)
        
        view.addSubview(tableView)
        view.addSubview(createButton)
        
        view.addSubview(emptyStateView)
        emptyStateView.addSubview(emptyStateImageView)
        emptyStateView.addSubview(emptyStateLabel)
    }
    
    private func setupConstraints() {
        headerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(80)
        }
        
        categoryLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalTo(settingButton.snp.leading).offset(-8)
        }
        
        taskLabel.snp.makeConstraints { make in
            make.top.equalTo(categoryLabel.snp.bottom).offset(4)
            make.leading.equalToSuperview().offset(16)
        }
        
        settingButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.width.height.equalTo(32)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(createButton.snp.top).offset(-16)
        }
        
        createButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            make.height.equalTo(50)
        }
        
        emptyStateView.snp.makeConstraints { make in
            make.center.equalTo(tableView)
            make.leading.trailing.equalToSuperview().inset(40)
        }
        
        emptyStateImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.height.equalTo(80)
        }
        
        emptyStateLabel.snp.makeConstraints { make in
            make.top.equalTo(emptyStateImageView.snp.bottom).offset(16)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ContentTableViewCell.self, forCellReuseIdentifier: "contentCell")
        viewModel.getFetchedResultsController()?.delegate = self
    }
    
    private func setupActions() {
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        settingButton.addTarget(self, action: #selector(settingButtonTapped), for: .touchUpInside)
    }
    
    private func setupSwipeGesture() {
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeGesture.direction = .right
        view.addGestureRecognizer(swipeGesture)
    }
    
    private func updateEmptyState() {
        let isEmpty = taskCount == 0
        emptyStateView.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }
    
    // MARK: - Actions
    @objc private func createButtonTapped() {
        let addTodoVC = AddTodoViewController()
        addTodoVC.categoryName = categoryName
        navigationController?.pushViewController(addTodoVC, animated: true)
    }
    
    @objc private func settingButtonTapped() {
        let alert = UIAlertController(title: "카테고리 설정", message: "작업을 선택하세요", preferredStyle: .actionSheet)
        
        let deleteButton = UIAlertAction(title: "삭제", style: .destructive) { _ in
            self.showDeleteCategoryAlert()
        }
        let cancelButton = UIAlertAction(title: "취소", style: .cancel, handler: nil)

        alert.addAction(deleteButton)
        alert.addAction(cancelButton)
        present(alert, animated: true, completion: nil)
    }
    
    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .right {
            navigationController?.popViewController(animated: true)
        }
    }
    
    private func showDeleteCategoryAlert() {
        let alert = UIAlertController(
            title: "카테고리 삭제",
            message: "이 카테고리와 모든 할 일이 삭제됩니다. 계속하시겠습니까?",
            preferredStyle: .alert
        )
        
        let deleteAction = UIAlertAction(title: "삭제", style: .destructive) { _ in
            self.viewModel.deleteCategory()
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    private func showDeletionErrorAlert() {
        let alert = UIAlertController(
            title: "삭제 실패",
            message: "카테고리 삭제 중 오류가 발생했습니다. 다시 시도해주세요.",
            preferredStyle: .alert
        )
        
        let confirmAction = UIAlertAction(title: "확인", style: .default, handler: nil)
        
        alert.addAction(confirmAction)
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDelegate & DataSource
extension ContentViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = viewModel.getFetchedResultsController()?.sections else {
            fatalError("No sections in fetchedResultsController at ContentViewController")
        }

        let sectionInfo = sections[section]
        taskCount = sectionInfo.numberOfObjects
        
        DispatchQueue.main.async {
            self.taskLabel.text = "\(self.taskCount) task\(self.taskCount != 1 ? "s" : "")"
            self.updateEmptyState()
        }
        
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contentCell", for: indexPath)
        
        if let content = viewModel.getFetchedResultsController()?.object(at: indexPath) as? Todo {
            if content.categoryName == categoryName {
                cell.textLabel?.text = content.todoName
                cell.textLabel?.font = .systemFont(ofSize: 16)
                cell.textLabel?.textColor = .label
                cell.selectionStyle = .none
                
                // 체크마크 아이콘 추가
                let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
                let checkImage = UIImage(systemName: "circle", withConfiguration: config)
                let checkImageView = UIImageView(image: checkImage)
                checkImageView.tintColor = .systemGray3
                cell.accessoryView = checkImageView
            } else {
                cell.textLabel?.text = ""
                cell.accessoryView = nil
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // TODO: 할 일 완료/미완료 토글 기능 구현
        if let cell = tableView.cellForRow(at: indexPath),
           let accessoryView = cell.accessoryView as? UIImageView {
            
            let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
            let isCompleted = accessoryView.image == UIImage(systemName: "checkmark.circle.fill", withConfiguration: config)
            
            if isCompleted {
                accessoryView.image = UIImage(systemName: "circle", withConfiguration: config)
                accessoryView.tintColor = .systemGray3
            } else {
                accessoryView.image = UIImage(systemName: "checkmark.circle.fill", withConfiguration: config)
                accessoryView.tintColor = .systemGreen
            }
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if viewModel.deleteTodo(at: indexPath) {
                viewModel.loadData()
                tableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension ContentViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, 
                   didChange anObject: Any, 
                   at indexPath: IndexPath?, 
                   for type: NSFetchedResultsChangeType, 
                   newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .fade)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        case .move:
            if let indexPath = indexPath, let newIndexPath = newIndexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
                tableView.insertRows(at: [newIndexPath], with: .fade)
            }
        case .update:
            if let indexPath = indexPath {
                tableView.reloadRows(at: [indexPath], with: .fade)
            }
        @unknown default:
            if let indexPath = indexPath {
                tableView.reloadRows(at: [indexPath], with: .fade)
            }
        }
    }
}

// MARK: - ContentViewModelDelegate
extension ContentViewController: ContentViewModelDelegate {
    func didDeleteCategorySuccessfully() {
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func didFailToDeleteCategory(error: String) {
        DispatchQueue.main.async {
            self.showDeletionErrorAlert()
        }
    }
    
    func didUpdateTaskCount(_ count: Int) {
        DispatchQueue.main.async {
            self.taskCount = count
            self.taskLabel.text = "\(count) task\(count != 1 ? "s" : "")"
            self.updateEmptyState()
        }
    }
}
