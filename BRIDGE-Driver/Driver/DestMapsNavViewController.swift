//
//  DestMapsNavViewController.swift
//  BRIDGE-Driver
//
//  Created by Bharat Kathi on 8/11/18.
//  Copyright © 2018 Bharat Kathi. All rights reserved.
//

import UIKit
import Firebase
import MapKit
import CoreLocation
import UserNotifications

class DestMapsNavViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    var ref:DatabaseReference?
    var databaseHandle:DatabaseHandle?
    
    let locationManager = CLLocationManager()
    var userLocation:CLLocationCoordinate2D?
    
    var geoFenceRegion:CLCircularRegion = CLCircularRegion(center: CLLocationCoordinate2DMake(0.0, 0.0), radius: 10, identifier: "Destination")

    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        locationManager.allowsBackgroundLocationUpdates = true
        
        let destCoordinates = CLLocationCoordinate2DMake(myRiderDestLat, myRiderDestLong)
        
        let regionDistance:CLLocationDistance = 1000
        let regionSpan = MKCoordinateRegionMakeWithDistance(destCoordinates, regionDistance, regionDistance)
        
        self.geoFenceRegion = CLCircularRegion(center: destCoordinates, radius: 10, identifier: "Destination")
        locationManager.startMonitoring(for: geoFenceRegion)
        
        let options = [MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center), MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)]
        let placemark = MKPlacemark(coordinate: destCoordinates)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "Rider Destinaton"
        mapItem.openInMaps(launchOptions: options)
    }
    
    @IBAction func route(_ sender: Any) {
        let destCoordinates = CLLocationCoordinate2DMake(myRiderDestLat, myRiderDestLong)
        
        let regionDistance:CLLocationDistance = 1000
        let regionSpan = MKCoordinateRegionMakeWithDistance(destCoordinates, regionDistance, regionDistance)
        
        let options = [MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center), MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)]
        let placemark = MKPlacemark(coordinate: destCoordinates)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "Rider Destinaton"
        mapItem.openInMaps(launchOptions: options)
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        //Driver Notification
        let content = UNMutableNotificationContent()
        content.title = "Arrived at Destination"
        content.body = "You have arrived at your rider's destination!"
        content.sound = UNNotificationSound.default()
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let request = UNNotificationRequest(identifier: "DestArrival", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
        //Delete Request Data
        self.locationManager.stopUpdatingLocation()
        let requestRef = ref?.child("acceptedRides").child(userID)
        let values = ["riderName": nil, "riderLat": nil, "riderLong": nil, "driverID": nil, "driverLat": nil, "driverLong": nil, "driverArrived": nil, "pickedUp": nil, "dest": nil] as [String : AnyObject]
        requestRef?.updateChildValues(values)
        rideDone = true
        
        //Save time info
        let now = Date()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "hh:mm a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        endTime = formatter.string(from: now)
        
        locationManager.stopMonitoring(for: geoFenceRegion)
        
        self.performSegue(withIdentifier: "rideDone", sender: self)
    }
    
}
