//
//  FormDetailViewController.swift
//  SynergyAppointmentForm
//
//  Created by Jaymond Richardson on 11/21/23.
//

import UIKit

class FormDetailViewController: UIViewController {
    
    // MARK: OUTLETS
    
    @IBOutlet weak var dateTimePicker: UIDatePicker!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var spouseTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var zipTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var stateTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var numberOfWindowsTextField: UITextField!
    @IBOutlet weak var energyBillTextField: UITextField!
    @IBOutlet weak var quoteTextField: UITextField!
    @IBOutlet weak var financeOptionsTextField: UITextField!
    @IBOutlet weak var yearsOwnedTextField: UITextField!
    @IBOutlet weak var reasonTextView: UITextView!
    @IBOutlet weak var rateTextField: UITextField!
    @IBOutlet weak var commentsTextView: UITextView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = UIColor.eden

        
    }
    
    // MARK: PROPERTIES
    var form: Form?
    
    // MARK: FUNCTIONS
    

}
