//
//  FormModel.swift
//  SynergyAppointmentForm
//
//  Created by Jaymond Richardson on 11/14/23.
//

import Foundation
import CloudKit
//
struct FirebaseKeys {
    static let collectionID = "Forms"
    static let firbaseID = "firebaseID"
    static let fAmpm = "ampm"
    static let fAddress = "address"
    static let fBody = "body"
    static let fCity = "city"
    static let fComments = "comments"
    static let fDate = "date"
    static let fDateString = "dateString"
    static let fDay = "day"
    static let fEmail = "email"
    static let fEnergyBill = "energyBill"
    static let fFirstName = "firstName"
    static let fFinanceOptions = "financeOptions"
    static let fFirebaseID = "firebaseID"
    static let fLastName = "lastName"
    static let fMyName = "myName"
    static let fNumberOfWindows = "numberOfWindows"
    static let fPhone = "phone"
    static let fRate = "rate"
    static let fReason = "reason"
    static let fRetailQuote = "retailQuote"
    static let fSpouse = "spouse"
    static let fState = "state"
    static let fTime = "time"
    static let fYear = "year"
    static let fYearsOwned = "yearsOwned"
    static let fZip = "zip"
}

class Form {
    
    var firebaseID: String
    var address: String
    var ampm: String
    var city: String
    var comments: String
    var date: String
    var dateString: String
    var day: String
    var email: String
    var energyBill: String
    var financeOptions: String
    var firstName: String
    var lastName: String
    var numberOfWindows: String
    var phone: String
    var rate: String
    var reason: String
    var retailQuote: String
    var spouse: String
    var state: String
    var time: String
    var year: String
    var yearsOwned: String
    var zip: String
    
    init(firebaseID: String = "formError", address: String, ampm: String, city: String, comments: String, date: String, dateString: String, day: String, email: String, energyBill: String, financeOptions: String, firstName: String, lastName: String, numberOfWindows: String, phone: String, rate: String, reason: String, retailQuote: String, spouse: String, state: String, time: String, year: String, yearsOwned: String, zip: String) {
        
        self.firebaseID = firebaseID
        self.address = address
        self.ampm = ampm
        self.city = city
        self.comments = comments
        self.date = date
        self.dateString = dateString
        self.day = day
        self.email = email
        self.energyBill = energyBill
        self.financeOptions = financeOptions
        self.firstName = firstName
        self.lastName = lastName
        self.numberOfWindows = numberOfWindows
        self.phone = phone
        self.rate = rate
        self.reason = reason
        self.retailQuote = retailQuote
        self.spouse = spouse
        self.state = state
        self.time = time
        self.year = year
        self.yearsOwned = yearsOwned
        self.zip = zip

    }
    
    convenience init(firebaseID: String, firebaseData: [String : Any]) {
        let firebaseID = firebaseData[FirebaseKeys.fFirebaseID] as? String ?? ""
        let address = firebaseData[FirebaseKeys.fAddress] as? String ?? ""
        let ampm = firebaseData[FirebaseKeys.fAmpm] as? String ?? ""
        let city = firebaseData[FirebaseKeys.fCity] as? String ?? ""
        let comments = firebaseData[FirebaseKeys.fComments] as? String ?? ""
        let date = firebaseData[FirebaseKeys.fDate] as? String ?? ""
        let dateString = firebaseData[FirebaseKeys.fDateString] as? String ?? ""
        let day = firebaseData[FirebaseKeys.fDay] as? String ?? ""
        let email = firebaseData[FirebaseKeys.fEmail] as? String ?? ""
        let energyBill = firebaseData[FirebaseKeys.fEnergyBill] as? String ?? ""
        let financeOptions = firebaseData[FirebaseKeys.fFinanceOptions] as? String ?? ""
        let firstName = firebaseData[FirebaseKeys.fFirstName] as? String ?? ""
        let lastName = firebaseData[FirebaseKeys.fLastName] as? String ?? ""
        let numberOfWindows = firebaseData[FirebaseKeys.fNumberOfWindows] as? String ?? ""
        let phone = firebaseData[FirebaseKeys.fPhone] as? String ?? ""
        let rate = firebaseData[FirebaseKeys.fRate] as? String ?? ""
        let reason = firebaseData[FirebaseKeys.fReason] as? String ?? ""
        let retailQuote = firebaseData[FirebaseKeys.fRetailQuote] as? String ?? ""
        let spouse = firebaseData[FirebaseKeys.fSpouse] as? String ?? ""
        let state = firebaseData[FirebaseKeys.fState] as? String ?? ""
        let time = firebaseData[FirebaseKeys.fTime] as? String ?? ""
        let year = firebaseData[FirebaseKeys.fYear] as? String ?? ""
        let yearsOwned = firebaseData[FirebaseKeys.fYearsOwned] as? String ?? ""
        let zip = firebaseData[FirebaseKeys.fZip] as? String ?? ""

        
        self.init(firebaseID: firebaseID, address: address, ampm: ampm, city: city, comments: comments, date: date, dateString: dateString, day: day, email: email, energyBill: energyBill, financeOptions: financeOptions, firstName: firstName, lastName: lastName, numberOfWindows: numberOfWindows, phone: phone, rate: rate, reason: reason, retailQuote: retailQuote, spouse: spouse, state: state, time: time, year: year, yearsOwned: yearsOwned, zip: zip)


    }
    
    static func firebaseRepresentation(form: Form) -> [String : Any] {
        let data = [
            FirebaseKeys.fFirebaseID: form.firebaseID ?? "",
            FirebaseKeys.fAddress: form.address,
            FirebaseKeys.fAmpm: form.ampm.lowercased(),
            FirebaseKeys.fCity: form.city,
            FirebaseKeys.fComments: form.comments,
            FirebaseKeys.fDate: form.date,
            FirebaseKeys.fDateString: form.dateString,
            FirebaseKeys.fDay: form.day,
            FirebaseKeys.fEmail: form.email,
            FirebaseKeys.fEnergyBill: form.energyBill,
            FirebaseKeys.fFinanceOptions: form.financeOptions,
            FirebaseKeys.fFirstName: form.firstName,
            FirebaseKeys.fLastName: form.lastName,
            FirebaseKeys.fNumberOfWindows: form.numberOfWindows,
            FirebaseKeys.fPhone: form.phone,
            FirebaseKeys.fRate: form.rate,
            FirebaseKeys.fReason: form.reason,
            FirebaseKeys.fRetailQuote: form.retailQuote,
            FirebaseKeys.fSpouse: form.spouse,
            FirebaseKeys.fState: form.state,
            FirebaseKeys.fTime: form.time,
            FirebaseKeys.fYear: form.year,
            FirebaseKeys.fYearsOwned: form.yearsOwned,
            FirebaseKeys.fZip: form.zip
        ]
        return data
    }
}
