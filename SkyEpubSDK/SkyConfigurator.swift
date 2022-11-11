//
//  SkyConfigurator.swift
//  EpubBookReader
//
//  Created by Amr Elghadban on 11/11/2022.
//

import Foundation

class SkyConfigurator {
    static let shared = SkyConfigurator()
    
    var data: SkyData!
    
    private init() {
        
    }
    
    func configureSkyEpubData() {
        self.data = SkyData()
    }
    
}
