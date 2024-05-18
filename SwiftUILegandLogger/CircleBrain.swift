//
//  CircleBrain.swift
//  SwiftUILegandLogger
//
//  Created by Laura Hart on 5/15/24.
//

import Foundation
import CoreGraphics
import UIKit


class CircleBrain {
    static let shared = CircleBrain()
    
    func getCircleXCoords(circleLocation: CGPoint) -> CGFloat {
        return circleLocation.x
    }
    
    func getCircleYCoords(circleLocation: CGPoint) -> CGFloat {
        return circleLocation.y
    }
    
    func getRGB(circleColor: UIColor) -> (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        return circleColor.components
    }
}

extension UIColor {
    var coreImageColor: CIColor {
           return CIColor(color: self)
        }
    
    var components: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        let coreImageColor = self.coreImageColor
        
        return (coreImageColor.red, coreImageColor.green, coreImageColor.blue, coreImageColor.alpha)
    }
}

