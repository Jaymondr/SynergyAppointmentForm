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
    @IBOutlet weak var addVisitDetailsButton: UIButton!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var logVisitButton: UIButton!
    @IBOutlet weak var pinView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var currentLocationButton: UIButton!
    
    
    
    // MARK: - LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        loadSavedPins()
        dismissPinView()
        
    }
    
    
    // MARK: - PROPERTIES
    private let pinIdentifier = "Pin"
    private let locationManager = CLLocationManager()
    private var pins: [Pin]?
    private var pin: Pin?
    
    // MARK: - SETUP
    private func setupView() {
        mapView.delegate = self
        
        // Add tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        mapView.addGestureRecognizer(tapGesture)
        
        // Map customization
        mapView.tintColor = .green
        mapView.overrideUserInterfaceStyle = .dark
        
        // Current location button style
        currentLocationButton.backgroundColor = .steelAccent
        currentLocationButton.layer.cornerRadius = currentLocationButton.frame.width / 2
    }
    
    // MARK: - GESTURE HANDLING
    @objc private func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        let location = gestureRecognizer.location(in: mapView)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        var annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        
        addPin(at: coordinate)
        showPinView(for: annotation)
        
    }
    
    // MARK: - PIN HANDLING
    private func addPin(at coordinate: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        self.pin = Pin(coordinate: coordinate)
    }
    
    private func savePin(coordinate: CLLocationCoordinate2D) {
        let pin = Pin(coordinate: coordinate)
        var annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        
        FirebaseController.shared.createPin(pin: pin) { savedPin, error in
            if let error = error {
                print("Error saving pin: \(error.localizedDescription)")
                return
            }
            print("Pin saved successfully with ID: \(savedPin?.firebaseID ?? "Unknown ID")")
        }
    }
    
    private func loadSavedPins() {
        FirebaseController.shared.fetchPins { [weak self] pins, error in
            if let error = error {
                print("Error loading pins: \(error.localizedDescription)")
                return
            }
            self?.pins = pins
            pins?.forEach { self?.addPin(at: $0.location.coordinate) }
        }
    }
    
    // MARK: - PINVIEW
    private func dismissPinView() {
        UIView.animate(withDuration: 0.3) {
            self.pinView.transform = CGAffineTransform(translationX: 0, y: self.pinView.frame.height)
        }
    }
    
    private func showPinView(for annotation: MKAnnotation) {
        UIView.animate(withDuration: 0.3) {
            self.pinView.transform = .identity
        }
        
        let location = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
        getAddress(from: location) { [weak self] address in
            guard let address = address else {
                self?.addressLabel.text = "Lat: \(annotation.coordinate.latitude), Lon: \(annotation.coordinate.longitude)"
                return
            }
            self?.addressLabel.text = "\(address.address), \(address.city), \(address.state) \(address.zip)"
        }
    }
    
    // MARK: - LOCATION
    private func centerMapOnUserLocation() {
        guard let location = locationManager.location?.coordinate else {
            print("User location not available.")
            return
        }
        let region = MKCoordinateRegion(
            center: location,
            latitudinalMeters: 500,
            longitudinalMeters: 500
        )
        mapView.setRegion(region, animated: true)
    }
    
    private func getAddress(from location: CLLocation, completion: @escaping (Address?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print("Error retrieving address: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let place = placemarks?.first,
                  let address = place.name,
                  let zip = place.postalCode,
                  let city = place.locality,
                  let state = place.administrativeArea else {
                completion(nil)
                return
            }
            completion(Address(address: address, zip: zip, city: city, state: state))
        }
    }
    
    // MARK: - BUTTON ACTIONS
    @IBAction func dismissPinViewButtonPressed(_ sender: Any) {
        dismissPinView()
    }
    
    @IBAction func addVisitDetailsButtonPressed(_ sender: Any) {
        print("Visit Details Button Pressed")
    }
    
    @IBAction func logVisitButtonPressed(_ sender: Any) {
        print("Log visit button pressed")
        
        if let coordinate = pin?.location.coordinate {
            savePin(coordinate: coordinate)
            dismissPinView()
        } else {
            print("No pin")
        }
    }
    
    @IBAction func currentLocationButtonPressed(_ sender: Any) {
        centerMapOnUserLocation()
    }
    
    // MARK: - MKMapViewDelegate
    func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
        showPinView(for: annotation)
    }
}
