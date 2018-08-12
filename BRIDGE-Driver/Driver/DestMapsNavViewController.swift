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

class DestMapsNavViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    var ref:DatabaseReference?
    var databaseHandle:DatabaseHandle?
    
    let locationManager = CLLocationManager()
    var userLocation:CLLocationCoordinate2D?

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
        
        let geoFenceRegion:CLCircularRegion = CLCircularRegion(center: destCoordinates, radius: 10, identifier: "Destination")
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
        //Arrived at Dest!
        self.performSegue(withIdentifier: "rideDone", sender: self)
    }
    
}
