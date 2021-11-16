//
//  GenerateMultipleTimes.swift
//  Random Things Generator
//
//  Created by Michael Horowitz on 10/9/21.
//

import SwiftUI
import Combine

struct GenerateMultipleTimes<Format: View>: View {
  @State private var showsAlert = false
  let function: () -> String
  let formatValue: ((String) -> Format)?
  init(_ function: @escaping () -> String, formatValue: ((_ value: String) -> Format)? = nil) {
    self.function = function
    self.formatValue = formatValue
  }
  @State private var results = [String]()
  @State private var sheetPresented = false
  @State private var numberOfTimes = ""
  @State private var generateStatistics = false
  @State private var shareItem: ShareItem?
  @FocusState private var focused: Bool
  @EnvironmentObject var preferences: UserPreferences
    var body: some View {
//      NavigationView {
        VStack {
          HStack {
            TextField("Generate Multiple Times", text: $numberOfTimes, prompt: Text("Number of times"))
              .onReceive(Just(numberOfTimes)) { newValue in
                var filtered = newValue.filter {"0123456789".contains($0)}
                if filtered.count > 5 {
                  filtered = String(filtered.prefix(5))
                }
                numberOfTimes = filtered
              }
              .keyboardType(.numberPad)
              .textFieldStyle(.roundedBorder)
              .focused($focused)
            Button {
              UIImpactFeedbackGenerator(style: .light).impactOccurred()
              if let number = Int(numberOfTimes) {
                if number > 0 {
                  let results = (1...number).map {_ in
                    function()
                  }
                  self.results = results
                  focused = false
                }
              }
            } label: {
              Text("Generate")
                .foregroundColor(.white)
                .padding(5)
            }
            .background(.blue)
            .cornerRadius(10)
          }
          .padding(.horizontal)
          List(0..<results.count, id: \.self) { num in
            HStack {
              Text("\(num+1). ")
                .font(.title)
              Spacer()
              if formatValue != nil {
                formatValue!(results[num])
              } else {
                Text(results[num])
                  .font(.title)
              }
            }
            .padding(.vertical, 5)
          }
          NavigationLink(isActive: $generateStatistics) {
            GenerateMultipleTimesStatistics(results: results)
          } label: {
            EmptyView()
          }
        }
        .sheet(item: $shareItem, onDismiss: {
          shareItem = nil
        }, content: { item in
          ShareSheet(activityItems: [item.url])
        })
        .navigationTitle("Multiple Generator")
        .toolbar {
          ToolbarItem(placement: .navigationBarTrailing) {
            Menu {
              if !results.isEmpty {
                Button {
                  generateStatistics = true
                } label: {
                  HStack {
                    Text("Statistics")
                    Image(systemName: "chart.bar")
                  }
                }
                Button {
                  let saver = CSVSave(namePrefix: "generate_multiple_times", rows: [results])
                  let url = saver.save()
                  shareItem = ShareItem(url: url)
                } label: {
                  HStack {
                    Text("Save")
                    Image(systemName: "square.and.arrow.down")
                  }
                }
              }
            } label: {
              Image(systemName: "ellipsis")
            }
          }
        }
    }
}
private struct ResultsItem: Identifiable {
  let id = UUID()
  let results: [String]
}
