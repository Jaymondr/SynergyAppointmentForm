//
//  EmptyTableViewCell.swift
//  SynergyAppointmentForm
//
//  Created by Jaymond Richardson on 1/4/24.
//

import UIKit

class EmptyTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        selectionStyle = .none
    }

}
