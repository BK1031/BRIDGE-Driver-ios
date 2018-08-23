//
//  ViewController.swift
//  BRIDGE-Rider
//
//  Created by Bharat Kathi on 6/26/18.
//  Copyright © 2018 Bharat Kathi. All rights reserved.
//

import UIKit
import Firebase
import GoogleMaps
import UserNotifications

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var requestButton: UIButton!
    @IBOutlet weak var mapView: GMSMapView!
    
    let locationManager = CLLocationManager()
    
    //Firebase Database Reference Creation
    var ref:DatabaseReference?
    var databaseHandle:DatabaseHandle?

    //Only for ride completion error non-crashing gizmos
    var riderName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Firebase Database Reference Setup
        ref = Database.database().reference()
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        mapView.padding.bottom = view.safeAreaInsets.bottom + 70
        
        let center =  UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { (result, error) in
            //handle result of request failure
        }
        
        self.navigationItem.title = "BRIDGE"
        requestButton.layer.cornerRadius = 10
        
        //Hardcoded School Coordinates
        if school == "Valley Christian High School" {
            schoolLat = 37.2761
            schoolLong = -121.8254
        }
        
        if rideDone {
            //Save Date info
            let now = Date()
            let formatter = DateFormatter()
            formatter.timeZone = TimeZone.current
            formatter.dateFormat = "MM/dd/yy"
            let date = formatter.string(from: now)
            
            let values = ["date": date, "startTime": startTime, "midTime": midTime, "endTime": endTime, "riderID": myRiderID, "riderName": myRiderName, "dest": destination]
            let historyRef = Database.database().reference().child("drivers").child(userID).child("history").child("\(now)")
            historyRef.updateChildValues(values)
            
            myRiderName = ""
            myRiderID = ""
            myRiderLat = 0.0
            myRiderLong = 0.0
            myRiderDestLat = 0.0
            myRiderDestLong = 0.0
            destination = ""
            startTime = ""
            midTime = ""
            endTime = ""
            rideDone = false
            
            let alert = UIAlertController(title: "Ride Completed", message: "Your rider has successfully been dropped off at their destination!", preferredStyle: .alert)
            let action = UIAlertAction(title: "Got it", style: .default, handler: { (action) in
                //Don't do anything boi
            })
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
        
        ref?.child("stableVersion").observeSingleEvent(of: .value, with: { (snapshot) in
            if let stableVersion = snapshot.value as? Double {
                if appVersion < stableVersion {
                    let alert = UIAlertController(title: "Outdated App", message: "It looks like you are using an outdated version of the BRIDGE Driver App. Please update to the latest version to avoid any bugs or crashes.", preferredStyle: .alert)
                    let action = UIAlertAction(title: "Got it", style: .default, handler: { (action) in
                        exit(1)
                    })
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                }
                else if appVersion > stableVersion {
                    let alert = UIAlertController(title: "BRIDGE Canary Detected", message: "It looks like you are using the BRIDGE Canary release of our Driver app. Note that this version should only be used for approved beta testing and not for everyday use.", preferredStyle: .alert)
                    let action = UIAlertAction(title: "Got it", style: .default, handler: { (action) in
                        //Don't do anything boi
                    })
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        })
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        let center = location.coordinate
        let camera = GMSCameraPosition(target: center, zoom: 16.0, bearing: 0, viewingAngle: 0)
        mapView.animate(to: camera)
    }
    
    @IBAction func showAccount(_ sender: Any) {
        self.performSegue(withIdentifier: "toAccount", sender: self)
    }
    
    @IBAction func drive(_ sender: Any) {
        self.performSegue(withIdentifier: "drive", sender: self)
    }
    
}

