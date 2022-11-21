//
//  ArrowView.swift
//  EpubBookReader
//
//  Created by Amr Elghadban on 05/11/2022.
//

import UIKit

class SkyEpubArrowView : UIView {
    private var _upSide:Bool = true
    private var _color:UIColor = UIColor.white
    
    var color:UIColor {
        get {
            return _color
        }
        set(newColor) {
            _color = newColor
            self.setNeedsDisplay()
        }
    }
    
    var upSide:Bool {
        get {
            return _upSide
        }
        set(newValue) {
            _upSide = newValue
            self.setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        let ctx:CGContext! = UIGraphicsGetCurrentContext();
        if (upSide) {
            ctx.beginPath()
            ctx.move(to: CGPoint(x:(rect.maxX)/2,y:rect.minY))
            ctx.addLine(to: CGPoint(x:rect.minX,y:rect.maxY))
            ctx.addLine(to: CGPoint(x:rect.maxX,y:rect.maxX))
            ctx.closePath()
        }else {
            ctx.beginPath()
            ctx.move(to: CGPoint(x:rect.minX,y:rect.minY))
            ctx.addLine(to: CGPoint(x:rect.maxX,y:rect.minY))
            ctx.addLine(to: CGPoint(x:(rect.maxX)/2,y:rect.maxY))
            ctx.closePath()
        }
        ctx.setFillColor(_color.cgColor)
        ctx.fillPath()
    }
}
