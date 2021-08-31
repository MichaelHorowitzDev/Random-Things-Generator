//
//  RandomHistory.swift
//  RandomHistory
//
//  Created by Michael Horowitz on 8/31/21.
//

import SwiftUI

struct RandomHistory: View {
  @Environment(\.managedObjectContext) var managedObjectContext
  @FetchRequest var history: FetchedResults<Random>
  
  init(randomType: String) {
    self._history = FetchRequest(entity: Random.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Random.timestamp, ascending: false)], predicate: NSPredicate(format: "randomType == %@", randomType), animation: .default)
  }
    var body: some View {
      List(history) { item in
//        Text("\(item.timestamp?.description ?? "")")
        Text(item.value ?? "Unknown")
      }
    }
}
