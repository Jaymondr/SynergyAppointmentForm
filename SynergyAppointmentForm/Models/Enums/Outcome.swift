//
//  Outcome.swift
//  SynergyAppointmentForm
//
//  Created by Jaymond Richardson on 11/27/23.
//

import Foundation

enum Outcome: String {
    case pending = "pending"
    case cancelled = "cancelled"
    case rescheduled = "rescheduled"
    case ran = "ran"
    case ranIncomplete = "ran-incomplete"
    case sold = "sold"
    
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
