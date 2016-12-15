//
//  FilepilePopupView.swift
//  DropdownFilemenu
//
//  Created by Christian Schraga on 12/15/16.
//  Copyright © 2016 Straight Edge Digital. All rights reserved.
//

import UIKit

protocol FilepilePopupViewOutlineDelegate {
    func popupOutlineClicked(view: FilepilePopupViewOutline, isVisible: Bool)
}

class FilepilePopupViewOutline: UIView {
    var buttonTint  = UIColor(red: 108/255, green: 135/255, blue: 153/255, alpha: 1.0)
    var bgColor = UIColor(red: 239/255, green: 248/255, blue: 255/255, alpha: 0.87)
    var buttonImage: UIImage? {
        get{
            return button.image(for: .normal)
        }
        set(newVal){
            button.setImage(newVal, for: .normal)
        }
    }
    var button: UIButton!
    var delegate: FilepilePopupViewOutlineDelegate?
    fileprivate var _buttonFrame = CGRect.zero
    var buttonFrame: CGRect {
        get{
            return _buttonFrame
        }
        set(newVal){
            let redraw = newVal != _buttonFrame
            if redraw {
                _buttonFrame = newVal
                setNeedsDisplay()
            }
        }
    }
    var isVisible: Bool {
        get{
            return self.alpha > 0.0
        }
        set(newVal){
            self.alpha = newVal ? 1.0 : 0.0
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    init(){
        super.init(frame: CGRect.zero)
        setup()
    }
    
    func setup(){
        self.backgroundColor = UIColor.clear
        self.button = UIButton(type: .custom)
        self.button.setImage(UIImage(named: "filepileGrey"), for: .normal)
        self.button.addTarget(self, action: #selector(toggleMe), for: .touchUpInside)
        self.button.backgroundColor = UIColor.clear
        self.button.tintColor = buttonTint
        self.addSubview(self.button)
        placeButton()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        placeButton()
    }
    
    fileprivate func placeButton(){
        let inset = CGFloat(0.0)
        let x = inset
        let y = inset
        let w = buttonFrame.width  - 2.0*inset
        let h = buttonFrame.height - 2.0*inset
        button.frame = CGRect(x: x, y: y, width: w, height: h)
    }
    
    func toggleMe(){
        delegate?.popupOutlineClicked(view: self, isVisible: isVisible)
    }
    
    
    override func draw(_ rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.setStrokeColor(UIColor.clear.cgColor)
        ctx?.setFillColor(bgColor.cgColor)
        
        //let patha = UIBezierPath(roundedRect: rect, cornerRadius: 5.0)
        let rad = CGFloat(5.0)
        //outline path has 10 points. 5xs and 5ys
        let x0 = rect.minX
        let x1 = rect.minX + rad
        let x5 = rect.maxX
        let x4 = rect.maxX - rad
        let x3 = rect.minX + _buttonFrame.size.width
        let x2 = rect.minX + _buttonFrame.size.width - rad
        let y0 = rect.minY
        let y1 = rect.minY + rad
        let y2 = rect.minY + _buttonFrame.size.height
        let y3 = rect.minY + _buttonFrame.size.height + rad
        let y4 = rect.maxY - rad
        let y5 = rect.maxY
        
        //four corner angles
        let a0 = CGFloat(M_PI)
        let a1 = CGFloat(M_PI * 1.5)
        let a2 = CGFloat(0.0)
        let a3 = CGFloat(M_PI/2)
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: x0, y: y1))
        path.addArc(withCenter: CGPoint(x: x1, y: y1), radius: rad, startAngle: a0, endAngle: a1, clockwise: true)
        path.addLine(to: CGPoint(x: x2, y: y0))
        path.addArc(withCenter: CGPoint(x: x2, y: y1), radius: rad, startAngle: a1, endAngle: a2, clockwise: true)
        path.addLine(to: CGPoint(x: x3, y: y2))
        path.addLine(to: CGPoint(x: x4, y: y2))
        path.addArc(withCenter: CGPoint(x: x4, y: y3), radius: rad, startAngle: a1, endAngle: a2, clockwise: true)
        path.addLine(to: CGPoint(x: x5, y: y4))
        path.addArc(withCenter: CGPoint(x: x4, y: y4), radius: rad, startAngle: a2, endAngle: a3, clockwise: true)
        path.addLine(to: CGPoint(x: x1, y: y5))
        path.addArc(withCenter: CGPoint(x: x1, y: y4), radius: rad, startAngle: a3, endAngle: a0, clockwise: true)
        path.addLine(to: CGPoint(x: x0, y: y1))
        path.close()
        path.fill()
        
    }
    

}
