//
//  FormRecord.swift
//  SynergyAppointmentForm
//
//  Created by Jaymond Richardson on 11/17/23.
//

import Foundation
import CloudKit

struct FormRecordCloudStrings {
    static let recordTypeKey = "FormRecord"
    fileprivate static let cCKRecordID = "ckRecordID"
    fileprivate static let cDay = "day"
    fileprivate static let cTime = "time"
    fileprivate static let cDate = "date"
    fileprivate static let cFirstName = "firstName"
    fileprivate static let cLastName = "lastName"
    fileprivate static let cAddress = "address"
    fileprivate static let cPhone = "phone"
    fileprivate static let cBody = "body"
}

class FormRecord {
    var ckRecordID: CKRecord.ID
    var firstName: String
    var lastName: String
    var day: String
    var time: String
    var date: String
    var address: String
    var phone: String
    var body: String
    
    init(ckRecordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString), firstName: String, lastName: String, day: String, time: String, date: String, address: String, phone: String, body: String) {
        self.ckRecordID = ckRecordID
        self.firstName = firstName
        self.lastName = lastName
        self.day = day
        self.time = time
        self.date = date
        self.address = address
        self.phone = phone
        self.body = body
    }
    
    convenience init?(ckRecord: CKRecord) {
        guard let firstName = ckRecord[FormRecordCloudStrings.cFirstName] as? String,
              let lastName = ckRecord[FormRecordCloudStrings.cLastName] as? String,
              let day = ckRecord[FormRecordCloudStrings.cDay] as? String,
              let time = ckRecord[FormRecordCloudStrings.cTime] as? String,
              let date = ckRecord[FormRecordCloudStrings.cDate] as? String,
              let address = ckRecord[FormRecordCloudStrings.cAddress] as? String,
              let phone = ckRecord[FormRecordCloudStrings.cPhone] as? String,
              let body = ckRecord[FormRecordCloudStrings.cBody] as? String
        else { return nil }
        self.init(firstName: firstName, lastName: lastName, day: day, time: time, date: date, address: address, phone: phone, body: body)
    }
    
}
extension CKRecord {
    convenience init(formRecord: FormRecord) {
        self.init(recordType: FormRecordCloudStrings.recordTypeKey)
        self.setValuesForKeys([
            FormRecordCloudStrings.cFirstName : formRecord.firstName,
            FormRecordCloudStrings.cLastName : formRecord.lastName,
            FormRecordCloudStrings.cDay : formRecord.day,
            FormRecordCloudStrings.cTime : formRecord.time,
            FormRecordCloudStrings.cDate : formRecord.date,
            FormRecordCloudStrings.cPhone : formRecord.phone,
            FormRecordCloudStrings.cBody : formRecord.body
        ])
    }
}
