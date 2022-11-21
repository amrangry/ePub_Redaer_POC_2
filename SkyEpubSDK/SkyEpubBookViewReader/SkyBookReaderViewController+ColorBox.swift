//
//  SkyBookReaderViewController+ColorBox.swift
//  BookStore
//
//  Created by Amr Elghadban on 13/11/2022.
//  Copyright © 2022 ADKA Tech. All rights reserved.
//

import UIKit

// MARK: - SkyBookReaderViewController+ColorBox
extension SkyBookReaderViewController {
    
    @IBAction func yellowPressed(_ sender: Any) {
        let color = self.getMarkerColor(colorIndex: 0)
        self.changeHighlightColor(newColor: color)
    }
    
    @IBAction func greenPressed(_ sender: Any) {
        let color = self.getMarkerColor(colorIndex: 1)
        self.changeHighlightColor(newColor: color)
    }
    
    @IBAction func bluePressed(_ sender: Any) {
        let color = self.getMarkerColor(colorIndex: 2)
        self.changeHighlightColor(newColor: color)
    }
    
    @IBAction func redPressed(_ sender: Any) {
        let color = self.getMarkerColor(colorIndex: 3)
        self.changeHighlightColor(newColor: color)
    }
    
    func showColorBox() {
        showBaseView()
        self.view.addSubview(colorBox)
        colorBox.frame.origin.x = currentMenuFrame.origin.x
        colorBox.frame.origin.y = currentMenuFrame.origin.y
        colorBox.backgroundColor = currentColor
        colorBox.isHidden = false
        showArrow(type: 1)
    }
    
    func hideColorBox() {
        self.colorBox.removeFromSuperview()
        colorBox.isHidden = true
        arrow.isHidden = true
        hideBaseView()
    }
    
    func UIColorFromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    func RGBFromUIColor(color: UIColor) -> UInt32 {
        let colorComponents = color.cgColor.components!
        let value = UInt32(0xFF0000*colorComponents[0] + 0xFF00*colorComponents[1] + 0xFF*colorComponents[2])
        return value
    }
    
    func changeHighlightColor(newColor:UIColor) {
        currentColor = newColor
        highlightBox.backgroundColor = currentColor
        colorBox.backgroundColor = currentColor
        rv.changeHighlight(currentHighlight,color:currentColor)
        self.hideColorBox()
    }
    
    func getMarkerColor(colorIndex: Int32) -> UIColor {
        var markerColor:UIColor!
        switch colorIndex {
        case 0: // yellow
            markerColor = UIColor(red: 238/255, green: 230/255, blue: 142/255, alpha: 1)
        case 1: //
            markerColor = UIColor(red: 218/255, green: 244/255, blue: 160/255, alpha: 1)
        case 2:
            markerColor = UIColor(red: 172/255, green: 201/255, blue: 246/255, alpha: 1)
        case 3:
            markerColor = UIColor(red: 249/255, green: 182/255, blue: 214/255, alpha: 1)
        default:
            markerColor = UIColor(red: 249/255, green: 182/255, blue: 214/255, alpha: 1)
        }
        return markerColor
    }
    
    func getMakerImageFromColor(color: UIColor) -> UIImage {
        if isEqual(color: color, anotherColor: getMarkerColor(colorIndex: 0)) {
            return UIImage(named: "yellowmarker")!
        }
        if isEqual(color: color, anotherColor: getMarkerColor(colorIndex: 1)) {
            return UIImage(named: "greenmarker")!
        }
        if isEqual(color: color, anotherColor: getMarkerColor(colorIndex: 2)) {
            return UIImage(named: "bluemarker")!
        }
        if isEqual(color: color, anotherColor: getMarkerColor(colorIndex: 3)) {
            return UIImage(named: "redmarker")!
        }
        
        if isEqual(color: color, anotherColor: UIColor.yellow) {
            return UIImage(named: "yellowmarker")!
        }
        if isEqual(color: color, anotherColor: UIColor.green) {
            return UIImage(named: "greenmarker")!
        }
        if isEqual(color: color, anotherColor: UIColor.blue) {
            return UIImage(named: "bluemarker")!
        }
        if isEqual(color: color, anotherColor: UIColor.red) {
            return UIImage(named: "redmarker")!
        }
        
        return UIImage(named: "yellowmarker")!
    }
    
    
    func isEqual(color: UIColor, anotherColor: UIColor) ->Bool {
        let colorComponents = color.cgColor.components!
        let anotherColorComponents = anotherColor.cgColor.components!
        
        if  (abs(colorComponents[0]-anotherColorComponents[0])<0.00001) && (abs(colorComponents[1]-anotherColorComponents[1])<0.00001) &&
                (abs(colorComponents[2]-anotherColorComponents[2])<0.00001) {
            return true
        }
        return false
    }
    
    func getMarkerIndexByRGB(rgb: UInt32) -> Int32 {
        for i in 0..<4 {
            let mc = getMarkerColor(colorIndex: Int32(i))
            let mrgb = RGBFromUIColor(color: mc)
            if mrgb == rgb {
                return Int32(i)
            }
        }
        return 0
    }
    
    @IBAction func colorPressed(_ sender: Any) {
        hideHighlightBox()
        showColorBox()
    }
}
