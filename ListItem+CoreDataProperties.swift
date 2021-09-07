//
//  ListItem+CoreDataProperties.swift
//  ListItem
//
//  Created by Michael Horowitz on 9/6/21.
//
//

import Foundation
import CoreData


extension ListItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ListItem> {
        return NSFetchRequest<ListItem>(entityName: "ListItem")
    }

    @NSManaged public var dateCreated: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var itemName: String?
    @NSManaged public var timesShown: Int32
    @NSManaged public var lastShown: Date?
    @NSManaged public var list: GeneratorList?

}

extension ListItem : Identifiable {

}
