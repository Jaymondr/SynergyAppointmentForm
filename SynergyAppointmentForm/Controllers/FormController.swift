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
        guard let user = UserAccount.currentUser else { return }
        if user.branch == .raleigh {
        // RALEIGHS FORM LAYOUT
        let formString =
        """
        \(user.firstName)'s APPT
        Created Date: \(Date().formattedStringDate())
        
        Appointment for: \(form.date.formattedDay()) \(form.date.formattedTime())\(form.date.formattedAmpm().lowercased()), \(form.date.formattedMonth()) \(form.date.formattedDayNumber())
        
        \(form.firstName) & \(form.spouse) \(form.lastName)
        
        \(form.address), \(form.city), \(form.state) \(form.zip)
        
        \(form.firstName)'s Phone: \(form.phone)
        Email: \(form.email)
        
        Home Value: \(form.homeValue ?? "--")
        Year Built: \(form.yearBuilt ?? "--")
        Moved in \(form.yearsOwned) year(s) ago.
        
        Rating: \(form.rate)

        Previous estimates: \(form.retailQuote)
        
        Comments: \(form.comments)
        """
            
            UIPasteboard.general.string = formString
            UIAlertController.presentDismissingAlert(title: "Form Copied!", dismissAfter: 0.3)
        }
        else
        {
        // OTHER BRANCHES FORM LAYOUT
        let formString =
        """
        APT FORM
        Created Date: \(Date().formattedStringDate())
        
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
            
            UIPasteboard.general.string = formString
            UIAlertController.presentDismissingAlert(title: "Form Copied!", dismissAfter: 0.3)
        }
    }
    
    func getCompletedFormText(from form: Form) -> String {
        guard let user = UserAccount.currentUser else { return "" }
        if user.branch == .raleigh {
            // RALEIGHS FORM LAYOUT
            let formString =
    """
    \(user.firstName)'s APPT
    (Created Date: \(Date().formattedDayMonthYear()))
    
    Appointment for: \(form.date.formattedDay()) \(form.date.formattedTime())\(form.date.formattedAmpm().lowercased()), \(form.date.formattedMonth()) \(form.date.formattedDayNumber())
    
    \(form.firstName) & \(form.spouse) \(form.lastName)
    
    \(form.address), \(form.city), \(form.state) \(form.zip)
    
    \(form.firstName)'s Phone: \(form.phone)
    Email: \(form.email)
    
    Home Value: \(form.homeValue ?? "--")
    Year Built: \(form.yearBuilt ?? "--")
    Moved in \(form.yearsOwned) year(s) ago.
    
    Rating: \(form.rate)
    
    Previous estimates: \(form.retailQuote)
    
    Comments: \(form.comments)
    """
            return formString
        }
        else
        {
            // OTHER BRANCHES FORM LAYOUT
            let formString =
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
    return formString
        }
    }
    
    func createAndCopyTrello(form: Form) {
        guard let user = UserAccount.currentUser else { return }
        let trelloString = form.spouse.isNotEmpty ?
        """
        \(form.date.formattedDay()) \(form.date.formattedDayMonth()) @\(form.date.formattedTime()) \(form.firstName) & \(form.spouse) \(form.lastName) (\(form.city)) -\(user.firstName)
        """
        :
        """
        \(form.date.formattedDay()) \(form.date.formattedDayMonth()) @\(form.date.formattedTime()) \(form.firstName) \(form.lastName) (\(form.city)) -\(user.firstName)
        """
        UIPasteboard.general.string = trelloString

        UIAlertController.presentDismissingAlert(title: "Trello Copied!", dismissAfter: 0.3)
    }
    
    func copy(phone: String?) {
        UIPasteboard.general.string = phone ?? ""
        UIAlertController.presentDismissingAlert(title: "Phone Number Copied!", dismissAfter: 0.3)
    }
    
    func copy(email: String?) {
        guard let user = UserAccount.currentUser else { return }
        let emailString = email != "" ? email : user.email
        UIPasteboard.general.string = emailString
        UIAlertController.presentDismissingAlert(title: "Email Copied!", dismissAfter: 0.3)
    }
    
    func createHomeownerText(from form: Form) -> String {
        guard let user = UserAccount.currentUser else { return "No User" }
        
        let text =
        """
        Hey \(form.firstName), it's \(user.firstName) with \(user.companyName) Windows.
        
        Your appointment is good to go for \(form.date.formattedDay()) \(form.date.formattedDayMonth()) at \(form.date.formattedTime())\(form.date.formattedAmpm().lowercased()). Thanks for your time, and if you need anything just call or text!
        
        - \(user.firstName)
        """
        return text
        
        
//         OPTION 2
//        let text =
//        """
//        Hello \(form.firstName)! Thank you for taking the time to talk with me today. Your appointment is set for \(form.date.formattedDay()) @\(form.date.formattedTime() + form.date.formattedAmpm()). If we find our 2 marketing homes before your appointment, I will notify you. Please let me know if you have any questions!
//        
//        \(user.firstName + " " + user.lastName),
//        Synergy Windows
//        """
//        return text
         
    }
    
    func createFollowUpText(from form: Form) -> String {
        guard let user = UserAccount.currentUser else { return "No User"}
        
        let text = """
            Hey \(form.firstName), it's \(user.firstName) with \(user.companyName) Windows.
            I wanted let you know we had an opening in the schedule for a Marketing Home in your area, and wanted to give you first right of refusal. If you're ready to get to ball rolling, I can schedule a time for a Marketing Director to come and see how we would be able to help you. Please let me know as soon as possible. Thanks!
            - \(user.firstName)
            """
        return text
    }
            
    func prepareToSendMessage(form: Form, phoneNumber: String, viewController: UIViewController) {
        // CREATE ALERT
        let title: String = "Select Message Type"
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        
        // ACTIONS
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        let homeownerTextAction = UIAlertAction(title: "Homeowner Text", style: .default) { _ in
            let text = FormController.shared.createHomeownerText(from: form)
            self.sendMessage(body: text, recipients: [phoneNumber], alert: alert, viewController: viewController)
        }
        
        let managerTextAction = UIAlertAction(title: "Manager Text", style: .default) { _ in
            let text = FormController.shared.getCompletedFormText(from: form)
            let alliePhone = "4708710421"
            let hermanPhone = "7702985397"
            self.sendMessage(body: text, recipients: [alliePhone, hermanPhone], alert: alert, viewController: viewController)
        }

        let followUpTextAction = UIAlertAction(title: "Follow-Up Text", style: .default) { _ in
            let text = FormController.shared.createFollowUpText(from: form)
            self.sendMessage(body: text, recipients: [phoneNumber], alert: alert, viewController: viewController)
        }
        
        let seeConversationAction = UIAlertAction(title: "See Conversation", style: .default) { _ in
            self.sendMessage(body: "", recipients: [phoneNumber], alert: alert, viewController: viewController)
        }

        // ADD ALERT
        alert.addAction(homeownerTextAction)
        if UserAccount.currentUser?.branch == .raleigh {
            alert.addAction(managerTextAction)
        }
        alert.addAction(seeConversationAction)
        alert.addAction(cancelAction)
        viewController.present(alert, animated: true)
    }

    func sendMessage(body: String, recipients: [String], alert: UIAlertController, viewController: UIViewController) {
        if MFMessageComposeViewController.canSendText() {
            let messageComposeViewController = MFMessageComposeViewController()
            messageComposeViewController.body = body
            messageComposeViewController.recipients = recipients
            messageComposeViewController.messageComposeDelegate = viewController as? MFMessageComposeViewControllerDelegate
            viewController.present(messageComposeViewController, animated: true, completion: nil)
        } else {
            print("Messages cannot be sent from this device.")
            viewController.title = "Unable to send messages"
            alert.title = "Unable to send messages"
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
