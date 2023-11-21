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
    func saveForm(data: [String : Any], completion: @escaping (_ error: Error?) -> Void) {
        db.collection(FormFirebaseKey.collectionID).addDocument(data: data) { error in
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
        db.collection(FormFirebaseKey.collectionID).getDocuments { snapshot, error in
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
    
    
    // DELETE
    
}
