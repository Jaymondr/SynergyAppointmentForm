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
    func getNames(completion: @escaping (_ names: [String], _ error: Error? ) -> Void) {
        db.collection("Forms").getDocuments { snapshot, error in
            if let error = error {
                completion([], error)
                return
            }
            
            guard let documents = snapshot?.documents else{
                completion([], nil)
                    return
            }
            var names: [String] = []
            for document in documents {
                let data = document.data()
                let name = data["name"] as? String ?? ""
                names.append(name)
            }
            completion(names, nil)
        }
    }
}
