//
//  SignUpViewController.swift
//  SynergyAppointmentForm
//
//  Created by Jaymond Richardson on 12/12/23.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

class SignUpViewController: UIViewController {
    
    // MARK: - OUTLETS
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    

    // MARK: - LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpView()
        
    }
    
    // MARK: - PROPERTIES
    var user: UserAccount?
    var approvedEmails: [String]?
    
    var isValid: Validity {
        guard let email = emailTextField.text,
              let password = passwordTextField.text,
              let firstName = firstNameTextField.text,
              let lastName = lastNameTextField.text
        else { return .invalid }
        
        let approvedEmails = approvedEmails ?? ["synergywindow", "gmail", "energyone"]
        let validEmailDomain = approvedEmails.contains { domain in
                return email.hasSuffix("@\(domain)")
            }
        let validFirstName = firstName != ""
        let validLastName = lastName != ""
        let validPassword = password.count > 5 && password.range(of: "[A-Z]", options: .regularExpression) != nil && password.range(of: "[a-z]", options: .regularExpression) != nil
        
        if validEmailDomain && validFirstName && validLastName && validPassword {
            return .valid
        } else if !validFirstName {
            return .invalidFirstName
        } else if !validLastName {
            return .invalidLastName
        } else if !validEmailDomain {
            return .invalidEmail
        } else if !validPassword {
            return .invalidPassword
        } else {
            return .invalid
        }
    }
    
    // MARK: - ACTIONS
    @IBAction func signUpButtonPressed(_ sender: Any) {
        createUser()
    }
    
    // MARK: - FUNCTIONS
    
    func setUpView() {
        signInButton.layer.cornerRadius = 8
        
        // Get Approved Emails
        FirebaseController.shared.getApprovedEmails { approvedEmails in
            self.approvedEmails = approvedEmails
        }
    }
        
    func createUser() {
        switch isValid {
        case .valid:
            // CREATE AUTHENTICATED USER.
            Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { authResult, error in
                if let error = error {
                    print("Authentication error: \(error.localizedDescription)")
                    UIAlertController.presentDismissingAlert(title: "Error: \(error)", dismissAfter: 2.0)
                    return
                }
                guard let authResult = authResult else { print("No auth result"); return }
                print("Auth uID: \(authResult.user.uid), Result: \(authResult.description)")
                
                // CREATE USER LOCALLY
                let user = UserAccount(firebaseID: authResult.user.uid, firstName: self.firstNameTextField.text!, lastName: self.lastNameTextField.text!, email: self.emailTextField.text!)
                
                // SAVE USER INFORMATION TO USER DEFAULTS
                let userDefaultsData = user.toUserDefaultsDictionary()
                UserDefaults.standard.set(userDefaultsData, forKey: UserAccount.kUser)
                
                // CREATE USER ACCOUNT IN FIREBASE USING UID FROM AUTHENTICATION FOR FIREBASE ID
                FirebaseController.shared.createUser(from: user) { user, error in
                    if let error = error {
                        UIAlertController.presentDismissingAlert(title: "Error Creating User", dismissAfter: 0.5)
                        print("Error creating user: \(error.localizedDescription)")
                        return
                    }
                self.navigationController?.popToRootViewController(animated: false)
                    return
                }
            }
            

        case .invalidPassword:
            UIAlertController.presentOkAlert(message: "Invalid Password. \nMust be at least 5 character with upper and lowercase letters", actionOptionTitle: "OK")
            
        case .invalidEmail:
            UIAlertController.presentDismissingAlert(title: "Invalid Email", dismissAfter: 0.5)

        case .invalidFirstName:
            UIAlertController.presentDismissingAlert(title: "Invalid First Name", dismissAfter: 0.5)

        case .invalidLastName:
            UIAlertController.presentDismissingAlert(title: "Invalid Last Name", dismissAfter: 0.5)

        case .invalid:
            UIAlertController.presentOkAlert(message: "Unable to create account. Contact support @jrichardson@synergywindow.com", actionOptionTitle: "OK")

        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    

}
enum StoryboardReference: String {
    case signUpScreen = "SignUpScreen"
}

enum Validity: CaseIterable {
    case valid
    case invalidPassword
    case invalidEmail
    case invalidFirstName
    case invalidLastName
    case invalid
}
