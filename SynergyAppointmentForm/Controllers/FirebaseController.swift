//
//  FirebaseController.swift
//  SynergyAppointmentForm
//
//  Created by Jaymond Richardson on 11/20/23.
//

import Foundation
import FirebaseFirestore


// MARK: - TODO
/*
 NOTES: 
 Is the uid different than firebaseID?
 
 
 1. Set the userID to the currentaccount userID
 2. Fix login bug
 3. Clean up profile page
 4. Double check login functionality on ipad
 5. Add notes view
 6. Add search functionality
 7. Add text message curration
 8. Remove forms from previously logged in user
 9. Add sales to profileVC
 10. Add created date to user and form
 
 */


class FirebaseController {
    static let shared = FirebaseController()

    let approvedEmailsCollectionID = "ApprovedEmailList"
    
    let db = Firestore.firestore()
    
    // MARK: FORMS
    // CREATE
    func saveForm(form: Form, completion: @escaping (_ form: Form?, _ error: Error?) -> Void) {
        let documentReference = db.collection(Form.CodingKeys.collectionID.rawValue).document()
        var data = form.firebaseRepresentation
        data[Form.CodingKeys.firebaseID.rawValue] = documentReference.documentID
        
        documentReference.setData(data) { error in
            if let error = error {
                completion(nil, error)
            } else {
                print("No Errors saving form")
                let newForm = Form(firebaseData: data, firebaseID: documentReference.documentID)
                completion(newForm, nil)
            }
        }
    }
    
    func saveDeletedForm(form: Form, completion: @escaping (_ error: Error?) -> Void) {
        let documentReference = db.collection(Form.CodingKeys.deletedCollectionID.rawValue).document()
        var data = form.firebaseRepresentation
        data[Form.CodingKeys.firebaseID.rawValue] = documentReference.documentID
        
        documentReference.setData(data) { error in
            if let error = error {
                completion(error)
            } else {
                print("No Errors saving deleted document")
                completion(nil)
            }
        }
    }

    // READ
    func getForms(for userID: String, completion: @escaping (_ forms: [Form], _ error: Error? ) -> Void) {
        db.collection(Form.CodingKeys.collectionID.rawValue)
            .whereField(Form.CodingKeys.userID.rawValue, isEqualTo: userID)
            .getDocuments { snapshot, error in
            if let error = error {
                print("There was an error getting forms: \(error)")
                completion([], error)
                return
            }
            guard let documents = snapshot?.documents else {
                completion([], nil)
                    return
            }
            var forms: [Form] = []
            for document in documents {
                let data = document.data()
                guard let form = Form(firebaseData: data, firebaseID: document.documentID) else {
                    print("Error creating form from firebaseData")
                    completion([], nil)
                    return
                }
                forms.append(form)
            }
            completion(forms, nil)
        }
    }
    
    // UPDATE
    func updateForm(firebaseID: String, form: Form, completion: @escaping (_ updatedForm: Form?, _ error: Error?) -> Void) {
        let data = form.firebaseRepresentation
        db.collection(Form.CodingKeys.collectionID.rawValue).document(firebaseID).updateData(data) { error in
            if let error = error {
                completion(nil, error)
                print("There was an error updating the form: \(error)")
                return
            }
            let updatedForm = Form(firebaseData: data, firebaseID: firebaseID)
            print("Successfully updated form. ID: \(firebaseID), Name: \(form.firstName)")
            completion(updatedForm, nil)
        }
    }
    
    // DELETE
    func deleteForm(firebaseID: String, completion: @escaping (_ error: Error?) -> Void) {
        db.collection(Form.CodingKeys.collectionID.rawValue).document(firebaseID).delete { error in
            if let error = error {
                completion(error)
                print("Deleted form: \(firebaseID)")
                return
            }
        }
    }
    
    
    // MARK: - USER
    func createUser(from user: UserAccount, completion: @escaping (_ user: UserAccount?, _ error: Error?) -> Void) {
        let docRef = db.collection(UserAccount.collectionKey).document(user.firebaseID)
        var data = user.firebaseRepresentation
        
        // ADD CREATED DATE
        let createdDate = Timestamp(date: Date())
        data["createdDate"] = createdDate
    
        docRef.setData(data) { error in
            if let error = error {
                completion(nil, error)
            } else {
                print("No Errors creating User")
                let newUser = UserAccount(firebaseData: data, firebaseID: user.firebaseID)
                completion(newUser, nil)
            }
        }
    }
    
