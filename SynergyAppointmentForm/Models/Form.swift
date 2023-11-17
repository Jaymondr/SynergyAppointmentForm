//
//  FormModel.swift
//  SynergyAppointmentForm
//
//  Created by Jaymond Richardson on 11/14/23.
//

import Foundation
import CloudKit
//
//struct FormCloudStrings {
//    static let recordTypeKey = "Form"
//    fileprivate static let cMyName = "myName"
//    fileprivate static let cCKRecordID = "ckRecordID"
//    fileprivate static let cDay = "day"
//    fileprivate static let cTime = "time"
//    fileprivate static let cDate = "date"
//    fileprivate static let cFirstName = "firstName"
//    fileprivate static let cLastName = "lastName"
//    fileprivate static let cSpouse = "spouse"
//    fileprivate static let cAddress = "address"
//    fileprivate static let cZip = "zip"
//    fileprivate static let cCity = "city"
//    fileprivate static let cState = "state"
//    fileprivate static let cPhone = "phone"
//    fileprivate static let cEmail = "email"
//    fileprivate static let cNumberOfWindows = "numberOfWindows"
//    fileprivate static let cEnergyBill = "energyBill"
//    fileprivate static let cRetailQuote = "retailQuote"
//    fileprivate static let cFinanceOptions = "financeOptions"
//    fileprivate static let cYearsOwned = "yearsOwned"
//    fileprivate static let cReason = "reason"
//    fileprivate static let cRate = "rate"
//    fileprivate static let cComments = "comments"
//    fileprivate static let cBody = "body"
//}

class Form {
    
    var ckRecordID: CKRecord.ID
    var myName: String
    var day: String
    var time: String
    var date: String
    var ampm: String
    var firstName: String
    var lastName: String
    var spouse: String
    var address: String
    var zip: String
    var city: String
    var state: String
    var phone: String
    var email: String
    var numberOfWindows: String
    var energyBill: String
    var retailQuote: String
    var financeOptions: String
    var yearsOwned: String
    var reason: String
    var rate: String
    var comments: String
    
    init(ckRecordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString), myName: String = "Jaymond", day: String, time: String, date: String, ampm: String, firstName: String, lastName: String, spouse: String, address: String, zip: String, city: String, state: String, phone: String, email: String, numberOfWindows: String, energyBill: String, retailQuote: String, financeOptions: String, yearsOwned: String, reason: String, rate: String, comments: String) {
        
        self.ckRecordID = ckRecordID
        self.myName = myName
        self.day = day
        self.time = time
        self.date = date
        self.ampm = ampm
        self.firstName = firstName
        self.lastName = lastName
        self.spouse = spouse
        self.address = address
        self.zip = zip
        self.city = city
        self.state = state
        self.phone = phone
        self.email = email
        self.numberOfWindows = numberOfWindows
        self.energyBill = energyBill
        self.retailQuote = retailQuote
        self.financeOptions = financeOptions
        self.yearsOwned = yearsOwned
        self.reason = reason
        self.rate = rate
        self.comments = comments
    }
    
//    convenience init?(ckRecord: CKRecord) {
//        guard let day = ckRecord[FormCloudStrings.cDay] as? String,
//              let time = ckRecord[FormCloudStrings.cTime] as? String,
//              let date = ckRecord[FormCloudStrings.cDate] as? String,
//              let firstName = ckRecord[FormCloudStrings.cFirstName] as? String,
//              let lastName = ckRecord[FormCloudStrings.cLastName] as? String,
//              let spouse = ckRecord[FormCloudStrings.cSpouse] as? String,
//              let address = ckRecord[FormCloudStrings.cAddress] as? String,
//              let zip = ckRecord[FormCloudStrings.cZip] as? String,
//              let city = ckRecord[FormCloudStrings.cCity] as? String,
//              let state = ckRecord[FormCloudStrings.cState] as? String,
//              let phone = ckRecord[FormCloudStrings.cPhone] as? String,
//              let email = ckRecord[FormCloudStrings.cEmail] as? String,
//              let numberOfWindows = ckRecord[FormCloudStrings.cNumberOfWindows] as? String,
//              let energyBill = ckRecord[FormCloudStrings.cEnergyBill] as? String,
//              let retailQuote = ckRecord[FormCloudStrings.cRetailQuote] as? String,
//              let financeOptions = ckRecord[FormCloudStrings.cFinanceOptions] as? String,
//              let yearsOwned = ckRecord[FormCloudStrings.cYearsOwned] as? String,
//              let reason = ckRecord[FormCloudStrings.cReason] as? String,
//              let rate = ckRecord[FormCloudStrings.cRate] as? String,
//              let comments = ckRecord[FormCloudStrings.cComments] as? String
//        else { return nil }
//        self.init(day: day, time: time, date: date, firstName: firstName, lastName: lastName, spouse: spouse, address: address, zip: zip, city: city, state: state, phone: phone, email: email, numberOfWindows: numberOfWindows, energyBill: energyBill, retailQuote: retailQuote, financeOptions: financeOptions, yearsOwned: yearsOwned, reason: reason, rate: rate, comments: comments)
//    }
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
