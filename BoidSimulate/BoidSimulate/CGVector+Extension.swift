//
//  CGVector+Extension.swift
//  BoidSimulate
//
//  Created by Avinash P on 4/10/22.
//

import Foundation

extension CGVector {
    var length: CGFloat {
        return sqrt(dx * dx + dy * dy)
    }
    
    var normalized: CGVector {
        return (length > 0) ? self / length : .zero
    }
    
    static func + (lhs: Self, rhs: Self) -> Self {
        return CGVector(dx: lhs.dx + rhs.dx, dy: lhs.dy + rhs.dy)
    }
    
    static func - (lhs: Self, rhs: Self) -> Self {
        return CGVector(dx: lhs.dx - rhs.dx, dy: lhs.dy - rhs.dy)
    }
    
    static func / (lhs: Self, rhs: Self) -> Self {
        return CGVector(dx: lhs.dx / rhs.dx, dy: lhs.dy / rhs.dy)
    }
    
    static func / (lhs: Self, rhs: CGFloat) -> Self {
        return CGVector(dx: lhs.dx / rhs, dy: lhs.dy / rhs)
    }
    
    func speed() -> CGFloat {
        return length
    }
    
    func angle() -> CGFloat {
        return atan2(dy, dx)
    }
}
