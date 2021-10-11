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
  private var settings = AnyView(EmptyView())
  
  init(randomType: String, generatorList: GeneratorList? = nil, id: String? = nil, customPredicate: NSPredicate? = nil, isCustomList: Bool = false, formatValue: ((_ value: String) -> AnyView)? = nil) {
    self._predicate = State(initialValue: NSPredicate(format: "randomType == %@", randomType))
    self.formatValue = formatValue
    self.randomType = randomType
    self.id = id
    self.customPredicate = customPredicate
    self.isCustomList = isCustomList
    self.generatorList = generatorList
  }
  
  private let randomType: String
  private let id: String?
  private let customPredicate: NSPredicate?
  private let formatValue: ((_ value: String) -> AnyView)?
  private let isCustomList: Bool
  private let generatorList: GeneratorList?
  func setPredicate(timeFrame: String) {
    var compareDate: Date? = Date()
    switch timeFrame {
    case "7 Days":
      compareDate = Calendar.current.date(byAdding: .day, value: -7, to: compareDate!)!
    case "30 Days":
      compareDate = Calendar.current.date(byAdding: .day, value: -30, to: compareDate!)!
    case "90 Days":
      compareDate = Calendar.current.date(byAdding: .day, value: -90, to: compareDate!)!
    default:
      compareDate = nil
    }
    var predicates = [NSPredicate]()
    if !isCustomList {
      predicates.append(NSPredicate(format: "randomType == %@", randomType))
      if id == nil {
        predicates.append(NSPredicate(format: "id = nil"))
      }
    }
    
    if let compareDate = compareDate {
      predicates.append(NSPredicate(format: "timestamp >= %@", compareDate as CVarArg))
    }
    if let id = id {
      predicates.append(NSPredicate(format: "id == %@", id))
    }
    if let customPredicate = customPredicate {
      predicates.append(customPredicate)
    }
    let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    self.predicate = compoundPredicate
//    if let id = id {
//      if compareDate == nil {
//        self.predicate = NSPredicate(format: "randomType == %@ AND id == %@", randomType, id)
//      } else {
//        self.predicate = NSPredicate(format: "randomType == %@ AND id == %@ AND timestamp >= %@", randomType, id, compareDate! as CVarArg)
//      }
//    } else {
//      if compareDate == nil {
//        self.predicate = NSPredicate(format: "randomType == %@", randomType)
//      } else {
//        self.predicate = NSPredicate(format: "randomType == %@ AND timestamp >= %@", randomType, compareDate! as CVarArg)
//      }
//    }
  }
  var body: some View {
    NavigationView {
//      List {
//        settings
//        if generatorList != nil {
//          RandomGeneratorSettings(generatorList: generatorList!)
//        }
//        NavigationLink {
//          RandomHistoryItems(predicate: predicate, timeFrame: $timeFrame, randomType: randomType, formatValue: formatValue)
//            .settings({
//              settings
//            })
//            .navigationTitle("History")
//              .onChange(of: timeFrame) { newValue in
//                setPredicate(timeFrame: newValue)
//              }
//              .onAppear(perform: {
//                setPredicate(timeFrame: timeFrame)
//              })
//        } label: {
//          Text("History")
//        }
//
//      }
      RandomHistoryItems(predicate: predicate, timeFrame: $timeFrame, randomType: randomType, formatValue: formatValue)
        .settings({
          settings
        })
          .onChange(of: timeFrame) { newValue in
            setPredicate(timeFrame: newValue)
          }
          .onAppear(perform: {
            setPredicate(timeFrame: timeFrame)
          })
      .navigationTitle("Options")
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button("Cancel") {
            presentationMode.wrappedValue.dismiss()
          }
          .foregroundColor(preferences.themeColor)
        }
      }
    }
    .accentColor(preferences.themeColor)
  }
}

extension RandomHistory {
  func settings<Content: View>(@ViewBuilder _ settings: () -> Content) -> Self {
    var copy = self
    copy.settings = AnyView(settings())
    return copy
  }
}
private struct RandomGeneratorSettings: View {
  @State private var nonRepeat = false
  @Environment(\.managedObjectContext) var moc
  let generatorList: GeneratorList
  init(generatorList: GeneratorList) {
    self.generatorList = generatorList
  }
  var body: some View {
    Section {
      Toggle("Non Repeating", isOn: $nonRepeat)
        .onChange(of: nonRepeat) { newValue in
          generatorList.nonRepeating = newValue
          try? moc.save()
        }
    } header: {
      Text("Settings")
    }

  }
}

private struct RandomHistoryItems: View {
  @FetchRequest var history: FetchedResults<Random>
  @Binding var timeFrame: String
  @State private var shareItem: Item?
  @EnvironmentObject var preferences: UserPreferences
  private var timeFrames = ["7 Days", "30 Days", "90 Days", "All Time"]
  private var settings = AnyView(EmptyView())
  
  init(predicate: NSPredicate, timeFrame: Binding<String>, randomType: String, generatorList: GeneratorList? = nil, formatValue: ((_ value: String) -> AnyView)? = nil) {
    self._history = FetchRequest(entity: Random.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Random.timestamp, ascending: false)], predicate: predicate, animation: .default)
    self.formatValue = formatValue
    self._timeFrame = timeFrame
    self.randomType = randomType
    self.generatorList = generatorList
  }
  func formatDate(date: Date?) -> String {
    if date == nil {
      return "Unknown Date"
    } else {
      let formatter = DateFormatter()
      formatter.dateFormat = "M/d/yy"
      let dateString = formatter.string(from: date!)
      formatter.dateFormat = "h:mm:ss a"
      let timeString = formatter.string(from: date!)
      return dateString+"\n"+timeString
    }
  }
  private let randomType: String
  private let generatorList: GeneratorList?
  private let formatValue: ((_ value: String) -> AnyView)?
  var body: some View {
    List {
      settings
      if generatorList != nil {
        RandomGeneratorSettings(generatorList: generatorList!)
      }
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

extension RandomHistoryItems {
  func settings(@ViewBuilder _ settings: () -> AnyView) -> Self {
    var copy = self
    copy.settings = settings()
    return copy
  }
}

private struct Item: Identifiable {
    let id = UUID()
    let url: URL
}
