//
//  ContentViewController.swift
//  TodoList
//
//  Created by 김기현 on 2020/10/22.
//

import UIKit
import CoreData

class ContentViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    
    @IBOutlet private weak var categoryLabel: UILabel!
    @IBOutlet private weak var taskLabel: UILabel!
    @IBOutlet private weak var createButton: UIButton!
    
    @IBOutlet private var swipeGesture: UISwipeGestureRecognizer!
    
    var categoryName: String?
    private var taskCount: Int?
    private var controller: NSFetchedResultsController<NSManagedObject>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.register(UINib(nibName: "ContentTableViewCell", bundle: nil), forCellReuseIdentifier: "contentCell")
        
        self.controller?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadData()
        
        categoryLabel.text = categoryName
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }

    @IBAction func leftSwipe(_ sender: Any) {
        if swipeGesture.direction == .right {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func createTodo(_ sender: Any) {
        let vc = AddTodoViewController()
        vc.categoryName = self.categoryName
        self.navigationController?.pushViewController(vc, animated: true)
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "contentCell", for: indexPath) as? ContentTableViewCell else {
            return UITableViewCell()
        }
        
        if let content = controller?.object(at: indexPath) as? Todo {
            if content.categoryName == self.categoryName {
                cell.todoLabel.text = content.todoName
                cell.todoLabelView.isHidden = false
            } else {
                cell.todoLabel.text = ""
                cell.todoLabelView.isHidden = true
            }
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
