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
    var memberIDs: [String] // Stores only userIDs of reps
    var directorUserIDs: [String] // Stores only userIDs of directors
    var scheduleNotes: String?
    
    var firebaseRepresentation: [String : FirestoreType] {
        var firebaseRepresentation: [String : FirestoreType] = [
            Team.CodingKeys.teamID.rawValue             : teamID,
            Team.CodingKeys.name.rawValue               : name,
            Team.CodingKeys.memberIDs.rawValue         : memberIDs,
            Team.CodingKeys.directorUserIDs.rawValue    : directorUserIDs,
            
        ]
        
        if let scheduleNotes = scheduleNotes {
            firebaseRepresentation[Team.CodingKeys.scheduleNotes.rawValue] = scheduleNotes
        }
        
        return firebaseRepresentation
    }
    
    
    init(teamID: String, name: String) {
        self.teamID = teamID
        self.name = name
        self.memberIDs = []
        self.directorUserIDs = []
    }
    
    required init?(firebaseData: [String : Any], firebaseID: String) {
        guard let teamID = firebaseData[Team.CodingKeys.teamID.rawValue] as? String,
              let name = firebaseData[Team.CodingKeys.name.rawValue] as? String,
              let memberIDs = firebaseData[Team.CodingKeys.memberIDs.rawValue] as? [String],
              let directorUserIDs = firebaseData[Team.CodingKeys.directorUserIDs.rawValue] as? [String]
        else { return nil }
                
        self.teamID = teamID
        self.name = name
        self.memberIDs = memberIDs
        self.directorUserIDs = directorUserIDs
    }
    
    // MARK: - METHODS
    func addMember(_ userID: String) {
        memberIDs.append(userID)
    }
    
    func addDirector(_ userID: String) {
        directorUserIDs.append(userID)
    }
    
    func removeMember(_ userID: String) {
        if let index = memberIDs.firstIndex(of: userID) {
            memberIDs.remove(at: index)
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
        case memberIDs = "memberIDs"
        case directorUserIDs = "directorUserIDs"
        case scheduleNotes = "scheduleNotes"
    }
}
