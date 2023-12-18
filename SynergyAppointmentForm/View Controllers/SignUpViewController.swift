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
    @IBOutlet weak var createButton: UIButton!
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
    
    var isValid: Validity {
        guard let email = emailTextField.text,
              let password = passwordTextField.text,
              let firstName = firstNameTextField.text,
              let lastName = lastNameTextField.text
        else { return .invalid }
        
        let validEmail = email.contains("@synergywindow")
        let validFirstName = firstName != ""
        let validLastName = lastName != ""
        let validPassword = password.count > 5 && password.range(of: "[A-Z]", options: .regularExpression) != nil && password.range(of: "[a-z]", options: .regularExpression) != nil
        
        if validEmail && validFirstName && validLastName && validPassword {
            return .valid
        } else if !validFirstName {
            return .invalidFirstName
        } else if !validLastName {
            return .invalidLastName
        } else if !validEmail {
            return .invalidEmail
        } else if !validPassword {
            return .invalidPassword
        } else {
            return .invalid
        }
    }
    
    // MARK: - ACTIONS
    @IBAction func createButtonPressed(_ sender: Any) {
        showMainStoryboard()
//        createUser()
    }
    
    // MARK: - FUNCTIONS
    
    func setUpView() {
        createButton.layer.cornerRadius = 10
    }
    
    private func showMainStoryboard() {
        print("User firebase ID: \(user?.firebaseID ?? "nil")")
        // Assuming you're inside the SignUpViewController
        // Dismiss the SignUpViewController
        self.dismiss(animated: true) {
            // Instantiate the FormListViewController
            let formListViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FormListViewController") as! FormListViewController

            // Present the navigation controller
            // Assuming your current view controller is embedded in a navigation controller
            self.navigationController?.pushViewController(formListViewController, animated: true)

        }
    }
    
    func createUser() {
        switch isValid {
        case .valid:
            // CREATE AUTHENTICATED USER.
            Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { authResult, error in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
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
                    
                    guard let user = user else { print("No User!"); return }
                    self.user = user
                    self.showMainStoryboard()
                }
            }
            

        case .invalidPassword:
            UIAlertController.presentDismissingAlert(title: "Invalid Password", dismissAfter: 0.5)
            
        case .invalidEmail:
            UIAlertController.presentDismissingAlert(title: "Invalid Email", dismissAfter: 0.5)

        case .invalidFirstName:
            UIAlertController.presentDismissingAlert(title: "Invalid First Name", dismissAfter: 0.5)

        case .invalidLastName:
            UIAlertController.presentDismissingAlert(title: "Invalid Last Name", dismissAfter: 0.5)

        case .invalid:
            UIAlertController.presentDismissingAlert(title: "Unable to create account. Contact support @jrichardson@synergywindow.com", dismissAfter: 0.5)

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
