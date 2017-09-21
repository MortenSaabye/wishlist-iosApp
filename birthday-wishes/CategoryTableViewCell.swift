//
//  CategoryTableViewCell.swift
//  birthday-wishes
//
//  Created by Morten Saabye Kristensen on 18/09/2017.
//  Copyright © 2017 Morten Saabye Kristensen. All rights reserved.
//

import UIKit

class CategoryTableViewCell: UITableViewCell {
//    MARK: Properties
    
    @IBOutlet weak var categoryLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
