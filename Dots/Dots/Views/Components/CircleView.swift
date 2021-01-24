//
//  CircleView.swift
//  Dots
//
//  Created by Jack Zhao on 1/11/21.
//

import SwiftUI

struct CircleView: View {
    let index: Int
    let diameter: Double
    let hasRing: Bool
    private let radius: CGFloat
    private let ringStroke: Double
    init (index: Int = 0, diameter: Double = 30, hasRing: Bool = false, ringStroke: Double = 8) {
        self.index = index
        self.diameter = diameter
        self.hasRing = hasRing
        self.ringStroke = ringStroke
        self.radius = self.hasRing ? CGFloat(diameter - self.ringStroke) : CGFloat(diameter)
    }
    var body: some View {
        ZStack {
            if (self.hasRing) {
                Circle()
                    .foregroundColor(.white)
                    .frame(width: CGFloat(self.diameter), height: CGFloat(self.diameter))
            }
            Circle()
                .foregroundColor(dotColors[index])
                .frame(width: self.radius, height: self.radius)
        }
    }
}


struct CircleView_Previews: PreviewProvider {
    static var previews: some View {
        CircleView(index: 1, diameter: 30, hasRing: false, ringStroke: 8)
            .preferredColorScheme(.dark)
            .previewLayout(.sizeThatFits)
    }
}