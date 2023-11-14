//
//  FormController.swift
//  SynergyAppointmentForm
//
//  Created by Jaymond Richardson on 11/14/23.
//

import UIKit

class FormController {
    
//    var form: Form?
    static let shared = FormController()
    
    func createAndCopyForm(name: String) {
        guard !name.isEmpty else {return}
        UIPasteboard.general.string = "First name \(name)"
    }
}
