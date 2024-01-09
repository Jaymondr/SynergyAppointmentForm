//
//  UserAccountController.swift
//  SynergyAppointmentForm
//
//  Created by Jaymond Richardson on 1/5/24.
//

import Foundation
import Firebase

class UserAccountController {
    static let shared = UserAccountController()
    
    // MARK: - Update Branch Function
    func updateBranch(newBranch: Branch) {
        guard let user = UserAccount.currentUser else { return }
        // Update locally
        user.branch = newBranch

        // Update UserDefaults
        if var userDefaultsDict = UserDefaults.standard.dictionary(forKey: UserAccount.kUser) {
            userDefaultsDict[UserAccount.CodingKeys.branch.rawValue] = newBranch.rawValue
            UserDefaults.standard.set(userDefaultsDict, forKey: UserAccount.kUser)
        }

        // Update in Firebase
        let userRef = Firestore.firestore().collection(UserAccount.collectionKey).document(user.uID)
        userRef.updateData([UserAccount.CodingKeys.branch.rawValue: newBranch.rawValue]) { error in
            if let error = error {
                print("Error updating branch in Firebase: \(error.localizedDescription)")
                // Handle error as needed
            } else {
                print("Branch updated successfully in Firebase!")
                UIAlertController.presentDismissingAlert(title: "Added to \(newBranch.rawValue)'s branch", dismissAfter: 1.4)
            }
        }
    }
}

