//
//  ListItems+CoreDataProperties.swift
//  ListItems
//
//  Created by Michael Horowitz on 9/5/21.
//
//

import Foundation
import CoreData


extension ListItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ListItem> {
        return NSFetchRequest<ListItem>(entityName: "ListItems")
    }

    @NSManaged public var itemName: String?
    @NSManaged public var dateCreated: Date?
    @NSManaged public var list: GeneratorList?
    @NSManaged public var id: UUID?

}

extension ListItem : Identifiable {

}
