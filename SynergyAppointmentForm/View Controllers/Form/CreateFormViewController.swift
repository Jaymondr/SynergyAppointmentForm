//
//  FormViewController.swift
//  SynergyAppointmentForm
//
//  Created by Jaymond Richardson on 11/14/23.
//

import UIKit
import CoreLocation
import MessageUI

protocol CreateFormViewDelegate: AnyObject {
    func didAddNewForm(_ form: Form)
    func didUpdateNew(_ form: Form)
}

class CreateFormViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate, UITextViewDelegate {
    // MARK: OUTLETS
    // SCHEDULE
    @IBOutlet weak var showCalendarButton: UIButton!
    @IBOutlet weak var dayOneTextField: UITextView!
    @IBOutlet weak var dayTwoTextField: UITextView!
    @IBOutlet weak var dayThreeTextField: UITextView!
    @IBOutlet weak var showScheduleNotesButton: UIButton!
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
    @IBOutlet weak var homeValueTextfield: UITextField!
    @IBOutlet weak var yearBuiltTextfield: UITextField!
    @IBOutlet weak var reasonTextview: UITextView!
    @IBOutlet weak var rateTextfield: UITextField!
    @IBOutlet weak var commentsTextview: UITextView!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var trelloButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    // STACK VIEWS
    @IBOutlet weak var homeValueStackView: UIStackView!
    @IBOutlet weak var yearBuiltStackView: UIStackView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var locationManager = CLLocationManager()
    weak var delegate: CreateFormViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        phoneTextfield.layer.borderWidth = 1.0
        phoneTextfield.layer.cornerRadius = 5
        phoneTextfield.layer.borderColor = UIColor.clear.cgColor
        setupView()
        setTextFieldsDelegate()
        navigationController?.navigationBar.tintColor = UIColor.eden
        NotificationCenter.default.addObserver(self, selector: #selector(traitCollectionDidChange(_:)), name: NSNotification.Name("traitCollectionDidChangeNotification"), object: nil)
        
        // Uncomment line when you want to show save before leaving message
//        let backButton = UIBarButtonItem.customBackButton(target: self, action: #selector(backButtonPressed))
//        navigationItem.leftBarButtonItem = backButton

    }
        
    // MARK: PROPERTIES
    var firebaseID: String = ""
    var savedForm: Form?
    var timeSlots = ["10am", "12pm", "2pm", "4pm", "6pm", "8pm"]
    var timeSlotLabels: [UILabel] = []
    var user: UserAccount? {
        UserAccount.currentUser
    }


    // MARK: BUTTONS
    @IBAction func saveButtonPressed(_ sender: Any) {
        saveForm()
    }

    @IBAction func messageButtonPressed(_ sender: Any) {
        if let form = createForm() {
            FormController.shared.prepareToSendMessage(form: form, phoneNumber: phoneTextfield.text ?? "", viewController: self)
        } else {
            UIAlertController.presentDismissingAlert(title: "Unable to create form...", dismissAfter: 1.0)
        }
    }
    
    @IBAction func trelloButtonPressed(_ sender: Any) {
        self.vibrateForButtonPress(.heavy)
        if let form = createForm() {
        FormController.shared.createAndCopyTrello(form: form)
        } else {
            UIAlertController.presentDismissingAlert(title: "Unable to create form...", dismissAfter: 1.0)
        }
    }
    
    @IBAction func copyButtonPressed(_ sender: Any) {
        self.vibrateForButtonPress(.heavy)
        if let form = createForm() {
        FormController.shared.createAndCopyForm(form: form)
        } else {
            UIAlertController.presentDismissingAlert(title: "Unable to create form...", dismissAfter: 1.0)
        }
    }
    
