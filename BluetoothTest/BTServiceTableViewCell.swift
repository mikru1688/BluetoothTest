//
//  BTServiceTableViewCell.swift
//  BluetoothTest
//
//  Created by Frank.Chen on 2017/5/2.
//  Copyright © 2017年 Frank.Chen. All rights reserved.
//

import UIKit

class BTServiceTableViewCell: UITableViewCell {

    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var propLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var notificationLabel: UILabel!
    @IBOutlet weak var uuidLabel: UILabel!
    @IBOutlet weak var propertyLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
