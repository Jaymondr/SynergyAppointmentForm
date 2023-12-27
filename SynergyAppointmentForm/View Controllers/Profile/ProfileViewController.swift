//
//  ProfileViewController.swift
//  SynergyAppointmentForm
//
//  Created by Jaymond Richardson on 12/23/23.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController {
    
    // MARK: - OUTLETS
    @IBOutlet weak var nameStackView: UIStackView!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var salesLabel: UILabel!
    
    
    // MARK: - LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.tintColor = .eden
        logOutButton.isHidden = UserAccount.currentUser == nil
        signInButton.isHidden = UserAccount.currentUser != nil
        emailTextField.isHidden = UserAccount.currentUser != nil
        passwordTextField.isHidden = UserAccount.currentUser != nil
        nameStackView.isHidden = UserAccount.currentUser == nil
        setupView()
        
    }
    
    var forms: [Form] = []
    
    // MARK: - BUTTONS
    @IBAction func signInButtonPressed(_ sender: Any) {
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
                        // SAVE USER INFORMATION TO USER DEFAULTS
                        let userDefaultsData = user.toUserDefaultsDictionary()
                        UserDefaults.standard.set(userDefaultsData, forKey: UserAccount.kUser)
                    
                    UIAlertController.presentDismissingAlert(title: "\(user.firstName) signed in.", dismissAfter: 1.2)
                    self.emailTextField.isHidden = true
                    self.passwordTextField.isHidden = true
                    self.logOutButton.isHidden = false
                    self.nameStackView.isHidden = false
                    self.nameLabel.text = user.firstName
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
                self.logOutButton.isHidden = true
                self.emailTextField.isHidden = false
                self.passwordTextField.isHidden = false
                self.signInButton.isHidden = false
                self.nameStackView.isHidden = true
                print("Signed out user")
                
            } catch let signOutError as NSError {
                UIAlertController.presentDismissingAlert(title: signOutError.localizedDescription, dismissAfter: 2.0)
            }
        }
    }
    
    // MARK: - FUNCTIONS
    func setupView() {
        var sales = forms.filter( { $0.outcome == .sold } )
        salesLabel.text = "Sales: \(sales.count)"
        
        var firstName = UserAccount.currentUser?.firstName ?? ""
        var lastName = UserAccount.currentUser?.lastName ?? ""
        if let lastNameFirstLetter = lastName.first {
            nameLabel.text = "\(firstName) \(lastNameFirstLetter)"
        } else {
            nameLabel.text = firstName + lastName
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
