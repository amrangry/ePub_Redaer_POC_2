//
//  SkyBookReaderViewController+listBox.swift
//  BookStore
//
//  Created by Amr Elghadban on 13/11/2022.
//  Copyright © 2022 ADKA Tech. All rights reserved.
//

import UIKit

// MARK: - SkyBookReaderViewController+listBox
extension SkyBookReaderViewController {
    
    @IBAction func listPressed(_ sender: Any) {
        self.showListBox()
    }
    
    // listBox
    @IBAction func listBoxSegmentedControlChanged(_ sender: UISegmentedControl) {
        print(listBoxSegmentedControl.selectedSegmentIndex)
        self.showTableView(index: listBoxSegmentedControl.selectedSegmentIndex)
    }
    
    @IBAction func listBoxResumePressed(_ sender: Any) {
        self.hideListBox()
    }
    
    func showListBox() {
        showBaseView()
        isRotationLocked = true
        var sx, sy, sw, sh: CGFloat
        listBox.layer.borderColor = UIColor.clear.cgColor
        sx = view.safeAreaInsets.left * 0.4
        sy = view.safeAreaInsets.top
        sw = self.view.bounds.size.width-(view.safeAreaInsets.left+view.safeAreaInsets.right) * 0.4
        sh = self.view.bounds.size.height-(view.safeAreaInsets.top+view.safeAreaInsets.bottom)
        
        listBox.frame = CGRect(x: sx, y: sy, width: sw, height: sh)
        
        listBoxTitleLabel.text = rv.title
        
        reloadContents()
        reloadHighlights()
        reloadBookmarks()
        
        showTableView(index: listBoxSegmentedControl.selectedSegmentIndex)
        
        view.addSubview(listBox)
        applyThemeToListBox(theme: currentTheme)
        listBox.isHidden = false
    }
    
    func hideListBox() {
        if listBox.isHidden {
            return
        }
        listBox.isHidden = true
        listBox.removeFromSuperview()   // this line causes the constraint issues.
        isRotationLocked = setting.lockRotation
        hideBaseView()
    }
}
