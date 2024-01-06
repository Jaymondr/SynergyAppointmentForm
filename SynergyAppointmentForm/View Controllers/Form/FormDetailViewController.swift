//
//  FormDetailViewController.swift
//  SynergyAppointmentForm
//
//  Created by Jaymond Richardson on 11/21/23.
//

import UIKit
import CoreLocation
import MessageUI

protocol FormDetailViewDelegate: AnyObject {
    func didUpdate(form: Form)
}

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
    @IBOutlet weak var blurView: UIView!
    @IBOutlet weak var labelButton: UIButton!
    
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var activityIndicator:
    
    UIActivityIndicatorView!
    // MARK: PROPERTIES

    var locationManager = CLLocationManager()
    weak var delegate: FormDetailViewDelegate?
    
    // MARK: LIFECYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = UIColor.eden
        setUpView(with: form)
        if traitCollection.userInterfaceStyle == .dark {
            blurView.backgroundColor = .black
            dateTimePicker.tintColor = .lightText
        } else {
            let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
            blurEffectView.frame = blurView.bounds

            blurView.addSubview(blurEffectView)
        }
    }
    
    // MARK: PROPERTIES
    
    var form: Form?
    var tag: Outcome? {
        return form?.outcome
    }
    
    // MARK: FUNCTIONS
    func updateFormWithOutcome(_ outcome: Outcome) {
        guard let form = form else { return }

        form.outcome = outcome
        setUpView(with: form)

        FirebaseController.shared.updateForm(firebaseID: form.firebaseID, form: form) { error in
            if let error = error {
                UIAlertController.presentDismissingAlert(title: "Failed to Save", dismissAfter: 0.6)
                print("Error: \(error)")
                return
            }

            self.delegate?.didUpdate(form: form)
            UIAlertController.presentDismissingAlert(title: "Label Updated!", dismissAfter: 0.6)
        }
    }
    
    @IBAction func tagButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Add Label", message: "Select Label", preferredStyle: .alert)
        
        for outcome in Outcome.allCases {
            let action = UIAlertAction(title: outcome.rawValue.capitalized, style: .default) { _ in
                self.updateFormWithOutcome(outcome)
            }
            
            let color: UIColor
            switch outcome {
            case .pending: color = UIColor.eden
            case .sold: color = UIColor.outcomeGreen
            case .rescheduled: color = UIColor.outcomePurple
            case .cancelled: color = UIColor.outcomeRed
            case .ran: color = UIColor.outcomeBlue
            case .ranIncomplete: color = UIColor.outcomeRed
            }
            
            action.setValue(color, forKey: "titleTextColor")
            alert.addAction(action)
        }
        
        alert.addAction(UIAlertAction(title: "CANCEL", style: .cancel))
        self.present(alert, animated: true)
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        self.vibrateForButtonPress(.medium)
        saveButton.isEnabled = false
        activityIndicator.startAnimating()
        
        guard let form = createForm() else {
            saveButton.isEnabled = true
            return
        }
        
        print("form id: \(form.firebaseID)")
        FirebaseController.shared.updateForm(firebaseID: form.firebaseID, form: form) { error in
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.saveButton.isEnabled = true
            }
            
            if let error = error {
                UIAlertController.presentDismissingAlert(title: "Failed to Save", dismissAfter: 0.6)
                self.vibrateForError()
                print("Error: \(error)")
                return
            }
            
            self.delegate?.didUpdate(form: form)
            print("Form Name: \(form.firstName)")
            UIAlertController.presentDismissingAlert(title: "Updated Form!", dismissAfter: 0.6)
            self.vibrate()
        }
    }
    
    @IBAction func trelloCopyButtonPressed(_ sender: Any) {
        guard let form = createForm() else { return }
        self.vibrateForButtonPress(.heavy)
        FormController.shared.createAndCopyTrello(form: form)
    }
    
    @IBAction func sendMessageButtonPressed(_ sender: Any) {
        guard let form = createForm() else { return }
        FormController.shared.prepareToSendMessage(form: form, phoneNumber: phoneTextField.text, viewController: self)
    }
    
    @IBAction func copyFormButtonPressed(_ sender: Any) {
        guard let form = createForm() else { return }
        self.vibrateForButtonPress(.heavy)
        FormController.shared.createAndCopyForm(form: form)
    }
    
    @IBAction func locationButtonPressed(_ sender: Any) {
        self.vibrateForButtonPress(.heavy)
        FormController.shared.getLocationData(manager: &locationManager) { address in
            self.addressTextField.text = address?.address
            self.zipTextField.text = address?.zip
            self.cityTextField.text = address?.city
            self.stateTextField.text = address?.state
        }
    }
    
    @IBAction func copyPhoneButtonPressed(_ sender: Any) {
        let phoneNumber = phoneTextField.text ?? ""
        self.vibrateForButtonPress(.heavy)
        FormController.shared.copy(phone: phoneNumber)
    }
    @IBAction func clearReasonButtonPressed(_ sender: Any) {
        self.vibrateForButtonPress(.heavy)
        UIAlertController.presentMultipleOptionAlert(message: "Are you sure you want to clear this section?", actionOptionTitle: "Clear", cancelOptionTitle: "Cancel") {
            self.reasonTextView.text = ""
        }
    }
    
    @IBAction func clearCommentsButtonPressed(_ sender: Any) {
        self.vibrateForButtonPress(.heavy)
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
        dateTimePicker.date = form.date
        
        reasonTextView.layer.cornerRadius = 5.0
        commentsTextView.layer.cornerRadius = 5.0
        
        // BACKGROUND
        var labelColor: CGColor
        
        switch form.outcome {
        case .pending:
            labelColor = UIColor.eden.cgColor
            
        case .cancelled:
            labelColor = UIColor.outcomeRed.cgColor
            
        case .rescheduled:
            labelColor = UIColor.outcomePurple.cgColor
            
        case .ran:
            labelColor = UIColor.outcomeBlue.cgColor
            
        case .ranIncomplete:
            labelColor = UIColor.outcomeRed.cgColor
            
        case .sold:
            labelColor = UIColor.outcomeGreen.cgColor
        }
        
        // Label Button
        labelButton.configuration?.baseForegroundColor = UIColor(cgColor: labelColor)
        
        if traitCollection.userInterfaceStyle == .dark {
            // BACKGROUND
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = view.bounds
            gradientLayer.colors = [UIColor.black.cgColor, UIColor.black.cgColor, labelColor] // Gradient colors
            gradientLayer.locations = [-0.05, 0.4, 2.0] // Gradient locations (start and end)
            view.layer.insertSublayer(gradientLayer, at: 0)
            
        } else {
            // BACKGROUND
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = view.bounds
            gradientLayer.colors = [UIColor.white.cgColor, UIColor.white.cgColor, labelColor] // Gradient colors
            gradientLayer.locations = [-0.05, 0.4, 3.0] // Gradient locations (start and end)
            view.layer.insertSublayer(gradientLayer, at: 0)
        }
    }
    
    func createForm() -> Form? {
        guard let form = form else { UIAlertController.presentDismissingAlert(title: "Error: No Form.", dismissAfter: 0.6); return nil }
        guard let user = UserAccount.currentUser else { UIAlertController.presentDismissingAlert(title: "Error: No User.", dismissAfter: 0.6); return nil }

        let updatedForm = Form(firebaseID: form.firebaseID,
                               address: addressTextField.text ?? "",
                               city: cityTextField.text ?? "",
                               comments: commentsTextView.text ?? "",
                               date: dateTimePicker.date,
                               email: emailTextField.text ?? "",
                               energyBill: energyBillTextField.text ?? "",
                               financeOptions: financeOptionsTextField.text ?? "",
                               firstName: firstNameTextField.text ?? "",
                               lastName: lastNameTextField.text ?? "",
                               numberOfWindows: numberOfWindowsTextField.text ?? "",
                               outcome: tag ?? .pending, phone: phoneTextField.text ?? "",
                               rate: rateTextField.text ?? "",
                               reason: reasonTextView.text ?? "",
                               retailQuote: quoteTextField.text ?? "",
                               spouse: spouseTextField.text ?? "",
                               state: stateTextField.text ?? "",
                               userID: user.firebaseID,
                               yearsOwned: yearsOwnedTextField.text ?? "",
                               zip: zipTextField.text ?? ""
        )
        
        return updatedForm
    }
}


// MARK: - EXTENSIONS
extension FormDetailViewController: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
}
