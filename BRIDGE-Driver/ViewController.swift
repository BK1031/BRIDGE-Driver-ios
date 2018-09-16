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
    @IBOutlet weak var profileButton: UIButton!
    
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
        
        profileButton.setImage(profilePic, for: .normal)
        profileButton.imageView?.layer.cornerRadius = (profileButton.imageView?.frame.height)! / 2
        
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
            
            let values = ["date": date, "startTime": startTime, "midTime": midTime, "endTime": endTime, "riderID": myRiderID, "riderName": myRiderName, "dest": destination, "startLat": startLat, "startLong": startLong, "endLat": endLat, "endLong": endLong] as [String : AnyObject]
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
        
        ref?.child("stableVersion").observe(.value, with: { (snapshot) in
            if let stableVersion = snapshot.value as? Double {
                if appVersion < stableVersion {
                    self.performSegue(withIdentifier: "outdatedAlert", sender: self)
                }
                else if appVersion > stableVersion {
                    self.performSegue(withIdentifier: "betaAlert", sender: self)
                }
            }
        })
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        profileButton.setImage(profilePic, for: .normal)
        profileButton.imageView?.layer.cornerRadius = (profileButton.imageView?.frame.height)! / 2
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
        if driverStatus != "Verified" {
            self.performSegue(withIdentifier: "notVerified", sender: self)
        }
        else {
            self.performSegue(withIdentifier: "drive", sender: self)
        }
    }
    
}

