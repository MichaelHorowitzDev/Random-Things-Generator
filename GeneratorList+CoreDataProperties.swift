//
//  GeneratorList+CoreDataProperties.swift
//  Random Things Generator
//
//  Created by Michael Horowitz on 9/24/21.
//
//

import Foundation
import CoreData


extension GeneratorList {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GeneratorList> {
        return NSFetchRequest<GeneratorList>(entityName: "GeneratorList")
    }

    @NSManaged public var color: Data?
    @NSManaged public var dateCreated: Date?
    @NSManaged public var dateModified: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var title: String?
    @NSManaged public var totalTimes: Int32
    @NSManaged public var nonRepeating: Bool
    @NSManaged public var items: NSSet?

}

// MARK: Generated accessors for items
extension GeneratorList {

    @objc(addItemsObject:)
    @NSManaged public func addToItems(_ value: ListItem)

    @objc(removeItemsObject:)
    @NSManaged public func removeFromItems(_ value: ListItem)

    @objc(addItems:)
    @NSManaged public func addToItems(_ values: NSSet)

    @objc(removeItems:)
    @NSManaged public func removeFromItems(_ values: NSSet)

}

extension GeneratorList : Identifiable {

}
