//
//  FormTableViewCell.swift
//  SynergyAppointmentForm
//
//  Created by Jaymond Richardson on 11/20/23.
//

import UIKit

protocol NotesViewDelegate: AnyObject {
    func showNotesView(form: Form)
}

class FormTableViewCell: UITableViewCell {
    
    weak var delegate: NotesViewDelegate?
    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var cityStateLabel: UILabel!
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var dropShadowView: UIView!
    
    
    // MARK: - LIFECYCLE
    override func awakeFromNib() {
        super.awakeFromNib()
        loadView()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        resetCell()
    }
    
    
    // MARK: - PROPERTIES
    var form: Form?

    
    // MARK: - ACTIONS
    @IBAction func notesButtonPressed(_ sender: Any) {
        print("Notes Button Pressed")
        guard let form = form else { return }
        delegate?.showNotesView(form: form)
    }
    
    
    // MARK: - FUNCTIONS
    private func resetCell() {
        dropShadowView.layer.applySketchShadow(color: .clear, alpha: 0.0, x: 0.0, y: 0.0, blur: 0.0, spread: 0.0)
    }

    
    func setCellData(with form: Form) {
        dayLabel.text = form.date.formattedDay()
        dateLabel.text = form.date.formattedDayMonth()
        timeLabel.text = "\(form.date.formattedTime())\(form.date.formattedAmpm())"
        cityStateLabel.text = "\(form.city.uppercased())(\(form.state))"
        if form.spouse.isEmpty {
            firstNameLabel.text = form.firstName.uppercased() + " " + form.lastName.uppercased()
        } else {
            firstNameLabel.text = form.firstName.uppercased() + " & " + form.spouse.uppercased()
        }
        
        // Set background view for outcome
        setOutcomeView(form: form)
    }
    
    func loadView() {
        cellView.layer.cornerRadius = 8
        dropShadowView.layer.cornerRadius = 8
        cellView.layer.borderWidth = 1.5
    }
    
    private func setOutcomeView(form: Form) {
        let alpha: Double = 0.4
        switch form.outcome {
        case .pending:
            cellView.layer.borderColor = UIColor.eden.cgColor
            cellView.backgroundColor = UIColor.eden.withAlphaComponent(alpha)
//            dropShadowView.layer.applySketchShadow(color: .eden, alpha: 0.6, x: 0.0, y: 0.0, blur: 20.0, spread: 0.0)
        case .cancelled:
            cellView.layer.borderColor = UIColor.outcomeRed.cgColor
            cellView.backgroundColor = UIColor.outcomeRed.withAlphaComponent(alpha)
//            dropShadowView.layer.applySketchShadow(color: .outcomeRed, alpha: 0.6, x: 0.0, y: 0.0, blur: 20.0, spread: 0.0)
        case .rescheduled:
            cellView.layer.borderColor = UIColor.outcomePurple.cgColor
            cellView.backgroundColor = UIColor.outcomePurple.withAlphaComponent(alpha)
//            dropShadowView.layer.applySketchShadow(color: .outcomePurple, alpha: 0.6, x: 0.0, y: 0.0, blur: 20.0, spread: 0.0)
        case .ran:
            cellView.layer.borderColor = UIColor.outcomeBlue.cgColor
            cellView.backgroundColor = UIColor.outcomeBlue.withAlphaComponent(alpha)
//            dropShadowView.layer.applySketchShadow(color: .outcomeBlue, alpha: 0.6, x: 0.0, y: 0.0, blur: 20.0, spread: 0.0)
        case .ranIncomplete:
            cellView.layer.borderColor = UIColor.outcomeBlue.cgColor
            cellView.backgroundColor = UIColor.outcomeRed.withAlphaComponent(alpha)
        case .sold:
            cellView.layer.borderColor = UIColor.outcomeGreen.cgColor
            cellView.backgroundColor = UIColor.outcomeGreen.withAlphaComponent(alpha)
            dropShadowView.layer.applySketchShadow(color: .outcomeGreen, alpha: 0.6, x: 0.0, y: 1.0, blur: 5.0, spread: 0.0)
        }
    }
}
