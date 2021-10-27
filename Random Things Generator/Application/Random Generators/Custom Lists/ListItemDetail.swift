//
//  ListItemDetail.swift
//  ListItemDetail
//
//  Created by Michael Horowitz on 9/6/21.
//

import SwiftUI

struct ListItemDetail: View {
  let listItem: ListItem
  func formatDate(date: Date?) -> String {
    if date == nil {
      return "Never"
    } else {
      let formatter = DateFormatter()
      formatter.dateFormat = "M/d/yy"
      let dateString = formatter.string(from: date!)
      formatter.dateFormat = "h:mm:ss a"
      let timeString = formatter.string(from: date!)
      return dateString+"\n"+timeString
    }
  }
  func totalPercentage(times: Int32?, totalTimes: Int32?) -> String {
    guard let times = times else {
      return "0%"
    }
    guard let totalTimes = totalTimes else {
      return "0%"
    }
    let percentage = Double(times) / Double(totalTimes)
    if percentage.isNaN || percentage.isInfinite {
      return "0%"
    }
    let formatter = NumberFormatter()
    formatter.numberStyle = .percent
    let formattedPercent = formatter.string(from: percentage as NSNumber)
    return formattedPercent ?? "0%"
  }
  var body: some View {
    List {
      HStack {
        Text("Date Created")
        Spacer()
        Text(formatDate(date: listItem.dateCreated))
      }
      HStack {
        Text("Times Shown")
        Spacer()
        Text("\(listItem.timesShown)")
      }
      HStack {
        Text("Last Shown")
        Spacer()
        Text(formatDate(date: listItem.lastShown))
      }
      HStack {
        Text("Percentage shown of total")
        Spacer()
        Text(totalPercentage(times: listItem.timesShown, totalTimes: listItem.list?.totalTimesShown))
      }
    }
    .navigationTitle(listItem.itemName ?? "Unknown")
    .navigationBarTitleDisplayMode(.large)
  }
}

extension GeneratorList {
  var generatorListItems: [ListItem] {
    self.items?.allObjects as? [ListItem] ?? []
  }
  var totalTimesShown: Int32 {
    self.generatorListItems.reduce(0) { partialResult, listItem in
      partialResult+listItem.timesShown
    }
  }
}
