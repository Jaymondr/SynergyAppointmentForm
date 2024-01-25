//
//  ProfileViewController.swift
//  SynergyAppointmentForm
//
//  Created by Jaymond Richardson on 12/23/23.
//

import UIKit
import FirebaseAuth
import MessageUI

protocol VisibleToggleable {
    var isVisible: Bool { get set }
}

class ProfileViewController: UIViewController {
    
    // MARK: - OUTLETS
    @IBOutlet weak var nameStackView: UIStackView!
    @IBOutlet weak var salesStackView: UIStackView!
    @IBOutlet weak var emailStackView: UIStackView!
    @IBOutlet weak var emptyBranchStackView: UIStackView!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var salesLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    @IBOutlet weak var branchInfoButton: UIButton!
    @IBOutlet weak var branchLabel: UILabel!
    
    // REPORTS
    @IBOutlet weak var reportsView: UIView!
    @IBOutlet weak var salesRate: UILabel!
    @IBOutlet weak var ranRate: UILabel!
    @IBOutlet weak var ranIncompleteRate: UILabel!
    @IBOutlet weak var rescheduledRate: UILabel!
    @IBOutlet weak var cancelledRate: UILabel!
    
    
    // MARK: - LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        // manageCurrentUserState decides what to show if user is signed in/out
        configureViewForState()
        
