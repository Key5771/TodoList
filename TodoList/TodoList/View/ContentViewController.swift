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
    
    // MARK: - Section Enum
    private enum Section: Int, CaseIterable {
        case pending = 0
        case completed = 1
        
        var title: String {
            switch self {
            case .pending: return "할 일"
            case .completed: return "완료된 일"
            }
        }
        
        var headerHeight: CGFloat {
            switch self {
            case .pending: return 40
            case .completed: return 40
            }
        }
    }
    
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
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = .systemGroupedBackground
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.contentInsetAdjustmentBehavior = .automatic
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.estimatedSectionHeaderHeight = 40
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
    private var pendingTodos: [Todo] = []
    private var completedTodos: [Todo] = []
    private var totalTaskCount: Int = 0
    private var controller: NSFetchedResultsController<Todo>?
    private var pendingUpdates: [() -> Void] = []
    
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
        
        loadData()
        tableView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // 화면을 벗어날 때 확실히 저장
        saveContext()
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
        view.backgroundColor = .systemGroupedBackground
        
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
        
        // 섹션 헤더/푸터 설정
        tableView.sectionFooterHeight = 0
    }
    
    private func setupActions() {
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
    }
    
    private func updateEmptyState() {
        let isEmpty = totalTaskCount == 0
        emptyStateView.isHidden = !isEmpty
        tableView.isHidden = isEmpty
        
        // Subtitle 업데이트
        updateSubtitle()
    }
    
    private func updateSubtitle() {
        // "2 pending, 3 completed" 형태로 표시
        let pendingCount = pendingTodos.count
        let completedCount = completedTodos.count
        
        if totalTaskCount == 0 {
            subtitleLabel.text = "No tasks"
        } else if completedCount == 0 {
            subtitleLabel.text = "\(pendingCount) task\(pendingCount != 1 ? "s" : "")"
        } else if pendingCount == 0 {
            subtitleLabel.text = "\(completedCount) completed"
        } else {
            subtitleLabel.text = "\(pendingCount) pending, \(completedCount) completed"
        }
    }
    
    private func organizeTodos() {
        guard let controller = controller,
              let fetchedObjects = controller.fetchedObjects else {
            pendingTodos = []
            completedTodos = []
            totalTaskCount = 0
            return
        }
        
        // 완료 상태에 따라 분류
        pendingTodos = fetchedObjects.filter { !$0.isCompleted }
        completedTodos = fetchedObjects.filter { $0.isCompleted }
        totalTaskCount = fetchedObjects.count
        
        // 정렬 (pending: 최신순, completed: 완료일 역순)
        pendingTodos.sort { (todo1, todo2) in
            guard let date1 = todo1.createDate, let date2 = todo2.createDate else {
                return false
            }
            return date1 > date2
        }
        
        completedTodos.sort { (todo1, todo2) in
            guard let date1 = todo1.completedDate, let date2 = todo2.completedDate else {
                return false
            }
            return date1 > date2
        }
    }
    
    private func saveContext() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let context = appDelegate.persistentContainer.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
                print("✅ Context saved successfully")
            } catch let error as NSError {
                print("❌ Could not save context: \(error), \(error.userInfo)")
            }
        }
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionType = Section(rawValue: section) else { return 0 }
        
        switch sectionType {
        case .pending:
            return pendingTodos.count
        case .completed:
            return completedTodos.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "contentCell", for: indexPath) as? ContentTableViewCell,
              let sectionType = Section(rawValue: indexPath.section) else {
            return UITableViewCell()
        }
        
        let todo: Todo
        switch sectionType {
        case .pending:
            todo = pendingTodos[indexPath.row]
        case .completed:
            todo = completedTodos[indexPath.row]
        }
        
        cell.delegate = self
        cell.configure(with: todo)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let sectionType = Section(rawValue: section) else { return nil }
        
        let count: Int
        switch sectionType {
        case .pending:
            count = pendingTodos.count
        case .completed:
            count = completedTodos.count
        }
        
        // 해당 섹션에 데이터가 없으면 헤더를 표시하지 않음
        if count == 0 {
            return nil
        }
        
        let headerView = UIView()
        headerView.backgroundColor = .systemGroupedBackground
        
        let titleLabel = UILabel()
        titleLabel.text = "\(sectionType.title) (\(count))"
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .label
        
        headerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let sectionType = Section(rawValue: section) else { return 0 }
        
        let count: Int
        switch sectionType {
        case .pending:
            count = pendingTodos.count
        case .completed:
            count = completedTodos.count
        }
        
        // 해당 섹션에 데이터가 없으면 헤더 높이를 0으로 설정
        if count == 0 {
            return 0
        }
        
        return sectionType.headerHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // 행 선택 시 아무 작업하지 않음 (체크박스만 사용)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
                  let sectionType = Section(rawValue: indexPath.section) else { return }
            
            let context = appDelegate.persistentContainer.viewContext
            
            let todo: Todo
            switch sectionType {
            case .pending:
                todo = pendingTodos[indexPath.row]
            case .completed:
                todo = completedTodos[indexPath.row]
            }
            
            do {
                context.delete(todo)
                try context.save()
            } catch let error as NSError {
                print("Could not Delete Todo. \(error), \(error.userInfo)")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70 // 날짜 라벨을 위해 높이 증가
    }
}

