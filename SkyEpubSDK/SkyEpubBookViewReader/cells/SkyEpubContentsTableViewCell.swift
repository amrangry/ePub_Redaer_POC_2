//
//  ContentsTableViewCell.swift
//  SkyAD
//
//  Created by 하늘나무 on 2020/09/28.
//  Copyright © 2020 Dev. All rights reserved.
//

import UIKit

class SkyEpubContentsTableViewCell: UITableViewCell {
    @IBOutlet weak var chapterTitleLabel: UILabel!
    @IBOutlet weak var positionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
