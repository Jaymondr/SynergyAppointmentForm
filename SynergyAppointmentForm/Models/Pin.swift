//
//  Pin.swift
//  SynergyAppointmentForm
//
//  Created by Jaymond Richardson on 1/8/25.
//

import CoreLocation
import Firebase

class Pin {
    var firebaseID:         String
    var location:           CLLocation

    
    // Initializer
    init(firebaseID: String = "", location: CLLocation) {
        self.firebaseID = firebaseID
        self.location = location
    }
    
    // Convenience initializer to create a Pin from CLLocationCoordinate2D
    init(coordinate: CLLocationCoordinate2D) {
        self.firebaseID = "" // Initialize with an empty ID, will be set after saving
        self.location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
    
    
    required init?(firebaseData: [String: Any], firebaseID: String) {
        guard let firebaseID = firebaseData[Pin.CodingKeys.firebaseID.rawValue] as? String,
        let geoPoint = firebaseData[Pin.CodingKeys.location.rawValue] as? GeoPoint
        else { return nil }
        
        let location = CLLocation(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
        
        self.firebaseID = firebaseID
        self.location = location
    }
    
    
    var firebaseRepresentation: [String : FirestoreType] {
        let firebaseRepresentation: [String : FirestoreType] = [
            Pin.CodingKeys.firebaseID.rawValue              : firebaseID,
            Pin.CodingKeys.location.rawValue                : GeoPoint(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude
            )
        ]
        return firebaseRepresentation
    }
    
    enum CodingKeys: String, CodingKey {
        case collectionID = "Pins"
        case firebaseID
        case result
        case location
        case formInfo
    }
}
