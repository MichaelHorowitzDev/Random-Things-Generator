//
//  SaveCSV.swift
//  Random Things Generator
//
//  Created by Michael Horowitz on 10/9/21.
//

import SwiftUI
import CSV


//struct CSVSaver {
//  func save() -> URL {
//    let tempDirectory = NSTemporaryDirectory()
//    let tempURL = URL(fileURLWithPath: tempDirectory, isDirectory: true).appendingPathComponent("\(randomType)_\(UUID().uuidString.prefix(8)).csv")
//    print(tempURL)
//    let stream = OutputStream(toFileAtPath: tempURL.path, append: false)!
//    let csv = try! CSVWriter(stream: stream)
//    for item in history {
//      try! csv.write(row: [item.value ?? "Unknown Value", formatDate(date: item.timestamp)])
//    }
//    csv.stream.close()
//    return tempURL
//  }
//}

struct CSVSave {
  let namePrefix: String
  let rows: [[String]]
  func save() -> URL {
    let tempDirectory = NSTemporaryDirectory()
    let tempURL = URL(fileURLWithPath: tempDirectory, isDirectory: true).appendingPathComponent("\(namePrefix)_\(UUID().uuidString.prefix(8)).csv")
    print(tempURL)
    let stream = OutputStream(toFileAtPath: tempURL.path, append: false)!
    let csv = try! CSVWriter(stream: stream)
    for row in rows {
      try! csv.write(row: row)
    }
    csv.stream.close()
    return tempURL
  }
}

struct CSVSaver<Content:View>: View {
  let namePrefix: String
  let rows: [[String]]
  let label: Content?
  init(namePrefix: String, rows: [[String]], @ViewBuilder label: () -> Content) {
    self.namePrefix = namePrefix
    self.rows = rows
    self.label = label()
  }
//  init(namePrefix: String, rows: [[String]]) {
//    self.namePrefix = namePrefix
//    self.rows = rows
//    self.label = nil
//  }
  @State private var shareItem: ShareItem?
  var body: some View {
    Button {
      let tempDirectory = NSTemporaryDirectory()
      let tempURL = URL(fileURLWithPath: tempDirectory, isDirectory: true).appendingPathComponent("\(namePrefix)_\(UUID().uuidString.prefix(8)).csv")
      print(tempURL)
      let stream = OutputStream(toFileAtPath: tempURL.path, append: false)!
      let csv = try! CSVWriter(stream: stream)
      for row in rows {
        try! csv.write(row: row)
      }
      csv.stream.close()
      shareItem = ShareItem(url: tempURL)
    } label: {
      if label == nil {
        Image(systemName: "square.and.arrow.up")
      } else {
        label
      }
    }
    .sheet(item: $shareItem, onDismiss: {
      shareItem = nil
    }, content: { item in
      ShareSheet(activityItems: [item.url])
    })
  }
}

struct ShareItem: Identifiable {
    let id = UUID()
    let url: URL
}
