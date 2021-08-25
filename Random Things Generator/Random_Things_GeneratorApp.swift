//
//  Random_Things_GeneratorApp.swift
//  Random Things Generator
//
//  Created by Michael Horowitz on 8/25/21.
//

import SwiftUI

@main
struct Random_Things_GeneratorApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
