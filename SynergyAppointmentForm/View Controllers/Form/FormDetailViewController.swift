//
//  FormDetailViewController.swift
//  SynergyAppointmentForm
//
//  Created by Jaymond Richardson on 11/21/23.
//

import UIKit
import CoreLocation
import MessageUI

// MARK: - TODO:
/*
 1. 🐞 When viewing other users forms and you hit the search bar, it does not search the other users forms
 2. 🐞 When making edits to another users form, it doesn't update it in the table view locally
 
 */

protocol FormDetailViewDelegate: AnyObject {
    func didUpdate(form: Form)
}

class FormDetailViewController: UIViewController {
    
    // MARK: OUTLETS
    @IBOutlet weak var trelloButton: UIButton!
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
    @IBOutlet weak var quoteTextView: UITextView!
    @IBOutlet weak var financeOptionsTextField: UITextField!
    @IBOutlet weak var yearBuiltTextField: UITextField!
    @IBOutlet weak var yearsOwnedTextField: UITextField!
    @IBOutlet weak var homeValueTextField: UITextField!
    @IBOutlet weak var reasonTextView: UITextView!
    @IBOutlet weak var rateTextField: UITextField!
    @IBOutlet weak var commentsTextView: UITextView!
    @IBOutlet weak var labelButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    // STACK VIEWS
    @IBOutlet weak var homeValueStackView: UIStackView!
    @IBOutlet weak var yearBuiltStackView: UIStackView!
    
    
    @IBOutlet weak var activityIndicator:
    
    UIActivityIndicatorView!
    // MARK: PROPERTIES

    var locationManager = CLLocationManager()
    weak var delegate: FormDetailViewDelegate?
    
