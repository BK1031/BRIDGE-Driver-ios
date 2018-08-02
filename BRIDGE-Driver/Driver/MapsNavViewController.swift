//
//  MapsNavViewController.swift
//  BRIDGE-Driver
//
//  Created by Bharat Kathi on 8/1/18.
//  Copyright © 2018 Bharat Kathi. All rights reserved.
//

import UIKit
import MapKit
import Firebase

class MapsNavViewController: UIViewController, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    var userLocation:CLLocationCoordinate2D?
    
    var ref:DatabaseReference?
    var databaseHandle:DatabaseHandle?

    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
        let riderCoordinates = CLLocationCoordinate2D(latitude: myRiderLat, longitude: myRiderLong)
        let regionDistance:CLLocationDistance = 1000
        let regionSpan = MKCoordinateRegionMakeWithDistance(riderCoordinates, regionDistance, regionDistance)
        let options = [MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center), MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)]
        let placemark = MKPlacemark(coordinate: riderCoordinates)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "Rider Location"
        mapItem.openInMaps(launchOptions: options)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        let driverCoordinates = location.coordinate
        
        let requestRef = ref?.child("acceptedRides").child(myRiderID)
        let values = ["riderName": name, "riderLat": 0.0, "riderLong": 0.0, "driverID": "", "driverLat": 0.0, "driverLong": 0.0, "driverArrived": false, "dest": destination] as [String : Any]
        requestRef?.updateChildValues(values)
    }

}
