//
//  MapGenerator.swift
//  MapGenerator
//
//  Created by Michael Horowitz on 8/30/21.
//

import SwiftUI
import MapKit

struct MapGenerator: View {
  @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), span: MKCoordinateSpan(latitudeDelta: 30, longitudeDelta: 30))
  @State private var annotations = [MapPoint]()
  @Environment(\.managedObjectContext) var moc
  var body: some View {
    ZStack {
      RandomGeneratorView("Map") {
        Map(coordinateRegion: $region, annotationItems: annotations) {
          MapMarker(coordinate: $0.coordinate, tint: nil)
        }
        .ignoresSafeArea(.all, edges: [.bottom, .horizontal])
      }
      .showRandomButton(true)
      .disablesGestures(true)
      .randomButtonOverContent(true)
      .onRandomPressed {
        updateMap()
      }
      
      
//      VStack {
//        Spacer()
//        RandomizeButton("Randomize") {
//          updateMap()
//        }
//        .shadow(color: .black.opacity(0.2), radius: 10, x: 10, y: 10)
//        .shadow(color: .black.opacity(0.2), radius: 10, x: -5, y: -5)
//        .padding(.bottom)
//      }
    }
  }
  func updateMap() {
      let longitude = Double.random(in: -179.9...179.9)
      let latitude = Double.random(in: -89.9...89.9)
      let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
      let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
      let geoCoder = CLGeocoder()
      print(geoCoder)
    annotations = [MapPoint(coordinate: coordinate)]
    region.center = coordinate
    func formatDouble(_ num: Double) -> String {
      let numberFormatter = NumberFormatter()
      numberFormatter.maximumFractionDigits = 6
      return numberFormatter.string(from: num as NSNumber) ?? ""
    }
    let coreDataItem = Random(context: moc)
    coreDataItem.timestamp = Date()
    coreDataItem.randomType = "Map"
    coreDataItem.value = "\(formatDouble(coordinate.latitude)), \(formatDouble(coordinate.longitude))"
    try? moc.save()
//      geoCoder.reverseGeocodeLocation(location) { placemarks, error in
//        if error != nil {
//          updateInterface()
//          return
//        }
//        if placemarks?.count == 0 { updateMap(); return }
//        for placemark in placemarks ?? [] {
//          if placemark.ocean != nil { updateMap(); return }
//        }
//        updateInterface()
//        
//      }
//    func updateInterface() {
//      DispatchQueue.main.async {
//        annotations = [MapPoint(coordinate: coordinate)]
//        region.center = coordinate
//      }
//    }
  }
}
private struct MapPoint: Identifiable {
  let id = UUID()
  let coordinate: CLLocationCoordinate2D
}

struct MapGenerator_Previews: PreviewProvider {
    static var previews: some View {
        MapGenerator()
    }
}
