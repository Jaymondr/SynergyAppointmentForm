//
//  FormController.swift
//  SynergyAppointmentForm
//
//  Created by Jaymond Richardson on 11/14/23.
//

import UIKit
import CoreLocation
import CloudKit
import MessageUI

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
        \(form.date.formattedDay()) \(form.date.formattedDayMonth()) @\(form.date.formattedTime()) \(form.firstName) & \(form.spouse) \(form.lastName) (\(form.city)) -\(UserAccount.CodingKeys.userFirstName.rawValue)
        """
        :
        """
        \(form.date.formattedDay()) \(form.date.formattedDayMonth()) @\(form.date.formattedTime()) \(form.firstName) \(form.lastName) (\(form.city)) -\(UserAccount.CodingKeys.userFirstName.rawValue)
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
        Hey \(form.firstName), it's \(UserAccount.CodingKeys.userFirstName.rawValue) with Synergy.
        
        Your appointment is good to go for \(form.date.formattedDay()) \(form.date.formattedDayMonth()) at \(form.date.formattedTime())\(form.date.formattedAmpm().lowercased()). Thanks for your time, and if you need anything just call or text!
        
        - \(UserAccount.CodingKeys.userFirstName.rawValue)
        """
        return text
        
        /*
         OPTION 2
        let text =
        """
        Hello \(form.firstName)! Thank you for taking the time to talk with me today. Your appointment is set for \(form.date.formattedDay()) @\(form.date.formattedTime() + form.date.formattedAmpm()). If we find our 2 marketing homes before your appointment, I will notify you. Please let me know if you have any questions!
        
        \(User.CodingKeys.userFirstName.rawValue + " " + User.CodingKeys.userLastName.rawValue),
        Synergy Windows
        """
        return text
         */
    }
    
    func createFollowUpText(from form: Form) -> String {
        let text = """
            Hey \(form.firstName),
            Just wanted to reach out and let you know we had an opening in the schedule. I'd love to see how we can use this Marketing Home opportunity to help you with your windows.
            - \(UserAccount.CodingKeys.userFirstName.rawValue)
            """
        return text
    }
        
    func prepareToSendMessage(form: Form, phoneNumber: String?, viewController: UIViewController) {
        // CREATE ALERT
        let title: String = "Select Message Type"
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let initialTextAction = UIAlertAction(title: "Initial Message", style: .default) { _ in
            let text = FormController.shared.createInitialText(from: form)
            self.sendMessage(body: text, recipient: phoneNumber, alert: alert, viewController: viewController)
        }

        let followUpTextAction = UIAlertAction(title: "Follow-Up Text", style: .default) { _ in
            let text = FormController.shared.createFollowUpText(from: form)
            self.sendMessage(body: text, recipient: phoneNumber, alert: alert, viewController: viewController)
        }
        
        // ADD ALERT
        alert.addAction(initialTextAction)
        alert.addAction(followUpTextAction)
        alert.addAction(cancelAction)
        viewController.present(alert, animated: true)
    }

    func sendMessage(body: String, recipient: String?, alert: UIAlertController, viewController: UIViewController) {
        if MFMessageComposeViewController.canSendText() {
            let messageComposeViewController = MFMessageComposeViewController()
            messageComposeViewController.body = body
            messageComposeViewController.recipients = [recipient ?? ""]
            messageComposeViewController.messageComposeDelegate = viewController as? MFMessageComposeViewControllerDelegate
            viewController.present(messageComposeViewController, animated: true, completion: nil)
        } else {
            print("Messages cannot be sent from this device.")
            viewController.title = "Unable to send messages"
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                alert.dismiss(animated: true)
            }
        }
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
