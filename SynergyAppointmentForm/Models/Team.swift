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
        // REQUIRED PROPERTIES
        guard let firstName = firebaseData[UserAccount.CodingKeys.firstName.rawValue] as? String,
              let lastName = firebaseData[UserAccount.CodingKeys.lastName.rawValue] as? String,
              let email = firebaseData[UserAccount.CodingKeys.email.rawValue] as? String
        else { return nil }
        
        // OPTIONALS
        if let branchString = firebaseData[UserAccount.CodingKeys.branch.rawValue] as? String {
            self.branch = Branch(rawValue: branchString)
        }
        
        if let teamID = firebaseData[UserAccount.CodingKeys.teamID.rawValue] as? String {
            self.teamID = teamID
        }
        
        if let accountTypeString = firebaseData[UserAccount.CodingKeys.accountType.rawValue] as? String {
            self.accountType = AccountType(rawValue: accountTypeString)
        }
        
        self.firebaseID = firebaseID
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
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
    
    enum CodingKeys: String, CaseIterable {
        case teamID = "teamID"
        case name = "name"
        case repUserIDs = "repUserIDs"
        case directorUserIDs = "directorUserIDs"
    }
}
