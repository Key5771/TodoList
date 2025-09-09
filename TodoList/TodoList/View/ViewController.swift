//
//  ViewController.swift
//  TodoList
//
//  Created by 김기현 on 2020/10/16.
//

import UIKit
import CoreData
import SnapKit

class ViewController: UIViewController {
    // MARK: - UI Components
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.showsVerticalScrollIndicator = false
        collectionView.contentInsetAdjustmentBehavior = .automatic
        return collectionView
    }()
    
    private let createButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .systemBlue
        button.setTitle("새 카테고리", for: .normal)
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
        let config = UIImage.SymbolConfiguration(pointSize: 80, weight: .light)
        let image = UIImage(systemName: "folder.badge.plus", withConfiguration: config)
        imageView.image = image
        imageView.tintColor = .tertiaryLabel
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "아직 카테고리가 없습니다\n새로운 카테고리를 추가해보세요"
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = .tertiaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    // MARK: - Properties
    private var controller: NSFetchedResultsController<NSManagedObject>?
    private var blockOperation = BlockOperation()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        setupConstraints()
        setupCollectionView()
        setupActions()
        loadData()
        controller?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // NavigationBar를 표시하고 Large Title 활성화
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        
        collectionView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 스크롤 시 Large Title 동적 처리를 위한 설정
        if let navigationController = navigationController {
            navigationController.navigationBar.sizeToFit()
        }
    }
    
    // MARK: - Setup Methods
    private func setupNavigationBar() {
        // Navigation Title 설정
        title = "카테고리"
        
        // Large Title 설정
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        
        // Navigation Bar 스타일 설정
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        appearance.shadowColor = .clear
        
        // Large Title 폰트 설정
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.label,
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]
        
        // 일반 Title 폰트 설정
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.label,
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        
        // 설정 버튼을 Navigation Bar 우측에 추가
        let settingButton = UIBarButtonItem(
            image: UIImage(systemName: "gearshape"),
            style: .plain,
            target: self,
            action: #selector(settingButtonTapped)
        )
        settingButton.tintColor = .systemBlue
        navigationItem.rightBarButtonItem = settingButton
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(collectionView)
        view.addSubview(createButton)
        
        view.addSubview(emptyStateView)
        emptyStateView.addSubview(emptyStateImageView)
        emptyStateView.addSubview(emptyStateLabel)
    }
    
    private func setupConstraints() {
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(createButton.snp.top).offset(-20)
        }
        
        createButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            make.height.equalTo(50)
        }
        
        emptyStateView.snp.makeConstraints { make in
            make.center.equalTo(collectionView)
            make.leading.trailing.equalToSuperview().inset(40)
        }
        
        emptyStateImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.height.equalTo(100)
        }
        
        emptyStateLabel.snp.makeConstraints { make in
            make.top.equalTo(emptyStateImageView.snp.bottom).offset(20)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: "categoryCell")
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        
        // 스크롤 감지를 위한 델리게이트 추가
        collectionView.delegate = self
    }
    
    private func setupActions() {
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
    }
    
    private func updateEmptyState() {
        guard let sections = controller?.sections else { return }
        let sectionInfo = sections.first
        let isEmpty = sectionInfo?.numberOfObjects == 0
        
        emptyStateView.isHidden = !isEmpty
        collectionView.isHidden = isEmpty
    }
    
    // MARK: - Actions
    @objc private func createButtonTapped() {
        let categoryVC = CategoryViewController()
        categoryVC.modalPresentationStyle = .fullScreen
        present(categoryVC, animated: true, completion: nil)
    }
    
    @objc private func settingButtonTapped() {
        // TODO: 설정 화면 구현
        let alert = UIAlertController(title: "설정", message: "설정 기능은 아직 구현되지 않았습니다.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Custom Collection View Cell
class CategoryCollectionViewCell: UICollectionViewCell {
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 32, weight: .medium)
        let image = UIImage(systemName: "folder.fill", withConfiguration: config)
        imageView.image = image
        imageView.tintColor = .systemBlue
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    
    let taskLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        contentView.addSubview(containerView)
        containerView.addSubview(iconImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(taskLabel)
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        iconImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(40)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(iconImageView.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(8)
        }
        
        taskLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview().inset(8)
            make.bottom.lessThanOrEqualToSuperview().offset(-16)
        }
    }
}

