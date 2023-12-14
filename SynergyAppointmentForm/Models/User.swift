//
//  User.swift
//  SynergyAppointmentForm
//
//  Created by Jaymond Richardson on 12/1/23.
//

import Foundation
import Firebase

class User {
    static var currentUser: User? {
        get {
            guard let uid = Auth.auth().currentUser?.uid, let userDictionary = UserDefaults.standard.dictionary(forKey: kUser), let dictionaryID = userDictionary[User.CodingKeys.firebaseID.rawValue] as? String, uid == dictionaryID else {
                print("No User in User defaults")
                return nil
            }
            return User(userDefaultsDict: userDictionary, firebaseID: uid)
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
    
    static let collectionKey = "Users"
    static let kUser = "User"

    var firebaseID: String
    var firstName: String
    var lastName: String
    var email: String
    
    init(firebaseID: String, firstName: String, lastName: String, email: String) {
        self.firebaseID = firebaseID
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
    }
    
    var firebaseRepresentation: [String : FirestoreType] {
        let firebaseRepresentation: [String : FirestoreType] = [
            User.CodingKeys.firebaseID.rawValue              : firebaseID,
            User.CodingKeys.firstName.rawValue               : firstName,
            User.CodingKeys.lastName.rawValue                : lastName,
            User.CodingKeys.email.rawValue                   : email,
        ]
        
        return firebaseRepresentation
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
    
    init?(userDefaultsDict: [String: Any], firebaseID: String) {
        guard let firstName = userDefaultsDict[User.CodingKeys.firstName.rawValue] as? String,
              let lastName = userDefaultsDict[User.CodingKeys.lastName.rawValue] as? String,
              let email = userDefaultsDict[User.CodingKeys.email.rawValue] as? String
        else { return nil }
        
        self.firebaseID = firebaseID
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
    }
    
    func toUserDefaultsDictionary() -> [String: Any] {
        let userDefaultsDictionary: [String : Any] = [
            User.CodingKeys.firebaseID.rawValue:              uID,
            User.CodingKeys.firstName.rawValue:               firstName,
            User.CodingKeys.lastName.rawValue:                lastName,
            User.CodingKeys.email.rawValue:                   email,
        ]
        
        return userDefaultsDictionary
    }
    
    
    enum CodingKeys: String, CodingKey {
        case email = "email"
        case firebaseID = "firebaseID"
        case firstName = "firstName"
        case lastName = "lastName"
        
        // CHANGE FOR NEW USER
        case userID = "jaymondR" // i.e jaymondR
        case userFirstName = "Jaymond" // This is how name appears in text and trello
        case userLastName = "Richardson" // unused currently
        case userEmail = "jrichardson@synergywindow.com" // unused currently
    }
}

