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
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    
    // PROFILE CARD
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var emptyBranchStackView: UIStackView!
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var accountTypeLabel: UILabel!
    @IBOutlet weak var salesLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var branchInfoButton: UIButton!
    @IBOutlet weak var branchLabel: UILabel!
    
    // SIGN IN CARD
    @IBOutlet weak var signInView: UIView!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // REPORTS
    @IBOutlet weak var appointmentsLabel: UILabel!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var pendingNumber: UILabel!
    @IBOutlet weak var reportsView: UIView!
    @IBOutlet weak var salesRate: UILabel!
    @IBOutlet weak var soldNumber: UILabel!
    @IBOutlet weak var ranRate: UILabel!
    @IBOutlet weak var ranNumber: UILabel!
    @IBOutlet weak var ranIncompleteRate: UILabel!
    @IBOutlet weak var ranIncompleteNumber: UILabel!
    @IBOutlet weak var rescheduledRate: UILabel!
    @IBOutlet weak var rescheduledNumber: UILabel!
    @IBOutlet weak var cancelledRate: UILabel!
    @IBOutlet weak var cancelledNumber: UILabel!
    
    
    // MARK: - LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        // manageCurrentUserState decides what to show if user is signed in/out
        configureViewForState()
        
        // Loads view data and style
        setupView()
        getReports(for: nil)
        filterButton.tintColor = .gray
        
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
    
    @IBAction func filterButtonPressed(_ sender: Any) {
        guard let user = UserAccount.currentUser, let branch = user.branch else { return }
        FirebaseController.shared.getActiveUsers(for: branch) { users, error in
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            let alert = UIAlertController(title: "Filter Reports", message: nil, preferredStyle: .alert)
            for user in users {
                let userAction = UIAlertAction(title: user.firstName, style: .default) { _ in
                    print("Selected user: \(user.firstName)")
                    self.getReports(for: user.firebaseID)
                }
                alert.addAction(userAction)
            }
            self.present(alert, animated: true)
        }
    }
    
    
    // MARK: - FUNCTIONS
    private func setupView() {
        navigationController?.navigationBar.tintColor = .eden
        guard let user = UserAccount.currentUser else { return }
        
        // BRANCH LABEL
        if let branch = user.branch {
            emptyBranchStackView.isHidden = true
            branchLabel.text = branch.rawValue

        } else {
            branchLabel.isHidden = true
            emptyBranchStackView.isVisible = true
        }
        
        // REPORT CARD
        reportsView.layer.cornerRadius = 8
        reportsView.layer.borderWidth = 1.5
        reportsView.layer.borderColor = UIColor.outcomeGreen.cgColor
        
        // PROFILE CARD
        profileView.layer.borderWidth = 1.5
        profileView.layer.borderColor = UIColor.eden.cgColor
        profileView.backgroundColor = .clear
        // Name
        if let lastNameFirstLetter = user.lastName.first {
            nameLabel.text = "\(user.firstName) \(lastNameFirstLetter)."
        } else {
            nameLabel.text = user.firstName + user.lastName
        }
        // Account Type
        accountTypeLabel.text = user.accountType?.rawValue
        // Branch
        branchLabel.text = user.branch?.rawValue ?? ""
        // Email
        emailLabel.text = UserAccount.currentUser?.email ?? ""
        // Sales
        salesLabel.text = "Sales: \(sales)"


        // SIGN IN CARD
        signInView.layer.borderWidth = 1.5
        signInView.layer.borderColor = UIColor.outcomeBlue.cgColor
        signInView.backgroundColor = .clear
        
    }
    
    func getReports(for userID: String?) {
        guard let user = UserAccount.currentUser else { return }
        let userID = userID ?? user.firebaseID
        FirebaseController.shared.getForms(for: userID) { forms, error in
            if let error = error {
                print("Error: \(error)")
            }
            
            // Get reports for non pending forms only
            let nonPendingForms = forms.filter({ $0.outcome != .pending })
            
            // ALL
            self.appointmentsLabel.text = "Appointments (\(forms.count))"
            
            // PENDING
            let pendingCount = ReportController.shared.getNumber(of: .pending, from: forms)
            self.pendingNumber.text = "Pending (\(pendingCount))"
            
            // SOLD
            let soldCount = ReportController.shared.getNumber(of: .sold, from: nonPendingForms)
            self.salesRate.text = ReportController.shared.calculateTurnoverRate(for: nonPendingForms, outcome: .sold) + "%"
            self.soldNumber.text = "Sold (\(soldCount))"
            
            // RAN
            let ranCount = ReportController.shared.getNumber(of: .ran, from: nonPendingForms)
            self.ranRate.text = ReportController.shared.calculateTurnoverRate(for: nonPendingForms, outcome: .ran) + "%"
            self.ranNumber.text = "Ran (\(ranCount))"
            
            // RESCHEDULED
            let rescheduledCount = ReportController.shared.getNumber(of: .rescheduled, from: nonPendingForms)
            self.rescheduledRate.text = ReportController.shared.calculateTurnoverRate(for: nonPendingForms, outcome: .rescheduled) + "%"
            self.rescheduledNumber.text = "Rescheduled (\(rescheduledCount))"
            
            // RAN-INCOMPLETE
            let ranIncomplete = ReportController.shared.getNumber(of: .ranIncomplete, from: nonPendingForms)
            self.ranIncompleteRate.text = ReportController.shared.calculateTurnoverRate(for: nonPendingForms, outcome: .ranIncomplete) + "%"
            self.ranIncompleteNumber.text = "Ran/Incomplete (\(ranIncomplete))"
            
            // CANCELLED
            let cancelledCount = ReportController.shared.getNumber(of: .cancelled, from: nonPendingForms)
            self.cancelledRate.text = ReportController.shared.calculateTurnoverRate(for: nonPendingForms, outcome: .cancelled) + "%"
            self.cancelledNumber.text = "Cancelled (\(cancelledCount))"
        }
    }
    
    private func configureViewForState() {
        if UserAccount.currentUser == nil {
            // NOT SIGNED IN
            hide([profileView, reportsView])
            show([signInView])
            
        } else {
            // SIGNED IN
            show([profileView, reportsView])
            hide([signInView])
        }
        
        if UserAccount.currentUser?.accountType == .admin || UserAccount.currentUser?.accountType == .manager {
            show([filterButton])
        } else {
            hide([filterButton])
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

