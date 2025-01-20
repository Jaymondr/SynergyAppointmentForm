//
//  FirestoreType.swift
//  SynergyAppointmentForm
//
//  Created by Jaymond Richardson on 11/26/23.
//

import Foundation
import Firebase

protocol FirestoreType: Any {}

extension String: FirestoreType {}
extension Int: FirestoreType {}
extension UInt: FirestoreType {}
extension Double: FirestoreType {}
extension NSNull: FirestoreType {}
extension Bool: FirestoreType {}
extension Timestamp: FirestoreType {}
extension GeoPoint: FirestoreType {}
extension Dictionary: FirestoreType where Key == String, Value == FirestoreType
{}
extension Array: FirestoreType {}
extension FieldValue: FirestoreType {}
extension DocumentReference: FirestoreType {}
