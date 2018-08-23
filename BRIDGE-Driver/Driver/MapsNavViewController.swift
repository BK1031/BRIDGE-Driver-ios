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
import UserNotifications

class MapsNavViewController: UIViewController, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    var userLocation:CLLocationCoordinate2D?
    
    var ref:DatabaseReference?
    var databaseHandle:DatabaseHandle?

    var geoFenceRegion:CLCircularRegion = CLCircularRegion(center: CLLocationCoordinate2DMake(0.0, 0.0), radius: 10, identifier: "Rider")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        locationManager.allowsBackgroundLocationUpdates = true
        
        let requestRef = ref?.child("acceptedRides").child(myRiderID)
        let values = ["riderName": myRiderName, "riderLat": 0.0, "riderLong": 0.0, "driverID": userID, "driverName": name, "driverLat": 0.0, "driverLong": 0.0, "driverArrived": false, "pickedUp": false, "dest": destination] as [String : Any]
        requestRef?.updateChildValues(values)
        
        let riderCoordinates = CLLocationCoordinate2D(latitude: myRiderLat, longitude: myRiderLong)
        let regionDistance:CLLocationDistance = 1000
        let regionSpan = MKCoordinateRegionMakeWithDistance(riderCoordinates, regionDistance, regionDistance)
        
        self.geoFenceRegion = CLCircularRegion(center: riderCoordinates, radius: 10, identifier: "Rider")
        locationManager.startMonitoring(for: geoFenceRegion)
        
        let options = [MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center), MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)]
        let placemark = MKPlacemark(coordinate: riderCoordinates)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "Rider Location"
        mapItem.openInMaps(launchOptions: options)
    }
    
    @IBAction func route(_ sender: Any) {
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
        let values = ["driverID": userID, "driverLat": driverCoordinates.latitude, "driverLong": driverCoordinates.longitude] as [String : Any]
        requestRef?.updateChildValues(values)
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        locationManager.stopMonitoring(for: geoFenceRegion)
        //Driver arrive at Rider Location
        let requestRef = ref?.child("acceptedRides").child(myRiderID)
        let values = ["driverArrived": true] as [String : Any]
        requestRef?.updateChildValues(values)
        
        locationManager.stopUpdatingLocation()
        
        //Driver Notification
        let content = UNMutableNotificationContent()
        content.title = "Arrived at Rider"
        content.body = "You have arrived at your rider's location!"
        content.sound = UNNotificationSound.default()
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let request = UNNotificationRequest(identifier: "Arrival", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
        self.performSegue(withIdentifier: "arrivedAtRider", sender: self)
    }

}