// MARK: - UICollectionView Delegate & DataSource
extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sections = controller?.sections else {
            fatalError("No sections in fetchedResultsController")
        }
        
        let sectionInfo = sections[section]
        
        DispatchQueue.main.async {
            self.updateEmptyState()
        }
        
        return sectionInfo.numberOfObjects
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryCell", for: indexPath) as? CategoryCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        if let content = controller?.object(at: indexPath) as? TodoCategory {
            cell.titleLabel.text = content.categoryName
            
            // 해당 카테고리의 할 일 개수 계산
            let taskCount = getTaskCount(for: content.categoryName ?? "")
            cell.taskLabel.text = "\(taskCount) task\(taskCount != 1 ? "s" : "")"
        } else {
            cell.titleLabel.text = "카테고리"
            cell.taskLabel.text = "0 tasks"
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        guard let content = controller?.object(at: indexPath) as? TodoCategory else { return }
        let contentVC = ContentViewController()
        contentVC.categoryName = content.categoryName
        
        // 자연스러운 네비게이션 애니메이션을 위한 설정
        navigationController?.pushViewController(contentVC, animated: true)
    }
    
    private func getTaskCount(for categoryName: String) -> Int {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return 0 }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Todo")
        fetchRequest.predicate = NSPredicate(format: "categoryName == %@", categoryName)
        
        do {
            let results = try managedContext.fetch(fetchRequest)
            return results.count
        } catch {
            print("Error fetching task count: \(error)")
            return 0
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width
        let spacing: CGFloat = 16
        let insets: CGFloat = 40 // 20 + 20
        
        let availableWidth = width - insets - spacing
        let cellWidth = availableWidth / 2
        let cellHeight = cellWidth * 0.8 // 4:3.2 비율
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
}

// MARK: - UIScrollViewDelegate (Large Title 동적 처리)
extension ViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 스크롤에 따른 Large Title 동적 처리는 자동으로 처리됩니다
        // 필요시 추가적인 커스터마이징 가능
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension ViewController: NSFetchedResultsControllerDelegate {
    private func loadData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        managedContext.automaticallyMergesChangesFromParent = true
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "TodoCategory")
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
            print("Could not Fetch. \(error), \(error.userInfo)")
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        blockOperation = BlockOperation()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, 
                   didChange sectionInfo: NSFetchedResultsSectionInfo, 
                   atSectionIndex sectionIndex: Int, 
                   for type: NSFetchedResultsChangeType) {
        let sectionIndexSet = IndexSet(integer: sectionIndex)
        
        switch type {
        case .insert:
            blockOperation.addExecutionBlock {
                self.collectionView.insertSections(sectionIndexSet)
            }
        case .delete:
            blockOperation.addExecutionBlock {
                self.collectionView.deleteSections(sectionIndexSet)
            }
        case .update:
            blockOperation.addExecutionBlock {
                self.collectionView.reloadSections(sectionIndexSet)
            }
        case .move:
            assertionFailure("Move operation not supported for sections")
        @unknown default:
            collectionView.reloadData()
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, 
                   didChange anObject: Any, 
                   at indexPath: IndexPath?, 
                   for type: NSFetchedResultsChangeType, 
                   newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath {
                blockOperation.addExecutionBlock {
                    self.collectionView.insertItems(at: [newIndexPath])
                }
            }
        case .delete:
            if let indexPath = indexPath {
                blockOperation.addExecutionBlock {
                    self.collectionView.deleteItems(at: [indexPath])
                }
            }
        case .update:
            if let indexPath = indexPath {
                blockOperation.addExecutionBlock {
                    self.collectionView.reloadItems(at: [indexPath])
                }
            }
        case .move:
            if let indexPath = indexPath, let newIndexPath = newIndexPath {
                blockOperation.addExecutionBlock {
                    self.collectionView.moveItem(at: indexPath, to: newIndexPath)
                }
            }
        @unknown default:
            collectionView.reloadData()
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView.performBatchUpdates({
            blockOperation.start()
        }, completion: nil)
    }
}
