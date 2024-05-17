//
//  NotesViewController.swift
//  SynergyAppointmentForm
//
//  Created by Jaymond Richardson on 1/9/24.
//

import UIKit

protocol NotesViewDelegate: AnyObject {
    func didUpdateForm(with form: Form)
}

class NotesViewController: UIViewController {
    // MARK: - OUTLETS
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var cityStateLabel: UILabel!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var tagButton: UIButton!
    @IBOutlet weak var messageButton: UIButton!
    
    
    
    // MARK: - LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        // UNCOMMENT LATER
        messageButton.isHidden = true
        tagButton.isHidden = true
        self.navigationController?.navigationBar.isHidden = true
    }
    
    // MARK: - PROPERTIES
    var form: Form?
    weak var delegate: NotesViewDelegate?
    
    
    // MARK: BUTTONS
    @IBAction func saveButtonPressed(_ sender: Any) {
        saveForm()
    }
    
    
    // MARK: - FUNCTIONS
    func setupView() {
        guard let form = form else { return }
        // SETUP DATA
        setFormData(with: form)
        
        // SETUP VIEW
        backgroundView.layer.cornerRadius = 8
        backgroundView.layer.borderWidth = 2.0
        
        if traitCollection.userInterfaceStyle == .dark {
            firstNameLabel.textColor = .lightText
            timeLabel.textColor = .lightText
            dateLabel.textColor = .lightText
            dayLabel.textColor = .lightText
        } else {
            firstNameLabel.textColor = .black
            timeLabel.textColor = .black
            dateLabel.textColor = .black
            dayLabel.textColor = .black
        }
    }
    
    func setFormData(with form: Form) {
        dayLabel.text = form.date.formattedDay()
        dateLabel.text = form.date.formattedDayMonth()
        timeLabel.text = "\(form.date.formattedTime())\(form.date.formattedAmpm())"
        cityStateLabel.text = "\(form.city.uppercased())(\(form.state))"
        if form.spouse.isEmpty {
            firstNameLabel.text = form.firstName.uppercased() + " " + form.lastName.uppercased()
        } else {
            firstNameLabel.text = form.firstName.uppercased() + " & " + form.spouse.uppercased()
        }
        notesTextView.text = form.notes
        notesTextView.textColor = .black
        // Set background view for outcome
        setOutcomeView(form: form)
    }
    
    private func saveForm() {
        guard let form = form else { return }

        let notes = notesTextView.text ?? ""
        form.notes = notes
        FirebaseController.shared.updateForm(firebaseID: form.firebaseID, form: form) { updatedForm, error in
            if let error = error {
                print("Error: \(error)")
            }
            if let updatedForm = updatedForm {
                self.delegate?.didUpdateForm(with: updatedForm)
                self.vibrateForButtonPress(.heavy)
                self.titleLabel.text = "SAVED!"
                self.titleLabel.textColor = UIColor.outcomeGreen
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    self.titleLabel.text = "Notes"
                    self.titleLabel.textColor = .black

                }
            }
        }
    }
    
    private func setOutcomeView(form: Form) {
        let alpha: Double = 0.4
        switch form.outcome {
        case .pending:
            backgroundView.layer.borderColor = UIColor.eden.cgColor
            backgroundView.backgroundColor = UIColor.eden.withAlphaComponent(alpha)
        case .cancelled:
            backgroundView.layer.borderColor = UIColor.outcomeRed.cgColor
            backgroundView.backgroundColor = UIColor.outcomeRed.withAlphaComponent(alpha)
        case .rescheduled:
            backgroundView.layer.borderColor = UIColor.outcomePurple.cgColor
            backgroundView.backgroundColor = UIColor.outcomePurple.withAlphaComponent(alpha)
        case .ran:
            backgroundView.layer.borderColor = UIColor.outcomeBlue.cgColor
            backgroundView.backgroundColor = UIColor.outcomeBlue.withAlphaComponent(alpha)
        case .ranIncomplete:
            backgroundView.layer.borderColor = UIColor.outcomeBlue.cgColor
            backgroundView.backgroundColor = UIColor.outcomeRed.withAlphaComponent(alpha)
        case .sold:
            backgroundView.layer.borderColor = UIColor.outcomeGreen.cgColor
            backgroundView.backgroundColor = UIColor.outcomeGreen.withAlphaComponent(alpha)
            backgroundView.layer.applySketchShadow(color: .outcomeGreen, alpha: 0.6, x: 0.0, y: 1.0, blur: 5.0, spread: 0.0)
        }
    }
}
