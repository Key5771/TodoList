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
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "0 tasks"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .left
        return label
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .systemBackground
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.tableFooterView = UIView()
        tableView.contentInsetAdjustmentBehavior = .automatic
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
        
        // 아이콘 추가
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        let image = UIImage(systemName: "plus", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)
        button.tintColor = .white
        
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
    private var controller: NSFetchedResultsController<NSManagedObject>?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        setupConstraints()
        setupTableView()
        setupActions()
        loadData()
        controller?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // NavigationBar 표시하고 Large Title 비활성화 (상세 화면)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .never
        
        tableView.reloadData()
    }
    
    // MARK: - Setup Methods
    private func setupNavigationBar() {
        // Navigation Title을 카테고리 이름으로 설정 (개수 없이)
        title = categoryName ?? "할 일 목록"
        
        // Large Title 비활성화 (상세 화면이므로)
        navigationItem.largeTitleDisplayMode = .never
        
        // Back 버튼 커스터마이징 (기본 "Back" 텍스트 제거)
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(
            title: "",
            style: .plain,
            target: nil,
            action: nil
        )
        
        // 설정 버튼을 Navigation Bar 우측에 추가
        let settingButton = UIBarButtonItem(
            image: UIImage(systemName: "ellipsis.circle"),
            style: .plain,
            target: self,
            action: #selector(settingButtonTapped)
        )
        settingButton.tintColor = .systemBlue
        navigationItem.rightBarButtonItem = settingButton
        
        // Navigation Bar appearance 설정 (부모와 일관성 유지)
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        appearance.shadowColor = .clear
        
        // 일반 Title 폰트 설정
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.label,
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(subtitleLabel)
        view.addSubview(tableView)
        view.addSubview(createButton)
        
        view.addSubview(emptyStateView)
        emptyStateView.addSubview(emptyStateImageView)
        emptyStateView.addSubview(emptyStateLabel)
    }
    
    private func setupConstraints() {
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(16)
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
    }
    
    private func setupActions() {
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
    }
    
    private func updateEmptyState() {
        let isEmpty = taskCount == 0
        emptyStateView.isHidden = !isEmpty
        tableView.isHidden = isEmpty
        
        // Subtitle 업데이트
        updateSubtitle()
    }
    
    private func updateSubtitle() {
        // "5 tasks" 형태로 표시
        subtitleLabel.text = "\(taskCount) task\(taskCount != 1 ? "s" : "")"
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
    
    private func showDeleteCategoryAlert() {
        let alert = UIAlertController(
            title: "카테고리 삭제",
            message: "이 카테고리와 모든 할 일이 삭제됩니다. 계속하시겠습니까?",
            preferredStyle: .alert
        )
        
        let deleteAction = UIAlertAction(title: "삭제", style: .destructive) { _ in
            self.deleteCategory()
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    private func deleteCategory() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
              let categoryName = categoryName else { return }
        
        let context = appDelegate.persistentContainer.viewContext
        
        // 먼저 해당 카테고리의 모든 할 일 삭제
        let todoFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Todo")
        todoFetchRequest.predicate = NSPredicate(format: "categoryName == %@", categoryName)
        
        do {
            let todos = try context.fetch(todoFetchRequest)
            for todo in todos {
                context.delete(todo)
            }
        } catch {
            print("Error fetching todos for deletion: \(error)")
            return
        }
        
        // 카테고리 삭제
        let categoryFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "TodoCategory")
        categoryFetchRequest.predicate = NSPredicate(format: "categoryName == %@", categoryName)
        
        do {
            let categories = try context.fetch(categoryFetchRequest)
            for category in categories {
                context.delete(category)
            }
            
            try context.save()
            
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        } catch {
            print("Error deleting category: \(error)")
            showDeletionErrorAlert()
        }
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
        guard let sections = controller?.sections else {
            fatalError("No sections in fetchedResultsController at ContentViewController")
        }

        let sectionInfo = sections[section]
        taskCount = sectionInfo.numberOfObjects
        
        DispatchQueue.main.async {
            self.updateEmptyState()
        }
        
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "contentCell", for: indexPath) as? ContentTableViewCell else {
            return UITableViewCell()
        }
        
        if let content = controller?.object(at: indexPath) as? Todo {
            if content.categoryName == categoryName {
                cell.configure(with: content.todoName ?? "", isCompleted: false)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // 완료/미완료 토글 기능
        if let cell = tableView.cellForRow(at: indexPath) as? ContentTableViewCell {
            cell.toggleCompletion()
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            
            let context = appDelegate.persistentContainer.viewContext
            guard let todo = controller?.object(at: indexPath) else { return }
            
            do {
                context.delete(todo)
                try context.save()
            } catch let error as NSError {
                print("Could not Delete Todo. \(error), \(error.userInfo)")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension ContentViewController: NSFetchedResultsControllerDelegate {
    private func loadData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate, 
              let categoryName = categoryName else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        managedContext.automaticallyMergesChangesFromParent = true
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Todo")
        fetchRequest.predicate = NSPredicate(format: "categoryName == %@", categoryName)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createDate", ascending: false)]
        
        controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: managedContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        controller?.delegate = self
        
        do {
            try controller?.performFetch()
        } catch let error as NSError {
            print("Could not Content Fetch. \(error), \(error.userInfo)")
        }
    }
    
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
