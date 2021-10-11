//
//  GenerateMultipleTimes.swift
//  Random Things Generator
//
//  Created by Michael Horowitz on 10/9/21.
//

import SwiftUI
import Combine

struct GenerateMultipleTimes: View {
  @State private var showsAlert = false
  let function: () -> String
  let formatValue: ((String) -> AnyView)?
  init(_ function: @escaping () -> String, formatValue: ((_ value: String) -> AnyView)? = nil) {
    self.function = function
    self.formatValue = formatValue
  }
  @State private var results = [String]()
  @State private var sheetPresented = false
  @State private var numberOfTimes = ""
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
            Button {
              if let number = Int(numberOfTimes) {
                if number > 0 {
                  let results = (1...number).map {_ in
                    function()
                  }
                  self.results = results
                }
              }
            } label: {
              Text("Generate")
                .foregroundColor(.white)
                .padding(5)
//                .padding(.vertical, )
                .background(.blue)
                .cornerRadius(10)
            }
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
        }
        .navigationTitle("Multiple Generator")
        .toolbar {
          ToolbarItem(placement: .navigationBarTrailing) {
            Menu {
              NavigationLink {
                GenerateMultipleTimesStatistics(results: results)
              } label: {
                Text("Results Statistics")
              }

            } label: {
              Image(systemName: "ellipsis")
            }
          }
//          ToolbarItem(placement: .navigationBarTrailing) {
//            CSVSaver(namePrefix: "multiple_generator", rows: [results])
//          }
        }
        
//      }
//      if showsAlert {
//        TextFieldAlert(show: $showsAlert, title: "Generate multiple times", message: "Generate a random item multiple times", placeholder: "Number of times") { string in
//          if let numberOfTimes = Int(string ?? "") {
//            if numberOfTimes > 0 {
//              let results = (1...numberOfTimes).map { _ in
//                function()
//              }
//              self.results = ResultsItem(results: results)
//              print(results)
//              print(results.count)
//            }
//          }
//        }
//      }
//      Button {
//        showsAlert = true
//      } label: {
//        Text("Generate multiple times")
//      }
//      .sheet(item: $results) { results in
//        NavigationView {
//          #warning("sheet dismisses itself")
//          List(0..<results.results.count, id: \.self) {_ in
//            Text("dsad")
////            Text(results.results[$0])
//          }
//          .navigationTitle("Generated")
//        }
//      }
    }
}
private struct ResultsItem: Identifiable {
  let id = UUID()
  let results: [String]
}

//struct GenerateMultipleTimes_Previews: PreviewProvider {
//    static var previews: some View {
//        GenerateMultipleTimes()
//    }
//}
