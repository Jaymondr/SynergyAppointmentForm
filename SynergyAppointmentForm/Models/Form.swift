//
//  FormModel.swift
//  SynergyAppointmentForm
//
//  Created by Jaymond Richardson on 11/14/23.
//

import Foundation
import CloudKit
//
struct FormFirebaseKey {
    static let collectionID = "Forms"
    static let fMyName = "myName"
    static let fFirebaseID = "firebaseID"
    static let fDay = "day"
    static let fTime = "time"
    static let fDate = "date"
    static let fFirstName = "firstName"
    static let fLastName = "lastName"
    static let fSpouse = "spouse"
    static let fAddress = "address"
    static let fZip = "zip"
    static let fCity = "city"
    static let fState = "state"
    static let fPhone = "phone"
    static let fEmail = "email"
    static let fNumberOfWindows = "numberOfWindows"
    static let fEnergyBill = "energyBill"
    static let fRetailQuote = "retailQuote"
    static let fFinanceOptions = "financeOptions"
    static let fYearsOwned = "yearsOwned"
    static let fReason = "reason"
    static let fRate = "rate"
    static let fComments = "comments"
    static let fBody = "body"
    static let fAmpm = "ampm"
}

class Form {
    
    var address: String
    var ampm: String
    var city: String
    var comments: String
    var date: String
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
    var yearsOwned: String
    var zip: String
    
    init(address: String, ampm: String, city: String, comments: String, date: String, day: String, email: String, energyBill: String, financeOptions: String, firstName: String, lastName: String, numberOfWindows: String, phone: String, rate: String, reason: String, retailQuote: String, spouse: String, state: String, time: String, yearsOwned: String, zip: String) {
        
        self.address = address
        self.ampm = ampm
        self.city = city
        self.comments = comments
        self.date = date
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
        self.yearsOwned = yearsOwned
        self.zip = zip

    }
    
    convenience init?(firebaseID: String, firebaseData: [String : Any]) {
        let address = firebaseData[FormFirebaseKey.fAddress] as? String ?? ""
        let ampm = firebaseData[FormFirebaseKey.fAmpm] as? String ?? ""
        let city = firebaseData[FormFirebaseKey.fCity] as? String ?? ""
        let comments = firebaseData[FormFirebaseKey.fComments] as? String ?? ""
        let date = firebaseData[FormFirebaseKey.fDate] as? String ?? ""
        let day = firebaseData[FormFirebaseKey.fDay] as? String ?? ""
        let email = firebaseData[FormFirebaseKey.fEmail] as? String ?? ""
        let energyBill = firebaseData[FormFirebaseKey.fEnergyBill] as? String ?? ""
        let financeOptions = firebaseData[FormFirebaseKey.fFinanceOptions] as? String ?? ""
        let firstName = firebaseData[FormFirebaseKey.fFirstName] as? String ?? ""
        let lastName = firebaseData[FormFirebaseKey.fLastName] as? String ?? ""
        let numberOfWindows = firebaseData[FormFirebaseKey.fNumberOfWindows] as? String ?? ""
        let phone = firebaseData[FormFirebaseKey.fPhone] as? String ?? ""
        let rate = firebaseData[FormFirebaseKey.fRate] as? String ?? ""
        let reason = firebaseData[FormFirebaseKey.fReason] as? String ?? ""
        let retailQuote = firebaseData[FormFirebaseKey.fRetailQuote] as? String ?? ""
        let spouse = firebaseData[FormFirebaseKey.fSpouse] as? String ?? ""
        let state = firebaseData[FormFirebaseKey.fState] as? String ?? ""
        let time = firebaseData[FormFirebaseKey.fTime] as? String ?? ""
        let yearsOwned = firebaseData[FormFirebaseKey.fYearsOwned] as? String ?? ""
        let zip = firebaseData[FormFirebaseKey.fZip] as? String ?? ""

        
        self.init(address: address, ampm: ampm, city: city, comments: comments, date: date, day: day, email: email, energyBill: energyBill, financeOptions: financeOptions, firstName: firstName, lastName: lastName, numberOfWindows: numberOfWindows, phone: phone, rate: rate, reason: reason, retailQuote: retailQuote, spouse: spouse, state: state, time: time, yearsOwned: yearsOwned, zip: zip)


    }
    
    static func firebaseRepresentation(form: Form, completion: @escaping (_ formDictionary: [String : Any]) -> Void) {
        let data = [
        FormFirebaseKey.fAddress : form.address,
        FormFirebaseKey.fAmpm : form.ampm,
        // TODO: Finish
        ]
        
        completion(data)
    }
}

//extension CKRecord {
//    convenience init(form: Form) {
//        self.init(recordType: FormCloudStrings.recordTypeKey)
//        self.setValuesForKeys([
//            FormCloudStrings.cDay : form.day,
//            FormCloudStrings.cTime : form.time,
//            FormCloudStrings.cDate : form.date,
//            FormCloudStrings.cFirstName : form.firstName,
//            FormCloudStrings.cLastName : form.lastName,
//            FormCloudStrings.cSpouse : form.spouse,
//            FormCloudStrings.cAddress : form.address,
//            FormCloudStrings.cZip : form.zip,
//            FormCloudStrings.cCity : form.city,
//            FormCloudStrings.cState : form.state,
//            FormCloudStrings.cPhone : form.phone,
//            FormCloudStrings.cEmail : form.email,
//            FormCloudStrings.cNumberOfWindows : form.numberOfWindows,
//            FormCloudStrings.cEnergyBill : form.energyBill,
//            FormCloudStrings.cRetailQuote : form.retailQuote,
//            FormCloudStrings.cFinanceOptions : form.financeOptions,
//            FormCloudStrings.cYearsOwned : form.yearsOwned,
//            FormCloudStrings.cReason : form.reason,
//            FormCloudStrings.cRate : form.rate,
//            FormCloudStrings.cComments : form.comments
//        ])
//    }
    
//    convenience init(formRecord: FormRecord) {
//        self.init(recordType: FormCloudStrings.recordTypeKey)
//        self.setValuesForKeys([
//            FormCloudStrings.cFirstName : formRecord.firstName,
//            FormCloudStrings.cLastName : formRecord.lastName,
//            FormCloudStrings.cDay : formRecord.day,
//            FormCloudStrings.cTime : formRecord.time,
//            FormCloudStrings.cDate : formRecord.date,
//            FormCloudStrings.cPhone : formRecord.phoneNumber,
//            FormCloudStrings.cBody : formRecord.body
//        ])
//    }
//}
