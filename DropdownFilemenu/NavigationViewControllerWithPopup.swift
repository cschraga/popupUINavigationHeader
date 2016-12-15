//
//  NavigationViewControllerWithPopup.swift
//  DropdownFilemenu
//
//  Created by Christian Schraga on 12/15/16.
//  Copyright © 2016 Straight Edge Digital. All rights reserved.
//

import UIKit

protocol NavigationPopupDatasource {
    func navPopupItemCount(source: NavigationViewControllerWithPopup) -> Int
    func navPopupItemTitleAtIndex(source: NavigationViewControllerWithPopup, index: Int) -> String
}

protocol NavigationPopupDelegate {
    
    func navPopupSelectedAtIndex(source: NavigationViewControllerWithPopup, index: Int)
    func navPopupDeletedAtIndex(source: NavigationViewControllerWithPopup,index: Int)
    
}

class NavigationViewControllerWithPopup: UINavigationController, UITableViewDelegate, UITableViewDataSource, FilepilePopupViewOutlineDelegate  {

    //positioning.  user can control width and height below navbar. System calculates relative position of button
    
    var popupButtonFrame: CGRect?{
        get{
            var result: CGRect? = nil
            if _popupAddedYet {
                result = CGRect.zero //make sure to return result now
                if let originView = popupButton.value(forKey: "view"), let recast = originView as? UIView{
                    result = recast.frame
                    result = self.view.convert(recast.frame, from: navigationBar)
                }
            }
            return result
        }
    }
    fileprivate var popupFrame = CGRect.zero
    //fileprivate var buttonFrame = CGRect.zero
    
    //appearance
    var popupButtonImage = UIImage(named: "filepileGrey")
    var popupBackgroundColor = UIColor.lightGray
    var popupTitle  = "Active Files"
    //var titleFont = UIFont(name: "OpenSans-Semibold", size: 14.0)
    //var itemFont  = UIFont(name: "OpenSans", size: 14.0)
    var titleFont   = UIFont.boldSystemFont(ofSize: 16.0)
    var itemFont    = UIFont.systemFont(ofSize: 16.0)
    var textColor   = UIColor(red: 14/255, green: 62/255, blue: 104/255, alpha: 1.0)
    var buttonTint  = UIColor(red: 108/255, green: 135/255, blue: 153/255, alpha: 1.0)
    
    //flags
    fileprivate var _popupVisible = false  //dont access directly use switchVisibility()
    fileprivate var _popupAddedYet = false //keeps track of whether addPopupButton fired yet.
    var isPopupVisible: Bool {
        get{
            return _popupVisible
        }
    }
    
    //ui elements
    fileprivate var popupButton: UIBarButtonItem!
    fileprivate var outline: FilepilePopupViewOutline!
    fileprivate var tableView: UITableView!
    
    //delegates
    var dataSource: NavigationPopupDatasource?
    var popupDelegate: NavigationPopupDelegate?
    
    //constants
    let kReuseIdentifier = "popupCell"
    
    //LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //make nav bar pretty (delete this before implementing)
        navigationBar.setBackgroundImage(UIImage(named: "headerBG"), for: UIBarMetrics.default)
        navigationBar.isTranslucent = true
        navigationBar.layer.shadowOpacity = 0.4
        navigationBar.layer.shadowOffset  = CGSize(width: 1, height: 2)
        navigationBar.layer.shadowRadius  = 4
        navigationBar.barTintColor  = UIColor(red: 108/255, green: 135/255, blue: 153/255, alpha: 1.0)
        var attributes = [String : Any]()
        attributes[NSForegroundColorAttributeName] = UIColor(red: 108/255, green: 135/255, blue: 153/255, alpha: 1.0)
        navigationBar.titleTextAttributes = attributes
        
