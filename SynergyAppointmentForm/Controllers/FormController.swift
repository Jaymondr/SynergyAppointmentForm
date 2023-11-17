//
//  FormController.swift
//  SynergyAppointmentForm
//
//  Created by Jaymond Richardson on 11/14/23.
//

import UIKit
import CoreLocation
import CloudKit

class FormController {
    
    // MARK: SHARED INSTANCE
    static let shared = FormController()
    
    // MARK: PROPERTIES
    let geocoder = CLGeocoder()
    let privateDB = CKContainer.default().privateCloudDatabase
    var formRecords: [FormRecord] = []
    
    // MARK: CRUD FUNCTIONS
    
    func createFormRecordWith(newFormRecord: FormRecord, completion: @escaping (_ form: FormRecord?, _ error: Error?) -> Void) {
        saveFormRecord(formRecord: newFormRecord) { form, error in
            if let error = error {
                print("There was an error saving your form")
                completion(nil, error)
            } else {
                guard let form = form else { return completion(nil, error) }
                completion(form, nil)
            }
        }
    }
    
    
    func fetchFormRecordsWith(completion: @escaping(_ forms: [FormRecord]?, _ error: Error?) -> Void ) {
        
        let fetchAllPredicates = NSPredicate(value: true)
        
        let query = CKQuery(recordType: FormRecordCloudStrings.recordTypeKey, predicate: fetchAllPredicates)
        privateDB.perform(query, inZoneWith: nil) { records, error in
            if let error = error { print("The error is here 1: \(error)"); return completion(nil, error) }
            
            
            guard let records = records else {return completion(nil, error)}
            print("You did the Fetching of the Forms!")
            
            let forms = records.compactMap({FormRecord(ckRecord: $0)})
            
            self.formRecords = forms
            
            
            DispatchQueue.main.async {
                for form in forms {
                    print("name: \(form.firstName), \(form.phone)")
                }

                completion(forms, nil)
            }
        }
    }
    
    func saveFormRecord(formRecord: FormRecord, completion: @escaping (_ form: FormRecord?, _ error: Error?) -> Void) {
        let formRecord = CKRecord(formRecord: formRecord)
        privateDB.save(formRecord) { (record, error) in
            if let error = error {
                print("Error: \(error)")
                return completion(nil, error)
            }
            
            guard let record = record,
                  let savedForm = FormRecord(ckRecord: record) else { completion(nil, error); return }
            print("Saved form")
            
            self.formRecords.insert(savedForm, at: 0)
            
            DispatchQueue.main.async { completion(savedForm, nil)}
        }
    }
    
    // MARK: FUNCTIONS
    func createAndCopyForm(form: Form) {

        UIPasteboard.general.string =
        """
        APT FORM
        
        Appointment Day: \(form.day)
        Time: \(form.time)
        Date: \(form.date)
        Name: \(form.firstName + " " + form.lastName)
        Spouse: \(form.spouse)
        Address: \(form.address)
        Zip: \(form.zip)
        City: \(form.city)
        State: \(form.state)
        Phone: \(form.phone)
        Email: \(form.email)
        
        Number of windows: \(form.numberOfWindows)
        Energy bill (average): \(form.energyBill)
        Retail Quote: \(form.retailQuote)
        Finance Options: \(form.financeOptions)
        Years Owned: \(form.yearsOwned)
        
        Reason you need window replacement: \(form.reason)
        
        Rate 1-10: \(form.rate)
        
        Comments: \(form.comments)
        """
    }
    
    func createFormRecord(with form: Form) -> FormRecord {
        let body = 
        """
        APT FORM
                
        Appointment Day: \(form.day)
        Time: \(form.time)
        Date: \(form.date)
        Name: \(form.firstName + " " + form.lastName)
        Spouse: \(form.spouse)
        Address: \(form.address)
        Zip: \(form.zip)
        City: \(form.city)
        State: \(form.state)
        Phone: \(form.phone)
        Email: \(form.email)
                
                Number of windows: \(form.numberOfWindows)
        Energy bill (average): \(form.energyBill)
        Retail Quote: \(form.retailQuote)
        Finance Options: \(form.financeOptions)
        Years Owned: \(form.yearsOwned)
                
        Reason you need window replacement: \(form.reason)
                
        Rate 1-10: \(form.rate)
                
        Comments: \(form.comments)
        """
        let formRecord = FormRecord(firstName: form.firstName, lastName: form.lastName, day: form.day, time: form.time, date: form.date, address: form.address, phone: form.phone, body: body)
        return formRecord
    }
    
    func createAndCopyTrello(form: Form) {
        UIPasteboard.general.string =
        """
        \(form.day) \(form.date) @\(form.time) \(form.firstName) & \(form.spouse) \(form.lastName) (\(form.city)) -\(form.myName)
        """
    }
    
    func createAndCopy(phone: String) {
        UIPasteboard.general.string = phone
    }
    
    func createText(from form: Form) -> String {
        let text =
        """
        Hey \(form.firstName), it's \(form.myName) with Synergy.
        
        Your appointment is good to go for \(form.day) \(form.date) at \(form.time). Thanks for your time, and if you need anything just call or text!
        
        - Jaymond
        """
        return text
    }
    
    // LOCATION
    func getLocationData(manager: inout CLLocationManager, completion: @escaping (Address?) -> Void) {
        manager.startUpdatingLocation()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        // FILL LOCATION INFO
        if let location = manager.location {
            geocoder.reverseGeocodeLocation(location, preferredLocale: .current) { placemarks, error in
                guard let place = placemarks?.first, error == nil else {
                    completion(nil)
                    return
                }
                
                let address = place.name ?? ""
                let zip = place.postalCode ?? ""
                let city = place.locality ?? ""
                let state = place.administrativeArea ?? ""
                
                let addressObject = Address(address: address, zip: zip, city: city, state: state)
                completion(addressObject)
            }
        } else {
            print("No location")
            completion(nil)
        }
        manager.stopUpdatingLocation()
    }
}
