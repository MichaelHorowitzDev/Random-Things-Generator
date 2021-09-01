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
  
  init(randomType: String, formatValue: ((_ value: String) -> AnyView)? = nil) {
    self._history = FetchRequest(entity: Random.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Random.timestamp, ascending: false)], predicate: NSPredicate(format: "randomType == %@", randomType), animation: .default)
    self.formatValue = formatValue
  }
  func formatDate(date: Date?) -> String {
    if date == nil {
      return "Unknown Date"
    } else {
      let formatter = DateFormatter()
      formatter.dateFormat = "M/d/yy"
      let dateString = formatter.string(from: date!)
      formatter.dateFormat = "h:mm:ss a" //s.SSS"
      let timeString = formatter.string(from: date!)
      return dateString+"\n"+timeString
    }
  }
  private let formatValue: ((_ value: String) -> AnyView)?
  var body: some View {
    NavigationView {
      List(history) { item in
        HStack {
          if let value = item.value {
            if formatValue != nil {
              formatValue!(value)
            } else {
              Text(value)
                .font(.title)
            }
          } else {
            Text("Unknown")
          }
          Spacer(minLength: 50)
          Text(formatDate(date: item.timestamp))
        }
      }
      .navigationTitle("History")
    }
  }
}
