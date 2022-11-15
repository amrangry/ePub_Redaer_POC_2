//
//  BookmarksTableViewCell.swift
//  SkyAD
//
//  Created by 하늘나무 on 2020/09/28.
//  Copyright © 2020 Dev. All rights reserved.
//

import UIKit

class SkyEpubBookmarksTableViewCell: UITableViewCell {
    @IBOutlet weak var positionLabel: UILabel!
    @IBOutlet weak var datetimeLabel: UILabel!    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
