//
//  ViewController.swift
//  EpubBookReader
//
//  Created by Amr Elghadban on 17/09/2022.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func openArabicBook(_ sender: Any) {
        print("Arabic")
        let name = "Arabic_Book"
        open(book: name)
    }
    
    @IBAction func openEnglishBook(_ sender: Any) {
        print("English")
        let name = "English_Book"
        open(book: name)
    }
    
    func open(book name: String) {
        let storyBoard = UIStoryboard(name: "Main", bundle: .main)
        guard let vc = storyBoard.instantiateViewController(identifier: "LibraryListViewController") as? LibraryListViewController else { return }
        vc.bookName = name
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

