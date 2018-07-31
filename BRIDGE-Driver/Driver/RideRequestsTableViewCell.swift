//
//  RideRequestsTableViewCell.swift
//  BRIDGE
//
//  Created by Bharat Kathi on 1/18/18.
//  Copyright © 2018 Bharat Kathi. All rights reserved.
//

import UIKit

class RideRequestsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var cellView: UIView!
    
    @IBOutlet weak var riderPic: UIImageView!
    
    @IBOutlet weak var riderName: UILabel!
    
    @IBOutlet weak var riderLocation: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
