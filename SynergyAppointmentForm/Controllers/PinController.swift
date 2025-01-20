//
//  PinController.swift
//  SynergyAppointmentForm
//
//  Created by Jaymond Richardson on 1/20/25.
//

import CoreLocation

class PinController {
    
    
    // MARK: - SHARED INSTANCE
    static let shared = PinController()
    
    // MARK: - CRUD FUNCTIONS
    func createPin(location: CLLocation) {
        var pin = Pin(firebaseID: "", location: location)
        
        FirebaseController.shared.createPin(pin: pin) { pin, error in
            if let error = error {
                print("Error creating pin: \(error)")
            }
            
            if let pin = pin {
                
            }
        }
        
        
    }
}

