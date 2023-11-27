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
    @IBOutlet weak var outcomeView: UIView!
    
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
        cellView.layer.borderColor = UIColor.eden.cgColor
        outcomeView.layer.cornerRadius = 10
        outcomeView.backgroundColor = .white

    }
    
    func setOutcomeView(form: Form) {
        switch form.outcome {
        case .pending:
            outcomeView.backgroundColor = .white
        case .cancelled:
            outcomeView.backgroundColor = .red
        case .rescheduled:
            outcomeView.backgroundColor = .purple
        case .sold:
            outcomeView.backgroundColor = .green
        }
    }
    
}
