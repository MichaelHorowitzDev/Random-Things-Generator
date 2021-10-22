//
//  MapGenerator.swift
//  MapGenerator
//
//  Created by Michael Horowitz on 8/30/21.
//

import SwiftUI
import MapKit

private class MapLocation: ObservableObject {
  @Published var region = MKCoordinateRegion()
  @Published var annotations = [MapPoint]()
  
  init() {
    region.span = MKCoordinateSpan(latitudeDelta: 30, longitudeDelta: 30)
    let longitude = Double.random(in: -179...179.9)
    let latitude = Double.random(in: -89.9...89.9)
    let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    region.center = location
    annotations = [MapPoint(coordinate: location)]
  }
  
  func updateMap(location: CLLocationCoordinate2D) {
    withAnimation(.easeInOut(duration: 0.2)) {
      region.center = location
      annotations = [MapPoint(coordinate: location)]
    }
    
  }
}

struct MapGenerator: View {
  @StateObject private var mapLocation = MapLocation()
  @Environment(\.managedObjectContext) var moc
  var body: some View {
    ZStack {
      RandomGeneratorView("Map") {
        Map(coordinateRegion: $mapLocation.region, annotationItems: mapLocation.annotations) {
          MapMarker(coordinate: $0.coordinate, tint: nil)
        }
        .ignoresSafeArea(.all, edges: [.bottom, .horizontal])
      }
      .overrideShowRandomButton(true)
      .disablesGestures(true)
      .randomButtonOverContent(true)
      .generateRandom({
        return {
          let longitude = Double.random(in: -179...179.9)
          let latitude = Double.random(in: -89.9...89.9)
          
          guard let longitudeString = longitude.trim(fractionDigits: 6) else { return ""}
          guard let latitudeString = latitude.trim(fractionDigits: 6) else { return "" }
          return "\(latitudeString), \(longitudeString)"
        }
      })
      .onRandomSuccess { result in
        let coordinates = result.replacingOccurrences(of: ", ", with: "\n").split(separator: "\n")
        if coordinates.count != 2 { return }
        guard let latitude = Double(coordinates[0]) else { return }
        guard let longitude = Double(coordinates[1]) else { return }
        let locationCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        mapLocation.updateMap(location: locationCoordinate)
        guard let longitudeString = longitude.trim(fractionDigits: 6) else { return }
        guard let latitudeString = latitude.trim(fractionDigits: 6) else { return }
        let coreDataItem = Random(context: moc)
        coreDataItem.timestamp = Date()
        coreDataItem.randomType = "Map"
        coreDataItem.value = "\(latitudeString), \(longitudeString)"
        try? moc.save()
      }
    }
  }
}
private struct MapPoint: Identifiable, Equatable {
  static func == (lhs: MapPoint, rhs: MapPoint) -> Bool {
    lhs.id == rhs.id
  }
  
  let id = UUID()
  let coordinate: CLLocationCoordinate2D
}

struct MapGenerator_Previews: PreviewProvider {
    static var previews: some View {
        MapGenerator()
    }
}
