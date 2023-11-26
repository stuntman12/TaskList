
import UIKit
import CoreData

final class TaskTableViewController: UITableViewController {
    
    private let store = StorageManager.share
    private let cellId = "taskCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        store.fetchResultController.delegate = self
        
        setupNavigationBar()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
    }
    
    @objc
    func addNewTask() {
        showAlert(title: "New Task", message: "What do you want to do?")
    }
    
    @objc
    func deleteAll() {
        guard let fetchObject = store.fetchResultController.fetchedObjects else { return }
        
        for object in fetchObject {
            store.fetchResultController.managedObjectContext.delete(object)
            store.saveContext()
        }
        tableView.reloadData()
    }

}

// MARK: - Table view data source

extension TaskTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        store.fetchResultController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = store.fetchResultController.sections?[section]
        return sectionInfo?.numberOfObjects ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        
        let anyTask = store.fetchResultController.object(at: indexPath)
        var content = cell.defaultContentConfiguration()
        
        content.text = anyTask.taskTitle
        
        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showEditAlert(title: "Edit Task", message: "What you want edit?", indexPatch: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let anyTask = store.fetchResultController.object(at: indexPath)
            store.persistentContainer.viewContext.delete(anyTask)
        }
    }
    
}


// MARK: - Table view data source

extension TaskTableViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if indexPath != nil {
                tableView.insertRows(at: [indexPath!], with: .bottom)
            }
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .middle)
        case .move:
            break
        case .update:
            break
        @unknown default:
            break
        }
    }
}

private extension TaskTableViewController {
    func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground() // Блюр эффект
        navigationBarAppearance.backgroundColor = UIColor(named: "MainColor")
        navigationBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = navigationBarAppearance // Передали в маленький title
        navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance // Передали в большой title
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewTask))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteAll))
        
        navigationController?.navigationBar.tintColor = .white // цвет кнопки
        
    }
    
    func showEditAlert(title: String, message: String, indexPatch: IndexPath) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let editButton = UIAlertAction(title: "Edit", style: .default) { [unowned self] textField in
            let taskForIndexPatch = store.fetchResultController.object(at: indexPatch) // объект из модели по индекспас
            guard let textFronTextField = alert.textFields?.first?.text else { return }
            edit(task: taskForIndexPatch, text: textFronTextField)
        }
        
        alert.addAction(editButton)
        alert.addTextField { [unowned self] in
            $0.text = store.fetchResultController.object(at: indexPatch).taskTitle
        }
        present(alert, animated: true)
    }
    
    func edit(task: TaskManager, text: String) {
        task.taskTitle = text
        store.saveContext()
        tableView.reloadData()
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert)
        
        let saveButton = UIAlertAction(title: "Save", style: .default) { [unowned self] _ in
            guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
            save(taskTitle: task)
        }
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
        }
        
        alert.addAction(saveButton)
        alert.addAction(cancelButton)
        alert.addTextField { textField in
            textField.placeholder = "New Task"
        }
        
        present(alert, animated: true)
    }
    
    func save(taskTitle: String) {
        
        let task = TaskManager(context: store.persistentContainer.viewContext)
        task.taskTitle = taskTitle
        
        store.saveContext()
        
        guard let fetchObject = store.fetchResultController.fetchedObjects else { return }
        let index = IndexPath(row: fetchObject.count - 1, section: 0)
        tableView.insertRows(at: [index], with: .automatic)
        tableView.reloadData()
        
    }
}
