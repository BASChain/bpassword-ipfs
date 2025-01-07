//
//  RoundedCornersShape.swift
//  oneLock
//
//  Created by wesley on 2025/1/7.
//
import SwiftUI

struct RoundedCornersShape: Shape {
        var corners: UIRectCorner
        var radius: CGFloat
        
        func path(in rect: CGRect) -> Path {
                let path = UIBezierPath(
                        roundedRect: rect,
                        byRoundingCorners: corners,
                        cornerRadii: CGSize(width: radius, height: radius)
                )
                return Path(path.cgPath)
        }
}
