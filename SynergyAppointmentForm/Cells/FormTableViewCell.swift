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
    @IBOutlet weak var dropShadowView: UIView!
    @IBOutlet weak var outcomeView: UIView!
    @IBOutlet weak var outcomeLabel: UILabel!
    
    
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

    
    // MARK: - FUNCTIONS
    private func resetCell() {
        dropShadowView.layer.applySketchShadow(color: .clear, alpha: 0.0, x: 0.0, y: 0.0, blur: 0.0, spread: 0.0)
        outcomeLabel.font = .systemFont(ofSize: 10, weight: .light)
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

    
    func setCellData(with form: Form) {
        dayLabel.text = form.date.formattedDayAbbr() + ","
        dateLabel.text = form.date.formattedDayMonthAbbr() + ":"
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
        dropShadowView.layer.cornerRadius = 10
        cellView.layer.cornerRadius = 10
        cellView.layer.borderWidth = 0.0
        cellView.backgroundColor = .clear
        outcomeView.roundCorners(radius: 8, corners: [.topLeft, .bottomLeft])
        if traitCollection.userInterfaceStyle == .dark {
            firstNameLabel.textColor = .lightText
            timeLabel.textColor = .lightText
            dateLabel.textColor = .lightText
            dayLabel.textColor = .lightText
            cellView.backgroundColor = .steel
        } else {
            firstNameLabel.textColor = .black
            timeLabel.textColor = .black
            dateLabel.textColor = .black
            dayLabel.textColor = .black
        }
    }
    
    private func setOutcomeView(form: Form) {
        let alpha: Double = 1
        switch form.outcome {
        case .lead:
            cellView.layer.borderColor = UIColor.outcomeYellow.cgColor
            outcomeView.backgroundColor = UIColor.outcomeYellow.withAlphaComponent(alpha)
            outcomeLabel.text = form.outcome.rawValue.uppercased()
            outcomeLabel.textColor =  UIColor.outcomeYellow
        case .pending:
            cellView.layer.borderColor = UIColor.eden.cgColor
            outcomeView.backgroundColor = UIColor.eden.withAlphaComponent(alpha)
            outcomeLabel.text = form.outcome.rawValue.uppercased()
            outcomeLabel.textColor =  UIColor.eden
//            dropShadowView.layer.applySketchShadow(color: .eden, alpha: 0.6, x: 0.0, y: 0.0, blur: 20.0, spread: 0.0)
        case .cancelled:
            cellView.layer.borderColor = UIColor.outcomeRed.cgColor
            outcomeView.backgroundColor = UIColor.outcomeRed.withAlphaComponent(alpha)
            outcomeLabel.text = form.outcome.rawValue.uppercased()
            outcomeLabel.textColor =  UIColor.outcomeRed
//            dropShadowView.layer.applySketchShadow(color: .outcomeRed, alpha: 0.6, x: 0.0, y: 0.0, blur: 20.0, spread: 0.0)
        case .rescheduled:
            cellView.layer.borderColor = UIColor.outcomePurple.cgColor
            outcomeView.backgroundColor = UIColor.outcomePurple.withAlphaComponent(alpha)
            outcomeLabel.text = form.outcome.rawValue.uppercased()
            outcomeLabel.textColor =  UIColor.outcomePurple
//            dropShadowView.layer.applySketchShadow(color: .outcomePurple, alpha: 0.6, x: 0.0, y: 0.0, blur: 20.0, spread: 0.0)
        case .ran:
            cellView.layer.borderColor = UIColor.outcomeBlue.cgColor
            outcomeView.backgroundColor = UIColor.outcomeBlue.withAlphaComponent(alpha)
            outcomeLabel.text = form.outcome.rawValue.uppercased()
            outcomeLabel.textColor =  UIColor.outcomeBlue
//            dropShadowView.layer.applySketchShadow(color: .outcomeBlue, alpha: 0.6, x: 0.0, y: 0.0, blur: 20.0, spread: 0.0)
        case .ranIncomplete:
            cellView.layer.borderColor = UIColor.outcomeBlue.cgColor
            outcomeView.backgroundColor = UIColor.outcomeRed.withAlphaComponent(alpha)
            outcomeLabel.text = form.outcome.rawValue.uppercased()
            outcomeLabel.textColor =  UIColor.outcomeRed
        case .sold:
            cellView.layer.borderColor = UIColor.outcomeGreen.cgColor
            outcomeView.backgroundColor = UIColor.outcomeGreen.withAlphaComponent(alpha)
            outcomeLabel.text = form.outcome.rawValue.uppercased()
            outcomeLabel.textColor =  UIColor.outcomeGreen
            outcomeLabel.font = .systemFont(ofSize: 11, weight: .semibold)
            dropShadowView.layer.applySketchShadow(color: .outcomeGreen, alpha: 0.6, x: 0.0, y: 1.0, blur: 5.0, spread: 0.0)
        }
    }
}
