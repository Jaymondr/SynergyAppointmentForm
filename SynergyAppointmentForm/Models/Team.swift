// Define the Team class
class Team {
    
    // Firebase Collection Key
    static let kCollectionKey = "Teams"
    
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
