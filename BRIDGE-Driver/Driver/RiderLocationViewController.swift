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
import GoogleMaps

class RiderLocationViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: GMSMapView!
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
        
        mapView.isMyLocationEnabled = true
        
        directionsView.layer.cornerRadius = 10
        pickedRiderButton.layer.cornerRadius = 10
        
        let riderMarker = GMSMarker()
        riderMarker.position = riderCoordinates
        riderMarker.title = "Rider"
        riderMarker.snippet = "This is the location of your rider"
        riderMarker.map = self.mapView
        
        var driverLocation = locationManager.location?.coordinate
        
        ref?.child("acceptedRides").child(userID).observe(.value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                myRiderLat = dictionary["driverLat"] as! Double
                myRiderLong = dictionary["driverLong"] as! Double
                self.riderCoordinates = CLLocationCoordinate2DMake(myRiderLat, myRiderLong)
                riderMarker.position = self.riderCoordinates
                
                if self.firstMapView {
                    let sourceCoorString = "\(driverLocation!.latitude),\(driverLocation!.longitude)"
                    let destCoorString = "\(myRiderLat),\(myRiderLong)"
                    
                    let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(sourceCoorString)&destination=\(destCoorString)&key=AIzaSyDpnFep4SN9iBjtN6MKG9bwdS1ocxNXuRs"
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
                                
                            }
                            
                        } catch let jsonError {
                            print("Error Serializing JSON")
                        }
                        
                        }.resume()
                    
                    self.firstMapView = false
                }
                
            }
        })
    }
    
    @IBAction func pickedUp(_ sender: Any) {
        let requestRef = ref?.child("acceptedRides").child(myRiderID)
        let values = ["pickedUp": true] as [String : Any]
        requestRef?.updateChildValues(values)
        //Save time info
        let now = Date()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "hh:mm a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        midTime = formatter.string(from: now)
        
        self.performSegue(withIdentifier: "finalNav", sender: self)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        let center = location.coordinate
        let camera = GMSCameraPosition(target: center, zoom: 16.0, bearing: 0, viewingAngle: 0)
        mapView.animate(to: camera)
        if let location = locationManager.location?.coordinate {
            userLocation = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            let requestRef = ref?.child("acceptedRides").child(myRiderID)
            let values = ["driverLat": userLocation!.latitude, "driverLong": userLocation!.longitude] as [String : Any]
            requestRef?.updateChildValues(values)
        }
    }
    
}