    // Define an async function to fetch team data and handle UI updates
    func fetchTeamDataAndHandleUI() async {
        guard let teamID = UserAccount.currentUser?.teamID else { return }
        
        do {
            // Fetch team asynchronously
            let team = try await FirebaseController.shared.getTeamAsync(teamID: teamID)
                        
            // Fetch appointments for the fetched team asynchronously
            let appointments = try await FirebaseController.shared.getTeamAppointmentsAsync(for: team)
            
            
            // TODO: Show full appointment times, and notes
            if !appointments.isEmpty {
                UIAlertController.presentDismissingAlert(title: "Number of upcoming Appointments: \(appointments.count)", dismissAfter: 2.0)
                let sortedAppointments = groupAndSortAppointmentsByDay(appointments)
                
                updateUI(with: sortedAppointments)
                
            } else {
                UIAlertController.presentDismissingAlert(title: "No upcoming Appointments found", dismissAfter: 5.0)
            }
            
        } catch {
            print("Error fetching data: \(error.localizedDescription)")
            UIAlertController.presentDismissingAlert(title: "Error fetching data: \(error.localizedDescription)", dismissAfter: 5.0)
        }
    }

    // IBAction function
    @IBAction func showScheduleNotesButtonPressed(_ sender: Any) {
        Task {
            await fetchTeamDataAndHandleUI()
        }
    }
    
    @IBAction func locationButtonPressed(_ sender: Any) {
        self.vibrateForButtonPress(.heavy)
        FormController.shared.getLocationData(manager: &locationManager) { address in
            self.addressTextfield.text = address?.address
            self.zipTextfield.text = address?.zip
            self.cityTextfield.text = address?.city
            self.stateTextfield.text = address?.state
            self.phoneTextfield.becomeFirstResponder()
        }
    }
    
    @IBAction func copyPhoneNumberPressed(_ sender: Any) {
        self.vibrateForButtonPress(.heavy)
        FormController.shared.copy(phone: phoneTextfield.text)
    }
    
    @IBAction func copyEmailButtonPressed(_ sender: Any) {
        FormController.shared.copy(email: emailTextfield.text)
    }
    
    @IBAction func clearReasonButtonPressed(_ sender: Any) {
        self.vibrateForButtonPress(.heavy)
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
        self.vibrateForButtonPress(.heavy)
        let alert = UIAlertController(title: nil, message: "Are you sure you want to clear this section?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Clear", style: .default) {_ in
            self.commentsTextview.text = ""
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true)
        
    }
    
    deinit {
        // Remove the observer when the view controller is deallocated
        NotificationCenter.default.removeObserver(self)
    }

