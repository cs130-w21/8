//
//  BlurView.swift
//  Dots
//
//  Created by Jack Zhao on 1/22/21.
//

import SwiftUI

struct BlurView: View {
    @Environment(\.colorScheme) var scheme

    var active: Bool
    var onTap: () -> ()

    var body: some View {
        if active {
            VisualEffectView(uiVisualEffect: UIBlurEffect(style: scheme == .dark ? .dark : .light))
                .edgesIgnoringSafeArea(.all)
                .onTapGesture(perform: self.onTap)
        }
    }
}

struct BlurView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Text("Test Text")
                .font(.title)
            BlurView(active: true, onTap: {})
            
        }
    }
}
