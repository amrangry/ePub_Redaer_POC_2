//
//  SkyBookReaderViewController+Theme.swift
//  BookStore
//
//  Created by Amr Elghadban on 13/11/2022.
//  Copyright © 2022 ADKA Tech. All rights reserved.
//

import UIKit

// MARK: - SkyBookReaderViewController+Theme
extension SkyBookReaderViewController {
    
    @IBAction func theme0Pressed(_ sender: Any) {
        self.themePressed(themeIndex: 0)
    }
    
    @IBAction func theme1Pressed(_ sender: Any) {
        self.themePressed(themeIndex: 1)
    }
    
    @IBAction func theme2Pressed(_ sender: Any) {
        self.themePressed(themeIndex: 2)
    }
    
    @IBAction func theme3Pressed(_ sender: Any) {
        self.themePressed(themeIndex: 3)
    }
    
    func themePressed(themeIndex: Int) {
        if themeIndex == currentThemeIndex {
            return
        }
        if setting.transitionType == 2 {
            self.showSnapView()
            self.showActivityIndicator()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.hideActivityIndicator()
                self.hideSnapView()
            }
        }
        currentThemeIndex = themeIndex
        setting.theme = currentThemeIndex
        applyCurrentTheme()
    }
    
    // make all custom themes.
    func makeThemes() {
        // Theme 0  -  White
        self.themes.add(SkyEpubTheme(themeName: "White", textColor: .black, backgroundColor: UIColor.init(red:252/255,green:252/255,blue: 252/255,alpha:1), boxColor: .white, borderColor: UIColor.init(red:198/255,green:198/255,blue: 200/255,alpha:1), iconColor: UIColor.init(red:0/255,green:2/255,blue: 0/255,alpha:1), labelColor: .black,     selectedColor:.blue, sliderThumbColor: .black,sliderMinTrackColor: .darkGray, sliderMaxTrackColor: UIColor.init(red:220/255,green:220/255,blue: 220/255,alpha:1)))
        // Theme 1 -   Brown
        self.themes.add(SkyEpubTheme(themeName: "Brown", textColor: .black, backgroundColor: UIColor.init(red:240/255,green:232/255,blue: 206/255,alpha:1), boxColor: UIColor.init(red:253/255,green:249/255,blue: 237/255,alpha:1), borderColor: UIColor.init(red:219/255,green:212/255,blue: 199/255,alpha:1), iconColor:UIColor.brown, labelColor: UIColor.init(red:70/255,green:52/255,blue: 35/255,alpha:1), selectedColor:.blue,sliderThumbColor: UIColor.init(red:191/255,green:154/255,blue: 70/255,alpha:1),sliderMinTrackColor: UIColor.init(red:191/255,green:154/255,blue: 70/255,alpha:1), sliderMaxTrackColor: UIColor.init(red:219/255,green:212/255,blue: 199/255,alpha:1)))
        // Theme 2 -  Dark
        self.themes.add(SkyEpubTheme(themeName: "Dark", textColor: UIColor.init(red:212/255,green:212/255,blue: 213/255,alpha:1), backgroundColor: UIColor.init(red:71/255,green:71/255,blue: 73/255,alpha:1), boxColor: UIColor.init(red:77/255,green:77/255,blue: 79/255,alpha:1), borderColor: UIColor.init(red:91/255,green:91/255,blue: 95/255,alpha:1), iconColor: UIColor.init(red:238/255,green:238/255,blue: 238/255,alpha:1), labelColor: UIColor.init(red:212/255,green:212/255,blue: 213/255,alpha:1),selectedColor:.yellow, sliderThumbColor: UIColor.init(red:254/255,green:254/255,blue: 254/255,alpha:1),sliderMinTrackColor: UIColor.init(red:254/255,green:254/255,blue: 254/255,alpha:1), sliderMaxTrackColor: UIColor.init(red:103/255,green:103/255,blue: 106/255,alpha:1)))
        // Theme 3 - Black
        self.themes.add(SkyEpubTheme(themeName: "Black",textColor: UIColor.init(red:175/255,green:175/255,blue: 175/255,alpha:1), backgroundColor: .black, boxColor: UIColor.init(red:44/255,green:44/255,blue: 46/255,alpha:1), borderColor: UIColor.init(red:90/255,green:90/255,blue: 92/255,alpha:1), iconColor: UIColor.init(red:241/255,green:241/255,blue: 241/255,alpha:1), labelColor: UIColor.init(red:169/255,green:169/255,blue: 169/255,alpha:1),selectedColor:.white, sliderThumbColor: UIColor.init(red:169/255,green:169/255,blue: 169/255,alpha:1),sliderMinTrackColor: UIColor.init(red:169/255,green:169/255,blue: 169/255,alpha:1), sliderMaxTrackColor: UIColor.init(red:42/255,green:42/255,blue: 44/255,alpha:1)))
    }
    
    func applyThemeToSearchTextFieldClearButton(theme: SkyEpubTheme) {
        if didApplyClearBox {
            return
        }
        for view in searchTextField.subviews {
            if view is UIButton {
                let button = view as! UIButton
                if let image = button.image(for: .highlighted) {
                    button.setImage(image.imageWithColor(color: .lightGray), for: .highlighted)
                    button.setImage(image.imageWithColor(color: .lightGray), for: .normal)
                    didApplyClearBox = true
                }
                if let image = button.image(for: .normal) {
                    button.setImage(image.imageWithColor(color: .lightGray), for: .highlighted)
                    button.setImage(image.imageWithColor(color: .lightGray), for: .normal)
                    didApplyClearBox = true
                }
            }
        }
    }
    
    func applyThemeToListBox(theme: SkyEpubTheme) {
        listBox.backgroundColor = theme.backgroundColor
        
        listBoxTitleLabel.textColor = theme.textColor
        listBoxResumeButton.setTitleColor(theme.textColor, for: .normal)
        
        if #available(iOS 13.0, *) {
            listBoxSegmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)
            listBoxSegmentedControl.setTitleTextAttributes([.foregroundColor: theme.labelColor], for: .normal)
        } else {
            listBoxSegmentedControl.tintColor = UIColor.darkGray
        }
    }
    
    func applyThemeToSearchBox(theme: SkyEpubTheme) {
        searchBox.backgroundColor = theme.boxColor
        searchBox.layer.borderWidth = 1
        searchBox.layer.borderColor = theme.borderColor.cgColor
        
        searchTextField.backgroundColor = UIColor.clear
        searchTextField.layer.masksToBounds = true
        searchTextField.layer.borderWidth = 1
        searchTextField.layer.cornerRadius = 5
        searchTextField.layer.borderColor = theme.borderColor.cgColor
        searchTextField.textColor = theme.textColor
        searchTextField.addTarget(self, action: #selector(self.searchTextFieldDidChange(_:)), for: .editingChanged)
        
        searchCancelButton.setTitleColor(theme.textColor, for: .normal)
        applyThemeToSearchTextFieldClearButton(theme: theme)
        
        let resultViews = searchScrollView.subviews.filter{$0 is SkyEpubSearchResultView}
        for i in 0..<resultViews.count {
            let resultView: SkyEpubSearchResultView = resultViews[i] as! SkyEpubSearchResultView
            resultView.headerLabel.textColor = theme.textColor
            resultView.contentLabel.textColor = theme.textColor
            resultView.bottomLine.backgroundColor = theme.borderColor
            resultView.bottomLine.alpha = 0.65
        }
    }
    
    func focusSelectedThemeButton() {
        theme0Button.layer.borderWidth = 1
        theme1Button.layer.borderWidth = 1
        theme2Button.layer.borderWidth = 1
        theme3Button.layer.borderWidth = 1
        
        switch currentThemeIndex {
        case 0: theme0Button.layer.borderWidth = 3
        case 1: theme1Button.layer.borderWidth = 3
        case 2: theme2Button.layer.borderWidth = 3
        case 3: theme3Button.layer.borderWidth = 3
        default:
            theme0Button.layer.borderWidth = 3
        }
        
        currentTheme = themes.object(at: currentThemeIndex) as! SkyEpubTheme
    }
    
    func applyCurrentTheme() {
        self.focusSelectedThemeButton()
        self.applyTheme(theme: currentTheme)
    }
    
    func applyTheme(theme: SkyEpubTheme) {
        applyThemeToBookViewer(theme: theme)
        applyThemeToFontBox(theme: theme)
        applyThemeToListBox(theme: theme)
        applyThemeToSearchBox(theme: theme)
        applyThemeToMediaBox(theme: theme)
    }
    
    func applyThemeToBookViewer(theme: SkyEpubTheme) {
        homeButton.tintColor = theme.iconColor
        listButton.tintColor = theme.iconColor
        searchButton.tintColor = theme.iconColor
        fontButton.tintColor = theme.iconColor
        bookmarkButton.tintColor = theme.iconColor
        
        titleLabel.textColor = theme.labelColor
        pageIndexLabel.textColor = theme.labelColor
        leftIndexLabel.textColor = theme.labelColor
        rightIndexLabel.textColor = theme.labelColor
        
        self.slider.setThumbImage(self.thumbImage(), for: .normal)
        self.slider.setThumbImage(self.thumbImage(), for: .highlighted)
        slider.minimumTrackTintColor = theme.sliderMinTrackColor
        slider.maximumTrackTintColor = theme.sliderMaxTrackColor
        
        self.view.backgroundColor = theme.backgroundColor
        rv.changeBackgroundColor(theme.backgroundColor)
        if theme.textColor == .black {
            rv.changeForegroundColor(nil)       // to set foreground color to nil will restore original book style color.
        } else {
            rv.changeForegroundColor(theme.textColor)
        }
    }
    
    func applyThemeToFontBox(theme: SkyEpubTheme) {
        fontBox.backgroundColor = theme.boxColor
        fontBox.layer.borderColor = theme.borderColor.cgColor
        
        brightnessSlider.thumbTintColor = UIColor.init(red: 250/255, green: 250/255, blue: 250/255, alpha: 1)
        brightnessSlider.minimumTrackTintColor = theme.sliderMinTrackColor
        brightnessSlider.maximumTrackTintColor = theme.sliderMaxTrackColor
        
        decreaseBrightnessIcon.tintColor = theme.iconColor
        increaseBrightnessIcon.tintColor = theme.iconColor
        
        increaseFontSizeButton.layer.borderColor = theme.borderColor.cgColor
        decreaseFontSizeButton.layer.borderColor = theme.borderColor.cgColor
        increaseFontSizeButton.tintColor = theme.iconColor
        decreaseFontSizeButton.tintColor = theme.iconColor
        
        increaseLineSpacingButton.layer.borderColor = theme.borderColor.cgColor
        increaseLineSpacingButton.tintColor = theme.iconColor
        decreaseLineSpacingButton.layer.borderColor = theme.borderColor.cgColor
        decreaseLineSpacingButton.tintColor = theme.iconColor
        
        fontScrollView.layer.borderColor = theme.borderColor.cgColor
        
        focusSelectedFont()
    }
    
    func applyThemeToMediaBox(theme: SkyEpubTheme) {
        prevButton.tintColor = theme.iconColor
        playButton.tintColor = theme.iconColor
        stopButton.tintColor = theme.iconColor
        nextButton.tintColor = theme.iconColor
    }
    
}
