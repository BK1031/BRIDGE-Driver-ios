//
//  RiderLocationViewController.swift
//  BRIDGE-Driver
//
//  Created by Bharat Kathi on 8/10/18.
//  Copyright © 2018 Bharat Kathi. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation
import MapKit

class RiderLocationViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var directionsView: UIView!
    @IBOutlet weak var pickedRiderButton: UIButton!
    
    var ref:DatabaseReference?
    var databaseHandle:DatabaseHandle?
    
    let locationManager = CLLocationManager()
    var userLocation:CLLocationCoordinate2D?
    
    var riderCoordinates = CLLocationCoordinate2DMake(myRiderLat, myRiderLong)
    
    var firstMapView = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        locationManager.allowsBackgroundLocationUpdates = true
        
        mapView.delegate = self
        mapView.showsScale = true
        mapView.showsPointsOfInterest = true
        mapView.showsUserLocation = true
        
        directionsView.layer.cornerRadius = 10
        pickedRiderButton.layer.cornerRadius = 10
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = riderCoordinates
        annotation.title = "Rider"
        annotation.subtitle = "This is the location of your Rider."
        self.mapView.addAnnotation(annotation)
        
        ref?.child("acceptedRides").child(userID).observe(.value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                self.mapView.removeAnnotation(annotation)
                myRiderLat = dictionary["driverLat"] as! Double
                myRiderLong = dictionary["driverLong"] as! Double
                self.riderCoordinates = CLLocationCoordinate2DMake(myRiderLat, myRiderLong)
                
                annotation.coordinate = self.riderCoordinates
                annotation.title = "Driver"
                annotation.subtitle = "This is the location of your BRIDGE."
                self.mapView.addAnnotation(annotation)
                
                if self.firstMapView {
                    let sourcePlacemark = MKPlacemark(coordinate: self.userLocation!)
                    let destPlacemark = MKPlacemark(coordinate: self.riderCoordinates)
                    
                    let sourceItem = MKMapItem(placemark: sourcePlacemark)
                    let destItem = MKMapItem(placemark: destPlacemark)
                    
                    let directionRequest = MKDirectionsRequest()
                    directionRequest.source = sourceItem
                    directionRequest.destination = destItem
                    directionRequest.transportType = .automobile
                    
                    let directions = MKDirections(request: directionRequest)
                    directions.calculate { (response, error) in
                        guard let response = response else {
                            if let error = error {
                                print("Something Went WRONG!!! WHAAA!!!!")
                            }
                            return
                        }
                        let route = response.routes[0]
                        
                        let rekt = route.polyline.boundingMapRect
                        self.mapView.setRegion(MKCoordinateRegionForMapRect(rekt), animated: true)
                    }
                    self.firstMapView = false
                }
                
            }
        })
    }
    
    @IBAction func pickedUp(_ sender: Any) {
        let requestRef = ref?.child("acceptedRides").child(userID)
        let values = ["pickedUp": true] as [String : Any]
        requestRef?.updateChildValues(values)
        self.performSegue(withIdentifier: "finalNav", sender: self)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locationManager.location?.coordinate {
            userLocation = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            let requestRef = ref?.child("acceptedRides").child(userID)
            let values = ["driverLat": userLocation!.latitude, "driverLong": userLocation!.longitude] as [String : Any]
            requestRef?.updateChildValues(values)
        }
    }
    
}
