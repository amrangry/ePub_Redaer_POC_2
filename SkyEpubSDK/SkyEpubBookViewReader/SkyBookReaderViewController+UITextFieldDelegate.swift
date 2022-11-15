//
//  SkyBookReaderViewController+UITextFieldDelegate.swift
//  BookStore
//
//  Created by Amr Elghadban on 13/11/2022.
//  Copyright © 2022 ADKA Tech. All rights reserved.
//

import UIKit

// MARK: - SkyBookReaderViewController+UITextFieldDelegate
extension SkyBookReaderViewController: UITextFieldDelegate {
    // Saerch Routine ======================================================================================
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
        let searchKey = searchTextField.text
        hideSearchBox()
        showSearchBox(isCollapsed: false)
        self.startSearch(key: searchKey)
        searchTextField.resignFirstResponder()
        return true
    }
    
    func clearSearchResults() {
        searchScrollHeight = 0
        searchResults.removeAllObjects()
        for sv in searchScrollView.subviews {
            sv.removeFromSuperview()
        }
        searchScrollView.contentSize.height = 0
    }
    
    func startSearch(key:String!)  {
        lastNumberOfSearched = 0
        
        self.clearSearchResults()
        rv.searchKey(key)
    }
    
    func searchMore() {
        rv.searchMore()
        rv.isSearching = true
    }
    
    func stopSearch() {
        rv.stopSearch()
    }
    
    func showSearchBox(isCollapsed:Bool) {
        showBaseView()
        var searchText:String!
        searchText = searchTextField.text
        
        searchTextField.leftViewMode = .always
        
        let imageView = UIImageView()
        let image = UIImage(named: "magnifier")
        imageView.image = image
        searchTextField.leftView = imageView
        
        searchBox.layer.borderWidth = 1
        searchBox.layer.cornerRadius = 10
        isRotationLocked = true
        
        var sx,sy,sw,sh:CGFloat
        let rightMargin:CGFloat = 50.0
        let topMargin:CGFloat = 60.0 + view.safeAreaInsets.top
        let bottomMargin:CGFloat = 50.0 + view.safeAreaInsets.bottom
        
        
        if isCollapsed {
            if (searchText ?? "").isEmpty {
                self.clearSearchResults()
                searchTextField.becomeFirstResponder()
            }
        }
        
        if self.isPad() {
            searchBox.layer.borderColor = UIColor.lightGray.cgColor
            sx = self.view.bounds.size.width - searchBox.bounds.size.width - rightMargin
            sw = 400
            sy = topMargin
            if isCollapsed && (searchText ?? "").isEmpty  {
                searchScrollView.isHidden = true
                sh = 95
            } else {
                sh = self.view.bounds.size.height - (topMargin+bottomMargin)
                searchScrollView.isHidden = false
            }
        } else {
            searchBox.layer.borderColor = UIColor.clear.cgColor
            sx = 0
            sy = view.safeAreaInsets.top
            sw = self.view.bounds.size.width
            sh = self.view.bounds.size.height-(view.safeAreaInsets.top+view.safeAreaInsets.bottom)
        }
        
        searchBox.frame = CGRect(x:sx,y:sy,width:sw,height:sh)
        searchScrollView.frame = CGRect(x:30,y:100,width:searchBox.frame.size.width-55,height:searchBox.frame.height-(35+95))
        
        view.addSubview(searchBox)
        
        applyThemeToSearchBox(theme: currentTheme)
        searchBox.isHidden = false
    }
    
    func hideSearchBox() {
        if searchBox.isHidden {
            return
        }
        searchTextField.resignFirstResponder()
        searchBox.isHidden = true
        searchBox.removeFromSuperview()   // this line causes the constraint issues.
        isRotationLocked = setting.lockRotation
        hideBaseView()
    }
    
    @objc func searchTextFieldDidChange(_ textField: UITextField) {
        if !(searchTextField.text ?? "").isEmpty {
            applyThemeToSearchTextFieldClearButton(theme: currentTheme)
        }
    }
}
