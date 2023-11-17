//
//  FormViewController.swift
//  SynergyAppointmentForm
//
//  Created by Jaymond Richardson on 11/14/23.
//

import UIKit
import CoreLocation

class FormViewController: UIViewController, CLLocationManagerDelegate {
    // MARK: OUTLETS
    @IBOutlet weak var appointmentDayTextfield: UITextField!
    @IBOutlet weak var dateTimeTextfield: UITextField!
    @IBOutlet weak var firstNameTextfield: UITextField!
    @IBOutlet weak var lastNameTextfield: UITextField!
    @IBOutlet weak var spouseTextfield: UITextField!
    @IBOutlet weak var addressTextfield: UITextField!
    @IBOutlet weak var zipTextfield: UITextField!
    @IBOutlet weak var cityTextfield: UITextField!
    @IBOutlet weak var stateTextfield: UITextField!
    @IBOutlet weak var phoneTextfield: UITextField!
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var numberOfWindowsTexfield: UITextField!
    @IBOutlet weak var energyBillTextfield: UITextField!
    @IBOutlet weak var quoteTextfield: UITextField!
    @IBOutlet weak var financeTextfield: UITextField!
    @IBOutlet weak var yearsOwnedTextfield: UITextField!
    @IBOutlet weak var reasonTextview: UITextView!
    @IBOutlet weak var rateTextfield: UITextField!
    @IBOutlet weak var commentsTextview: UITextView!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var trelloButton: UIButton!
    
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        reasonTextview.layer.cornerRadius = 5.0
        commentsTextview.layer.cornerRadius = 5.0
    }
    
    // MARK: BUTTONS
    @IBAction func messageButtonPressed(_ sender: Any) {
        // CREATE ALERT
        let alert = UIAlertController(title: "Send message?", message: nil, preferredStyle: .alert)
        self.present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) {
            alert.dismiss(animated: true)
        }
    }
    
    @IBAction func trelloButtonPressed(_ sender: Any) {
        let form = createForm()
        FormController.shared.createAndCopyTrello(form: form)
        // CREATE ALERT
        let alert = UIAlertController(title: "Trello Title Copied!", message: nil, preferredStyle: .alert)
        self.present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) {
            alert.dismiss(animated: true)
        }
    }
    
    @IBAction func copyButtonPressed(_ sender: Any) {
        let form = createForm()
        FormController.shared.createAndCopyForm(form: form)
        // CREATE ALERT
        let alert = UIAlertController(title: "Form Copied!", message: nil, preferredStyle: .alert)
        self.present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            alert.dismiss(animated: true)
        }
    }
    
    @IBAction func locationButtonPressed(_ sender: Any) {
        FormController.shared.getLocationData(manager: &locationManager) { address in
            self.addressTextfield.text = address?.address
            self.zipTextfield.text = address?.zip
            self.cityTextfield.text = address?.city
            self.stateTextfield.text = address?.state
        }
    }
    
    @IBAction func copyPhoneNumberPressed(_ sender: Any) {
        
        FormController.shared.createAndCopy(phone: phoneTextfield.text ?? "")
        // CREATE ALERT
        let alert = UIAlertController(title: "Phone Number Copied!", message: nil, preferredStyle: .alert)
        self.present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            alert.dismiss(animated: true)
        }
    }
    
    @IBAction func clearReasonButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: "Are you sure you want to clear this section?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Clear", style: .default) {_ in
            self.reasonTextview.text = ""
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true)
        
    }
    
    @IBAction func clearCommentsButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: "Are you sure you want to clear this section?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Clear", style: .default) {_ in
            self.commentsTextview.text = ""
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true)

    }
    
    // MARK: FUNCTIONS
    func createForm() -> Form {
        // Separate date time
        var time: String
        var date: String
        let dateTimeText = dateTimeTextfield.text ?? ""
        let dateTimeArray = dateTimeText.split(separator: " ")
        if dateTimeArray.count >= 2 {
            time = String(dateTimeArray[1])
            date = String(dateTimeArray[0])
            } else {
                time = ""
                date = ""
            }
        let form = Form(day: appointmentDayTextfield.text ?? "", time: time, date: date, firstName: firstNameTextfield.text ?? "", lastName: lastNameTextfield.text ?? "", spouse: spouseTextfield.text ?? "", address: addressTextfield.text ?? "", zip: zipTextfield.text ?? "", city: cityTextfield.text ?? "", state: stateTextfield.text ?? "", phone: phoneTextfield.text ?? "", email: emailTextfield.text ?? "", numberOfWindows: numberOfWindowsTexfield.text ?? "", energyBill: energyBillTextfield.text ?? "", retailQuote: quoteTextfield.text ?? "", financeOptions: financeTextfield.text ?? "", yearsOwned: yearsOwnedTextfield.text ?? "", reason: reasonTextview.text ?? "", rate: rateTextfield.text ?? "", comments: commentsTextview.text ?? "")
        
        return form
    }
    

    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse:  // Location services are available.
            locationButton.isEnabled = true
            break
            
        case .restricted, .denied:  // Location services currently unavailable.
            locationButton.isEnabled = false
            break
            
        case .notDetermined:        // Authorization not determined yet.
           manager.requestWhenInUseAuthorization()
            break
            
        default:
            break
        }
    }
}
