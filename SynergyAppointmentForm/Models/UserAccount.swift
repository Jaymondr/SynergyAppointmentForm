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
    
    var uID: String {
        return firebaseID
    }
    
    static var signUp: Bool {
        return true
    }
    
    
    // MARK: PROPERTIES
    static let collectionKey = "Users"
    static let kUser = "User"
    var firebaseID: String
    var firstName: String
    var lastName: String
    var email: String
    
    var firebaseRepresentation: [String : FirestoreType] {
        let firebaseRepresentation: [String : FirestoreType] = [
            UserAccount.CodingKeys.firebaseID.rawValue              : firebaseID,
            UserAccount.CodingKeys.firstName.rawValue               : firstName,
            UserAccount.CodingKeys.lastName.rawValue                : lastName,
            UserAccount.CodingKeys.email.rawValue                   : email,
            
        ]
        return firebaseRepresentation
    }
    
    
    // MARK: INITIALIZERS
    init(firebaseID: String, firstName: String, lastName: String, email: String) {
        self.firebaseID = firebaseID
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
    }
    
    init?(userDefaultsDict: [String: Any], firebaseID: String) {
        guard let firstName = userDefaultsDict[UserAccount.CodingKeys.firstName.rawValue] as? String,
              let lastName = userDefaultsDict[UserAccount.CodingKeys.lastName.rawValue] as? String,
              let email = userDefaultsDict[UserAccount.CodingKeys.email.rawValue] as? String
        else { return nil }
        
        self.firebaseID = firebaseID
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
    }
    
    required init?(firebaseData: [String : Any], firebaseID: String) {
        guard let firstName = firebaseData[Form.CodingKeys.firstName.rawValue] as? String,
              let lastName = firebaseData[Form.CodingKeys.lastName.rawValue] as? String,
              let email = firebaseData[Form.CodingKeys.email.rawValue] as? String
        else { return nil }
        
        self.firebaseID = firebaseID
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
    }
    
    
    // MARK: FUNCTIONS
    func toUserDefaultsDictionary() -> [String: Any] {
        let userDefaultsDictionary: [String : Any] = [
            UserAccount.CodingKeys.firebaseID.rawValue:              uID,
            UserAccount.CodingKeys.firstName.rawValue:               firstName,
            UserAccount.CodingKeys.lastName.rawValue:                lastName,
            UserAccount.CodingKeys.email.rawValue:                   email,
            
        ]
        return userDefaultsDictionary
    }
    
    
    // MARK: ENUMS
    enum CodingKeys: String, CodingKey {
        case email = "email"
        case firebaseID = "firebaseID"
        case firstName = "firstName"
        case lastName = "lastName"
    }
}

