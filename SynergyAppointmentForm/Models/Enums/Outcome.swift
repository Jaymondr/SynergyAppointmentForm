//
//  Outcome.swift
//  SynergyAppointmentForm
//
//  Created by Jaymond Richardson on 11/27/23.
//

import Foundation

enum Outcome: String, CaseIterable {
    case pending = "pending"
    case sold = "sold"
    case ran = "ran"
    case rescheduled = "rescheduled"
    case ranIncomplete = "ran-incomplete"
    case cancelled = "cancelled"
    
    static func fromString(_ stringValue: String) -> Outcome {
        switch stringValue {
        case "pending":
            return .pending
            
        case "cancelled":
            return .cancelled
            
        case "rescheduled":
            return .rescheduled
            
        case "ran":
            return .ran
            
        case "ran-incomplete":
            return .ranIncomplete
            
        case "sold":
            return .sold
            
        default:
            return .pending
        }
    }
}
