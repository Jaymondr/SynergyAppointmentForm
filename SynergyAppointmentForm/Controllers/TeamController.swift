//
//  TeamController.swift
//  SynergyAppointmentForm
//
//  Created by Jaymond Richardson on 6/21/24.
//

import Foundation


class TeamController {
    
    static let shared = TeamController()
    
    
    
    // MARK: - FUNCTIONS
    func handleTeamSelection(userID: String, newTeamID: String, oldTeamID: String?, teamName: String, completion: @escaping (Bool, Error?) -> Void) {
        FirebaseController.shared.addUserToTeam(userID: userID, teamID: newTeamID) { success, error in
            if let error = error {
                print("Error adding user to team: \(error)")
                completion(false, error)
                return
            }
            
            FirebaseController.shared.updateUserTeam(userID: userID, teamID: newTeamID) { success, error in
                if let error = error {
                    print("Error updating user's team ID: \(error)")
                    completion(false, error)
                    return
                }
                            
            FirebaseController.shared.removeUserFromTeam(userID: userID, oldTeamID: oldTeamID) { success, error in
                if let error = error {
                    print("Error removing user from team: \(error)")
                    completion(false, error)
                    return
                }
                
                UserAccountController.shared.updateTeamID(to: newTeamID)
                UserAccountController.shared.updateTeamNameInUserDefaults(to: teamName)
                
                    // All steps succeeded
                    print("Successfully handled team selection.")
                    completion(true, nil)
                }
            }
        }
    }
}
