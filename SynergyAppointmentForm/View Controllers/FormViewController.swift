//
//  FormViewController.swift
//  SynergyAppointmentForm
//
//  Created by Jaymond Richardson on 11/14/23.
//

import UIKit

class FormViewController: UIViewController {
    // MARK: OUTLETS
    @IBOutlet weak var appointmentDayTextfield: UITextField!
    @IBOutlet weak var dateTimeTextfield: UITextField!
    @IBOutlet weak var firstNameTextfield: UITextField!
    @IBOutlet weak var lastNameTextfield: UITextField!
    @IBOutlet weak var spouseTextfield: UITextField!
    @IBOutlet weak var addressTextfield: UITextField!
    @IBOutlet weak var zipTextfield: UITextField!
    @IBOutlet weak var cityTextfield: UITextField!
    @IBOutlet weak var stateTextfield: UITextField!
    @IBOutlet weak var phoneTextfield: UITextField!
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var numberOfWindowsTexfield: UITextField!
    @IBOutlet weak var energyBillTextfield: UITextField!
    @IBOutlet weak var quoteTextfield: UITextField!
    @IBOutlet weak var financeTextfield: UITextField!
    @IBOutlet weak var yearsOwnedTextfield: UITextField!
    @IBOutlet weak var reasonTextview: UITextView!
    @IBOutlet weak var rateTextfield: UITextField!
    @IBOutlet weak var commentsTextview: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: BUTTONS
    @IBAction func copyButtonPressed(_ sender: Any) {
        let form = createForm()
        FormController.shared.createAndCopyForm(form: form)
        let alert = UIAlertController(title: "Copied!", message: nil, preferredStyle: .alert)
        self.present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            alert.dismiss(animated: true)
        }
    }
    
    // MARK: FUNCTIONS
    func createForm() -> Form {
        // Separate date time
        var time: String
        var date: String
        let dateTimeText = dateTimeTextfield.text ?? ""
        let dateTimeArray = dateTimeText.split(separator: " ")
        if dateTimeArray.count >= 2 {
            time = String(dateTimeArray[1])
            date = String(dateTimeArray[0])
            } else {
                time = ""
                date = ""
            }
        let form = Form(day: appointmentDayTextfield.text ?? "", time: time, date: date, firstName: firstNameTextfield.text ?? "", lastName: lastNameTextfield.text ?? "", spouse: spouseTextfield.text ?? "", address: addressTextfield.text ?? "", zip: zipTextfield.text ?? "", city: cityTextfield.text ?? "", state: stateTextfield.text ?? "", phone: phoneTextfield.text ?? "", email: emailTextfield.text ?? "", numberOfWindows: numberOfWindowsTexfield.text ?? "", energyBill: energyBillTextfield.text ?? "", retailQuote: quoteTextfield.text ?? "", financeOptions: financeTextfield.text ?? "", yearsOwned: yearsOwnedTextfield.text ?? "", reason: reasonTextview.text ?? "", rate: rateTextfield.text ?? "", comments: commentsTextview.text ?? "")
        
        return form
    }
}
