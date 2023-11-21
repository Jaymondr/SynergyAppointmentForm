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
}
