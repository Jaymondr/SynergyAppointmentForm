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
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            self.navigationController?.popToRootViewController(animated: false)
        }

//        guard let email = emailTextField.text,
//              let password = passwordTextField.text else { return }
//        Auth.auth().signIn(withEmail: email, password: password) { result, error in
//            if let error = error {
//                print("There was an error: \(error)")
//                UIAlertController.presentDismissingAlert(title: "Error: \(error)", dismissAfter: 1.0)
//            }
//            if let result = result {
//                UIAlertController.presentDismissingAlert(title: "\("Welcome back \(result.user.displayName ?? "Welcome back")")", dismissAfter: 1.2)
//                DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
//                    self.navigationController?.popToRootViewController(animated: false)
//                }
//            }
//        }
    }
    
    // MARK: - FUNCTIONS
    func setupView() {
        loginButton.layer.cornerRadius = 8
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