// MARK: - ContentTableViewCellDelegate
extension ContentViewController: ContentTableViewCellDelegate {
    func didToggleCompletion(for cell: ContentTableViewCell) {
        // 즉시 Core Data에 저장
        saveContext()
        
        // UI 업데이트
        DispatchQueue.main.async {
            self.organizeTodos()
            self.updateEmptyState()
            
            // 애니메이션과 함께 테이블 뷰 리로드
            self.tableView.reloadSections(IndexSet([0, 1]), with: .fade)
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension ContentViewController: NSFetchedResultsControllerDelegate {
    private func loadData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate, 
              let categoryName = categoryName else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        managedContext.automaticallyMergesChangesFromParent = true
        
        let fetchRequest = NSFetchRequest<Todo>(entityName: "Todo")
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
            organizeTodos()
            updateEmptyState()
        } catch let error as NSError {
            print("Could not Content Fetch. \(error), \(error.userInfo)")
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        pendingUpdates.removeAll()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .update:
            let todo = anObject as! Todo
            
            let oldPendingTodos = pendingTodos
            let oldCompletedTodos = completedTodos
            organizeTodos()
            
            var oldIndexPath: IndexPath?
            var newIndexPath: IndexPath?
            
            if let oldIndex = oldPendingTodos.firstIndex(of: todo) {
                oldIndexPath = IndexPath(row: oldIndex, section: 0)
            } else if let oldIndex = oldCompletedTodos.firstIndex(of: todo) {
                oldIndexPath = IndexPath(row: oldIndex, section: 1)
            }
            
            if let newIndex = pendingTodos.firstIndex(of: todo) {
                newIndexPath = IndexPath(row: newIndex, section: 0)
            } else if let newIndex = completedTodos.firstIndex(of: todo) {
                newIndexPath = IndexPath(row: newIndex, section: 1)
            }
            
            pendingUpdates.append { [weak self] in
                guard let self = self else { return }
                
                if let oldPath = oldIndexPath, let newPath = newIndexPath {
                    if oldPath.section != newPath.section {
                        self.tableView.moveRow(at: oldPath, to: newPath)
                        if let cell = self.tableView.cellForRow(at: newPath) as? ContentTableViewCell {
                            cell.configure(with: todo)
                        }
                    } else {
                        if let cell = self.tableView.cellForRow(at: oldPath) as? ContentTableViewCell {
                            UIView.transition(with: cell, duration: 0.3, options: .transitionCrossDissolve) {
                                cell.configure(with: todo)
                            }
                        }
                    }
                }
            }
            
        case .insert, .delete, .move:
            pendingUpdates.append { [weak self] in
                self?.organizeTodos()
                self?.updateEmptyState()
                self?.tableView.reloadData()
            }
        @unknown default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.performBatchUpdates({
            for update in pendingUpdates {
                update()
            }
        }, completion: { _ in
            self.updateEmptyState()
        })
        pendingUpdates.removeAll()
    }
}
