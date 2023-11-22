//
//  FormDetailViewController.swift
//  SynergyAppointmentForm
//
//  Created by Jaymond Richardson on 11/21/23.
//

import UIKit
import CoreLocation
class FormDetailViewController: UIViewController {
    
    
    // MARK: OUTLETS
    
    @IBOutlet weak var dateTimePicker: UIDatePicker!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var spouseTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var zipTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var stateTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var numberOfWindowsTextField: UITextField!
    @IBOutlet weak var energyBillTextField: UITextField!
    @IBOutlet weak var quoteTextField: UITextField!
    @IBOutlet weak var financeOptionsTextField: UITextField!
    @IBOutlet weak var yearsOwnedTextField: UITextField!
    @IBOutlet weak var reasonTextView: UITextView!
    @IBOutlet weak var rateTextField: UITextField!
    @IBOutlet weak var commentsTextView: UITextView!
    
    
    // MARK: PROPERTIES

    var locationManager = CLLocationManager()

    
    // MARK: LIFECYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = UIColor.eden
        setUpView(with: form)
    }
    
    // MARK: PROPERTIES
    
    var form: Form?
    
    
    // MARK: FUNCTIONS
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        guard let form = createForm() else { return }
        print("form id: \(form.firebaseID)")
        FirebaseController.shared.updateForm(firebaseID: form.firebaseID, form: form) { error in
            if let error = error {
                UIAlertController.presentDismissingAlert(title: "Failed to Save", dismissAfter: 0.6)
                print("Error: \(error)")
                return
            }
            UIAlertController.presentDismissingAlert(title: "Updated Form!", dismissAfter: 0.6)
        }
    }
    
    @IBAction func trelloCopyButtonPressed(_ sender: Any) {
        guard let form = createForm() else { return }
        FormController.shared.createAndCopyTrello(form: form)
    }
    
    @IBAction func sendMessageButtonPressed(_ sender: Any) {
        guard let form = createForm() else { return }
        let text = FormController.shared.createText(from: form)
        var title: String = "Send Message?"
        
        // CREATE ALERT
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { _ in
            guard let phoneNumber = self.phoneTextField.text else { return }
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
    
    @IBAction func copyFormButtonPressed(_ sender: Any) {
        guard let form = createForm() else { return }
        FormController.shared.createAndCopyForm(form: form)
        UIAlertController.presentDismissingAlert(title: "Copied Form", dismissAfter: 0.6)
    }
    @IBAction func locationButtonPressed(_ sender: Any) {
        FormController.shared.getLocationData(manager: &locationManager) { address in
            self.addressTextField.text = address?.address
            self.zipTextField.text = address?.zip
            self.cityTextField.text = address?.city
            self.stateTextField.text = address?.state
            
        }
    }
    @IBAction func copyPhoneButtonPressed(_ sender: Any) {
        let phoneNumber = phoneTextField.text ?? ""
        FormController.shared.createAndCopy(phone: phoneNumber)
    }
    @IBAction func clearReasonButtonPressed(_ sender: Any) {
        UIAlertController.presentMultipleOptionAlert(message: "Are you sure you want to clear this section?", actionOptionTitle: "Clear", cancelOptionTitle: "Cancel") {
            self.reasonTextView.text = ""
        }
    }
    @IBAction func clearCommentsButtonPressed(_ sender: Any) {
        UIAlertController.presentMultipleOptionAlert(message: "Are you sure you want to clear this section?", actionOptionTitle: "Clear", cancelOptionTitle: "Cancel") {
            self.commentsTextView.text = ""
        }
    }
    
    func setUpView(with form: Form?) {
        guard let form = form else { print("No Form!"); return }
        firstNameTextField?.text = form.firstName
        lastNameTextField?.text = form.lastName
        spouseTextField?.text = form.spouse
        addressTextField.text = form.address
        zipTextField.text = form.zip
        cityTextField.text = form.city
        stateTextField.text = form.state
        phoneTextField.text = form.phone
        emailTextField.text = form.email
        numberOfWindowsTextField.text = form.numberOfWindows
        energyBillTextField.text = form.energyBill
        quoteTextField.text = form.retailQuote
        financeOptionsTextField.text = form.financeOptions
        yearsOwnedTextField.text = form.yearsOwned
        reasonTextView.text = form.reason
        rateTextField.text = form.rate
        commentsTextView.text = form.comments
        if let date = DateFormatter.dateFromFormattedString(form.dateString) {
            self.dateTimePicker.date = date
        } else {
            print("Unable to set date picker")
        }
    }
    
    func createForm() -> Form? {
        guard let form = form else { UIAlertController.presentDismissingAlert(title: "Error: No Form.", dismissAfter: 0.6); return nil }
        // Separate date time
        var day: String
        var date: String
        var time: String
        var ampm: String
        var year: String
        let dateString = dateTimePicker.date.formattedStringDate()
        print(dateString)
        let dateTimeArray = dateString.split(separator: " ")
        if dateTimeArray.count >= 2 {
            day = String(dateTimeArray[0])
            date = String(dateTimeArray[1])
            time = String(dateTimeArray[2])
            ampm = String(dateTimeArray[3])
            year = String(dateTimeArray[4])
        } else {
            day = ""
            date = ""
            time = ""
            ampm = ""
            year = ""
        }
        let updatedForm = Form(firebaseID: form.firebaseID, address: addressTextField.text ?? "", ampm: ampm, city: cityTextField.text ?? "", comments: commentsTextView.text ?? "", date: date, dateString: dateString, day: day, email: emailTextField.text ?? "", energyBill: energyBillTextField.text ?? "", financeOptions: financeOptionsTextField.text ?? "", firstName: firstNameTextField.text ?? "", lastName: lastNameTextField.text ?? "", numberOfWindows: numberOfWindowsTextField.text ?? "", phone: phoneTextField.text ?? "", rate: rateTextField.text ?? "", reason: reasonTextView.text ?? "", retailQuote: quoteTextField.text ?? "", spouse: spouseTextField.text ?? "", state: stateTextField.text ?? "", time: time, year: year, yearsOwned: yearsOwnedTextField.text ?? "", zip: zipTextField.text ?? "")
        
        return updatedForm
    }
}
