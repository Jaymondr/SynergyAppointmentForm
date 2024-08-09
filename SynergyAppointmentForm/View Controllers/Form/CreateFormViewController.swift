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
    @IBOutlet weak var scrollView: UIScrollView!
    // SCHEDULE
    @IBOutlet weak var scheduleView: UIView!
    @IBOutlet weak var ScheduleTitleLabel: UILabel!
    @IBOutlet weak var scheduleActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var dayOneTextField: UITextView!
    @IBOutlet weak var dayTwoTextField: UITextView!
    @IBOutlet weak var dayThreeTextField: UITextView!
    @IBOutlet weak var showScheduleButton: UIButton!
    // FORM
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
    @IBOutlet weak var financeTextField: UITextField!
    @IBOutlet weak var yearsOwnedTextField: UITextField!
    @IBOutlet weak var homeValueTextField: UITextField!
    @IBOutlet weak var yearBuiltTextField: UITextField!
    @IBOutlet weak var quoteTextView: UITextView!
    @IBOutlet weak var reasonTextView: UITextView!
    @IBOutlet weak var rateTextField: UITextField!
    @IBOutlet weak var commentsTextView: UITextView!
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
        phoneTextField.layer.borderWidth = 1.0
        phoneTextField.layer.cornerRadius = 5
        phoneTextField.layer.borderColor = UIColor.clear.cgColor
        setupView()
        setTextFieldsDelegate()
        navigationController?.navigationBar.tintColor = UIColor.steel
        NotificationCenter.default.addObserver(self, selector: #selector(traitCollectionDidChange(_:)), name: NSNotification.Name("traitCollectionDidChangeNotification"), object: nil)
        
        // Uncomment line when you want to show save before leaving message
//        let backButton = UIBarButtonItem.customBackButton(target: self, action: #selector(backButtonPressed))
//        navigationItem.leftBarButtonItem = backButton
    }
        
    // MARK: PROPERTIES
    var firebaseID: String = ""
    var savedForm: Form?
    var upcomingAppointmentsByDay: [[Form]] = []
    var fetchedTeam: Team?
    var user: UserAccount? {
        UserAccount.currentUser
    }
    private var textFieldScrollPositions: [UITextField: CGFloat] = [:]
    var scheduleViewScrollOffset: CGFloat {
        if scheduleView.isVisible {
            return 193
        } else {
            return 0
        }
    }
    
    var branchScrollOffset: CGFloat {
        if user?.branch != .raleigh {
            return -90
        } else {
            return 0
        }
    }


    // MARK: BUTTONS
    @IBAction func saveButtonPressed(_ sender: Any) {
        saveForm()
    }

    @IBAction func messageButtonPressed(_ sender: Any) {
        if let form = createForm() {
            FormController.shared.prepareToSendMessage(form: form, phoneNumber: phoneTextField.text ?? "", viewController: self)
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

    // IBAction function
    @IBAction func showScheduleNotesButtonPressed(_ sender: Any) {
        if scheduleView.isHidden {
            // Show the view and run the task
            scheduleView.isHidden = false
            Task {
                await fetchTeamAppointments(forDays: 3)
            }
        } else {
            // Hide the view and don't run the task
            scheduleView.isHidden = true
        }
    }
        
    @IBAction func locationButtonPressed(_ sender: Any) {
        self.vibrateForButtonPress(.heavy)
        FormController.shared.getLocationData(manager: &locationManager) { address in
            self.addressTextField.text = address?.address
            self.zipTextField.text = address?.zip
            self.cityTextField.text = address?.city
            self.stateTextField.text = address?.state
        }
        self.scrollView.scrollTo(yPosition: self.scheduleViewScrollOffset + 350, animated: true)
        self.numberOfWindowsTextField.becomeFirstResponder()
    }
    
    @IBAction func copyPhoneNumberPressed(_ sender: Any) {
        self.vibrateForButtonPress(.heavy)
        FormController.shared.copy(phone: phoneTextField.text)
    }
    
    @IBAction func copyEmailButtonPressed(_ sender: Any) {
        FormController.shared.copy(email: emailTextField.text)
    }
    
    @IBAction func clearQuoteButtonPressed(_ sender: Any) {
        self.vibrateForButtonPress(.heavy)
        let alert = UIAlertController(title: nil, message: "Are you sure you want to clear this section?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Clear", style: .default) {_ in
            self.quoteTextView.text = ""
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true)
        
    }
    
    @IBAction func clearReasonButtonPressed(_ sender: Any) {
        self.vibrateForButtonPress(.heavy)
        let alert = UIAlertController(title: nil, message: "Are you sure you want to clear this section?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Clear", style: .default) {_ in
            self.reasonTextView.text = ""
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
            self.commentsTextView.text = ""
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
        
        guard let form = createForm() else {
            UIAlertController.presentDismissingAlert(title: "Unable to create form...", dismissAfter: 1.0)
            return
        }

        let saveQueue = DispatchQueue(label: "com.example.saveQueue", qos: .background)
        saveButton.isEnabled = false
        activityIndicator.startAnimating()

        let completion: (Error?) -> Void = { error in
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
            }
        }

        let handleSaveResult: (Form?, Error?) -> Void = { savedForm, error in
            completion(error)
            
            guard error == nil, let savedForm = savedForm else { return }
            self.firebaseID = savedForm.firebaseID
            DispatchQueue.main.async {
                self.delegate?.didAddNewForm(savedForm)
                self.savedForm = savedForm
                UIAlertController.presentDismissingAlert(title: "Form Saved!", dismissAfter: 0.5)
                self.vibrate()
            }
        }

        if form.firebaseID.isNotEmpty {
            // Update Form
            saveQueue.async {
                FirebaseController.shared.updateForm(firebaseID: form.firebaseID, form: form, completion: handleSaveResult)
            }
        } else {
            // Create Form
            saveQueue.async {
                FirebaseController.shared.saveForm(form: form, completion: handleSaveResult)
            }
        }
    }

    
    func createForm() -> Form? {
        guard let user = user else { return nil }
        return Form(firebaseID: self.firebaseID,
                        address: addressTextField.text ?? "",
                        city: cityTextField.text ?? "",
                        comments: commentsTextView.text ?? "",
                        date: dateTimePicker.date,
                        email: emailTextField.text ?? "",
                        energyBill: energyBillTextField.text ?? "",
                        financeOptions: financeTextField.text ?? "",
                        firstName: firstNameTextField.text ?? "",
                        homeValue: homeValueTextField.text ?? "--",
                        lastName: lastNameTextField.text ?? "",
                        numberOfWindows: numberOfWindowsTextField.text ?? "",
                        phone: phoneTextField.text ?? "",
                        rate: rateTextField.text ?? "",
                        reason: reasonTextView.text ?? "",
                        retailQuote: quoteTextView.text ?? "",
                        spouse: spouseTextField.text ?? "",
                        state: stateTextField.text ?? "",
                        userID: user.firebaseID,
                        yearBuilt: yearBuiltTextField.text ?? "--",
                        yearsOwned: yearsOwnedTextField.text ?? "--",
                        zip: zipTextField.text ?? ""
        )
    }
    
    func fetchTeamAppointments(forDays numberOfDays: Int) async {
        if upcomingAppointmentsByDay.isEmpty {
            guard let teamID = UserAccount.currentUser?.teamID else { return }
            
            do {
                // Fetch team asynchronously
                let team = try await FirebaseController.shared.getTeamAsync(teamID: teamID)
                fetchedTeam = team
                let teamName = fetchedTeam?.name
                // SCHEDULE TITLE
                ScheduleTitleLabel.text = (teamName != nil) ? (teamName! + " Schedule") : "Schedule"

                // Start the activity indicator
                scheduleActivityIndicator.startAnimating()
                
                // Fetch appointments for the fetched team asynchronously
                let appointments = try await FirebaseController.shared.getTeamAppointmentsAsync(for: team)
                
                if !appointments.isEmpty {
                    // Group and sort appointments by day
                    let sortedAppointments = groupAndSortAppointmentsByDay(appointments, numberOfDays: numberOfDays)
                    upcomingAppointmentsByDay = sortedAppointments // Hold locally to reduce server traffic
                    // Update the schedule UI for the next 3 days
                    updateScheduleUI(with: sortedAppointments, numberOfDays: numberOfDays)
                } else {
                    UIAlertController.presentDismissingAlert(title: "No upcoming Appointments found", dismissAfter: 1.5)
                }
                
            } catch {
                print("Error fetching data: \(error.localizedDescription)")
                UIAlertController.presentDismissingAlert(title: "Error fetching data: \(error.localizedDescription)", dismissAfter: 5.0)
            }
            
            // Stop the activity indicator
            scheduleActivityIndicator.stopAnimating()
        } else {
            print("Already fetched appointments")
        }
    }

    // Group and sort appointments by day function
    func groupAndSortAppointmentsByDay(_ appointments: [Form], numberOfDays: Int) -> [[Form]] {
        var groupedAppointments: [Date: [Form]] = [:]
        let calendar = Calendar.current

        // Group appointments by day
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
        let today = calendar.startOfDay(for: Date())

        for dayOffset in 0..<numberOfDays {
            if let targetDate = calendar.date(byAdding: .day, value: dayOffset, to: today) {
                if let dayAppointments = groupedAppointments[targetDate] {
                    let sortedAppointments = dayAppointments.sorted { $0.date < $1.date }
                    sortedAppointmentsByDay.append(sortedAppointments)
                } else {
                    // No appointments for this day, append an empty array
                    sortedAppointmentsByDay.append([])
                }
            }
        }

        return sortedAppointmentsByDay
    }

    // UPDATE SCHEDULE UI
    func updateScheduleUI(with appointmentsByDay: [[Form]], numberOfDays: Int) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E M/d" // Format for displaying day and date

        let textFields = [dayOneTextField, dayTwoTextField, dayThreeTextField]

        for (index, textField) in textFields.enumerated() {
            guard index < numberOfDays else { break }

            let targetDate = Date().addingDays(index)
            let formattedTargetDate = dateFormatter.string(from: targetDate ?? Date())
            
            let attributedText = NSMutableAttributedString(string: "\(formattedTargetDate)\n", attributes: [
                .foregroundColor: UIColor.steel,
                .font: UIFont.systemFont(ofSize: 18, weight: .medium)
            ]) // Date color

            if index < appointmentsByDay.count {
                let dayAppointments = appointmentsByDay[index]
                if dayAppointments.isNotEmpty {
                    var timeSlotsCount: [Date: Int] = [:]
                    for appointment in dayAppointments {
                        timeSlotsCount[appointment.date, default: 0] += 1
                    }
                    
                    let sortedAppointments = timeSlotsCount.keys.sorted()

                    for appointmentDate in sortedAppointments {
                        let count = timeSlotsCount[appointmentDate] ?? 0
                        let timeString = DateFormatter.localizedString(from: appointmentDate, dateStyle: .none, timeStyle: .short)
                        let appointmentText: NSAttributedString
                        
                        if count > 1 {
                            appointmentText = NSAttributedString(string: "\(timeString) (\(count))\n", attributes: [
                                .foregroundColor: UIColor.outcomeBlue,
                                .font: UIFont.systemFont(ofSize: 17, weight: .medium)
                            ]) // Appointment time color
                        } else {
                            appointmentText = NSAttributedString(string: "\(timeString)\n", attributes: [
                                .foregroundColor: UIColor.outcomeBlue,
                                .font: UIFont.systemFont(ofSize: 17, weight: .medium)
                            ]) // Appointment time color
                        }
                        
                        attributedText.append(appointmentText)
                    }
                } else {
                    let openText = NSAttributedString(string: "<OPEN>", attributes: [.foregroundColor: UIColor.outcomeGreen, .font: UIFont.boldSystemFont(ofSize: 17)]) // Open text color
                    attributedText.append(openText)
                }
            } else {
                let openText = NSAttributedString(string: "<OPEN>", attributes: [.foregroundColor: UIColor.outcomeGreen, .font: UIFont.boldSystemFont(ofSize: 17)]) // Open text color
                attributedText.append(openText)
            }

            textField?.attributedText = attributedText
        }
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
        scheduleView.isHidden = true
        showScheduleButton.isHidden = user.teamID == nil
        
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
        
        // CORNER RADIUS
        quoteTextView.layer.cornerRadius = 5.0
        reasonTextView.layer.cornerRadius = 5.0
        commentsTextView.layer.cornerRadius = 5.0
        
        // SCHEDULE TEXTVIEWS
        let scheduleTextViews: [UITextView] = [dayOneTextField, dayTwoTextField, dayThreeTextField]

        // SCHEDULE TEXTFIELD
        for textView in scheduleTextViews {
            textView.layer.borderWidth = 1.5
            textView.layer.borderColor = UIColor.outcomeBlue.cgColor
            textView.layer.cornerRadius = 8
//            textView.backgroundColor = UIColor.steelAccent
        }
        
        let additionalCommentsTextViews: [UITextView] = [quoteTextView, reasonTextView, commentsTextView]
        
        for textView in additionalCommentsTextViews {
            textView.layer.borderWidth = 1
            textView.layer.cornerRadius = 8.0
            textView.layer.borderColor = UIColor.steel.cgColor
        }
        
        // TEXTFIELDS
        let textFields: [UITextField] = [firstNameTextField, lastNameTextField, spouseTextField, addressTextField, cityTextField, stateTextField, zipTextField, phoneTextField, emailTextField, numberOfWindowsTextField, energyBillTextField,financeTextField, yearBuiltTextField, yearsOwnedTextField, homeValueTextField, rateTextField]
        
        for textField in textFields {
            textField.addBottomBorder(with: .steel, andHeight: 1)
        }
                
        // LIGHT/DARK MODE
        if traitCollection.userInterfaceStyle == .dark {
            // BACKGROUND
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = view.bounds
            gradientLayer.colors = [UIColor.black.cgColor, UIColor.black.cgColor, UIColor.outcomeBlue.cgColor] // Gradient colors
            gradientLayer.locations = [-0.05, 0.3, 3.0] // Gradient locations (start and end)
            view.layer.insertSublayer(gradientLayer, at: 0)
            
        } else {
            // BACKGROUND
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = view.bounds
            gradientLayer.colors = [UIColor.white.cgColor, UIColor.white.cgColor, UIColor.outcomeBlue.cgColor] // Gradient colors
            gradientLayer.locations = [-0.05, 0.4, 3.0] // Gradient locations (start and end)
            view.layer.insertSublayer(gradientLayer, at: 0)
        }
    }
    
    func setTextFieldsDelegate() {
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        spouseTextField.delegate = self
        addressTextField.delegate = self
        zipTextField.delegate = self
        cityTextField.delegate = self
        stateTextField.delegate = self
        phoneTextField.delegate = self
        emailTextField.delegate = self
        numberOfWindowsTextField.delegate = self
        energyBillTextField.delegate = self
        yearBuiltTextField.delegate = self
        yearsOwnedTextField.delegate = self
        homeValueTextField.delegate = self
        quoteTextView.delegate = self
        financeTextField.delegate = self
        reasonTextView.delegate = self
        rateTextField.delegate = self
        commentsTextView.delegate = self
        
        textFieldScrollPositions[firstNameTextField] = 0
        textFieldScrollPositions[lastNameTextField] = 100
        textFieldScrollPositions[spouseTextField] = 100
        textFieldScrollPositions[phoneTextField] = 230
        textFieldScrollPositions[emailTextField] = 260
        textFieldScrollPositions[addressTextField] = 260
        textFieldScrollPositions[cityTextField] = 260
        textFieldScrollPositions[stateTextField] = 260
        textFieldScrollPositions[zipTextField] = 344
        textFieldScrollPositions[numberOfWindowsTextField] = 550
        textFieldScrollPositions[energyBillTextField] = 550
        textFieldScrollPositions[yearBuiltTextField] = 550
        textFieldScrollPositions[yearsOwnedTextField] = 550
        textFieldScrollPositions[homeValueTextField] = 804
        textFieldScrollPositions[financeTextField] = 930 + branchScrollOffset
        textFieldScrollPositions[rateTextField] = 1300 + branchScrollOffset

    }
    
    // MARK: - TEXTFIELD RETURN METHOD
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == firstNameTextField {
            lastNameTextField.becomeFirstResponder()
            scrollView.scrollTo(yPosition: scheduleViewScrollOffset, animated: true)
        } else if textField == lastNameTextField {
            spouseTextField.becomeFirstResponder()
            scrollView.scrollTo(yPosition: scheduleViewScrollOffset, animated: true)
        } else if textField == spouseTextField {
            phoneTextField.becomeFirstResponder()
            scrollView.scrollTo(yPosition: scheduleViewScrollOffset + 230, animated: true)
        } else if textField == phoneTextField {
            emailTextField.becomeFirstResponder()
            scrollView.scrollTo(yPosition: scheduleViewScrollOffset + 260, animated: true)
        } else if textField == emailTextField {
            addressTextField.becomeFirstResponder()
            scrollView.scrollTo(yPosition: scheduleViewScrollOffset + 260, animated: true)
        } else if textField == addressTextField {
            cityTextField.becomeFirstResponder()
            scrollView.scrollTo(yPosition: scheduleViewScrollOffset + 260, animated: true)
        } else if textField == cityTextField {
            stateTextField.becomeFirstResponder()
            scrollView.scrollTo(yPosition: scheduleViewScrollOffset + 260, animated: true)
        } else if textField == stateTextField {
            zipTextField.becomeFirstResponder()
            scrollView.scrollTo(yPosition: scheduleViewScrollOffset + 344, animated: true)
        } else if textField == zipTextField {
            numberOfWindowsTextField.becomeFirstResponder()
            scrollView.scrollTo(yPosition: scheduleViewScrollOffset + 550, animated: true)
        } else if textField == numberOfWindowsTextField {
            energyBillTextField.becomeFirstResponder()
            scrollView.scrollTo(yPosition: scheduleViewScrollOffset + 550, animated: true)
        } else if textField == energyBillTextField {
            yearBuiltTextField.becomeFirstResponder()
        } else if textField == yearBuiltTextField {
            yearsOwnedTextField.becomeFirstResponder()
        } else if textField == yearsOwnedTextField {
            homeValueTextField.becomeFirstResponder()
            scrollView.scrollTo(yPosition: scheduleViewScrollOffset + 706, animated: true)
        } else if textField == homeValueTextField {
            financeTextField.becomeFirstResponder()
            scrollView.scrollTo(yPosition: scheduleViewScrollOffset + 804, animated: true)
        } else if textField == financeTextField {
            quoteTextView.becomeFirstResponder()
            scrollView.scrollTo(yPosition: scheduleViewScrollOffset + branchScrollOffset + 1000, animated: true)
        } else if textField == quoteTextView {
            reasonTextView.becomeFirstResponder()
        } else if textField == reasonTextView {
            rateTextField.becomeFirstResponder()
        } else if textField == rateTextField {
            commentsTextView.becomeFirstResponder()
            scrollView.scrollTo(yPosition: scheduleViewScrollOffset + 1300, animated: true)
        }
        else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let scrollPosition = textFieldScrollPositions[textField] {
            scrollToTextField(textField, at: scrollPosition)
        }
    }

    private func scrollToTextField(_ textField: UITextField, at scrollPosition: CGFloat) {
        // Ensure scrollView is properly set up
        scrollView.scrollTo(yPosition: scrollPosition + scheduleViewScrollOffset, animated: true)
    }

    // Changes phone textField border color
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentLength = (textField.text ?? "").count
        let newLength = currentLength + string.count - range.length

        if textField == phoneTextField {
            if newLength != 10 {
                textField.layer.borderWidth = 1.0
                textField.layer.borderColor = UIColor.red.cgColor
            } else {
                textField.layer.borderColor = UIColor.clear.cgColor
            }
        }

        return true
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
