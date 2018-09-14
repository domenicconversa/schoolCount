//
//  ScheduleCell.swift
//  imIn
//
//  Created by Domenic Conversa on 6/1/17.
//  Copyright © 2017 versaTech. All rights reserved.
//

import UIKit

class ScheduleCell: UITableViewCell {

    @IBOutlet var catLabel: UILabel!
    @IBOutlet var countLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var locLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var goingButton: UIButton!
    @IBOutlet var multiplier: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
