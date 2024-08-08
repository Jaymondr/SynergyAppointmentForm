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
    
    func roundCorners(radius: CGFloat, corners: UIRectCorner) {
        let path = UIBezierPath(roundedRect: self.bounds,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    
    // MARK: - CONFETTI
    func generateConfettiImage(color: UIColor, shape: String) -> CGImage? {
        let size = CGSize(width: 10, height: 10)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }

        context.setFillColor(color.cgColor)

        let path: UIBezierPath
        switch shape {
        case "circle":
            path = UIBezierPath(ovalIn: CGRect(origin: .zero, size: size))
        case "square":
            path = UIBezierPath(rect: CGRect(origin: .zero, size: size))
        case "triangle":
            path = UIBezierPath()
            path.move(to: CGPoint(x: size.width / 2, y: 0))
            path.addLine(to: CGPoint(x: size.width, y: size.height))
            path.addLine(to: CGPoint(x: 0, y: size.height))
            path.close()
        default:
            path = UIBezierPath(rect: CGRect(origin: .zero, size: size)) // Default to square
        }

        path.fill()
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image?.cgImage
    }
    
    private struct AssociatedKeys {
        static var emitterLayer = "emitterLayer"
    }
    
    private var emitterLayer: CAEmitterLayer? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.emitterLayer) as? CAEmitterLayer
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.emitterLayer, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func startConfetti() {
        let emitterLayer = CAEmitterLayer()
        emitterLayer.emitterPosition = CGPoint(x: self.bounds.width / 2.0, y: -200)
        emitterLayer.emitterShape = .line
        emitterLayer.emitterSize = CGSize(width: self.bounds.size.width / 2, height: 1)
        emitterLayer.beginTime = CACurrentMediaTime()
        emitterLayer.timeOffset = CFTimeInterval(arc4random_uniform(6) + 5)
        
        let colors: [UIColor] = [.outcomeRed, .outcomeGreen, .outcomeBlue, .outcomeYellow, .outcomePurple, .outcomeGreen]
        let shapes = ["circle", "square", "triangle"]
        var cells: [CAEmitterCell] = []
        
        for color in colors {
            for shape in shapes {
                let cell = CAEmitterCell()
                cell.contents = generateConfettiImage(color: color, shape: shape)
                cell.birthRate = 8
                cell.lifetime = 7.0 // How long they are alive
                cell.velocity = CGFloat(arc4random_uniform(300) + 300) // Speed
                cell.velocityRange = 70
                cell.yAcceleration = 150 // Gravity effect
                cell.emissionLongitude = .pi
                cell.emissionRange = .pi / 4
                cell.spin = 3.5
                cell.spinRange = 1.0
                cell.scale = 0.2
                cell.scaleRange = 0.08
                cells.append(cell)
            }
        }
        
        emitterLayer.emitterCells = cells
        self.emitterLayer = emitterLayer
        self.layer.addSublayer(emitterLayer)
        
        // Stop confetti after 3.5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.stopConfetti()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            self.isHidden = true
        }
    }
    
    func stopConfetti() {
        guard let emitterLayer = self.emitterLayer else { return }
        emitterLayer.birthRate = 0
    }
}


// MARK: - SCROLLVIEW
extension UIScrollView {
    func scrollDownBy(points: CGFloat, animated: Bool = true) {
        var offset = self.contentOffset
        let maxOffsetY = self.contentSize.height - self.bounds.height
        
        offset.y = min(offset.y + points, maxOffsetY)
        self.setContentOffset(offset, animated: animated)
    }
    
    func scrollTo(yPosition: CGFloat, animated: Bool = true) {
        var offset = self.contentOffset
        let maxOffsetY = self.contentSize.height - self.bounds.height
        
        offset.y = min(max(yPosition, 0), maxOffsetY)
        self.setContentOffset(offset, animated: animated)
    }
}


// MARK: - TEXTFIELD
extension UITextField {
    func addBottomBorder(with color: UIColor, andHeight height: CGFloat) {
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0, y: self.frame.height - height, width: self.frame.width, height: height)
        bottomLine.backgroundColor = color.cgColor
        self.borderStyle = .none
        self.layer.addSublayer(bottomLine)
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


// MARK: - Array
extension Array {
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
    func addingDays(_ days: Int) -> Date? {
        return Calendar.current.date(byAdding: .day, value: days, to: self)
    }
    
    func formattedStringDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE MM/dd ha yyyy"
        return formatter.string(from: self)
    }
    
    func formattedDay() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: self)
    }
    
    func formattedDayAbbr() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EE"
        return formatter.string(from: self)
    }
    
    func formattedDayMonthShort() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return formatter.string(from: self)
    }
    
    func formattedDayMonth() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d"
        let dayString = formatter.string(from: self)
        
        let calendar = Calendar.current
        let day = calendar.component(.day, from: self)
        
        let daySuffix: String
        switch day {
        case 11, 12, 13:
            daySuffix = "th"
        default:
            switch day % 10 {
            case 1:
                daySuffix = "st"
            case 2:
                daySuffix = "nd"
            case 3:
                daySuffix = "rd"
            default:
                daySuffix = "th"
            }
        }
        
        return "\(dayString)\(daySuffix)"
    }
    
    func formattedDayMonthAbbr() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        let dayString = formatter.string(from: self)
        
        let calendar = Calendar.current
        let day = calendar.component(.day, from: self)
        
        let daySuffix: String
        switch day {
        case 11, 12, 13:
            daySuffix = "th"
        default:
            switch day % 10 {
            case 1:
                daySuffix = "st"
            case 2:
                daySuffix = "nd"
            case 3:
                daySuffix = "rd"
            default:
                daySuffix = "th"
            }
        }
        
        return "\(dayString)\(daySuffix)"
    }
    
    func formattedDayDateMonth() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd M/d"
        return formatter.string(from: self)
    }
    
    func formattedDayMonthYear() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d/yy"
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
