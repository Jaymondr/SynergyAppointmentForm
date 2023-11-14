//
//  FormViewController.swift
//  SynergyAppointmentForm
//
//  Created by Jaymond Richardson on 11/14/23.
//

import UIKit

class FormViewController: UIViewController {
    // MARK: OUTLETS
    @IBOutlet weak var nameTextfield: UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    var name: String?
    
    
    // MARK: BUTTONS
    @IBAction func copyButtonPressed(_ sender: Any) {
        if let name = nameTextfield.text {
            FormController.shared.createAndCopyForm(name: name)
        }
    }
}
