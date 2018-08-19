//
//  DriverNavViewController.swift
//  BRIDGE
//
//  Created by Bharat Kathi on 1/22/18.
//  Copyright © 2018 Bharat Kathi. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase
import GoogleMaps
import MapKit

class DriverNavViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var navigationLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var directionsView: UIView!
    
    let locationManager = CLLocationManager()
    
    var ref:DatabaseReference?
    var databaseHandle:DatabaseHandle?
    
    var riderCoordinates = CLLocationCoordinate2DMake(myRiderLat, myRiderLong)
    var destCoordinates = CLLocationCoordinate2DMake(myRiderDestLat, myRiderDestLong)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationItem.title = "BRIDGE"
        
        directionsView.layer.cornerRadius = 10
        confirmButton.layer.cornerRadius = 10
        
        ref = Database.database().reference()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        locationManager.allowsBackgroundLocationUpdates = true
        
        mapView.isMyLocationEnabled = true
        
        var driverLocation = locationManager.location?.coordinate
        
        let riderMarker = GMSMarker()
        riderMarker.position = riderCoordinates
        riderMarker.title = "Rider"
        riderMarker.snippet = "This is the location of your rider"
        riderMarker.map = self.mapView
        
        let destMarker = GMSMarker()
        destMarker.position = destCoordinates
        destMarker.title = "Destination"
        destMarker.snippet = "This is the location of your rider's destinaton"
        destMarker.map = self.mapView
        
        let sourceCoorString = "\(driverLocation!.latitude),\(driverLocation!.longitude)"
        let midCoorString = "\(myRiderLat),\(myRiderLong)"
        let destCoorString = "\(destCoordinates.latitude),\(destCoordinates.longitude)"
        
        let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(sourceCoorString)&destination=\(destCoorString)&waypoints=\(midCoorString)&key=AIzaSyDpnFep4SN9iBjtN6MKG9bwdS1ocxNXuRs"
        guard let url = URL(string: urlString) else {return}
        
        URLSession.shared.dataTask(with: url) { (data, response, erro) in
            //Extract data here
            guard let data = data else {return}
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String: AnyObject]
                
                print(json)
                
                //Extract JSON Data
                let arrayRoutes = json["routes"] as! NSArray
                let arrLegs = (arrayRoutes[0] as! NSDictionary).object(forKey: "legs") as! NSArray
                let arrSteps = arrLegs[0] as! NSDictionary
                
                let dicDistance = arrSteps["distance"] as! NSDictionary
                let distance = dicDistance["text"] as! String
                
                let dicDuration = arrSteps["duration"] as! NSDictionary
                let duration = dicDuration["text"] as! String
                
                print("\(distance), \(duration)")
                
                //Extract Polyline Data
                let array = json["routes"] as! NSArray
                let dic = array[0] as! NSDictionary
                let dic1 = dic["overview_polyline"] as! NSDictionary
                let points = dic1["points"] as! String
                print(points)
                
                //Return to main thread
                DispatchQueue.main.async {
                    //Show polyline
                    let path = GMSPath(fromEncodedPath: points)
                    var rectangle = GMSPolyline(path: path)
                    rectangle.map = nil
                    rectangle.strokeWidth = 4.0
                    rectangle.strokeColor = UIColor.blue
                    rectangle.map = self.mapView
                    
                    self.mapView.animate(with: GMSCameraUpdate.fit(GMSCoordinateBounds(path: rectangle.path!), withPadding: 50))

                }
                
            } catch let jsonError {
                print("Error Serializing JSON")
            }
        }.resume()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locationManager.location?.coordinate {
//            driverLocation = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        }
        
    }
    
    @IBAction func confirmButton(_ sender: UIButton) {
        let values = ["rideAccepted": true]
        let requestRef = ref?.child("rideRequests").child(myRiderID)
        requestRef?.updateChildValues(values)
        //Segue to Nav VC
        self.performSegue(withIdentifier: "toMapsNav", sender: self)
    }
    
}
