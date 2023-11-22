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
    func saveForm(form: Form, completion: @escaping (_ error: Error?) -> Void) {
        var data = Form.firebaseRepresentation(form: form)
    
        let documentReference = db.collection(FirebaseKeys.collectionID).document()
        data[FirebaseKeys.firbaseID] = documentReference.documentID
        
        documentReference.setData(data) { error in
            if let error = error {
                completion(error)
            } else {
                print("No Errors saving document")
                completion(nil)
            }
        }
    }
    
    // READ
    func getForms(completion: @escaping (_ forms: [Form], _ error: Error? ) -> Void) {
        db.collection(FirebaseKeys.collectionID).getDocuments { snapshot, error in
            if let error = error {
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
                let form = Form(firebaseID: document.documentID, firebaseData: data)
                forms.append(form)
            }
            completion(forms, nil)
        }
    }
    
    // UPDATE
    func updateForm(firebaseID: String, form: Form, completion: @escaping (_ error: Error?) -> Void) {
        let data = Form.firebaseRepresentation(form: form)
        db.collection(FirebaseKeys.collectionID).document(firebaseID).updateData(data) { error in
            if let error = error {
                completion(error)
                return
            }
            completion(nil)
        }
    }
    
    // DELETE
    func deleteForm(firebaseID: String, completion: @escaping (_ error: Error?) -> Void) {
        db.collection(FirebaseKeys.collectionID).document(firebaseID).delete { error in
            if let error = error {
                completion(error)
                return
            }
        }
    }
    
}
