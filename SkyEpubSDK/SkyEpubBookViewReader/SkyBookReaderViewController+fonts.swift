//
//  SkyBookReaderViewController+fonts.swift
//  BookStore
//
//  Created by Amr Elghadban on 13/11/2022.
//  Copyright © 2022 ADKA Tech. All rights reserved.
//

import UIKit

// MARK: - SkyBookReaderViewController+fonts
extension SkyBookReaderViewController {
    
    @IBAction func fontPressed(_ sender: Any) {
        self.showFontBox()
    }
    
    @objc func fontNameButtonClick(_ sender: Any) {
        if currentSelectedFontButton != nil {
            currentSelectedFontButton.isSelected = false
        }
        let button = sender as! UIButton
        button.isSelected = true
        currentSelectedFontButton = button
        currentSelectedFontIndex = button.tag
        var fontName = fontNames.object(at: currentSelectedFontIndex) as! String
        if fontName  == "Book Fonts" {
            fontName = ""
        }
        let ret = rv.changeFontName(fontName, fontSize: self.getRealFontSize(fontSizeIndex:setting.fontSize))
        if ret {
            setting.fontName = fontName
        }
    }
    
    @IBAction func decreaseFontSizeDown(_ sender: Any) {
        decreaseFontSizeButton.backgroundColor = .lightGray
        
    }
    
    @IBAction func decreaseFontSizePressed(_ sender: Any) {
        decreaseFontSizeButton.backgroundColor = .clear
        self.decreaseFontSize()
    }
    
    @IBAction func increaseFontSizeDown(_ sender: Any) {
        increaseFontSizeButton.backgroundColor = .lightGray
    }
    
    
    @IBAction func increaseFontSizePressed(_ sender: Any) {
        increaseFontSizeButton.backgroundColor = .clear
        self.increaseFontSize()
    }
    
    // fonts
    // register custom fonts.
    func makeFonts() {
        self.addFont(name:"Book Fonts", alias:"Book Fonts")
        self.addFont(name:"Courier", alias:"Courier")
        self.addFont(name:"Arial", alias:"Arial")
        self.addFont(name:"Times New Roman", alias:"Times New Roman")
        self.addFont(name:"American Typewriter", alias:"American Typewriter")
        self.addFont(name:"Marker Felt", alias:"Marker Felt")
        self.addFont(name:"Mayflower Antique", alias:"Mayflower Antique")
        self.addFont(name:"Underwood Champion", alias:"Underwood Champion")
    }
    
    func addFont(name:String,alias:String) {
        fontNames.add(name)
        fontAliases.add(alias)
    }
    
    func showFontBox() {
        var fx:CGFloat = 0
        var fy:CGFloat = 0
        
        self.showBaseView()
        fontBox.isExclusiveTouch = true
        fontBox.isHidden = false
        self.view.addSubview(fontBox)
        
        let rightMargin:CGFloat = 50.0
        let topMargin:CGFloat = 60.0 + view.safeAreaInsets.top
        
        if self.isPad() {
            fx = self.view.bounds.size.width - fontBox.bounds.size.width - rightMargin
            fy = topMargin
        } else {
            fx = (view.frame.size.width-fontBox.frame.size.width)/2
            fy = view.safeAreaInsets.top+50
        }
        
        fontBox.frame.origin = CGPoint(x:fx,y:fy)
        
        if !isFontBoxMade  {
            self.fillFontScrollView()
        }
        self.focusSelectedFont()
        
        fontBox.layer.borderWidth = 1
        fontBox.layer.cornerRadius = 10
        fontScrollView.layer.borderWidth = 1
        fontScrollView.layer.cornerRadius = 10
        
        brightnessSlider.value = Float(setting.brightness)
    }
    
    func focusSelectedFont() {
        let itemHeight:CGFloat = 40
        var selectedFontOffsetY:CGFloat = 0
        let fontButtons = fontScrollView.subviews.filter{$0 is UIButton}
        for i in 0..<fontButtons.count {
            let fontButton:UIButton = fontButtons[i] as! UIButton
            if fontButton.isSelected {
                selectedFontOffsetY = fontButton.frame.origin.y - itemHeight
            }
            fontButton.setTitleColor(currentTheme.selectedColor, for: .selected)
            fontButton.setTitleColor(currentTheme.labelColor, for: .normal)
        }
        fontScrollView.contentOffset = CGPoint(x:0,y:selectedFontOffsetY)
    }
    
    func fillFontScrollView() {
        let itemHeight:CGFloat = 40
        var itemOffsetY:CGFloat = 0
        var fontIndex:Int = 0
        for i in 0..<fontNames.count {
            let fontName:String = fontNames.object(at: i) as! String
            let fontAlias:String = fontAliases.object(at: i) as! String
            let font:UIFont = UIFont(name:fontName,size:18.0) ?? UIFont.systemFont(ofSize: 18.0)
            let button:UIButton = UIButton(type: .custom)
            button.setTitle(fontAlias, for: .normal)
            button.setTitleColor(.black, for: .normal)
            button.setTitleColor(UIColor.init(red: 20/255, green: 40/255, blue: 230/255, alpha: 1.0), for: .selected)
            button.frame = CGRect(x:0,y:itemOffsetY,width:280,height:itemHeight)
            if fontName == setting.fontName {
                button.isSelected = true
                selectedFontOffsetY = itemOffsetY
                currentSelectedFontIndex = fontIndex
                currentSelectedFontButton = button
            }
            button.tag = fontIndex
            button.titleLabel!.font = font
            
            button.showsTouchWhenHighlighted = true
            button.addTarget(self, action:#selector(self.fontNameButtonClick(_:)), for: .touchUpInside) //<- use `#selector(...)`
            fontScrollView.addSubview(button)
            fontIndex += 1
            itemOffsetY += itemHeight
        }
        
        fontScrollView.contentSize = CGSize(width:280, height:itemOffsetY)
        self.focusSelectedFont()
        isFontBoxMade = true
    }
    
    func hideFontBox() {
        fontBox.isHidden = true
        fontBox.removeFromSuperview()
        hideBaseView()
    }
    
    func increaseFontSize() {
        var fontName:String = setting.fontName
        if fontName  == "Book Fonts" {
            fontName = ""
        }
        if setting.fontSize != 4 {
            var fontSize = setting.fontSize!
            fontSize += 1
            // changeFontName changes font, fontSize.
            let ret = rv.changeFontName(fontName as String, fontSize: self.getRealFontSize(fontSizeIndex:fontSize))
            if ret {
                setting.fontSize = fontSize
            }
        }
    }
    
    func decreaseFontSize() {
        var fontName:String = setting.fontName
        if fontName  == "Book Fonts" {
            fontName = ""
        }
        if (self.setting.fontSize != 0) {
            var fontSize = setting.fontSize!
            fontSize -= 1
            let ret = rv.changeFontName(fontName as String, fontSize:  self.getRealFontSize(fontSizeIndex:fontSize))
            if ret {
                setting.fontSize = fontSize
            }
        }
        
    }
}
