//
//  CoreDataManager+CoreDataTaskManagerProtocol.swift
//  ToDoList
//
//  Created by Maryna Poliakova-Bilous on 18.04.2024.
//

import Foundation
import CoreData


protocol CoreDataTaskManagerProtocol {
    func createItem(title:String, id: Int)
    func getTasks() -> [ToDoListItem]
    func updateItem(item: ToDoListItem, newTitle: String)
    func deleteItem(_ item: ToDoListItem)
}

extension CoreDataManager: CoreDataTaskManagerProtocol {
    
    func createItem(title: String, id: Int) {
        let newItem = ToDoListItem(context: context)
        newItem.title = title
        newItem.time = 0
        newItem.id = id
        newItem.completed = false
        do {
            try context.save()
        }
        catch {
            print("error")
        }
    }
    
    func getTasks() -> [ToDoListItem] {
        let fetchRequest: NSFetchRequest<ToDoListItem> = ToDoListItem.fetchRequest()
        
        do {
            let tasks = try context.fetch(fetchRequest)
            return tasks
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return []
        }
    }
    
    func deleteItem(_ item: ToDoListItem) {
        context.delete(item)
        saveContext()
    }
    
    func updateItem(item: ToDoListItem, newTitle: String) {
        item.title = newTitle
        do {
            try context.save()
        }
        catch {
            print("error")
        }
    }
}
