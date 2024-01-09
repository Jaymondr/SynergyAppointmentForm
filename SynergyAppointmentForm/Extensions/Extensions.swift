//
//  Extensions.swift
//  SynergyAppointmentForm
//
//  Created by Jaymond Richardson on 11/21/23.
//

import UIKit
import AudioToolbox


// MARK: - BAR BUTTON
extension UIBarButtonItem {
    static func customBackButton(target: Any?, action: Selector) -> UIBarButtonItem {
         let chevronImage = UIImage(systemName: "chevron.left")
         let backButtonTitle = " FORMS"

         let button = UIButton(type: .system)
         button.setTitle(backButtonTitle, for: .normal)
         button.setImage(chevronImage, for: .normal)

         // Set the title label font to bold
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17)

         button.setTitleColor(UIColor.eden, for: .normal)
         button.sizeToFit()
         button.addTarget(target, action: action, for: .touchUpInside)

         let backButton = UIBarButtonItem(customView: button)
         backButton.tintColor = .eden

         return backButton
     }

}

// MARK: - NOTIFICATIONS
extension Notification.Name {
    static let signOutNotification = Notification.Name("SignOutNotification")
    static let signInNotification = Notification.Name("SignInNotification")
}

// MARK: - UIVIEW
extension UIView: VisibleToggleable {
    var isVisible: Bool {
        get {
            return !isHidden
        }
        set {
            isHidden = !newValue
        }
    }
}

// MARK: - UIVIEWCONTROLLER
extension UIViewController {
    func vibrateForSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }
    
    func vibrateForError() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.error)

    }
    
    func vibrateForButtonPress(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }

    
    func vibrate() {
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
}




// MARK: - STRING
extension String {
    var isNotEmpty: Bool {
        return !self.isEmpty
    }
}


// MARK: - CALAYER
extension CALayer {
    func applySketchShadow(color: UIColor, alpha: CGFloat, x: CGFloat, y: CGFloat, blur: CGFloat, spread: CGFloat) {
        shadowColor = color.cgColor
        shadowOpacity = Float(alpha)
        shadowOffset = CGSize(width: x, height: y)
        shadowRadius = blur / 2.0
        if spread == 0 {
            shadowPath = nil
        } else {
            let dx = -spread
            let rect = bounds.insetBy(dx: dx, dy: dx)
            shadowPath = UIBezierPath(rect: rect).cgPath
        }
    }
}


// MARK: - FORM
extension Form: Equatable {
    static func == (lhs: Form, rhs: Form) -> Bool {
        return lhs.firebaseID == rhs.firebaseID
    }
}


// MARK: - UIALERTCONTROLLER
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
    
    static func presentOkAlert(message: String, actionOptionTitle: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: actionOptionTitle, style: .cancel)
        
        alert.addAction(okAction)
        
        if let topWindowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }),
            let topViewController = topWindowScene.windows.first?.rootViewController {
            
            topViewController.present(alert, animated: true)
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
    
    func addActions(_ actions: [UIAlertAction]) {
        for action in actions {
            addAction(action)
        }
    }
}


// MARK: - STORYBOARD
public extension UIStoryboard {
    
    /**
     Creates and returns a storyboard object for the specified storyboard resource file in the main bundle of the current application.
     
     - parameter name: The name of the storyboard resource file without the filename extension.
     
     - returns: A storyboard object for the specified file. If no storyboard resource file matching name exists, an exception is thrown.
     */
    convenience init(name: String) {
        self.init(name: name, bundle: nil)
    }
}


// MARK: - DATE
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
        formatter.dateFormat = "M/d"
        return formatter.string(from: self)
    }
    
    func formattedMonth() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter.string(from: self)
    }
    
    func formattedDayNumber() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
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
