//
//  FormTableViewCell.swift
//  SynergyAppointmentForm
//
//  Created by Jaymond Richardson on 11/20/23.
//

import UIKit

class FormTableViewCell: UITableViewCell {
    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var cityStateLabel: UILabel!
    @IBOutlet weak var cellView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        loadView()
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
        cellView.layer.cornerRadius = 10
        cellView.layer.borderWidth = 2.5
        cellView.backgroundColor = .white
    }
    
    func setOutcomeView(form: Form) {
        switch form.outcome {
        case .pending:
            cellView.layer.borderColor = UIColor.eden.cgColor
            cellView.layer.applySketchShadow(color: .eden, alpha: 0.9, x: 0.0, y: 0.0, blur: 20.0, spread: 0.0)
        case .cancelled:
            cellView.layer.borderColor = UIColor.outcomeRed.cgColor
            cellView.layer.applySketchShadow(color: .outcomeRed, alpha: 0.9, x: 0.0, y: 0.0, blur: 20.0, spread: 0.0)
        case .rescheduled:
            cellView.layer.borderColor = UIColor.outcomePurple.cgColor
            cellView.layer.applySketchShadow(color: .outcomePurple, alpha: 0.9, x: 0.0, y: 0.0, blur: 20.0, spread: 0.0)
        case .ran:
            cellView.layer.borderColor = UIColor.outcomeBlue.cgColor
            cellView.layer.applySketchShadow(color: .outcomeBlue, alpha: 0.9, x: 0.0, y: 0.0, blur: 20.0, spread: 0.0)
        case .sold:
            cellView.layer.borderColor = UIColor.outcomeGreen.cgColor
            cellView.layer.applySketchShadow(color: .outcomeGreen, alpha: 0.9, x: 0.0, y: 0.0, blur: 20.0, spread: 0.0)
        }
    }
}
