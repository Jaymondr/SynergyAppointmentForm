//
//  FormController.swift
//  SynergyAppointmentForm
//
//  Created by Jaymond Richardson on 11/14/23.
//

import UIKit

class FormController {
    
//    var form: Form?
    static let shared = FormController()
    
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
}
