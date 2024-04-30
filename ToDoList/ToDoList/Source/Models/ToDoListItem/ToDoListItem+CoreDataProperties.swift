//
//  ToDoListItem+CoreDataProperties.swift
//  ToDoList
//
//  Created by Maryna Poliakova-Bilous on 13.04.2024.
//
//

import Foundation
import CoreData


extension ToDoListItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ToDoListItem> {
        return NSFetchRequest<ToDoListItem>(entityName: "ToDoListItem")
    }

    @NSManaged public var date: Date?
    @NSManaged public var completed: Bool
    @NSManaged public var time: Double
    @NSManaged public var title: String?
    @NSManaged public var id: Int
}

extension ToDoListItem : Identifiable {}
