//
//  Extensions.swift
//  SynergyAppointmentForm
//
//  Created by Jaymond Richardson on 11/21/23.
//

import UIKit
// UIALERT

extension UIAlertController {
    static func presentDismissingAlert(title: String, dismissAfter: Double) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        if let topWindowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }),
            let topViewController = topWindowScene.windows.first?.rootViewController {
            
            topViewController.present(alert, animated: true)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + dismissAfter) {
            alert.dismiss(animated: true)
        }
    }
    static func presentMultipleOptionAlert(message: String, actionOptionTitle: String, cancelOptionTitle: String, completion: @escaping () -> Void) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: actionOptionTitle, style: .default) { action in
            completion()
        }
        let cancelAction = UIAlertAction(title: cancelOptionTitle, style: .cancel)
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        if let topWindowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }),
            let topViewController = topWindowScene.windows.first?.rootViewController {
            
            topViewController.present(alert, animated: true)
        }
    }

}

extension Date {
    func formattedStringDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE MM/dd h a yyyy"
        return formatter.string(from: self)
    }
    
    func formattedDay() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: self)
    }
    
    func formattedDayMonth() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter.string(from: self)
    }
    
    func formattedTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h"
        return formatter.string(from: self)
    }
    
    func formattedAmpm() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "a"
        return formatter.string(from: self)
    }

}

extension DateFormatter {
    static func dateFromFormattedString(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE MM/dd h a yyyy"
        return formatter.date(from: dateString)
    }
}
