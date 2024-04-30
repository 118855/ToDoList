//
//  CoreDataManager.swift
//  ToDoList
//
//  Created by Maryna Poliakova-Bilous on 18.04.2024.
//

import Foundation
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ToDoList")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    } ()
    
    var fetchRequestForToDoList: NSFetchRequest<ToDoListItem>  {
        let request: NSFetchRequest<ToDoListItem> = ToDoListItem.fetchRequest()
            let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
            request.sortDescriptors = [sortDescriptor]
            return request
    }
    
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
    
    func fetchTasks() -> [ToDoListItem] {
        var tasks = [ToDoListItem]()
        
        do {
            tasks = try context.fetch(fetchRequestForToDoList)
        } catch {
            print("error")
        }
        print("fetch - \(tasks.count).")
        
        return tasks
    }
}
