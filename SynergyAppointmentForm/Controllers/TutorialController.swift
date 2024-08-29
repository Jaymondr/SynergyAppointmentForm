//
//  TutorialController.swift
//  SynergyAppointmentForm
//
//  Created by Jaymond Richardson on 8/28/24.
//

import Foundation
import UIKit


class TutorialController {
    static let kTutorialCollectionID = "Tutorials"
    var screenshots: [UIImage] = []
    
    init(screenshots: [UIImage]) {
        self.screenshots = screenshots
    }
    
    enum CodingKeys: String, Codable {
        case screenshots = "screenshots"
    }
}

enum Tutorials: String, CaseIterable {
    case welcome = "welcomeTutorial"
}


