//
//  DriverStatusTableViewController.swift
//  BRIDGE-Driver
//
//  Created by Bharat Kathi on 9/15/18.
//  Copyright © 2018 Bharat Kathi. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class DriverStatusTableViewController: UITableViewController {

    @IBOutlet weak var driverStatusLabel: UILabel!
    @IBOutlet weak var verificationButton: UIButton!
    
    var ref:DatabaseReference?
    var databaseHandle:DatabaseHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.largeTitleDisplayMode = .never
        self.navigationItem.title = "Driver Status"
        
        ref = Database.database().reference()
        
        driverStatusLabel.text = driverStatus
        
        if driverStatus != "Not Verified" {
            verificationButton.isEnabled = false
            if driverStatus == "Pending" {
                verificationButton.setTitle("Verification Requested", for: .normal)
            }
            else {
                verificationButton.setTitle("Already Verified", for: .normal)
            }
        }
    }
    
    @IBAction func requestVerification(_ sender: Any) {
        let request = ["userID": userID, "school": school] as [String: AnyObject]
        ref?.child("driverVerificationRequests").child(userID).updateChildValues(request)
        driverStatus = "Pending"
        driverStatusLabel.text = driverStatus
        ref?.child("drivers").child(userID).updateChildValues(["driverStatus": driverStatus])
        verificationButton.isEnabled = false
        verificationButton.setTitle("Verification Requested", for: .normal)
        let alert = UIAlertController(title: "Driver Verification Requested", message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: "Got it", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
}
