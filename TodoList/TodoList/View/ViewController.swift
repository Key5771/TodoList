//
//  ViewController.swift
//  TodoList
//
//  Created by 김기현 on 2020/10/16.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var createButton: UIButton!
    
    private var controller: NSFetchedResultsController<NSManagedObject>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(UINib(nibName: "MainCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "reuseCell")
        
        print("width: \(self.collectionView.frame.width)")
        print("height: \(self.collectionView.frame.height)")
        
        setCreateView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadData()
        self.collectionView.reloadData()
    }
    
    // MARK: - CreateView Layout Setting
    private func setCreateView() {
        // createButton layer effect
        createButton.layer.cornerRadius = 20
        createButton.layer.borderWidth = 1
        createButton.layer.borderColor = UIColor.clear.cgColor
        createButton.layer.masksToBounds = true
        createButton.layer.backgroundColor = UIColor.white.cgColor
        
        // createButton shadow effect
//        createButton.layer.shadowColor = UIColor.gray.cgColor
//        createButton.layer.shadowOffset = CGSize(width: 0, height: 0.0)
//        createButton.layer.shadowRadius = 4.0
//        createButton.layer.shadowOpacity = 0.6
//        createButton.layer.cornerRadius = 20
//        createButton.layer.masksToBounds = false
//        createButton.layer.shadowPath = UIBezierPath(rect: createButton.bounds).cgPath
    }
    
    // MARK: - CreateView Action
    @IBAction func create(_ sender: Any) {
        let vc = CategoryViewController(nibName: "CategoryViewController", bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.collectionView.deselectItem(at: indexPath, animated: true)
        
        guard let content = controller?.object(at: indexPath) as? TodoCategory else { return }
        let vc = ContentViewController(nibName: "ContentViewController", bundle: nil)
        vc.categoryName = content.name
        self.navigationController?.pushViewController(vc, animated: true)
//        if indexPath.section == 0 {
//            let vc = CategoryViewController(nibName: "CategoryViewController", bundle: nil)
//            vc.modalPresentationStyle = .fullScreen
//            self.present(vc, animated: true, completion: nil)
//        }
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sections = self.controller?.sections else {
            fatalError("No sections in fetchedResultsController")
        }
        
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let item = collectionView.dequeueReusableCell(withReuseIdentifier: "reuseCell", for: indexPath) as? MainCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        if let content = controller?.object(at: indexPath) as? TodoCategory {
            item.titleLabel.text = content.name
            item.taskLabel.text = "1 task"
        } else {
            item.titleLabel.text = "TEST"
            item.taskLabel.text = "TEST"
        }
        
        return item
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 30, bottom: 10, right: 30)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let screenSize = UIScreen.main.bounds
        let width = self.view.frame.width
        let height = self.view.frame.height
        
        if width < height {
            return CGSize(width: width / 3, height: width / 3)
        } else {
            return CGSize(width: height / 3, height: height / 3)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
}

extension ViewController: NSFetchedResultsControllerDelegate {
    private func loadData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        managedContext.automaticallyMergesChangesFromParent = true
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "TodoCategory")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createDate", ascending: false)]
        
        controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedContext, sectionNameKeyPath: nil, cacheName: nil)
        controller?.delegate = self
        
        do {
            try controller?.performFetch()
        } catch let error as NSError {
            print("Could not Fetch. \(error), \(error.userInfo)")
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.collectionView.performBatchUpdates(nil, completion: nil)
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.collectionView.performBatchUpdates(nil, completion: nil)
    }
}