    @objc override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setupView()
    }

    @objc func backButtonPressed() {
        let newForm = createForm()
        if savedForm != newForm {
            showLeaveConfirmationAlert()
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    
    // MARK: FUNCTIONS
    func saveForm() {
        self.vibrateForButtonPress(.medium)
        if let form = createForm() {
            let saveQueue = DispatchQueue(label: "com.example.saveQueue", qos: .background)
            
            saveButton.isEnabled = false
            activityIndicator.startAnimating()
            
            if form.firebaseID.isNotEmpty {
                // UPDATE FORM
                saveQueue.async {
                    FirebaseController.shared.updateForm(firebaseID: form.firebaseID, form: form) { updatedForm, error in
                        DispatchQueue.main.async {
                            self.saveButton.isEnabled = true
                            self.activityIndicator.stopAnimating()
                        }
                        if let error = error {
                            print("there was an error: \(error)")
                            DispatchQueue.main.async {
                                UIAlertController.presentDismissingAlert(title: "Failed to Save Form", dismissAfter: 1.2)
                                self.vibrateForError()
                            }
                            return
                        }
                        DispatchQueue.main.async {
                            self.delegate?.didUpdateNew(form)
                            self.savedForm = form
                            UIAlertController.presentDismissingAlert(title: "Form Updated!", dismissAfter: 0.5)
                            self.vibrate()
                        }
                    }
                }
            } else {
                // CREATE FORM IN FIREBASE
                saveQueue.async {
                    FirebaseController.shared.saveForm(form: form) { savedForm, error in
                        DispatchQueue.main.async {
                            self.saveButton.isEnabled = true
                            self.activityIndicator.stopAnimating()
                        }
                        if let error = error {
                            print("Error: \(error)")
                            DispatchQueue.main.async {
                                UIAlertController.presentDismissingAlert(title: "Failed to Save Form", dismissAfter: 1.2)
                                self.vibrateForError()
                            }
                            return
                        }
                        
                        guard let savedForm = savedForm else { print("No Form!"); return }
                        self.firebaseID = savedForm.firebaseID
                        DispatchQueue.main.async {
                            self.delegate?.didAddNewForm(savedForm)
                            self.savedForm = form
                            UIAlertController.presentDismissingAlert(title: "Form Saved!", dismissAfter: 0.5)
                            self.vibrate()
                        }
                    }
                }
            }
        } else {
            UIAlertController.presentDismissingAlert(title: "Unable to create form...", dismissAfter: 1.0)
        }
    }
    
    func updateUI(with appointmentsByDay: [[Form]]) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E M/d" // Format for displaying day and date
        
        // Update day1TextField
        if appointmentsByDay.count > 0 {
            let day1Appointments = appointmentsByDay[0]
            let day1Date = dateFormatter.string(from: day1Appointments[0].date)
            var day1Text = "\(day1Date)\n"
            for appointment in day1Appointments {
                let timeString = DateFormatter.localizedString(from: appointment.date, dateStyle: .none, timeStyle: .short)
                day1Text.append("\(timeString)\n")
            }
            dayOneTextField.text = day1Text.trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            dayOneTextField.text = "\(Date().formattedDayDateMonth())\n<OPEN>"
            dayTwoTextField.text = "\(Date().formattedDayDateMonth())\n<OPEN>"
            dayThreeTextField.text = "\(Date().formattedDayDateMonth())\n<OPEN>"
        }
        
        // Update day2TextField
        if appointmentsByDay.count > 1, appointmentsByDay[1][0].date.formattedDay() == Date().addingDays(1)?.formattedDay() {
            let day2Appointments = appointmentsByDay[1]
            let day2Date = dateFormatter.string(from: day2Appointments[0].date)
            var day2Text = "\(day2Date)\n"
            for appointment in day2Appointments {
                let timeString = DateFormatter.localizedString(from: appointment.date, dateStyle: .none, timeStyle: .short)
                day2Text.append("\(timeString)\n")
            }
            dayTwoTextField.text = day2Text.trimmingCharacters(in: .whitespacesAndNewlines)
            
        } else {
            let day1Appointments = appointmentsByDay[0]
            let day1Date = day1Appointments[0].date
            dayTwoTextField.text = "\(day1Date.addingDays(1)?.formattedDayDateMonth() ?? "")\n<OPEN>"
//            let day2Appointments = appointmentsByDay[1]
//            let day2Date = day2Appointments[0].date
//            dayThreeTextField.text = "\(day2Date.addingDays(1)?.formattedDayMonth() ?? "")\n<OPEN>"
        }
        
        // Update day3TextField
        if appointmentsByDay.count > 2 || appointmentsByDay[0][0].date.addingDays(2)?.formattedDay() == appointmentsByDay[2][0].date.formattedDay() {
            let day3Appointments = appointmentsByDay[2]
            let day3Date = dateFormatter.string(from: day3Appointments[0].date)
            var day3Text = "\(day3Date)\n"
            for appointment in day3Appointments {
                let timeString = DateFormatter.localizedString(from: appointment.date, dateStyle: .none, timeStyle: .short)
                day3Text.append("\(timeString)\n")
            }
            dayThreeTextField.text = day3Text.trimmingCharacters(in: .whitespacesAndNewlines)
            
        } else {
            let day1Appointments = appointmentsByDay[0]
            let day1Date = day1Appointments[0].date
            dayThreeTextField.text = "\(day1Date.addingDays(2)?.formattedDayDateMonth() ?? "")\n<OPEN>"
        }
    }

    
    func groupAndSortAppointmentsByDay(_ appointments: [Form]) -> [[Form]] {
        var groupedAppointments: [Date: [Form]] = [:]
        
        // Group appointments by day
        let calendar = Calendar.current
        for appointment in appointments {
            let date = calendar.startOfDay(for: appointment.date)
            if groupedAppointments[date] == nil {
                groupedAppointments[date] = [appointment]
            } else {
                groupedAppointments[date]?.append(appointment)
            }
        }
        
        // Sort appointments within each day by time
        var sortedAppointmentsByDay: [[Form]] = []
        let sortedDates = groupedAppointments.keys.sorted()
        for date in sortedDates {
            if let appointments = groupedAppointments[date] {
                let sortedAppointments = appointments.sorted { $0.date < $1.date }
                sortedAppointmentsByDay.append(sortedAppointments)
            }
        }
        
        return sortedAppointmentsByDay
    }

    
    func sortTeamsUpcomingAppointments(appointments: [Form?]) {
        
    }
    
    func showLeaveConfirmationAlert() {
        let alert = UIAlertController(title: "Save Changes?", message: nil, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            self.saveForm()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.navigationController?.popViewController(animated: true)
            }
        }
        let leaveAction = UIAlertAction(title: "Leave", style: .destructive) { _ in
            self.navigationController?.popViewController(animated: true)
        }
        
        alert.addActions([saveAction, leaveAction])
        self.present(alert, animated: true)
    }
    
    func setupView() {
        guard let user = UserAccount.currentUser else { return }
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
            emailTextfield.placeholder = "@synergywindow.com"
            trelloButton.isVisible = true

        case .sanAntonio:
            print("Form For San Antonio")
            
        default:
            break
        }
        
        // CORNER RADIUS
        reasonTextview.layer.cornerRadius = 5.0
        commentsTextview.layer.cornerRadius = 5.0
        
                
        // LIGHT/DARK MODE
        if traitCollection.userInterfaceStyle == .dark {
            // BACKGROUND
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = view.bounds
            gradientLayer.colors = [UIColor.black.cgColor, UIColor.black.cgColor, UIColor.eden.cgColor] // Gradient colors
            gradientLayer.locations = [-0.05, 0.4, 2.0] // Gradient locations (start and end)
            view.layer.insertSublayer(gradientLayer, at: 0)
            
        } else {
            // BACKGROUND
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = view.bounds
            gradientLayer.colors = [UIColor.white.cgColor, UIColor.white.cgColor, UIColor.eden.cgColor] // Gradient colors
            gradientLayer.locations = [-0.05, 0.4, 3.0] // Gradient locations (start and end)
            view.layer.insertSublayer(gradientLayer, at: 0)
        }
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
        let currentLength = (textField.text ?? "").count
        let newLength = currentLength + string.count - range.length

        if textField == phoneTextfield {
            if newLength != 10 {
                textField.layer.borderWidth = 1.0
                textField.layer.borderColor = UIColor.red.cgColor
            } else {
                textField.layer.borderColor = UIColor.clear.cgColor
            }
        }

        return true
    }
    
    func createForm() -> Form? {
        guard let user = user else { return nil }
        let form = Form(firebaseID: self.firebaseID,
                        address: addressTextfield.text ?? "",
                        city: cityTextfield.text ?? "",
                        comments: commentsTextview.text ?? "",
                        date: dateTimePicker.date,
                        email: emailTextfield.text ?? "",
                        energyBill: energyBillTextfield.text ?? "",
                        financeOptions: financeTextfield.text ?? "",
                        firstName: firstNameTextfield.text ?? "",
                        homeValue: homeValueTextfield.text ?? "--",
                        lastName: lastNameTextfield.text ?? "",
                        numberOfWindows: numberOfWindowsTexfield.text ?? "",
                        phone: phoneTextfield.text ?? "",
                        rate: rateTextfield.text ?? "",
                        reason: reasonTextview.text ?? "",
                        retailQuote: quoteTextfield.text ?? "",
                        spouse: spouseTextfield.text ?? "",
                        state: stateTextfield.text ?? "",
                        userID: user.firebaseID,
                        yearBuilt: yearBuiltTextfield.text ?? "--",
                        yearsOwned: yearsOwnedTextfield.text ?? "--",
                        zip: zipTextfield.text ?? ""
        )
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
extension CreateFormViewController: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
}
