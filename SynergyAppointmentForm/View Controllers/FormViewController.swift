//
//  FormViewController.swift
//  SynergyAppointmentForm
//
//  Created by Jaymond Richardson on 11/14/23.
//

import UIKit
import CoreLocation
import MessageUI

protocol FormViewDelegate: AnyObject {
    func didAddNewForm(_ form: Form)
    func didUpdateNew(_ form: Form)
}

class FormViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate, UITextViewDelegate {
    // MARK: OUTLETS
    @IBOutlet weak var dateTimePicker: UIDatePicker!
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
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var locationManager = CLLocationManager()
    weak var delegate: FormViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        phoneTextfield.layer.borderWidth = 1.0
        phoneTextfield.layer.cornerRadius = 5
        phoneTextfield.layer.borderColor = UIColor.clear.cgColor
        setupView()
        setTextFieldsDelegate()
        navigationController?.navigationBar.tintColor = UIColor.eden
    }
    
    
    // MARK: PROPERTIES
    var firebaseID: String = ""

    
    // MARK: BUTTONS
    @IBAction func saveButtonPressed(_ sender: Any) {
        let form = createForm()
        let saveQueue = DispatchQueue(label: "com.example.saveQueue", qos: .background)

        saveButton.isEnabled = false
        activityIndicator.startAnimating()
        
        if form.firebaseID.isNotEmpty {
            // UPDATE FORM
            saveQueue.async {
                FirebaseController.shared.updateForm(firebaseID: form.firebaseID, form: form) { error in
                    DispatchQueue.main.async {
                        self.saveButton.isEnabled = true
                        self.activityIndicator.stopAnimating()
                    }
                    if let error = error {
                        print("there was an error: \(error)")
                        DispatchQueue.main.async {
                            UIAlertController.presentDismissingAlert(title: "Failed to Save Form", dismissAfter: 1.2)
                        }
                        return
                    }
                    DispatchQueue.main.async {
                        self.delegate?.didUpdateNew(form)
                        UIAlertController.presentDismissingAlert(title: "Form Updated!", dismissAfter: 0.5)
                    }
                }
            }
        } else {
            // CREATE FORM IN FIREBASE
            saveQueue.async {
                FirebaseController.shared.saveForm(form: form) { savedForm, error in
                    DispatchQueue.main.async {
                        self.saveButton.isEnabled = true
                        self.activityIndicator.stopAnimating()                    }
                    if let error = error {
                        print("Error: \(error)")
                        DispatchQueue.main.async {
                            UIAlertController.presentDismissingAlert(title: "Failed to Save Form", dismissAfter: 1.2)
                        }
                        return
                    }
                    
                    guard let savedForm = savedForm else { print("No Form!"); return }
                    self.firebaseID = savedForm.firebaseID
                    DispatchQueue.main.async {
                        self.delegate?.didAddNewForm(savedForm)
                        UIAlertController.presentDismissingAlert(title: "Form Saved!", dismissAfter: 0.5)
                    }
                }
            }
        }
    }


    
    
    @IBAction func messageButtonPressed(_ sender: Any) {
        let form = createForm()
        FormController.shared.prepareToSendMessage(form: form, phoneNumber: phoneTextfield.text, viewController: self)
    }
    
    @IBAction func trelloButtonPressed(_ sender: Any) {
        let form = createForm()
        FormController.shared.createAndCopyTrello(form: form)
    }
    
    @IBAction func copyButtonPressed(_ sender: Any) {
        let form = createForm()
        FormController.shared.createAndCopyForm(form: form)
        
    }
    
    @IBAction func locationButtonPressed(_ sender: Any) {
        FormController.shared.getLocationData(manager: &locationManager) { address in
            self.addressTextfield.text = address?.address
            self.zipTextfield.text = address?.zip
            self.cityTextfield.text = address?.city
            self.stateTextfield.text = address?.state
            self.phoneTextfield.becomeFirstResponder()
        }
    }
    
    @IBAction func copyPhoneNumberPressed(_ sender: Any) {
        FormController.shared.createAndCopy(phone: phoneTextfield.text ?? "")
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
        
        // TEXTFIELDS
        
        
        // BACKGROUND
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [UIColor.white.cgColor, UIColor.white.cgColor, UIColor.eden.cgColor] // Gradient colors
        gradientLayer.locations = [-0.05, 0.4, 3.0] // Gradient locations (start and end)
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func setTextFieldsDelegate() {
        firstNameTextfield.delegate = self
        lastNameTextfield.delegate = self
        spouseTextfield.delegate = self
        addressTextfield.delegate = self
        zipTextfield.delegate = self
        cityTextfield.delegate = self
        stateTextfield.delegate = self
        phoneTextfield.delegate = self
        emailTextfield.delegate = self
        numberOfWindowsTexfield.delegate = self
        energyBillTextfield.delegate = self
        quoteTextfield.delegate = self
        financeTextfield.delegate = self
        reasonTextview.delegate = self
        rateTextfield.delegate = self
        commentsTextview.delegate = self

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == firstNameTextfield {
            lastNameTextfield.becomeFirstResponder()
        } else if textField == lastNameTextfield {
            spouseTextfield.becomeFirstResponder()
        } else if textField == spouseTextfield {
            addressTextfield.becomeFirstResponder()
        } else if textField == addressTextfield {
            zipTextfield.becomeFirstResponder()
        } else if textField == zipTextfield {
            cityTextfield.becomeFirstResponder()
        } else if textField == cityTextfield {
            stateTextfield.becomeFirstResponder()
        } else if textField == stateTextfield {
            phoneTextfield.becomeFirstResponder()
        } else if textField == phoneTextfield {
            emailTextfield.becomeFirstResponder()
        } else if textField == emailTextfield {
            numberOfWindowsTexfield.becomeFirstResponder()
        } else if textField == numberOfWindowsTexfield {
            energyBillTextfield.becomeFirstResponder()
        } else if textField == energyBillTextfield {
            quoteTextfield.becomeFirstResponder()
        } else if textField == quoteTextfield {
            financeTextfield.becomeFirstResponder()
        } else if textField == financeTextfield {
            yearsOwnedTextfield.becomeFirstResponder()
        } else if textField == yearsOwnedTextfield {
            reasonTextview.becomeFirstResponder()
        } else if textField == reasonTextview {
            rateTextfield.becomeFirstResponder()
        } else if textField == rateTextfield {
            commentsTextview.becomeFirstResponder()
        }
        else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Check if the current length is less than or equal to 10
        let currentLength = (textField.text ?? "").count
        let newLength = currentLength + string.count - range.length

        // Change the border color based on the condition
        if newLength != 10 {
            textField.layer.borderColor = UIColor.red.cgColor
        } else {
            textField.layer.borderColor = UIColor.clear.cgColor
        }

        // Allow the text change if needed
        return true
    }
    
    func createForm() -> Form {
        let form = Form(firebaseID: self.firebaseID, address: addressTextfield.text ?? "", city: cityTextfield.text ?? "", comments: commentsTextview.text ?? "", date: dateTimePicker.date, email: emailTextfield.text ?? "", energyBill: energyBillTextfield.text ?? "", financeOptions: financeTextfield.text ?? "", firstName: firstNameTextfield.text ?? "", lastName: lastNameTextfield.text ?? "", numberOfWindows: numberOfWindowsTexfield.text ?? "", phone: phoneTextfield.text ?? "", rate: rateTextfield.text ?? "", reason: reasonTextview.text ?? "", retailQuote: quoteTextfield.text ?? "", spouse: spouseTextfield.text ?? "", state: stateTextfield.text ?? "", yearsOwned: yearsOwnedTextfield.text ?? "", zip: zipTextfield.text ?? "")
        
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

// MARK: - EXTENSIONS
extension FormViewController: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
}
