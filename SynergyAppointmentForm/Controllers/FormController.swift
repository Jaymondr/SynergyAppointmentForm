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
    
    // MARK: FUNCTIONS
    func createAndCopyForm(form: Form) {

        UIPasteboard.general.string =
        """
        APT FORM
        
        Appointment Day: \(form.date.formattedDay())
        Time: \(form.date.formattedTime())\(form.date.formattedAmpm().lowercased())
        Date: \(form.date.formattedDayMonth())
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
        UIAlertController.presentDismissingAlert(title: "Form Copied!", dismissAfter: 0.5)
    }
    
    func createAndCopyTrello(form: Form) {
        let trelloString = form.spouse.isNotEmpty ?
        """
        \(form.date.formattedDay()) \(form.date.formattedDayMonth()) @\(form.date.formattedTime()) \(form.firstName) & \(form.spouse) \(form.lastName) (\(form.city)) -\(User.CodingKeys.userFirstName.rawValue)
        """
        :
        """
        \(form.date.formattedDay()) \(form.date.formattedDayMonth()) @\(form.date.formattedTime()) \(form.firstName) \(form.lastName) (\(form.city)) -\(User.CodingKeys.userFirstName.rawValue)
        """
        UIPasteboard.general.string = trelloString

        UIAlertController.presentDismissingAlert(title: "Trello Copied!", dismissAfter: 0.5)
    }
    
    func createAndCopy(phone: String) {
        UIPasteboard.general.string = phone
        UIAlertController.presentDismissingAlert(title: "Phone Number Copied!", dismissAfter: 0.6)
    }
    
    func createInitialText(from form: Form) -> String {
        let text =
        """
        Hey \(form.firstName), it's \(User.CodingKeys.userFirstName.rawValue) with Synergy.
        
        Your appointment is good to go for \(form.date.formattedDay()) \(form.date.formattedDayMonth()) at \(form.date.formattedTime())\(form.date.formattedAmpm().lowercased()). Thanks for your time, and if you need anything just call or text!
        
        - \(User.CodingKeys.userFirstName.rawValue)
        """
        return text
    }
    
    func createFollowUpText(from form: Form) -> String {
        let text = """
            Hey \(form.firstName),
            Just wanted to reach out and let you know we had an opening in the schedule. I'd love to see how we can use this Marketing Home opportunity to help you with your windows.
            - \(User.CodingKeys.userFirstName.rawValue)
            """
        return text
    }
    
    // LOCATION
    func getLocationData(manager: inout CLLocationManager, completion: @escaping (Address?) -> Void) {
        manager.startUpdatingLocation()
        defer { manager.stopUpdatingLocation(); print("Stopped updating Location") }
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
    }
}
