//
//  FirebaseController.swift
//  SynergyAppointmentForm
//
//  Created by Jaymond Richardson on 11/20/23.
//

import Foundation
import FirebaseFirestore

class FirebaseController {
    static let shared = FirebaseController()

    let db = Firestore.firestore()
    
    
    // MARK: CRUD FUNCTIONS
    
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
    
    func createUser(from user: UserAccount, completion: @escaping (_ user: UserAccount?, _ error: Error?) -> Void) {
        let docRef = db.collection(UserAccount.collectionKey).document(user.firebaseID)
        var data = user.firebaseRepresentation
        
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
        var data: [String: Any] = [
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
    func updateForm(firebaseID: String, form: Form, completion: @escaping (_ error: Error?) -> Void) {
        let data = form.firebaseRepresentation
        db.collection(Form.CodingKeys.collectionID.rawValue).document(firebaseID).updateData(data) { error in
            if let error = error {
                completion(error)
                print("There was an error updating the form: \(error)")
                return
            }
            print("Successfully updated form. ID: \(firebaseID), Name: \(form.firstName)")
            completion(nil)
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
    
}
