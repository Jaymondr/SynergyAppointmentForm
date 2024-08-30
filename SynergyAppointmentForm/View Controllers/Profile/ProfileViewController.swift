//
//  ProfileViewController.swift
//  SynergyAppointmentForm
//
//  Created by Jaymond Richardson on 12/23/23.
//

// MARK: - TODO
/*
 1. Need to load team when logged in
 
 
 */

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
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        getReports(for: nil)
        setupView()
    }
    
    // MARK: - PROPERTIES
    var forms: [Form] = []
    var user = UserAccount.currentUser
    
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
        
        // TEAM
        let teamAction = UIAlertAction(title: "Choose Team", style: .default) { _ in
            self.showTeamSelectionAlert()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addActions([branchAction, teamAction, feedbackAction, deleteAccountAction, cancelAction])
        self.present(alert, animated: true)
        
    }
    
//    @IBAction func signInButtonPressed(_ sender: Any) {
//        guard let email = emailTextField.text,
//              let password = passwordTextField.text else { return }
//        passwordTextField.resignFirstResponder()
//        Auth.auth().signIn(withEmail: email, password: password) { result, error in
//            if let error = error {
//                print("There was an error: \(error)")
//                UIAlertController.presentOkAlert(message: "Error: \(error)", actionOptionTitle: "Ok")
//            }
//            if let result = result {
//                // Fetch user
//                print("UID: \(result.user.uid)")
//                FirebaseController.shared.getUser(with: result.user.uid) { user, error in
//                    if let error = error {
//                        print("Error getting user info from firebas: \(error). Error ")
//                        return
//                    }
//                    
//                    guard  let user = user else { print("No User"); return }
//                    // Might not run if view controller gets dismissed first
//                    if let teamID = user.teamID {
//                        FirebaseController.shared.getTeamName(teamID: teamID) { teamName, error in
//                            if let error = error {
//                                print("Error getting team name: \(error)")
//                            }
//                            if let teamName = teamName {
//                                UserAccountController.shared.updateTeamNameInUserDefaults(to: teamName)
//                            }
//                        }
//                    }
//
//                    // SAVE USER INFORMATION TO USER DEFAULTS
//                    let userDefaultsData = user.toUserDefaultsDictionary()
//                    UserDefaults.standard.set(userDefaultsData, forKey: UserAccount.kUser)
//                    
//                    UIAlertController.presentDismissingAlert(title: "\(user.firstName) signed in.", dismissAfter: 1.2)
//                    self.configureViewForState()
//                    self.setupView()
//                    NotificationCenter.default.post(name: .signInNotification, object: nil)
//                }
//            }
//        }
//    }
    
    @IBAction func logOutButtonPressed(_ sender: Any) {
        logOutButton.isHidden = UserAccount.currentUser == nil
        UIAlertController.presentMultipleOptionAlert(message: "Log out?", actionOptionTitle: "Continue", cancelOptionTitle: "Cancel") {
            do  {
                try Auth.auth().signOut()
                UserDefaults.standard.removeObject(forKey: UserAccount.kUser)
                UserAccount.currentUser = nil
                print("Signed out user")
                NotificationCenter.default.post(name: .signOutNotification, object: nil)
                self.presentLoginChoiceVC()
                
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
        navigationController?.navigationBar.tintColor = .steel
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
        reportsView.layer.borderColor = UIColor.steel.cgColor
        
        // PROFILE CARD
        profileView.layer.borderWidth = 1.5
        profileView.layer.borderColor = UIColor.steel.cgColor
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
                
    }
    
    func getReports(for userID: String?) {
        guard let user = UserAccount.currentUser else { return }
        let userID = userID ?? user.firebaseID
        FirebaseController.shared.getForms(for: userID) { forms, error in
            if let error = error {
                print("Error: \(error)")
            }
            
            // Get reports for non pending and non lead forms only
            let nonPendingForms = forms.filter({ $0.outcome != .pending && $0.outcome != .lead })
            
            // ALL
            self.appointmentsLabel.text = "Appointments (\(forms.count))"
            
            // PENDING
            let pendingCount = ReportController.shared.getNumber(of: .pending, from: forms)
            self.pendingNumber.text = "Pending (\(pendingCount))"
            
            // SOLD
            let soldCount = ReportController.shared.getNumber(of: .sold, from: nonPendingForms)
            self.salesRate.text = ReportController.shared.calculateTurnoverRate(for: nonPendingForms, outcome: .sold) + "%"
            self.soldNumber.text = "Sold (\(soldCount))"
            self.salesLabel.text = "Sales: \(soldCount)"
            
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
        if UserAccount.currentUser?.accountType == .admin || UserAccount.currentUser?.accountType == .manager {
            show([filterButton])
        } else {
            hide([filterButton])
        }
    }
    
    func presentLoginChoiceVC() {
        let storyboard = UIStoryboard(name: "SignUpScreen", bundle: nil)
        
        guard let loginChoiceVC = storyboard.instantiateViewController(withIdentifier: "LoginChoiceViewController") as? LoginChoiceViewController else { return }
        navigationController?.pushViewController(loginChoiceVC, animated: false)
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
    
    func showTeamSelectionAlert() {
        guard let user = UserAccount.currentUser else { return }

        if user.branch == nil {
            UIAlertController.presentDismissingAlert(title: "Must Choose Branch First", dismissAfter: 2)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                return
            }
        }
        var teamName: String {
            // Retrieve the dictionary from UserDefaults
            if let userDefaultsDict = UserDefaults.standard.dictionary(forKey: UserAccount.kUser) {
                // Extract the teamName from the dictionary
                if let teamName = userDefaultsDict[UserAccount.CodingKeys.teamName.rawValue] as? String {
                    // Assign the teamName to a variable
                    print("Retrieved team name: \(teamName)")
                     return "Current: \(teamName)"
                } else {
                    print("teamName key not found or is not a String.")
                    return "No team"
                }
            } else {
                print("Dictionary for key \(UserAccountController.kTeamName) not found.")
                return "No team"
            }
        }
        
        let alert = UIAlertController(title: "Select Team", message: teamName, preferredStyle: .actionSheet)
        FirebaseController.shared.getTeamsForBranch(branch: user.branch) { teams, error in
            if let error = error {
                print("Error getting teams for branch")
            }
            for team in teams {
                if let team {
                    if team.teamID != user.teamID {
                        let teamAction = UIAlertAction(title: "\(team.name)", style: .default) { _ in
                            TeamController.shared.handleTeamSelection(userID: user.firebaseID, newTeamID: team.teamID, oldTeamID: user.teamID, teamName: team.name) { success, error in
                                if success {
                                    // Show success alert
                                    UIAlertController.presentDismissingAlert(title: "Success! Added to team \(team.name)", dismissAfter: 2.0)
                                } else if let error = error {
                                    // Show error alert with the specific error
                                    UIAlertController.presentDismissingAlert(title: "Error adding you to team \(team.name)", dismissAfter: 2.0)
                                }
                            }
                        }
                        alert.addAction(teamAction)
                    }
                }
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            
            alert.addAction(cancelAction)
            self.present(alert, animated: true)
        }
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

