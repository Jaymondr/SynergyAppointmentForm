//
//  FormModel.swift
//  SynergyAppointmentForm
//
//  Created by Jaymond Richardson on 11/14/23.
//

import Foundation
import CloudKit
import Firebase
import FirebaseFirestore

class Form: FirebaseModel {
    static var collectionKey: String = "Forms"
    var firebaseID: String
    var address: String
    var city: String
    var comments: String
    var date: Date
    var email: String
    var energyBill: String
    var financeOptions: String
    var firstName: String
    var lastName: String
    var notes: String?
    var numberOfWindows: String
    var outcome: Outcome
    var phone: String
    var rate: String
    var reason: String
    var retailQuote: String
    var spouse: String
    var state: String
    var yearsOwned: String
    var zip: String
    
    init(firebaseID: String, address: String, city: String, comments: String, date: Date, email: String, energyBill: String, financeOptions: String, firstName: String, lastName: String, notes: String = "", numberOfWindows: String, outcome: Outcome = .pending, phone: String, rate: String, reason: String, retailQuote: String, spouse: String, state: String, yearsOwned: String, zip: String) {
        
        self.firebaseID = firebaseID
        self.address = address
        self.city = city
        self.comments = comments
        self.date = date
        self.email = email
        self.energyBill = energyBill
        self.financeOptions = financeOptions
        self.firstName = firstName
        self.lastName = lastName
        self.notes = notes
        self.numberOfWindows = numberOfWindows
        self.outcome = outcome
        self.phone = phone
        self.rate = rate
        self.reason = reason
        self.retailQuote = retailQuote
        self.spouse = spouse
        self.state = state
        self.yearsOwned = yearsOwned
        self.zip = zip

    }
    
    required init?(firebaseData: [String : Any], firebaseID: String) {
        guard let address = firebaseData[Form.CodingKeys.address.rawValue] as? String,
              let city = firebaseData[Form.CodingKeys.city.rawValue] as? String,
              let comments = firebaseData[Form.CodingKeys.comments.rawValue] as? String,
              let date = (firebaseData[Form.CodingKeys.date.rawValue] as? Timestamp)?.dateValue(),
              let email = firebaseData[Form.CodingKeys.email.rawValue] as? String,
              let energyBill = firebaseData[Form.CodingKeys.energyBill.rawValue] as? String,
              let financeOptions = firebaseData[Form.CodingKeys.financeOptions.rawValue] as? String,
              let firstName = firebaseData[Form.CodingKeys.firstName.rawValue] as? String,
              let lastName = firebaseData[Form.CodingKeys.lastName.rawValue] as? String,
              let numberOfWindows = firebaseData[Form.CodingKeys.numberOfWindows.rawValue] as? String,
              let outcomeString = firebaseData[Form.CodingKeys.outcome.rawValue] as? String,
              let phone = firebaseData[Form.CodingKeys.phone.rawValue] as? String,
              let rate = firebaseData[Form.CodingKeys.rate.rawValue] as? String,
              let reason = firebaseData[Form.CodingKeys.reason.rawValue] as? String,
              let retailQuote = firebaseData[Form.CodingKeys.retailQuote.rawValue] as? String,
              let spouse = firebaseData[Form.CodingKeys.spouse.rawValue] as? String,
              let state = firebaseData[Form.CodingKeys.state.rawValue] as? String,
              let yearsOwned = firebaseData[Form.CodingKeys.yearsOwned.rawValue] as? String,
              let zip = firebaseData[Form.CodingKeys.zip.rawValue] as? String

        else { return nil }
        
        let notes = firebaseData[Form.CodingKeys.notes.rawValue] as? String
        let outcome = Outcome.fromString(outcomeString)
        
        self.firebaseID = firebaseID
        self.firstName = firstName
        self.lastName = lastName
        self.date = date
        self.city = city
        self.state = state
        self.spouse = spouse
        self.address = address
        self.email = email
        self.energyBill = energyBill
        self.retailQuote = retailQuote
        self.outcome = outcome
        self.phone = phone
        self.reason = reason
        self.comments = comments
        self.financeOptions = financeOptions
        self.notes = notes
        self.numberOfWindows = numberOfWindows
        self.yearsOwned = yearsOwned
        self.zip = zip
        self.rate = rate
    }
    
    var firebaseRepresentation: [String : FirestoreType] {
        var firebaseRepresentation: [String : FirestoreType] = [
            Form.CodingKeys.address.rawValue           : address,
            Form.CodingKeys.city.rawValue              : city,
            Form.CodingKeys.comments.rawValue          : comments,
            Form.CodingKeys.date.rawValue              : Timestamp(date: date),
            Form.CodingKeys.email.rawValue             : email,
            Form.CodingKeys.energyBill.rawValue        : energyBill,
            Form.CodingKeys.financeOptions.rawValue    : financeOptions,
            Form.CodingKeys.firstName.rawValue         : firstName,
            Form.CodingKeys.lastName.rawValue          : lastName,
            Form.CodingKeys.notes.rawValue             : notes ?? NSNull(),
            Form.CodingKeys.numberOfWindows.rawValue   : numberOfWindows,
            Form.CodingKeys.outcome.rawValue           : outcome.rawValue,
            Form.CodingKeys.phone.rawValue             : phone,
            Form.CodingKeys.rate.rawValue              : rate,
            Form.CodingKeys.reason.rawValue            : reason,
            Form.CodingKeys.retailQuote.rawValue       : retailQuote,
            Form.CodingKeys.spouse.rawValue            : spouse,
            Form.CodingKeys.state.rawValue             : state,
            Form.CodingKeys.yearsOwned.rawValue        : yearsOwned,
            Form.CodingKeys.zip.rawValue               : zip
        ]
        
        return firebaseRepresentation
    }
    
    enum CodingKeys: String, CodingKey {
        case collectionID = "Forms"
        case deletedCollectionID = "DeletedForms"
        case firebaseID = "firebaseID"
        case ampm = "ampm"
        case address = "address"
        case body = "body"
        case city = "city"
        case comments = "comments"
        case date = "date"
        case email = "email"
        case energyBill = "energyBill"
        case firstName = "firstName"
        case financeOptions = "financeOptions"
        case lastName = "lastName"
        case notes = "notes"
        case numberOfWindows = "numberOfWindows"
        case outcome = "outcome"
        case phone = "phone"
        case rate = "rate"
        case reason = "reason"
        case retailQuote = "retailQuote"
        case spouse = "spouse"
        case state = "state"
        case yearsOwned = "yearsOwned"
        case zip = "zip"
    }
}




