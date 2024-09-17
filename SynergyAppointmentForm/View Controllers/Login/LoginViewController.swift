//
//  LoginViewController.swift
//  SynergyAppointmentForm
//
//  Created by Jaymond Richardson on 12/21/23.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    // MARK: - OUTLETS
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    
    // MARK: - LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    // MARK: - BUTTONS
    @IBAction func loginButtonPressed(_ sender: Any) {
        guard let email = emailTextField.text,
              let password = passwordTextField.text else { return }
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
                    
                    // Might not run if view controller gets dismissed first
                    if let teamID = user.teamID {
                        FirebaseController.shared.getTeamName(teamID: teamID) { teamName, error in
                            if let error = error {
                                print("Error getting team name: \(error)")
                            }
                            if let teamName = teamName {
                                UserAccountController.shared.updateTeamNameInUserDefaults(to: teamName)
                            }
                        }
                    }
                        // SAVE USER INFORMATION TO USER DEFAULTS
                        let userDefaultsData = user.toUserDefaultsDictionary()
                        UserDefaults.standard.set(userDefaultsData, forKey: UserAccount.kUser)
                    
                    UIAlertController.presentDismissingAlert(title: "Welcome back \(user.firstName)!", dismissAfter: 1.2)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                        NotificationCenter.default.post(name: .signInNotification, object: nil)
                        self.navigationController?.popToRootViewController(animated: false)
                    }
                }
            }
        }
    }
    
    // MARK: - FUNCTIONS
    func setupView() {
        loginButton.layer.cornerRadius = 8
    }
}
