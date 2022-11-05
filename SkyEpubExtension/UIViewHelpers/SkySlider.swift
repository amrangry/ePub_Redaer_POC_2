//
//  SkySlider.swift
//  EpubBookReader
//
//  Created by Amr Elghadban on 05/11/2022.
//

import UIKit

@IBDesignable
class SkySlider : UISlider {
    @IBInspectable var thumbImage: UIImage?{
        didSet {
            setThumbImage(thumbImage, for: .normal)
            setThumbImage(thumbImage, for: .highlighted)
        }
    }
}
