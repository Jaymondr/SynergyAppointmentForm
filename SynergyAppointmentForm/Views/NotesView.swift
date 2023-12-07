//
//  NotesView.swift
//  SynergyAppointmentForm
//
//  Created by Jaymond Richardson on 12/7/23.
//

import UIKit


class NotesView: UIView {
    
    // Constants for initial width and height
    private let initialWidth: CGFloat = 200.0
    private let initialHeight: CGFloat = 150.0

    // UITextView to be added to the view
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.isScrollEnabled = true
        textView.isEditable = true
        textView.text = "Your initial text goes here."
        textView.backgroundColor = UIColor.lightGray
        return textView
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
        // Set initial width and height
        self.frame = CGRect(x: 0, y: 0, width: initialWidth, height: initialHeight)

        // Add UITextView to the view
        addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: topAnchor),
            textView.leadingAnchor.constraint(equalTo: leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        // You can customize other properties of the view as needed
        self.backgroundColor = UIColor.white
        self.layer.cornerRadius = 10.0
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.black.cgColor
    }

    // Function to update the width and height of the view
    func updateSize(width: CGFloat, height: CGFloat) {
        var newFrame = self.frame
        newFrame.size.width = width
        newFrame.size.height = height
        self.frame = newFrame
    }
}