    func createUser(firstName: String, lastName: String, email: String, completion: @escaping (_ user: UserAccount?, _ error: Error?) -> Void) {
        let docRef = db.collection(UserAccount.collectionKey).document()
        let data: [String: Any] = [
            UserAccount.CodingKeys.firstName.rawValue  : firstName,
            UserAccount.CodingKeys.lastName.rawValue   : lastName,
            UserAccount.CodingKeys.email.rawValue      : email,
            UserAccount.CodingKeys.firebaseID.rawValue : docRef.documentID
        ]
        
        docRef.setData(data) { error in
            if let error = error {
                completion(nil, error)
            } else {
                print("No Errors creating User")
                let newUser = UserAccount(firebaseData: data, firebaseID: docRef.documentID)
                completion(newUser, nil)
            }
        }
    }
        
    func getUser(with firebaseID: String, completion: @escaping (_ user: UserAccount?, _ error: Error? ) -> Void) {
        let docRef = db.collection(UserAccount.collectionKey).document(firebaseID)
        docRef.getDocument(completion: { document, error in
            if let error = error {
                print("There was an error getting forms: \(error)")
                completion(nil, error)
                return
            }
            if let document = document, document.exists,
               let data = document.data() {
                let user = UserAccount(firebaseData: data, firebaseID: firebaseID)
                completion(user, nil)
            } else {
                print("No document data.")
                completion(nil, nil)
            }
        })
    }
    
    func getActiveUsers(for branch: Branch, completion: @escaping (_ users: [UserAccount], _ error: Error?) -> Void) {
        db.collection(UserAccount.collectionKey)
            .whereField(UserAccount.CodingKeys.branch.rawValue, isEqualTo: branch.rawValue)
            .whereField(UserAccount.CodingKeys.isActive.rawValue, isEqualTo: true)
            .getDocuments { snap, error in
            if let error = error {
                print("There was an error getting users for \(branch.rawValue)")
                completion([], error)
            }
            
            if let docs = snap?.documents {
                var users: [UserAccount] = []
                for doc in docs {
                    let data = doc.data()
                    if let user = UserAccount(firebaseData: data, firebaseID: doc.documentID) {
                        users.append(user)
                    }
                }
                print("Users for branch count: \(users.count)")
                completion(users, nil)
            }
        }
    }
    
    
    // MARK: - TEAMS
    func removeUserFromTeam(userID: String, oldTeamID: String?, completion: @escaping (Bool, Error?) -> Void) {
        if let oldTeamID {
            db.collection(Team.kCollectionKey).document(oldTeamID).updateData([
                Team.CodingKeys.memberIDs.rawValue: FieldValue.arrayRemove([userID])
            ]) { error in
                if let error = error {
                    print("Error: \(error)")
                    completion(false, error)
                } else {
                    print("Removed user id from old team: \(oldTeamID)")
                    completion(true, nil)
                }
            }
        } else {
            print("No old team ID")
        }
    }

    func addUserToTeam(userID: String, teamID: String, completion: @escaping (Bool, Error?) -> Void) {
        db.collection(Team.kCollectionKey).document(teamID).updateData([
            Team.CodingKeys.memberIDs.rawValue: FieldValue.arrayUnion([userID])
        ]) { error in
            if let error = error {
                completion(false, error)
            } else {
                completion(true, nil)
            }
        }
    }

    func updateUserTeam(userID: String, teamID: String, completion: @escaping (Bool, Error?) -> Void) {
        db.collection(UserAccount.collectionKey).document(userID).updateData([
            UserAccount.CodingKeys.teamID.rawValue: teamID
        ]) { error in
            if let error = error {
                completion(false, error)
            } else {
                completion(true, nil)
            }
        }
    }
    
    /// Returns teams belonging to specific branch
    func getTeamsForBranch(branch: Branch?, completion: @escaping (_ teams: [Team?], _ error: Error?) -> Void) {
        if let branch = branch {
            db.collection(Team.kCollectionKey).whereField(Team.CodingKeys.branch.rawValue, isEqualTo: branch.rawValue).getDocuments { snap, error in
                if let error = error {
                    print("Error: \(error)")
                    completion([], error)
                }
                
                var teams: [Team?] = []
                guard let snap = snap else { print("No snap"); completion([], nil); return }
                let documents = snap.documents
                
                for document in documents {
                    let team = Team(firebaseData: document.data(), firebaseID: document.documentID)
                    teams.append(team)
                }
                completion(teams, nil)
            }
        } else {
            print("No branch")
        }
    }
    
