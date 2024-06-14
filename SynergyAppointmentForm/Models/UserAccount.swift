//
//  User.swift
//  SynergyAppointmentForm
//
//  Created by Jaymond Richardson on 12/1/23.
//

import Foundation
import Firebase

class UserAccount {
    // MARK: COMPUTED PROPERTIES
    static var currentUser: UserAccount? {
        get {
            guard let uid = Auth.auth().currentUser?.uid, let userDictionary = UserDefaults.standard.dictionary(forKey: kUser), let dictionaryID = userDictionary[UserAccount.CodingKeys.firebaseID.rawValue] as? String, uid == dictionaryID else {
                print("No User. Present account screen.")
                return nil
            }
            return UserAccount(userDefaultsDict: userDictionary, firebaseID: uid)
        }
        
        set {
            if let newValue = newValue {
                UserDefaults.standard.set(newValue.toUserDefaultsDictionary(), forKey: kUser)
            } else {
                UserDefaults.standard.removeObject(forKey: kUser)
            }
        }
    }
    
    static var signUp: Bool {
        return true
    }
    
    var uID: String {
        return firebaseID
    }
    
    var companyName: String {
        if branch == .southJordan || branch == .lasVegas {
            return "Synergy"
        } else {
            return "Energy One"
        }
    }
    
    var firebaseRepresentation: [String : FirestoreType] {
        let firebaseRepresentation: [String : FirestoreType] = [
            UserAccount.CodingKeys.firebaseID.rawValue              : firebaseID,
            UserAccount.CodingKeys.firstName.rawValue               : firstName,
            UserAccount.CodingKeys.lastName.rawValue                : lastName,
            UserAccount.CodingKeys.email.rawValue                   : email,
            
        ]
        return firebaseRepresentation
    }
    
    
    // MARK: PROPERTIES
    /// Users
    static let collectionKey = "Users"
    /// User
    static let kUser = "User"
    var firebaseID: String
    var firstName: String
    var lastName: String
    var email: String
    var branch: Branch?
    var teamID: String?
    var accountType: AccountType?

    
    // MARK: INITIALIZERS
    init(firebaseID: String, firstName: String, lastName: String, email: String, branch: Branch? = nil, teamID: String? = nil, accountType: AccountType? = nil) {
        self.firebaseID = firebaseID
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.branch = branch
        self.teamID = teamID
        self.accountType = accountType
    }
    
    init?(userDefaultsDict: [String: Any], firebaseID: String) {
        // REQUIRED PROPERTIES
        guard let firstName = userDefaultsDict[UserAccount.CodingKeys.firstName.rawValue] as? String,
              let lastName = userDefaultsDict[UserAccount.CodingKeys.lastName.rawValue] as? String,
              let email = userDefaultsDict[UserAccount.CodingKeys.email.rawValue] as? String
        else { return nil }
        
        // OPTIONALS
        if let branchString = userDefaultsDict[UserAccount.CodingKeys.branch.rawValue] as? String {
            self.branch = Branch(rawValue: branchString)
        }
        
        if let teamID = userDefaultsDict[UserAccount.CodingKeys.teamID.rawValue] as? String {
            self.teamID = teamID
        }
        
        if let accountTypeString = userDefaultsDict[UserAccount.CodingKeys.accountType.rawValue] as? String {
            self.accountType = AccountType(rawValue: accountTypeString)
        }
        
        self.firebaseID = firebaseID
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
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
    
    
    // MARK: FUNCTIONS
    func toUserDefaultsDictionary() -> [String: Any] {
        var userDefaultsDictionary: [String : Any] = [
            UserAccount.CodingKeys.firebaseID.rawValue:              uID,
            UserAccount.CodingKeys.firstName.rawValue:               firstName,
            UserAccount.CodingKeys.lastName.rawValue:                lastName,
            UserAccount.CodingKeys.email.rawValue:                   email,
            
        ]
        if let branch = branch {
            userDefaultsDictionary[UserAccount.CodingKeys.branch.rawValue] = branch.rawValue
        }
        
        if let teamID = teamID {
            userDefaultsDictionary[UserAccount.CodingKeys.teamID.rawValue] = teamID
        }
        
        if let accountType = accountType {
            userDefaultsDictionary[UserAccount.CodingKeys.accountType.rawValue] = accountType.rawValue
        }
        
        return userDefaultsDictionary
    }
    
    func joinTeam(_ teamID: String) {
        self.teamID = teamID
    }
    
    func leaveTeam() {
        self.teamID = nil
    }
    
    // MARK: ENUMS
    enum CodingKeys: String, CodingKey {
        case accountType = "accountType"
        case branch = "branch"
        case email = "email"
        case firebaseID = "firebaseID"
        case firstName = "firstName"
        case lastName = "lastName"
        case teamID = "teamID"
    }
}

