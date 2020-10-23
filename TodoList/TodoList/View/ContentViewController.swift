//
//  ContentViewController.swift
//  TodoList
//
//  Created by 김기현 on 2020/10/22.
//

import UIKit
import CoreData

class ContentViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet var swipeGesture: UISwipeGestureRecognizer!
    
    var categoryName: String?
    private var taskCount: Int?
    private var controller: NSFetchedResultsController<NSManagedObject>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.register(UINib(nibName: "ContentTableViewHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "contentHeader")
        self.tableView.register(UINib(nibName: "ContentTableViewFooter", bundle: nil), forHeaderFooterViewReuseIdentifier: "contentFooter")
        self.tableView.register(UINib(nibName: "ContentTableViewCell", bundle: nil), forCellReuseIdentifier: "contentCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }

    @IBAction func leftSwipe(_ sender: Any) {
        if swipeGesture.direction == .right {
            self.navigationController?.popViewController(animated: true)
        }
    }

}

// MARK: - UITableViewDelegate
extension ContentViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension ContentViewController: UITableViewDataSource {
    // MARK: - TableView Header
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "contentHeader") as? ContentTableViewHeader else {
            return UIView()
        }
        
        header.categoryLabel.text = categoryName
        if let count = taskCount {
            header.taskLabel.text = "\(count) task"
        }
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let width = self.view.frame.width
        let height = self.view.frame.height
        
        if width < height {
            return height / 6
        } else {
            return width / 5
        }
    }
    
    // MARK: - TableView Footer
    @objc func createTodo() {
        let vc = AddTodoViewController(nibName: "AddTodoViewController", bundle: nil)
        vc.category = self.categoryName
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: "contentFooter") as? ContentTableViewFooter else {
            return UIView()
        }
        
//        footer.createTodoButton.addTarget(self, action: #selector(createTodo), for: .touchUpInside)
        
        return footer
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 50
    }
    
    // MARK: - TableView Cell
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        guard let sections = self.controller?.sections else {
//            fatalError("No sections in fetchedResultsController at ContentViewController")
//        }
//
//        let sectionInfo = sections[section]
//        self.taskCount = sectionInfo.numberOfObjects
//        return sectionInfo.numberOfObjects
        
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "contentCell", for: indexPath) as? ContentTableViewCell else {
            return UITableViewCell()
        }
        
        if let content = controller?.object(at: indexPath) as? Todo {
            cell.todoLabel.text = content.todoName
        } else {
            cell.todoLabel.text = "TEST"
        }
        
        return cell
    }
    
    
}

// MARK: - NSFetchedResultsControllerDelegate
extension ContentViewController: NSFetchedResultsControllerDelegate {
    private func loadData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        managedContext.automaticallyMergesChangesFromParent = true
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Todo")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createDate", ascending: false)]
        
        controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedContext, sectionNameKeyPath: nil, cacheName: nil)
        controller?.delegate = self
        
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
}
