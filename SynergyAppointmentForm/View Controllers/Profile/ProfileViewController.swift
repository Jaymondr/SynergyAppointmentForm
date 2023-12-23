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
    
    
    // MARK: - LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.tintColor = .eden
        logOutButton.isHidden = UserAccount.currentUser == nil
        signInButton.isHidden = UserAccount.currentUser != nil
        emailTextField.isHidden = UserAccount.currentUser != nil
        passwordTextField.isHidden = UserAccount.currentUser != nil
        nameStackView.isHidden = UserAccount.currentUser == nil
        nameLabel.text = UserAccount.currentUser?.firstName ?? ""
        
    }
    
    
    // MARK: - BUTTONS
    @IBAction func signInButtonPressed(_ sender: Any) {
        guard let email = emailTextField.text,
              let password = passwordTextField.text else { return }
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print("There was an error: \(error)")
                UIAlertController.presentOkAlert(message: "Error: \(error)", actionOptionTitle: "Ok")
            } else {
                print("User signed in")
                self.emailTextField.isHidden = true
                self.passwordTextField.isHidden = true
                self.logOutButton.isHidden = false
                self.nameStackView.isHidden = false
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
