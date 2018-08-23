//
//  RideHistoryViewController.swift
//  BRIDGE-Rider
//
//  Created by Bharat Kathi on 8/21/18.
//  Copyright © 2018 Bharat Kathi. All rights reserved.
//

import UIKit
import Firebase

class RideHistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var ref:DatabaseReference?
    var databaseHandle:DatabaseHandle?
    
    var riderIDList = [String]()
    var riderNameList = [String]()
    var dateList = [String]()
    var destinationList = [String]()
    var timeList = [String]()
    
    var riderID = ""
    var date = ""
    var destination = ""
    var riderName = ""
    var time = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        databaseHandle = ref?.child("drivers").child(userID).child("history").observe(.value, with: { (snapshot) in
            if snapshot.childrenCount > 0 {
                self.riderIDList.removeAll()
                self.riderNameList.removeAll()
                self.dateList.removeAll()
                self.destinationList.removeAll()
                self.timeList.removeAll()
                
                for ride in snapshot.children.allObjects as! [DataSnapshot] {
                    let history = ride.value as? [String: AnyObject]
                    self.riderID = history!["riderID"] as! String
                    self.riderName = history!["riderName"] as! String
                    self.date = history!["date"] as! String
                    self.destination = history!["dest"] as! String
                    self.time = history!["endTime"] as! String
                    
                    self.riderIDList.append(self.riderID)
                    self.dateList.append(self.date)
                    self.riderNameList.append(self.riderName)
                    self.destinationList.append(self.destination)
                    self.timeList.append(self.time)
                }
                self.tableView.reloadData()
            }
            else {
                self.riderIDList.removeAll()
                self.dateList.removeAll()
                self.riderNameList.removeAll()
                self.destinationList.removeAll()
                self.timeList.removeAll()
                self.tableView.reloadData()
            }
        })
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return riderIDList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "rideHistory") as! RideHistoryTableViewCell
        
        cell.profilePic.image = #imageLiteral(resourceName: "profile")
        cell.profilePic.layer.cornerRadius = cell.profilePic.frame.height / 2
        cell.driverName.text = riderNameList[indexPath.row]
        cell.rideDate.text = "\(dateList[indexPath.row]), \(timeList[indexPath.row])"
        cell.rideDest.text = destinationList[indexPath.row]
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRide = riderIDList[indexPath.row]
        
        performSegue(withIdentifier: "rideDetails", sender: self)
    }
    
}