    /// Gets team object using teamID
    func getTeam(teamID: String, completion: @escaping (_ team: Team?, _ error: Error?) -> Void) {
        db.collection(Team.kCollectionKey).document(teamID).getDocument { snap, error in
            if let error = error {
                print("Error fetching team. Error: \(error)")
                completion(nil, error)
            }
            
            if let data = snap?.data() {
                let team = Team(firebaseData: data, firebaseID: teamID)
                completion(team, nil)
                
            } else {
                print("Error getting team. NO ERROR, NO TEAM... UH OH!")
                completion(nil, nil)
            }
        }
    }
    
    /// Gets team name from team object in firestore using teamID
    func getTeamName(teamID: String, completion: @escaping (_ teamName: String?, _ error: Error?) -> Void) {
        db.collection(Team.kCollectionKey).document(teamID).getDocument { snap, error in
            if let error = error {
                completion(nil, error)
            }
            
            if let data = snap?.data() {
                if let team = Team(firebaseData: data, firebaseID: teamID) {
                    completion(team.name, nil)
                } else {
                    completion("<Team/Name>", nil)
                }
            }
        }
    }

    /// Asynchornously gets team using teamID
    func getTeamAsync(teamID: String) async throws -> Team {
        let document = db.collection(Team.kCollectionKey).document(teamID)
        
        do {
            let snapshot = try await document.getDocument()
            
            if let data = snapshot.data(), let team = Team(firebaseData: data, firebaseID: teamID) {
                return team
            } else {
                throw NSError(domain: "Domain Error", code: 404, userInfo: [NSLocalizedDescriptionKey: "Team data not found"])
            }
        } catch {
            throw error
        }
    }

    /// Asynchronously gets team name using teamID
    func getTeamNameAsync(teamID: String) async throws -> String {
        let document = db.collection(Team.kCollectionKey).document(teamID)
        
        do {
            let snapshot = try await document.getDocument()
            
            if let data = snapshot.data(), let team = Team(firebaseData: data, firebaseID: teamID) {
                return team.name
            } else {
                return "<Team/Name>"
            }
        } catch {
            throw error
        }
    }
    
    /// Gets the appointments of team members for a given team
    func getTeamAppointmentsAsync(for team: Team?) async throws -> [Form] {
        guard let team = team else {
            throw NSError(domain: "Domain Error", code: 400, userInfo: [NSLocalizedDescriptionKey: "No team provided"])
        }
        
        let now = Timestamp(date: Date())
        var upcomingAppointmentForms: [Form] = []
        
        for id in team.memberIDs {
            do {
                let querySnapshot = try await db.collection(Form.collectionKey)
                    .whereField(Form.CodingKeys.date.rawValue, isGreaterThan: now)
                    .whereField(Form.CodingKeys.userID.rawValue, isEqualTo: id)
                    .whereField(Form.CodingKeys.outcome.rawValue, isEqualTo: Outcome.pending.rawValue)
//                    .whereField(Form.CodingKeys.outcome.rawValue, isEqualTo: Outcome.rescheduled.rawValue) // Cannot query
                    .getDocuments()
                
                for document in querySnapshot.documents {
                    let data = document.data()
                    if let form = Form(firebaseData: data, firebaseID: document.documentID) {
                        upcomingAppointmentForms.append(form)
                    }
                }
            } catch {
                throw error
            }
        }
        
        return upcomingAppointmentForms
    }

    
    // MARK: - APPROVED EMAILS
    func getApprovedEmails(completion: @escaping (_ approvedEmails: [String]?) -> Void) {
        db.collection(FirebaseController.shared.approvedEmailsCollectionID).document("approvedEmailList").getDocument(completion: { document, err in
            if let err = err {
                print("Error: \(err)")
                completion(nil)
                return
            }
            
            if let document = document, document.exists,
               let data = document.data(),
               let emailList = data["emailList"] as? [String] {
                completion(emailList)
            } else {
                print("No email list")
                completion(nil)
            }
        })
    }
}
