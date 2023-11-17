//
//  FormModel.swift
//  SynergyAppointmentForm
//
//  Created by Jaymond Richardson on 11/14/23.
//

import Foundation
import CloudKit

struct CloudStrings {
    static let recordTypeKey = "Form"
    fileprivate static let cMyName = "myName"
    fileprivate static let cCKRecordID = "ckRecordID"
    fileprivate static let cDay = "day"
    fileprivate static let cTime = "time"
    fileprivate static let cDate = "date"
    fileprivate static let cFirstName = "firstName"
    fileprivate static let cLastName = "lastName"
    fileprivate static let cSpouse = "spouse"
    fileprivate static let cAddress = "address"
    fileprivate static let cZip = "zip"
    fileprivate static let cCity = "city"
    fileprivate static let cState = "state"
    fileprivate static let cPhone = "phone"
    fileprivate static let cEmail = "email"
    fileprivate static let cNumberOfWindows = "numberOfWindows"
    fileprivate static let cEnergyBill = "energyBill"
    fileprivate static let cRetailQuote = "retailQuote"
    fileprivate static let cFinanceOptions = "financeOptions"
    fileprivate static let cYearsOwned = "yearsOwned"
    fileprivate static let cReason = "reason"
    fileprivate static let cRate = "rate"
    fileprivate static let cComments = "comments"
}

class Form {
    
    var ckRecordID: CKRecord.ID
    var myName: String
    var day: String
    var time: String
    var date: String
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
    
    init(ckRecordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString), myName: String = "Jaymond", day: String, time: String, date: String, firstName: String, lastName: String, spouse: String, address: String, zip: String, city: String, state: String, phone: String, email: String, numberOfWindows: String, energyBill: String, retailQuote: String, financeOptions: String, yearsOwned: String, reason: String, rate: String, comments: String) {
        
        self.ckRecordID = ckRecordID
        self.myName = myName
        self.day = day
        self.time = time
        self.date = date
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
    
    convenience init?(ckRecord: CKRecord) {
        guard let day = ckRecord[CloudStrings.cDay] as? String,
              let time = ckRecord[CloudStrings.cTime] as? String,
              let date = ckRecord[CloudStrings.cDate] as? String,
              let firstName = ckRecord[CloudStrings.cFirstName] as? String,
              let lastName = ckRecord[CloudStrings.cLastName] as? String,
              let spouse = ckRecord[CloudStrings.cSpouse] as? String,
              let address = ckRecord[CloudStrings.cAddress] as? String,
              let zip = ckRecord[CloudStrings.cZip] as? String,
              let city = ckRecord[CloudStrings.cCity] as? String,
              let state = ckRecord[CloudStrings.cState] as? String,
              let phone = ckRecord[CloudStrings.cPhone] as? String,
              let email = ckRecord[CloudStrings.cEmail] as? String,
              let numberOfWindows = ckRecord[CloudStrings.cNumberOfWindows] as? String,
              let energyBill = ckRecord[CloudStrings.cEnergyBill] as? String,
              let retailQuote = ckRecord[CloudStrings.cRetailQuote] as? String,
              let financeOptions = ckRecord[CloudStrings.cFinanceOptions] as? String,
              let yearsOwned = ckRecord[CloudStrings.cYearsOwned] as? String,
              let reason = ckRecord[CloudStrings.cReason] as? String,
              let rate = ckRecord[CloudStrings.cRate] as? String,
              let comments = ckRecord[CloudStrings.cComments] as? String
        else { return nil }
        self.init(day: day, time: time, date: date, firstName: firstName, lastName: lastName, spouse: spouse, address: address, zip: zip, city: city, state: state, phone: phone, email: email, numberOfWindows: numberOfWindows, energyBill: energyBill, retailQuote: retailQuote, financeOptions: financeOptions, yearsOwned: yearsOwned, reason: reason, rate: rate, comments: comments)
    }
}

extension CKRecord {
    convenience init(form: Form) {
        self.init(recordType: CloudStrings.recordTypeKey)
        self.setValuesForKeys([
            CloudStrings.cDay : form.day,
            CloudStrings.cTime : form.time,
            CloudStrings.cDate : form.date,
            CloudStrings.cFirstName : form.firstName,
            CloudStrings.cLastName : form.lastName,
            CloudStrings.cSpouse : form.spouse,
            CloudStrings.cAddress : form.address,
            CloudStrings.cZip : form.zip,
            CloudStrings.cCity : form.city,
            CloudStrings.cState : form.state,
            CloudStrings.cPhone : form.phone,
            CloudStrings.cEmail : form.email,
            CloudStrings.cNumberOfWindows : form.numberOfWindows,
            CloudStrings.cEnergyBill : form.energyBill,
            CloudStrings.cRetailQuote : form.retailQuote,
            CloudStrings.cFinanceOptions : form.financeOptions,
            CloudStrings.cYearsOwned : form.yearsOwned,
            CloudStrings.cReason : form.reason,
            CloudStrings.cRate : form.rate,
            CloudStrings.cComments : form.comments
        ])
    }
}
