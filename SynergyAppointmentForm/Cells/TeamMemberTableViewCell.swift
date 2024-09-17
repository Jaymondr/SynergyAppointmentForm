//
//  TeamMemberTableViewCell.swift
//  SynergyAppointmentForm
//
//  Created by Jaymond Richardson on 9/5/24.
//

import UIKit

class TeamMemberTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .blue
    }
    
    // MARK: - PROPERTIES
    var member: UserAccount?
    
    
    // MARK: - FUNCTIONS
    func setCellData(with member: UserAccount) {
        nameLabel.text = member.firstName
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
