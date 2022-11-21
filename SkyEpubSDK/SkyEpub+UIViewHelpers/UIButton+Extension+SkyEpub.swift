//
//  UIButton+Extension+SkyEpub.swift
//  EpubBookReader
//
//  Created by Amr Elghadban on 05/11/2022.
//

import UIKit

extension UIButton {
    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let margin: CGFloat = 10
        let hitArea = self.bounds.insetBy(dx: -margin, dy: -margin)
        return hitArea.contains(point)
    }
}