        popupButton = UIBarButtonItem(image: popupButtonImage, style: .plain, target: self, action: #selector(NavigationViewControllerWithPopup.popupButtonPressed(sender:)))
        
        outline     = FilepilePopupViewOutline()
        outline.delegate = self
        
        tableView   = UITableView(frame: CGRect.zero, style: .grouped)
        tableView.backgroundColor = UIColor.clear
        tableView.separatorStyle  = .none
        tableView.delegate   = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: kReuseIdentifier)
        tableView.showsVerticalScrollIndicator   = false
        tableView.showsHorizontalScrollIndicator = false
        switchVisibility(on: false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sizePopupStuff()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //PUBLIC METHODS
    
    //activate the popup
    func addPopupButton(viewController: UIViewController, dataSource: NavigationPopupDatasource, delegate: NavigationPopupDelegate, buttonImage: UIImage?){
        if buttonImage != nil {
            popupButtonImage    = buttonImage!
            outline.buttonImage = buttonImage!
        }
        var items = viewController.navigationItem.leftBarButtonItems ?? [UIBarButtonItem]()
        if items.contains(popupButton!){
            print("no need to add button cause its already there")
        } else {
            if !_popupAddedYet {
                _popupAddedYet = true
                items.append(popupButton)
                viewController.navigationItem.setLeftBarButtonItems(items, animated: true)
                self.view.addSubview(outline)
                self.view.addSubview(tableView)
                self.popupDelegate = delegate
                self.dataSource    = dataSource
                sizePopupStuff()
                
            } else{
                print("stopped you from adding the popup twice")
            }
            
        }
    }
    
    
    //SELECTORS
    func popupButtonPressed(sender: UIBarButtonItem){
        print("popup pressed")
        switchVisibility(on: !self.isPopupVisible)
        sizePopupStuff()
    }
    
    
    //INTERNAL HELPERS
    fileprivate func switchVisibility(on: Bool){
        _popupVisible = on
        outline.isVisible = on
        popupButton.isEnabled = !on
        popupButton.tintColor = on ? UIColor.clear : buttonTint
        tableView.alpha = on ? 1.0 : 0.0
    }
    
    fileprivate func sizePopupStuff(){
        let widthPct = CGFloat(0.5)
        let heightPct = CGFloat(4.0)
        let popupHeight = popupButtonFrame != nil ? popupButtonFrame!.size.height : 0.0
        var h = self.navigationBar.frame.height * heightPct + popupHeight
        var w = self.view.frame.width  * widthPct
        var x = popupButtonFrame != nil ? popupButtonFrame!.origin.x : 20.0
        var y = popupButtonFrame != nil ? popupButtonFrame!.origin.y : 20.0
        popupFrame = CGRect(x: x, y: y, width: w, height: h)
        outline.frame = popupFrame
        
        //add extra height to button so it matches the header height
        var adjFrame = self.popupButtonFrame ?? CGRect.zero
        let extraY = abs(adjFrame.maxY - navigationBar.bounds.maxY)
        adjFrame.size.height = adjFrame.size.height + extraY
        outline.buttonFrame = adjFrame
        
        //add table
        let inset = CGFloat(10.0)
        y += popupHeight + inset + extraY
        x += inset
        w -= 2.0*inset
        h  = popupFrame.maxY - y
        let tableFrame = CGRect(x: x, y: y, width: w, height: h)
        tableView.frame = tableFrame
        
        
    }
    
    //OUTLINE DELEGATE 
    func popupOutlineClicked(view: FilepilePopupViewOutline, isVisible: Bool){
        switchVisibility(on: !isVisible)
    }
    
    //TABLE VIEW DELEGATE
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        popupDelegate?.navPopupSelectedAtIndex(source: self, index: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete){
            popupDelegate?.navPopupDeletedAtIndex(source: self, index: indexPath.row)
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    //TABLE VIEW DATASOURCE
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource != nil ? dataSource!.navPopupItemCount(source: self) : 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        let label = UILabel(frame: view.bounds)
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(label)
        label.backgroundColor = UIColor.clear
        label.font = titleFont
        label.textColor = self.textColor
        label.text = self.popupTitle
        label.textAlignment = .left
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let result = UIView(frame: CGRect.zero)
        result.backgroundColor = UIColor.clear
        return result
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kReuseIdentifier, for: indexPath)
        cell.backgroundColor = UIColor.clear
        
        let label = UILabel(frame: cell.contentView.bounds)
        cell.contentView.addSubview(label)
        label.textAlignment = .left
        label.textColor = self.textColor
        label.font = itemFont
        label.text = dataSource != nil ? dataSource!.navPopupItemTitleAtIndex(source: self, index: indexPath.row) : "No Title"
        label.preservesSuperviewLayoutMargins = true
        
        /*
        cell.textLabel?.textColor = self.textColor
        cell.textLabel?.font = itemFont
        cell.textLabel?.text = dataSource != nil ? dataSource!.navPopupItemTitleAtIndex(source: self, index: indexPath.row) : "No Title"
        cell.textLabel?.textAlignment = .left
        cell.textLabel?.preservesSuperviewLayoutMargins = true
        */
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30.0
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
