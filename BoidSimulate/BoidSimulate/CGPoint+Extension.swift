//
//  CGPoint+Extension.swift
//  BoidSimulate
//
//  Created by Avinash P on 4/10/22.
//

import Foundation

extension CGPoint {
    func distance(point: CGPoint) -> CGFloat {
        let distanceRadius = (point.x - x) * (point.x - x) + (point.y - y) * (point.y - y)
        return distanceRadius
    }
}
