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
        
        let screenHeight = UIScreen.main.bounds.height
        let screenWidth = UIScreen.main.bounds.width
        let userInterfaceIdiom = UIDevice.current.userInterfaceIdiom

        // Handle iPads
        if userInterfaceIdiom == .pad {
            sizeThatFits.height = 70 // Adjust height for iPads
        }
        // Handle iPhone SE (1st & 2nd gen) and other smaller devices
        else if screenHeight <= 667 {
            sizeThatFits.height = 55 // Adjust height for smaller iPhones (SE, 8, etc.)
        }
        // Handle iPhone 12 Mini, 13 Mini, etc.
        else if screenHeight > 667 && screenWidth <= 375 {
            sizeThatFits.height = 55 // Adjust height for 'Mini' iPhones
        }
        // Handle larger iPhones (iPhone 12/13/14, Pro, Pro Max, etc.)
        else {
            sizeThatFits.height = 85 // Default height for standard and large iPhones
        }

        return sizeThatFits
    }
}
