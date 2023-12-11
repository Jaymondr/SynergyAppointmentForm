//
//  User.swift
//  SynergyAppointmentForm
//
//  Created by Jaymond Richardson on 12/1/23.
//

import Foundation

class User: FirebaseModel {
    static let collectionKey = "Users"
    var email: String
    var firebaseID: String
    var firstName: String
    var lastName: String
    
    init(email: String, firebaseID: String, firstName: String, lastName: String) {
        self.email = email
        self.firebaseID = firebaseID
        self.firstName = firstName
        self.lastName = lastName
    }
    
    var firebaseRepresentation: [String : FirestoreType] {
        let firebaseRepresentation: [String : FirestoreType] = [
            User.CodingKeys.email.rawValue          : email,
            User.CodingKeys.firebaseID.rawValue              : firebaseID,
            User.CodingKeys.firstName.rawValue               : firstName,
            User.CodingKeys.lastName.rawValue                : lastName
        ]
        
        return firebaseRepresentation
    }
    
    required init?(firebaseData: [String : Any], firebaseID: String) {
        guard let email = firebaseData[Form.CodingKeys.email.rawValue] as? String,
              let firstName = firebaseData[Form.CodingKeys.firstName.rawValue] as? String,
              let lastName = firebaseData[Form.CodingKeys.lastName.rawValue] as? String

        else { return nil }
        
        self.firebaseID = firebaseID
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
    }
    
    enum CodingKeys: String, CodingKey {
        case email = "email"
        case firebaseID = "firebaseID"
        case firstName = "firstName"
        case lastName = "lastName"
        
        // CHANGE FOR NEW USER
        case userID = "scottP"
        case userFirstName = "Scott"
        case userLastName = "Pilgram"
        case userEmail = "spilgram@synergywindow.com"
    }
}

