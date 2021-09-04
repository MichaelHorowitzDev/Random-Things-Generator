//
//  RandomHistory.swift
//  RandomHistory
//
//  Created by Michael Horowitz on 8/31/21.
//

import SwiftUI
import CSV

struct RandomHistory: View {
  @Environment(\.managedObjectContext) var managedObjectContext
  @State private var predicate: NSPredicate
  @State private var timeFrame = "All Time"
  @Environment(\.presentationMode) var presentationMode
  @EnvironmentObject var preferences: UserPreferences
  
  private var timeFrames = ["7 Days", "30 Days", "90 Days", "All Time"]
  
  init(randomType: String, formatValue: ((_ value: String) -> AnyView)? = nil) {
    self._predicate = State(initialValue: NSPredicate(format: "randomType == %@", randomType))
    self.formatValue = formatValue
    self.randomType = randomType
  }
  
  private let randomType: String
  private let formatValue: ((_ value: String) -> AnyView)?
  var body: some View {
    NavigationView {
      RandomHistoryItems(predicate: predicate, timeFrame: $timeFrame, randomType: randomType, formatValue: formatValue)
          .onChange(of: timeFrame) { newValue in
            var compareDate: Date? = Date()
            switch newValue {
            case "7 Days":
              compareDate = Calendar.current.date(byAdding: .day, value: -7, to: compareDate!)!
            case "30 Days":
              compareDate = Calendar.current.date(byAdding: .day, value: -30, to: compareDate!)!
            case "90 Days":
              compareDate = Calendar.current.date(byAdding: .day, value: -90, to: compareDate!)!
            default:
              compareDate = nil
            }
            if compareDate == nil {
              self.predicate = NSPredicate(format: "randomType == %@", randomType)
            } else {
              self.predicate = NSPredicate(format: "randomType == %@ AND timestamp >= %@", randomType, compareDate! as CVarArg)
            }
          }
      .navigationTitle("History")
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button("Cancel") {
            presentationMode.wrappedValue.dismiss()
          }
          .foregroundColor(preferences.themeColor)
        }
      }
    }
  }
}

private struct RandomHistoryItems: View {
  @FetchRequest var history: FetchedResults<Random>
  @Binding var timeFrame: String
  @State private var shareItem: Item?
  @EnvironmentObject var preferences: UserPreferences
  private var timeFrames = ["7 Days", "30 Days", "90 Days", "All Time"]
  
  init(predicate: NSPredicate, timeFrame: Binding<String>, randomType: String, formatValue: ((_ value: String) -> AnyView)? = nil) {
    self._history = FetchRequest(entity: Random.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Random.timestamp, ascending: false)], predicate: predicate, animation: .default)
    self.formatValue = formatValue
    self._timeFrame = timeFrame
    self.randomType = randomType
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
  private let randomType: String
  private let formatValue: ((_ value: String) -> AnyView)?
  var body: some View {
    List {
      Section(content: {
        ForEach(history, id: \.self) { item in
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
          .padding(.vertical, 5)
        }
      }, header: {
        HStack {
          Text("Total \(history.count)")
          Spacer()
          Text("Time Range")
          Picker("Time Range", selection: $timeFrame) {
            ForEach(timeFrames, id: \.self) {
              Text($0)
            }
          }
          .pickerStyle(.menu)
          .textCase(nil)
          .padding(.horizontal, 5)
          .padding(.vertical, 3)
          .overlay(
            RoundedRectangle(cornerRadius: 10)
              .stroke(.blue, lineWidth: 1)
          )
          .padding(.bottom, 3)
        }
      })
    }
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button (action: {
          let tempDirectory = NSTemporaryDirectory()
          let tempURL = URL(fileURLWithPath: tempDirectory, isDirectory: true).appendingPathComponent("\(randomType)_\(UUID().uuidString.prefix(8)).csv")
          print(tempURL)
          let stream = OutputStream(toFileAtPath: tempURL.path, append: false)!
          let csv = try! CSVWriter(stream: stream)
          for item in history {
            try! csv.write(row: [item.value ?? "Unknown Value", formatDate(date: item.timestamp)])
          }
          csv.stream.close()
          shareItem = Item(url: tempURL)
        }, label: {
          Image(systemName: "square.and.arrow.up").foregroundColor(preferences.themeColor)
        })
      }
    }
    .sheet(item: $shareItem, onDismiss: {
      shareItem = nil
    }, content: { item in
      ShareSheet(activityItems: [item.url])
    })
  }
}

private struct Item: Identifiable {
    let id = UUID()
    let url: URL
}
