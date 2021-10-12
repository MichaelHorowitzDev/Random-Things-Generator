//
//  GeneratorPreferences+CoreDataProperties.swift
//  Random Things Generator
//
//  Created by Michael Horowitz on 10/12/21.
//
//

import Foundation
import CoreData


extension GeneratorPreferences {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GeneratorPreferences> {
        return NSFetchRequest<GeneratorPreferences>(entityName: "GeneratorPreferences")
    }

    @NSManaged public var isCustomList: Bool
    @NSManaged public var uuid: UUID?
    @NSManaged public var randomType: String?
    @NSManaged public var dontRepeat: Bool
  
  static func initialize(context: NSManagedObjectContext, uuid: UUID) throws -> GeneratorPreferences {
    let preferences = GeneratorPreferences(context: context)
    preferences.uuid = uuid
    preferences.isCustomList = true
    preferences.randomType = nil
    try context.save()
    return preferences
  }
  static func initialize(context: NSManagedObjectContext, randomType: String) throws -> GeneratorPreferences {
    let preferences = GeneratorPreferences(context: context)
    preferences.uuid = nil
    preferences.isCustomList = false
    preferences.randomType = randomType
    try context.save()
    return preferences
  }
}

extension GeneratorPreferences : Identifiable {

}