        // Loads view data and style
        setupView()
        getReports()
        
    }
    
    // MARK: - PROPERTIES
    var sales: Int = 0
    var forms: [Form] = [] {
        didSet {
            sales = forms.filter( { $0.outcome == .sold } ).count
        }
    }
    
    
    // MARK: - BUTTONS
    @IBAction func settingsBarButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        let deleteAccountAction = UIAlertAction(title: "DELETE ACCOUNT", style: .destructive) { _ in
            guard let user = UserAccount.currentUser else { return }
            guard MFMailComposeViewController.canSendMail() else { return }

            let bodyText = "Please delete my account.\nName: \(user.firstName + " " + user.lastName)\nID: \(user.firebaseID)"
            
            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self
            mailComposer.setToRecipients(["coretechniquellc@gmail.com"])
            mailComposer.setSubject("Delete Account")
            mailComposer.setMessageBody(bodyText, isHTML: false)

            self.present(mailComposer, animated: true, completion: nil)
        }
        
        // FEEDBACK
        let feedbackAction = UIAlertAction(title: "Submit Feedback", style: .default) { _ in
            guard MFMailComposeViewController.canSendMail() else { return }

            let bodyText = "Please enter feedback here... "
            
            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self
            mailComposer.setToRecipients(["coretechniquellc@gmail.com"])
            mailComposer.setSubject("User Feedback")
            mailComposer.setMessageBody(bodyText, isHTML: false)

            self.present(mailComposer, animated: true, completion: nil)
        }
        
        // BRANCH
        let branchAction = UIAlertAction(title: "Choose Branch", style: .default) { _ in
            self.showBranchSelectionAlert()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addActions([branchAction, feedbackAction, deleteAccountAction, cancelAction])
        self.present(alert, animated: true)
        
    }
    
    @IBAction func signInButtonPressed(_ sender: Any) {
        guard let email = emailTextField.text,
              let password = passwordTextField.text else { return }
        passwordTextField.resignFirstResponder()
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print("There was an error: \(error)")
                UIAlertController.presentOkAlert(message: "Error: \(error)", actionOptionTitle: "Ok")
            }
            if let result = result {
                // Fetch user
                print("UID: \(result.user.uid)")
                FirebaseController.shared.getUser(with: result.user.uid) { user, error in
                    if let error = error {
                        print("Error getting user info from firebas: \(error). Error ")
                    return
                    }
                    guard  let user = user else { print("No User"); return }
                        // SAVE USER INFORMATION TO USER DEFAULTS
                        let userDefaultsData = user.toUserDefaultsDictionary()
                        UserDefaults.standard.set(userDefaultsData, forKey: UserAccount.kUser)
                    
                    UIAlertController.presentDismissingAlert(title: "\(user.firstName) signed in.", dismissAfter: 1.2)
                    self.configureViewForState()
                    self.setupView()
                    NotificationCenter.default.post(name: .signInNotification, object: nil)
                }
            }
        }
    }
    
    @IBAction func logOutButtonPressed(_ sender: Any) {
        logOutButton.isHidden = UserAccount.currentUser == nil
        UIAlertController.presentMultipleOptionAlert(message: "Log out?", actionOptionTitle: "Continue", cancelOptionTitle: "Cancel") {
            do  {
                try Auth.auth().signOut()
                UserDefaults.standard.removeObject(forKey: UserAccount.kUser)
                UserAccount.currentUser = nil
                self.configureViewForState()
                print("Signed out user")
                NotificationCenter.default.post(name: .signOutNotification, object: nil)
                
            } catch let signOutError as NSError {
                UIAlertController.presentDismissingAlert(title: signOutError.localizedDescription, dismissAfter: 2.0)
            }
        }
    }

    @IBAction func branchInfoButtonPressed(_ sender: Any) {
        showBranchSelectionAlert()
    }
    
    
    
    // MARK: - FUNCTIONS
    private func setupView() {
        navigationController?.navigationBar.tintColor = .eden

        salesLabel.text = "Sales: \(sales)"
        emailLabel.text = UserAccount.currentUser?.email ?? ""
        branchLabel.text = UserAccount.currentUser?.branch?.rawValue ?? ""
        let firstName = UserAccount.currentUser?.firstName ?? ""
        let lastName = UserAccount.currentUser?.lastName ?? ""
        
        // NAME LABELS
        if let lastNameFirstLetter = lastName.first {
            nameLabel.text = "\(firstName) \(lastNameFirstLetter)."
        } else {
            nameLabel.text = firstName + lastName
        }
        
        // BRANCH LABEL
        if let branch = UserAccount.currentUser?.branch {
            emptyBranchStackView.isHidden = true
            branchLabel.text = branch.rawValue

        } else {
            branchLabel.isHidden = true
            emptyBranchStackView.isVisible = true
        }
    }
    
    func getReports() {
        var pastAppointmentForms: [Form] = []
        let sortedAppointmentForms = forms.sorted {$0.date < $1.date}
        for form in sortedAppointmentForms {
            if form.date < Date() {
                pastAppointmentForms.append(form)
            }
        }

        // SOLD
        salesRate.text = ReportController.shared.calculateTurnoverRate(for: pastAppointmentForms, outcome: .sold) + "%"
        
        // CANCELLED
        cancelledRate.text = ReportController.shared.calculateTurnoverRate(for: pastAppointmentForms, outcome: .cancelled) + "%"
        
        // RESCHEDULED
        rescheduledRate.text = ReportController.shared.calculateTurnoverRate(for: pastAppointmentForms, outcome: .rescheduled) + "%"

        // RAN
        ranRate.text = ReportController.shared.calculateTurnoverRate(for: pastAppointmentForms, outcome: .ran) + "%"

        // RAN-INCOMPLETE
        ranIncompleteRate.text = ReportController.shared.calculateTurnoverRate(for: pastAppointmentForms, outcome: .ranIncomplete) + "%"

    }
    
    private func configureViewForState() {
        if UserAccount.currentUser == nil {
            // NOT SIGNED IN
            hide([logOutButton, nameStackView, salesStackView, emailStackView, branchLabel, reportsView])
            show([signInButton, emailTextField, passwordTextField])
            
        } else {
            // SIGNED IN
            show([logOutButton, nameStackView, salesStackView, emailStackView, branchLabel, reportsView])
            hide([signInButton, emailTextField, passwordTextField])
        }
    }
    
    private func show(_ views: [VisibleToggleable]) {
        for var view in views {
            view.isVisible = true
        }
    }
    
    private func hide(_ views: [VisibleToggleable]) {
        for var view in views {
            view.isVisible = false
        }
    }
    
    func showBranchSelectionAlert() {
        let alert = UIAlertController(title: "Select a Branch", message: nil, preferredStyle: .actionSheet)
        
        for branch in Branch.allCases {
            let action = UIAlertAction(title: branch.rawValue, style: .default) { [weak self] _ in
                self?.handleBranchSelection(branch)
            }
            alert.addAction(action)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0) // Set the position
            popoverController.permittedArrowDirections = []
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    func handleBranchSelection(_ selectedBranch: Branch) {
        print("Selected Branch: \(selectedBranch.rawValue)")
        UserAccountController.shared.updateBranch(newBranch: selectedBranch)
        branchLabel.text = selectedBranch.rawValue
        emptyBranchStackView.isHidden = true
        branchLabel.isVisible = true
    }
}

// MARK: - EXTENSTIONS
extension ProfileViewController: MFMailComposeViewControllerDelegate {

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

