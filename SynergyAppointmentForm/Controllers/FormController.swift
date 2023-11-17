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
    var forms: [Form] = []
    
    // MARK: CRUD FUNCTIONS
    
//    func createFormWith(form: Form, completion: @escaping (Result<Form?, FormError>) -> Void) {
//        let newForm = createAndCopyForm(form: form)
//        saveForm(form: newForm, completion: completion)
//    }
    
    
    func fetchFormsWith(completion: @escaping(_ result: Result<[Form]?, FormError>) -> Void ) {
        
        let fetchAllPredicates = NSPredicate(value: true)
        
        let query = CKQuery(recordType: CloudStrings.recordTypeKey, predicate: fetchAllPredicates)
        privateDB.perform(query, inZoneWith: nil) { records, error in
            if let error = error {return completion(.failure(.ckError(error)))}
            
            
            guard let records = records else {return completion(.failure(.couldNotUnwrap))}
            print("You did the Fetching of the Forms!")
            
            let forms = records.compactMap({Form(ckRecord: $0)})
            
            self.forms = forms
            
            
            DispatchQueue.main.async {
                for form in forms {
                    print("name: \(form.firstName), \(form.phone)")
                }

                completion(.success(forms))
            }
            
            
        }
    }
    
    func saveForm(form: Form, completion: @escaping (Result<Form, FormError>) -> Void) {
        let formRecord = CKRecord(form: form)
        privateDB.save(formRecord) { record, error in
            if let error = error {
                return completion(.failure(.ckError(error)))
            }
            
            guard let record = record,
                  let savedForm = Form(ckRecord: record) else { completion(.failure(.couldNotUnwrap)); return }
            print("Saved form")
            
            self.forms.insert(savedForm, at: 0)
            
            DispatchQueue.main.async { completion(.success(savedForm))}
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
