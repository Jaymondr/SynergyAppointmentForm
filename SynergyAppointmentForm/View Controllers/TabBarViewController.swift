//
//  TabBarViewController.swift
//  SynergyAppointmentForm
//
//  Created by Jaymond Richardson on 8/19/24.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
}

class CustomTabBar: UITabBar {
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var sizeThatFits = super.sizeThatFits(size)
        sizeThatFits.height = 85 // Set your desired height here
        return sizeThatFits
    }
}
