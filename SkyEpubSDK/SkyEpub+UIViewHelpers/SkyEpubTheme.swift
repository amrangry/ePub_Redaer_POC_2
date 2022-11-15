//
//  SkyEpubTheme.swift
//  EpubBookReader
//
//  Created by Amr Elghadban on 05/11/2022.
//

import UIKit

class SkyEpubTheme {
    var textColor:UIColor = .black
    var labelColor:UIColor = .darkGray
    var backgroundColor:UIColor = .white
    var boxColor:UIColor = .white
    var borderColor:UIColor = .lightGray
    var iconColor:UIColor = .lightGray
    var selectedColor:UIColor = .blue
    var themeName:String = ""
    
    var sliderMinTrackColor:UIColor = .lightGray
    var sliderMaxTrackColor:UIColor = .lightGray
    var sliderThumbColor:UIColor = .lightGray
    
    init() {
        
    }
    
    init(themeName:String,textColor:UIColor, backgroundColor:UIColor, boxColor:UIColor, borderColor:UIColor, iconColor:UIColor,labelColor:UIColor,selectedColor:UIColor,sliderThumbColor:UIColor,sliderMinTrackColor:UIColor,sliderMaxTrackColor:UIColor) {
        self.textColor = textColor
        self.backgroundColor = backgroundColor
        self.boxColor = boxColor
        self.borderColor = borderColor
        self.iconColor = iconColor
        self.labelColor = labelColor
        self.sliderThumbColor = sliderThumbColor
        self.sliderMinTrackColor = sliderMinTrackColor
        self.sliderMaxTrackColor = sliderMaxTrackColor
        self.selectedColor = selectedColor
    }
}
