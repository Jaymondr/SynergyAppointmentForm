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
    case sold = "sold"
    
    static func fromString(_ stringValue: String) -> Outcome {
            switch stringValue {
            case "pending":
                return .pending
                
            case "cancelled":
                return .cancelled
                
            case "rescheduled":
                return .rescheduled
                
            case "sold":
                return .sold
                
            default:
                return .pending
            }
        }
}
