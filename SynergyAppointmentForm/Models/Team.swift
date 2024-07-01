//
//  Team.swift
//  SynergyAppointmentForm
//
//  Created by Jaymond Richardson on 6/14/24.
//

// MARK: - TODO
/*
 1. Need to double check user defaults functions
 2. Double check and finish start up function that check for changes in teamID on account
 3. Add capability for Manager to assing user to directors team
 4. Make sure i can change things in firebase and them be updated in the app
 5. Add button in account page to change teams
 6. User can have multiple teams?
 7. Add tab bar for appointments, leads, and profile
 8. Add view for marketing directors
 9. Add get directions button
 10. Add lead card
 
 
 */

class Team {
    
    // Firebase Collection Key
    static let kCollectionKey = "Teams"
    static let kTeamID = "teamID"
    static let kTeamName = "teamName"
    
    let teamID: String
    let name: String
    var repUserIDs: [String] // Stores only userIDs of reps
    var directorUserIDs: [String] // Stores only userIDs of directors
    
    var firebaseRepresentation: [String : FirestoreType] {
        let firebaseRepresentation: [String : FirestoreType] = [
            Team.CodingKeys.teamID.rawValue             : teamID,
            Team.CodingKeys.name.rawValue               : name,
            Team.CodingKeys.repUserIDs.rawValue         : repUserIDs,
            Team.CodingKeys.directorUserIDs.rawValue    : directorUserIDs,
            
        ]
        return firebaseRepresentation
    }
    
    
    init(teamID: String, name: String) {
        self.teamID = teamID
        self.name = name
        self.repUserIDs = []
        self.directorUserIDs = []
    }
    
    required init?(firebaseData: [String : Any], firebaseID: String) {
        guard let teamID = firebaseData[Team.CodingKeys.teamID.rawValue] as? String,
              let name = firebaseData[Team.CodingKeys.name.rawValue] as? String,
              let repUserIDs = firebaseData[Team.CodingKeys.repUserIDs.rawValue] as? [String],
              let directorUserIDs = firebaseData[Team.CodingKeys.directorUserIDs.rawValue] as? [String]
        else { return nil }
                
        self.teamID = teamID
        self.name = name
        self.repUserIDs = repUserIDs
        self.directorUserIDs = directorUserIDs
    }
    
    // MARK: - METHODS
    func addRep(_ userID: String) {
        repUserIDs.append(userID)
    }
    
    func addDirector(_ userID: String) {
        directorUserIDs.append(userID)
    }
    
    func removeRep(_ userID: String) {
        if let index = repUserIDs.firstIndex(of: userID) {
            repUserIDs.remove(at: index)
        }
    }
    
    func removeDirector(_ userID: String) {
        if let index = directorUserIDs.firstIndex(of: userID) {
            directorUserIDs.remove(at: index)
        }
    }
    
    
    // MARK: - ENUMS
    
    enum CodingKeys: String, CaseIterable, CodingKey {
        case teamID = "teamID"
        case name = "name"
        case repUserIDs = "repUserIDs"
        case directorUserIDs = "directorUserIDs"
    }
}
