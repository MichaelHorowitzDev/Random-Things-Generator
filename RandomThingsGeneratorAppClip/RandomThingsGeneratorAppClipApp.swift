//
//  RandomThingsGeneratorAppClipApp.swift
//  RandomThingsGeneratorAppClip
//
//  Created by Michael Horowitz on 10/27/21.
//

import SwiftUI

@main
struct RandomThingsGeneratorAppClipApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
          NumberGenerator()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
