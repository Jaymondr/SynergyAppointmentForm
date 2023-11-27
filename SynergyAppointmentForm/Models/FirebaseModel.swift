//
//  FirebaseModel.swift
//  SynergyAppointmentForm
//
//  Created by Jaymond Richardson on 11/26/23.
//

import Foundation

protocol FirebaseModel {
    static var collectionKey: String { get }
    var firebaseID: String { get }
    var firebaseRepresentation: [String: FirestoreType] { get }
    
    init?(firebaseData: [String: Any], firebaseID: String)
}
