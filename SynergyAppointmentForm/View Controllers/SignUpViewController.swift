//
//  SignUpViewController.swift
//  SynergyAppointmentForm
//
//  Created by Jaymond Richardson on 12/12/23.
//

import UIKit

class SignUpViewController: UIViewController {
    
    // MARK: - OUTLETS
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    

    // MARK: - LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpView()
        
    }
    
    // MARK: - PROPERTIES
    var user: User?
    
    // MARK: - ACTIONS
    @IBAction func createButtonPressed(_ sender: Any) {
        createUser()
    }
    
    // MARK: - FUNCTIONS
    
    func setUpView() {
        createButton.layer.cornerRadius = 10
    }
    
    func createUser() {
        guard let firstName = firstNameTextField.text,
              let lastName = lastNameTextField.text,
              let email = emailTextField.text else {
            UIAlertController.presentDismissingAlert(title: "Please Enter All Information", dismissAfter: 0.7)
            return
        }
        FirebaseController.shared.createUser(firstName: firstName, lastName: lastName, email: email) { user, error in
            if let error = error {
                UIAlertController.presentDismissingAlert(title: "Error Creating User", dismissAfter: 0.5)
                print("Error creating user: \(error)")
                return
            }
            
            guard let user = user else { print("No User!"); return }
            self.user = user
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
