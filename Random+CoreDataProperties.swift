//
//  Random+CoreDataProperties.swift
//  Random
//
//  Created by Michael Horowitz on 8/31/21.
//
//

import Foundation
import CoreData


extension Random {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Random> {
        return NSFetchRequest<Random>(entityName: "Random")
    }

    @NSManaged public var timestamp: Date?
    @NSManaged public var value: String?
    @NSManaged public var image: Data?
    @NSManaged public var randomType: String?

}

extension Random : Identifiable {

}
