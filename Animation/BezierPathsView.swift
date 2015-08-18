//
//  BezierPathsView.swift
//  Animation
//
//  Created by Mac Bellingrath on 8/18/15.
//  Copyright © 2015 Mac Bellingrath. All rights reserved.
//

import UIKit

class BezierPathsView: UIView {
    
    private var bezierPaths = [String:UIBezierPath]()
    
    
    func setPath(path: UIBezierPath?, named: String) {
        bezierPaths[named] = path
        setNeedsDisplay()
    }

    override func drawRect(rect: CGRect) {
            for (_, path) in bezierPaths {
                path.stroke()
        }
    }

}
