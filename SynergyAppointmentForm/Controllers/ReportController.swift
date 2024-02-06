//
//  ReportController.swift
//  SynergyAppointmentForm
//
//  Created by Jaymond Richardson on 1/18/24.
//

import Foundation

class ReportController {
    
    static let shared = ReportController()
    
    func calculateTurnoverRate(for forms: [Form], outcome: Outcome) -> String {
        // FORMS THAT HAVE AN OUTCOME OTHER THAN PENDING
        let nonPendingForms = forms.filter({ $0.outcome != .pending })
        
        if nonPendingForms.count != 0 {
            var targets: Int = 0
            
            for form in nonPendingForms {
                if form.outcome == outcome {
                    targets += 1
                }
            }
            
            // Calculate turnover rate
            let turnoverRate: Double = Double(100 / Double(nonPendingForms.count)) * Double(targets)
            print("Forms count: \(nonPendingForms.count), targets: \(targets), turnover rate: \(turnoverRate)")
            // Ceil rounds up to the nearest number
            return String(Int(round(turnoverRate)))
            
        } else {
            return "--%"
        }
    }
    
    func getNumber(of outcome: Outcome, from forms: [Form]) -> String {
        
        let filteredForms = forms.filter { $0.outcome == outcome }
        
        return String(filteredForms.count)
    }
}
