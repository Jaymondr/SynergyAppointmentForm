//
//  NotesView.swift
//  SynergyAppointmentForm
//
//  Created by Jaymond Richardson on 12/7/23.
//

import UIKit

// MARK: - TODO
/*
 Add save button
 Add form details to the note view ie. homeowner name, outcome.
 Add text to a scrollview
 Make it look pretty
 Add note button to the detail view controller
 
 */

class NotesView: UIView {
    
    // Constants for initial width and height
    private let initialWidth: CGFloat = 300.0
    private let initialHeight: CGFloat = 150.0

    var form: Form? {
        didSet {
            textView.text = form?.notes ?? "Empty"
        }
    }
    
    // UITextView to be added to the view
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.isScrollEnabled = true
        textView.isEditable = true
        textView.text = form?.notes ?? "Empty"
        textView.backgroundColor = UIColor.lightGray
        return textView
    }()

    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        let xMarkImage = UIImage(systemName: "xmark")
        button.setTitle("", for: .normal)
        button.setBackgroundImage(xMarkImage, for: .normal)
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // Initializer for the custom view
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    // Function to set up the view and its components
    private func setupView() {
        // VIEW
        // Set initial width and height
        let screenSize = UIScreen.main.bounds.size
        // Calculate the center coordinates
        let centerX = screenSize.width / 2
        let centerY = screenSize.height / 4
        // Set initial width and height
        let frame = CGRect(x: centerX - initialWidth / 2, y: centerY - initialHeight / 2, width: initialWidth, height: initialHeight + 200)
        self.frame = frame

        
        // TEXT VIEW
        addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: topAnchor, constant: 45),
            textView.leadingAnchor.constraint(equalTo: leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        // CLOSE BUTTON
        addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8)
        ])


        // VIEW PROPERTIES
        self.layer.cornerRadius = 8.0
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.eden.cgColor
        
        
        // TEXTVIEW PROPERTIES
        textView.backgroundColor = .clear
        textView.layer.cornerRadius = 8.0
        
        
        // LIGHT / DARK MODE
        if traitCollection.userInterfaceStyle == .dark {
            self.backgroundColor = UIColor.darkGray
            textView.textColor = UIColor.white
            closeButton.tintColor = UIColor.white
            
        } else {
            self.backgroundColor = UIColor.white
            textView.textColor = UIColor.black
            closeButton.tintColor = UIColor.black

        }
    }

    // Function to update the width and height of the view
    func updateSize(width: CGFloat, height: CGFloat) {
        var newFrame = self.frame
        newFrame.size.width = width
        newFrame.size.height = height
        self.frame = newFrame
    }
    
    // Function to handle the close button tap action
    @objc private func closeButtonTapped() {
        removeFromSuperview()
    }

}
