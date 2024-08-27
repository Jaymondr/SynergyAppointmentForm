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
        
    static let kTeamName = "teamName"

    var teamName: String? {
        get {
            return UserDefaults.standard.string(forKey: Team.CodingKeys.name.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Team.CodingKeys.name.rawValue)
        }
    }
    
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
    
    func updateAccountType(to accountType: AccountType) {
        guard let user = UserAccount.currentUser else { return }
        // Update locally
        user.accountType = accountType
        
        // Update UserDefaults
        if var userDefaultsDict = UserDefaults.standard.dictionary(forKey: UserAccount.kUser) {
            userDefaultsDict[UserAccount.CodingKeys.accountType.rawValue] = accountType.rawValue
            UserDefaults.standard.set(userDefaultsDict, forKey: UserAccount.kUser)
        }
        
        // Update in Firebase
        let userRef = Firestore.firestore().collection(UserAccount.collectionKey).document(user.uID)
        userRef.updateData([UserAccount.CodingKeys.accountType.rawValue: accountType.rawValue]) { error in
            if let error = error {
                print("Error updating account type in Firebase: \(error.localizedDescription)")
                // Handle error as needed
            } else {
                print("Account type updated successfully in Firebase!")
                UIAlertController.presentDismissingAlert(title: "Updated account type to \(accountType.rawValue)", dismissAfter: 1.4)
            }
        }
    }
    
    func updateTeamID(to teamID: String) {
        guard let user = UserAccount.currentUser else { return }
        // Update Locally
        user.teamID = teamID
        
        // Update UserDefaults
        if var userDefaultsDict = UserDefaults.standard.dictionary(forKey: UserAccount.kUser) {
            userDefaultsDict[UserAccount.CodingKeys.teamID.rawValue] = teamID
            UserDefaults.standard.set(userDefaultsDict, forKey: UserAccount.kUser)

            // Update in Firebase
            /*
            let userRef = Firestore.firestore().collection(UserAccount.collectionKey).document(user.uID)
            userRef.updateData([UserAccount.CodingKeys.teamID.rawValue: teamID]) {error in
                if let error = error {
                    print("Error updating teamID  in Firebase: \(error.localizedDescription)")
                    // Handle error as needed
                } else {
                    print("Team ID updated successfully in Firebase!")
                    
                }
            }
             */
        }
    }
    
    
    
    func updateTeamNameInUserDefaults(to teamName: String) {
        // Update UserDefaults
        if var userDefaultsDict = UserDefaults.standard.dictionary(forKey: UserAccountController.kTeamName) {
            userDefaultsDict[UserAccount.CodingKeys.teamName.rawValue] = teamName
            UserDefaults.standard.set(userDefaultsDict, forKey: UserAccount.kUser)
        }
    }
}



