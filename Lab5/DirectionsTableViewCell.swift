//
//  DirectionsTableViewCell.swift
//  Lab5
//
//  Created by Patricia Caceres on 3/25/17.
//  Copyright © 2017 MyOrg. All rights reserved.
//

import UIKit

class DirectionsTableViewCell: UITableViewCell {

    @IBOutlet var Steps: UILabel!
    @IBOutlet var number: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