    // MARK: LIFECYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = UIColor.steel
        setUpView(with: form)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutSubviews() // ADDS BOTTOM BORDER TO TEXTFIELDS
        
    }
    
    // MARK: PROPERTIES
    
    var form: Form?
    var tag: Outcome? {
        return form?.outcome
    }
    
    // MARK: BUTTONS
    @IBAction func copyEmailButtonPressed(_ sender: Any) {
        FormController.shared.copy(email: emailTextField.text)
    }
    
    @IBAction func tagButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Select Outcome Label", message: nil, preferredStyle: .alert)
        
        for outcome in Outcome.allCases {
            let action = UIAlertAction(title: outcome.rawValue.capitalized, style: .default) { _ in
                self.updateFormWithOutcome(outcome)
            }
            
            let color: UIColor
            switch outcome {
            case .lead: color = UIColor.outcomeYellow
            case .pending: color = UIColor.steel
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
        FirebaseController.shared.updateForm(firebaseID: form.firebaseID, form: form) { updatedForm, error in
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
        FormController.shared.prepareToSendMessage(form: form, phoneNumber: phoneTextField.text ?? "", viewController: self)
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
    
    @IBAction func clearQuoteButtonPressed(_ sender: Any) {
        self.vibrateForButtonPress(.heavy)
        UIAlertController.presentMultipleOptionAlert(message: "Are you sure you want to clear this section?", actionOptionTitle: "Clear", cancelOptionTitle: "Cancel") {
            self.quoteTextView.text = ""
        }
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
    
    
    // MARK: FUNCTIONS
    private func layoutSubviews() {
        // TEXTFIELDS
        let textFields: [UITextField] = [firstNameTextField, lastNameTextField, spouseTextField, addressTextField, cityTextField, stateTextField, zipTextField, phoneTextField, emailTextField, numberOfWindowsTextField, energyBillTextField, financeOptionsTextField, yearBuiltTextField, yearsOwnedTextField, homeValueTextField, rateTextField]
        
        for textField in textFields {
            textField.addBottomBorder(with: .steel, andHeight: 1)
        }
    }
    
    func setUpView(with form: Form?) {
        guard let form = form else { print("No Form!"); return }
        guard let user = UserAccount.currentUser else { return }
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
        quoteTextView.text = form.retailQuote
        financeOptionsTextField.text = form.financeOptions
        yearBuiltTextField.text = form.yearBuilt
        yearsOwnedTextField.text = form.yearsOwned
        homeValueTextField.text = form.homeValue
        reasonTextView.text = form.reason
        rateTextField.text = form.rate
        commentsTextView.text = form.comments
        dateTimePicker.date = form.date
        
        reasonTextView.layer.cornerRadius = 5.0
        commentsTextView.layer.cornerRadius = 5.0
        
        // DEFAULT IMPLEMENTATIONS
        homeValueStackView.isHidden = true
        yearBuiltStackView.isHidden = true
        trelloButton.isHidden = true
        
        // VIEW FOR BRANCH
        switch user.branch {
        case .atlanta:
            print("Form For Atlanta")
            
        case .austin:
            print("Form For Austin")
            
        case .dallas:
            print("Form For Dallas")
            
        case .houston:
            print("Form For Houston")
            
        case .lasVegas:
            print("Form For Las Vegas")
            
        case .nashville:
            print("Form For Nashville")
            
        case .raleigh:
            print("Form For Raleigh")
            homeValueStackView.isVisible = true
            yearBuiltStackView.isVisible = true
            
        case .southJordan:
            print("Form For South Jordan")
            emailTextField.placeholder = "@synergywindow.com"
            trelloButton.isVisible = true

        case .sanAntonio:
            print("Form For San Antonio")
            
        default:
            break
        }
        
        // BACKGROUND
        var labelColor: CGColor
        
        switch form.outcome {
        case .lead:
            labelColor = UIColor.outcomeYellow.cgColor
        case .pending:
            labelColor = UIColor.steel.cgColor
            
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
        
        // CORNER RADIUS
        quoteTextView.layer.cornerRadius = 5.0
        reasonTextView.layer.cornerRadius = 5.0
        commentsTextView.layer.cornerRadius = 5.0

        let additionalCommentsTextViews: [UITextView] = [quoteTextView, reasonTextView, commentsTextView]
        
        for textView in additionalCommentsTextViews {
            textView.layer.borderWidth = 1
            textView.layer.cornerRadius = 8.0
            textView.layer.borderColor = UIColor.steel.cgColor
        }
            
        if traitCollection.userInterfaceStyle == .dark {
            // BACKGROUND
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = view.bounds
            gradientLayer.colors = [UIColor.black.cgColor, UIColor.black.cgColor, labelColor] // Gradient colors
            gradientLayer.locations = [-0.05, 0.5, 3.2] // Gradient locations (start and end)
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
        guard UserAccount.currentUser != nil else { UIAlertController.presentDismissingAlert(title: "Error: No User.", dismissAfter: 0.6); return nil }
        let updatedForm = Form(firebaseID: form.firebaseID,
                               address: addressTextField.text ?? "",
                               city: cityTextField.text ?? "",
                               comments: commentsTextView.text ?? "",
                               date: dateTimePicker.date,
                               email: emailTextField.text ?? "",
                               energyBill: energyBillTextField.text ?? "",
                               financeOptions: financeOptionsTextField.text ?? "",
                               firstName: firstNameTextField.text ?? "",
                               homeValue: homeValueTextField.text ?? "",
                               lastName: lastNameTextField.text ?? "",
                               notes: form.notes ?? "Notes: ",
                               numberOfWindows: numberOfWindowsTextField.text ?? "",
                               outcome: tag ?? .pending, phone: phoneTextField.text ?? "",
                               rate: rateTextField.text ?? "",
                               reason: reasonTextView.text ?? "",
                               retailQuote: quoteTextView.text ?? "",
                               spouse: spouseTextField.text ?? "",
                               state: stateTextField.text ?? "",
                               userID: form.userID,
                               yearBuilt: yearBuiltTextField.text ?? "",
                               yearsOwned: yearsOwnedTextField.text ?? "",
                               zip: zipTextField.text ?? ""
        )
        
        return updatedForm
    }
    
    func updateFormWithOutcome(_ outcome: Outcome) {
        guard let form = form else { return }

        form.outcome = outcome
        setUpView(with: form)

        FirebaseController.shared.updateForm(firebaseID: form.firebaseID, form: form) { updatedForm, error in
            if let error = error {
                UIAlertController.presentDismissingAlert(title: "Failed to Save", dismissAfter: 0.6)
                print("Error: \(error)")
                return
            }

            self.delegate?.didUpdate(form: form)
            UIAlertController.presentDismissingAlert(title: "Label Updated!", dismissAfter: 0.6)
        }
    }

}


// MARK: - EXTENSIONS
extension FormDetailViewController: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
}
