//
//  MapViewController.swift
//  SynergyAppointmentForm
//
//  Created by Jaymond Richardson on 1/8/25.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    // MARK: - OUTLETS

    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()

    }
    
    
    
    // MARK: - PROPERTIES
    
    
    
    // MARK: - FUNCTIONS
    
    private func setupView() {
        // MAP CHARACTERISTICS
        mapView.tintColor = UIColor.green
        mapView.overrideUserInterfaceStyle = .dark // Force dark mode

    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
