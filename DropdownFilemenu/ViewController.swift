//
//  ViewController.swift
//  DropdownFilemenu
//
//  Created by Christian Schraga on 12/15/16.
//  Copyright © 2016 Straight Edge Digital. All rights reserved.
//

import UIKit

class ViewController: UIViewController, NavigationPopupDatasource, NavigationPopupDelegate {

    var testItems = ["Aemon Targaeryan", "Robert Boratheon", "Geoffrey Lannister", "Tommen Lannister"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let nav = navigationController, let nwp = nav as? NavigationViewControllerWithPopup {
            nwp.addPopupButton(viewController: self, dataSource: self, delegate: self, buttonImage: nil)
        }
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func navPopupItemCount(source: NavigationViewControllerWithPopup) -> Int {
        return testItems.count
    }
    
    func navPopupItemTitleAtIndex(source: NavigationViewControllerWithPopup, index: Int) -> String{
        var result = ""
        if index < testItems.count{
            result = testItems[index]
        }
        return result
    }
    
    func navPopupSelectedAtIndex(source: NavigationViewControllerWithPopup, index: Int) {
        var name = ""
        if index < testItems.count{
            name = testItems[index]
        }
        print("item number \(index) selected name:\(name)")
    }
    
    func navPopupDeletedAtIndex(source: NavigationViewControllerWithPopup,index: Int) {
         if index < testItems.count{
            testItems.remove(at: index)
        }
    }
}

