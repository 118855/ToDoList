//
//  ToDoListViewModel.swift
//  ToDoList
//
//  Created by Maryna Poliakova-Bilous on 19.04.2024.
//

import Foundation

class ToDoListViewModel {
    private let manager: CoreDataManager
    private var toDoItems: [ToDoListItem] = []
    
    var itemsCount: Int {
        return toDoItems.count
    }
    
    var completedItemsCount: Int {
        return toDoItems.filter { $0.completed }.count
    }
    
    init(manager: CoreDataManager) {
        self.manager = manager
        self.toDoItems = manager.fetchTasks()
    }
    
    func itemAtIndex(_ index: Int) -> ToDoListItem {
        return toDoItems[index]
    }
    
    func deleteItemAtIndex(_ index: Int) {
        let item = toDoItems[index]
        manager.deleteItem(item)
        toDoItems.remove(at: index)
    }
    
    func addItem(title: String) {
        manager.createItem(title: title, id: itemsCount+1)
        toDoItems = manager.fetchTasks()
    }
    
    func updateItemAtIndex(_ index: Int, with newTitle: String) {
        let item = toDoItems[index]
        manager.updateItem(item: item, newTitle: newTitle)
        toDoItems[index] = manager.fetchTasks()[index]
    }
    
    func toggleIsDone(for item: ToDoListItem) {
        guard let index = toDoItems.firstIndex(where: { $0 === item }) else { return }
        toDoItems[index].completed.toggle()
        manager.saveContext()
    }
    
    func moveItem(from sourceIndex: Int, to destinationIndex: Int) {
        let item = toDoItems.remove(at: sourceIndex)
        toDoItems.insert(item, at: destinationIndex)
        
        for (index, item) in toDoItems.enumerated() {
                item.id = index+1
            }
        print(sourceIndex, destinationIndex)
        manager.saveContext()
    }
}
