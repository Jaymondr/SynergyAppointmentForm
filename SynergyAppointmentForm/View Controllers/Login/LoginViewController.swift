//
//  LoginViewController.swift
//  SynergyAppointmentForm
//
//  Created by Jaymond Richardson on 12/21/23.
//

import UIKit

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
    print("Login button pressed")
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
