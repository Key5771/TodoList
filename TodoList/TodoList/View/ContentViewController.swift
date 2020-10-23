//
//  ContentViewController.swift
//  TodoList
//
//  Created by 김기현 on 2020/10/22.
//

import UIKit
import CoreData

class ContentViewController: UIViewController {
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet var swipeGesture: UISwipeGestureRecognizer!
    
    var categoryName: String?
    private var taskCount: Int?
    private var controller: NSFetchedResultsController<NSManagedObject>?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        categoryLabel.text = categoryName
        if let count = taskCount {
            self.taskLabel.text = "\(count)"
        } else {
            self.taskLabel.text = "0 task"
        }
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: "ContentTableViewCell", bundle: nil), forCellReuseIdentifier: "contentCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadData()
        self.tableView.reloadData()
    }

    @IBAction func leftSwipe(_ sender: Any) {
        if swipeGesture.direction == .right {
            self.navigationController?.popViewController(animated: true)
        }
    }

}

extension ContentViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ContentViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = self.controller?.sections else {
            fatalError("No sections in fetchedResultsController at ContentViewController")
        }
        
        let sectionInfo = sections[section]
        self.taskCount = sectionInfo.numberOfObjects
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "contentCell", for: indexPath) as? ContentTableViewCell else {
            return UITableViewCell()
        }
        
        if let content = controller?.object(at: indexPath) as? Todo {
            cell.todoLabel.text = content.todoName
        }
        
        return cell
    }
    
    
}

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
        self.tableView.performBatchUpdates(nil, completion: nil)
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.performBatchUpdates(nil, completion: nil)
    }
}
