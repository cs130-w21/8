//
//  TitleComponent.swift
//  Dots
//
//  Created by Jack Zhao on 1/24/21.
//

import SwiftUI

struct HomeNavbarView: View {
    var menuAction: () -> ()
    var addAction: () -> ()
    var body: some View {
        VStack (spacing: 20){
            HStack {
                Button(action: menuAction) {
                    Image(systemName: "list.bullet")
                        .font(.title2)
                }
                Spacer()
                Button(action: {}) {
                    Image(systemName: "plus")
                        .font(.title2)
                }
            }
            .padding(.top)
            HStack {
                Text("Active Bills")
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
            }
        }
        .padding(.horizontal, 25)
        .frame(maxHeight: 100)
    }
}

struct TitleComponent_Previews: PreviewProvider {
    static var previews: some View {
        HomeNavbarView(menuAction: {}, addAction: {})
    }
}
