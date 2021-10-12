//
//  GenerateMultipleTimesStatistics.swift
//  Random Things Generator
//
//  Created by Michael Horowitz on 10/10/21.
//

import SwiftUI

struct GenerateMultipleTimesStatistics: View {
  let results: [String]
  @State private var sortedItems: [Common<String>]
  @State private var sortedBy: String = "Most Common"
  let sorts = ["Most Common", "Least Common"]
  init(results: [String]) {
    self.results = results
    self._sortedItems = State(initialValue: results.mostCommon())
  }
    var body: some View {
      List {
        Section {
          ForEach(0..<sortedItems.count, id: \.self) { num in
            HStack {
              Text("\(num+1). ")
                .font(.title)
              Spacer()
              Text(sortedItems[num].item)
                .font(.title)
                .bold()
                .minimumScaleFactor(0.1)
                .padding(.trailing)
              Text("\(sortedItems[num].num)")
                .font(.title2)
            }
          }
        } header: {
          HStack {
            Text("Sorted By")
            Spacer()
            Picker("Time Range", selection: $sortedBy) {
              ForEach(sorts, id: \.self) {
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
          .onChange(of: sortedBy) { newValue in
            print(sortedBy)
            print(newValue)
            switch newValue {
            case "Most Common":
              sortedItems = results.mostCommon()
            case "Least Common":
              sortedItems = results.leastCommon()
            default:
              break
            }
          }
        }
      }
      .navigationTitle("Statistics")
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          CSVSaver(namePrefix: "generate_multiple_statistics", rows: (sortedItems.map { [$0.item, $0.num.description] })) {
            Image(systemName: "square.and.arrow.up")
          }
        }
      }
    }
}
