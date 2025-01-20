//
//  VisitResult.swift
//  SynergyAppointmentForm
//
//  Created by Jaymond Richardson on 1/8/25.
//

enum VisitResult: String, CaseIterable {
    case notHome = "Not Home"
    case notHomeLeftDoorHanger = "Not Home - Left Door Hanger"
    case sold = "Sold"
    case talkTo = "Talk To"
    case setAppointment = "Set Appointment"
    case diyAppointment = "DIY Appointment"
    case notInterested = "Not Interested"
    case contactedGoBack = "Contacted - Go Back"
    case followUp = "Follow-Up"
    case doNotKnock = "Do Not Knock"
    case noSoliciting = "No Soliciting"
    case renter = "Renter"
    case demoNotSold = "Demo - Not Sold"
    case notRun = "Not Run"
    case diyEstimateGiven = "DIY Estimate Given"
    case rehashAppointment = "Rehash Appointment"
    
    var description: String {
        return self.rawValue
    }
}
