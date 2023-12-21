//
//  LoginChoiceViewController.swift
//  SynergyAppointmentForm
//
//  Created by Jaymond Richardson on 12/21/23.
//

import UIKit

class LoginChoiceViewController: UIViewController {
    // MARK: - OUTLETS
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    
    
    // MARK: - LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.hidesBackButton = true


    }
    
    
    // MARK: - BUTTONS
    @IBAction func loginButtonPressed(_ sender: Any) {
        guard let loginVC = storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController else { return }

        navigationController?.pushViewController(loginVC, animated: true)

    }
    
    @IBAction func signUpButtonPressed(_ sender: Any) {
        guard let signUpVC = storyboard?.instantiateViewController(withIdentifier: "SignUpViewController") as? SignUpViewController else { return }

        navigationController?.pushViewController(signUpVC, animated: true)
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
