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
    @IBOutlet weak var spouseNameLabel: UILabel!
    @IBOutlet weak var ambersandLabel: UILabel!
    @IBOutlet weak var cityStateLabel: UILabel!
    @IBOutlet weak var cellView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        loadView()
    }

//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//        // Configure the view for the selected state
//    }
    
    func setCellData(with form: Form) {
        dayLabel.text = form.day
        dateLabel.text = form.date
        timeLabel.text = "\(form.time)\(form.ampm.uppercased())"
        cityStateLabel.text = "\(form.city)(\(form.state))"
        firstNameLabel.text = form.firstName
        if form.spouse.isEmpty {
            firstNameLabel.textAlignment = .center
            spouseNameLabel.isHidden = true
            ambersandLabel.isHidden = true
        } else {
            spouseNameLabel.text = form.spouse
        }
    }
    
    func loadView() {
        cellView.layer.cornerRadius = 10.0
    }
    
}
