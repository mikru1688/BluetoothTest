//
//  BLEUITableViewCell.swift
//  BluetoothTest
//
//  Created by Frank.Chen on 2017/5/2.
//  Copyright © 2017年 Frank.Chen. All rights reserved.
//

import UIKit

class BLEUITableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var RSSILabel: UILabel!
    @IBOutlet weak var distLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var conectableLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
