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
    
    private lazy var settingButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "setting"), for: .normal)
        button.addTarget(self, action: #selector(settingTodo), for: .touchUpInside)
        return button
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton()
        button.setTitle("Create", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(createTodo), for: .touchUpInside)
        button.clipsToBounds = true
        button.backgroundColor = .black
        button.layer.cornerRadius = 8
        return button
    }()
    
    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 24)
        return label
    }()
    private let taskLabel = UILabel()
    
    private lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.delegate = self
        tv.dataSource = self
        tv.register(ContentTableViewCell.self,
                    forCellReuseIdentifier: ContentTableViewCell.identifier)
        return tv
    }()
    
    private lazy var swipeGesture: UISwipeGestureRecognizer = {
        let gesture = UISwipeGestureRecognizer()
        gesture.addTarget(self, action: #selector(leftSwipe))
        return gesture
    }()
    
    var categoryName: String?
    private var taskCount: Int?
    private var controller: NSFetchedResultsController<NSManagedObject>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        self.controller?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadData()
        
        categoryLabel.text = categoryName
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    private func setup() {
        view.backgroundColor = .white
        view.addSubview(settingButton)
        settingButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.right.equalToSuperview().inset(16)
            make.width.height.equalTo(24)
        }
        
        view.addSubview(categoryLabel)
        categoryLabel.snp.makeConstraints { make in
            make.top.equalTo(settingButton.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.height.equalTo(44)
        }
        
        view.addSubview(taskLabel)
        taskLabel.snp.makeConstraints { make in
            make.top.equalTo(categoryLabel.snp.bottom).inset(16)
            make.centerX.equalToSuperview()
            make.height.equalTo(44)
        }
        
        view.addSubview(createButton)
        createButton.snp.makeConstraints { make in
            make.top.equalTo(taskLabel.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.width.equalTo(100)
            make.height.equalTo(56)
        }
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(createButton.snp.bottom).offset(16)
            make.left.right.bottom.equalToSuperview()
        }
    }

    @objc private func leftSwipe() {
        if swipeGesture.direction == .right {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc private func createTodo() {
        let vc = AddTodoViewController()
        vc.categoryName = self.categoryName
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func settingTodo() {
        let alert = UIAlertController(title: "Category Setting", message: "Select Action", preferredStyle: .actionSheet)
        let deleteButton = UIAlertAction(title: "Delete", style: .destructive) { _ in
            print("Delete")
        }
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alert.addAction(cancelButton)
        alert.addAction(deleteButton)
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate
extension ContentViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            
            let context = appDelegate.persistentContainer.viewContext
            guard let todo = self.controller?.object(at: indexPath) else { return }
            
            do {
                context.delete(todo)
                try context.save()
            } catch let error as NSError {
                print("Could not Delete Todo. \(error), \(error.userInfo)")
            }
        }
        
        self.loadData()
        self.tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource
extension ContentViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = self.controller?.sections else {
            fatalError("No sections in fetchedResultsController at ContentViewController")
        }

        let sectionInfo = sections[section]
        if sectionInfo.numberOfObjects != 0 {
            taskLabel.text = "\(sectionInfo.numberOfObjects) task"
        } else {
            taskLabel.text = "0 task"
        }
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ContentTableViewCell.identifier, for: indexPath) as? ContentTableViewCell else {
            return UITableViewCell()
        }
        
        if let content = controller?.object(at: indexPath) as? Todo {
            cell.configure(with: content)
        }
        
        return cell
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension ContentViewController: NSFetchedResultsControllerDelegate {
    private func loadData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate, let categoryName = categoryName else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        managedContext.automaticallyMergesChangesFromParent = true
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Todo")
        fetchRequest.predicate = NSPredicate(format: "categoryName == %@", categoryName)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createDate", ascending: false)]
        
        controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try controller?.performFetch()
        } catch let error as NSError {
            print("Could not Content Fetch. \(error), \(error.userInfo)")
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        guard let newIndexPath = newIndexPath, let indexPath = indexPath else { return }
        
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath], with: .fade)
            break
        case .delete:
            tableView.deleteRows(at: [indexPath], with: .fade)
            break
        case .move:
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.insertRows(at: [newIndexPath], with: .fade)
            break
        case .update:
            tableView.reloadRows(at: [indexPath], with: .fade)
            break
        default:
            tableView.reloadRows(at: [indexPath], with: .fade)
            break
        }
    }
}
