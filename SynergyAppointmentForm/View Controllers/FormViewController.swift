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
    }
    
    // MARK: BUTTONS
    @IBAction func fetchFormsButtonPressed(_ sender: Any) {
        
        FormController.shared.fetchFormsWith { forms, error in
            if let error = error {
                print("There is an error with fetching forms")
            } else {
                guard let forms = forms else { print("There are no forms"); return }
                for form in forms {
                    print("Form info: \(form.firstName) \(form.lastName)")
                }
            }
        }
    }
    
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        let form = createForm()
        FormController.shared.saveForm(form: form) { form, error in
            if let error = error {
                print("There was an error saving the form")
            } else {
                guard let form = form else { print("there was an error with the form after saving"); return }
                print("Saved form: \(form.firstName) \(form.lastName)")
            }
        }

        
//        let newForm = createForm()
//        FormController.shared.saveForm(form: newForm) { result in
//            let alert = UIAlertController(title: "Saved", message: nil, preferredStyle: .alert)
//            DispatchQueue.main.async {
//                self.present(alert, animated: true)
//            }
//            
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                alert.dismiss(animated: true)
//            }
//        }
    }
    
    @IBAction func messageButtonPressed(_ sender: Any) {
        let form = createForm()
        let text = FormController.shared.createText(from: form)
        var title: String = "Send Message?"
        
        // CREATE ALERT
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { _ in
            guard let phoneNumber = self.phoneTextfield.text else { return }
            let urlString = "sms:\(phoneNumber)&body=\(text)"
            
            if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                // Handle the case where the Messages app or the URL scheme is not available
                print("Messages app is not installed or the URL scheme is not supported.")
                title = "Unable to open messages"
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    alert.dismiss(animated: true)
                }
            }
            
        }
        
        // ADD ALERT
        alert.addAction(yesAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true)
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
    func setupView() {
        reasonTextview.layer.cornerRadius = 5.0
        commentsTextview.layer.cornerRadius = 5.0

    }
    
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
