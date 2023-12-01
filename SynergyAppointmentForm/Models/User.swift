//
//  User.swift
//  SynergyAppointmentForm
//
//  Created by Jaymond Richardson on 12/1/23.
//

import Foundation

class User {
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
}
