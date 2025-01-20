//
//  MapViewController.swift
//  SynergyAppointmentForm
//
//  Created by Jaymond Richardson on 1/8/25.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    // MARK: - OUTLETS

    @IBOutlet weak var mapView: MKMapView!
    private let pinIdentifier = "Pin"

    
    // MARK: - LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        
        
        loadSavedPins()


    }
    
    
    
    // MARK: - PROPERTIES
    
    
    
    // MARK: - FUNCTIONS
    
    private func setupView() {
        // Delegate
        mapView.delegate = self
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        mapView.addGestureRecognizer(longPressGesture)

        
        // MAP CHARACTERISTICS
        mapView.tintColor = UIColor.green
        mapView.overrideUserInterfaceStyle = .dark // Force dark mode

    }
    
    // MARK: - Gesture Handling
    @objc private func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let location = gestureRecognizer.location(in: mapView)
            let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
            addPin(at: coordinate)
            savePin(coordinate: coordinate)
        }
    }
    
    // MARK: - Add Pin
    private func addPin(at coordinate: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
    }
    
    // MARK: - Save Pin
    private func savePin(coordinate: CLLocationCoordinate2D) {
        // Create a Pin object using the new initializer that takes CLLocationCoordinate2D
        let pin = Pin(coordinate: coordinate)

        // Call the createPin function from your FirebaseController
        FirebaseController.shared.createPin(pin: pin) { savedPin, error in
            if let error = error {
                print("Error saving pin: \(error.localizedDescription)")
            } else if let savedPin = savedPin {
                print("Pin saved successfully with ID: \(savedPin.firebaseID)")
            }
        }
    }
    
    // MARK: - Load Saved Pins
    private func loadSavedPins() {
        FirebaseController.shared.fetchPins { [weak self] pins, error in
            if let error = error {
                print("Error loading pins: \(error.localizedDescription)")
                return
            }

            guard let pins = pins else {
                print("No pins found.")
                return
            }

            // Iterate through the fetched pins and add them to the map
            for pin in pins {
                let coordinate = pin.location.coordinate
                self?.addPin(at: coordinate)
            }
        }
    }

//    private func loadSavedPins() {
//        let savedPins = UserDefaults.standard.array(forKey: pinIdentifier) as? [[String: Double]] ?? []
//        for pinData in savedPins {
//            if let latitude = pinData["latitude"], let longitude = pinData["longitude"] {
//                let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
//                addPin(at: coordinate)
//            }
//        }
//    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
