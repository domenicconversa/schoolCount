//
//  TestTableViewCell.swift
//  counts
//
//  Created by Domenic Conversa on 6/24/17.
//  Copyright © 2017 DomenicConversa. All rights reserved.
//

import UIKit

class TestTableViewCell: UITableViewCell {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var backgroundImage: UIImageView!
    @IBOutlet var detailImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
