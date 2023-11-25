
import UIKit
import CoreData


// MARK: - Core Data stack

final class StorageManager {
    
    static let share = StorageManager()
    
    private let fetchRequestTask: NSFetchRequest<TaskManager> = TaskManager.fetchRequest()
    
    var sortDescriptor = NSSortDescriptor(key: "taskTitle", ascending: true)

    lazy var fetchResultController: NSFetchedResultsController<TaskManager> = {
        fetchRequestTask.sortDescriptors = [sortDescriptor]
        let fetch = NSFetchedResultsController(fetchRequest: fetchRequestTask, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetch.performFetch()
        } catch {
            print("No perform")
        }
    
        return fetch
    }()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TaskTwo")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private init() {}
    
    // MARK: - Core Data Saving support

     func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

