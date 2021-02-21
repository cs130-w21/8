//
//  CustomListView.swift
//  Dots
//
//  Created by Jack Zhao on 2/1/21.
//

import SwiftUI

struct CustomEntryRowView: View {
    let content: EntryObject
    let deleteAction: () -> ()
    @Binding var editMode: Bool
    
    let width: CGFloat = 60
    let rowHeight: CGFloat = 100
    let buttonActiveThreshold: CGFloat = 35
    @State var draggingOffset: CGSize = .zero
    @State var previousOffset: CGSize = .zero
    @State var opacity: Double = 0
    @State var beingDeleted: Bool = false
    @State var releaseToDelete: Bool = false
    
    var body: some View {
        GeometryReader { geo in
            HStack (spacing: 9){
                EntryItemView(entryInfo: self.content)
                    .frame(width: geo.size.width, height: self.rowHeight, alignment: .leading)
                    .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .contextMenu(ContextMenu(menuItems: {
                        Button(action: {
                            withAnimation {
                                // TODO: Bug, no shrink animation here
                                self.beingDeleted = true
                                DispatchQueue.main.asyncAfter(deadline: .now()+0.3, execute: deleteAction)
                            }
                        }, label: {
                            Label("Remove", systemImage: "xmark.circle")
                        })
                    }))
                    
                
                Button (action: {
                    withAnimation {
                        self.beingDeleted = true
                        DispatchQueue.main.asyncAfter(deadline: .now()+0.3, execute: deleteAction)
                    }
                    haptic_one_click()
                }) {
                    ZStack {
                        Image(systemName: "trash")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    }
                    .frame(width: self.editMode ?  self.width : (self.draggingOffset.width<0 ? -self.draggingOffset.width : 0), height: self.rowHeight)
                    .background(Color.red)
                    .clipShape(RoundedRectangle(cornerRadius: 15.0))
                    .opacity(self.editMode ?  1 : self.draggingOffset.width < -0.5 * (self.width) ? -Double(self.draggingOffset.width)/Double(self.width)
                                : 0)
                }
            }
            .frame(maxHeight: self.rowHeight)
            .offset(x: self.editMode ?  -self.width : self.draggingOffset.width, y: 0)
            .animation(.spring())
            .gesture(DragGesture()
                        .onChanged { gesture in
                            // Add translation to current draggin offset
                            self.draggingOffset.width = gesture.translation.width + previousOffset.width
                            
                        }
                        .onEnded { _ in
                            if self.draggingOffset.width < -buttonActiveThreshold {
                                self.draggingOffset.width = -(self.width + 5)
                                self.previousOffset.width = self.draggingOffset.width
                            } else {
                                self.draggingOffset = .zero
                                self.previousOffset = .zero
                            }
                        })
            .onTapGesture {
                self.draggingOffset = .zero
                self.previousOffset = .zero
            }
        }
        .scaleEffect(x: 1, y: self.beingDeleted ? 0 : 1)
        .animation(.spring(response: 0.3, dampingFraction: 0.9, blendDuration: 0.1))
        .frame(height: self.rowHeight)
    }
    
    func edit() {
        withAnimation {
            if editMode {
                self.draggingOffset.width = -(self.width + 5)
                self.previousOffset.width = self.draggingOffset.width
            } else {
                self.draggingOffset = .zero
                self.previousOffset = .zero
            }
        }
    }
}
struct CustomListView: View {
    @Binding var tmp: [EntryObject]
    @State var triggerEdit: Bool = false
    var body: some View {
//        GeometryReader { geo in
            ScrollView {
                LazyVStack(spacing: 16) {
                    HStack {
                        Spacer()
                        Button(action: { self.triggerEdit.toggle() }) {
                        RoundedRectangle(cornerRadius: 20)
                            .frame(width: 60, height: 30, alignment: .center)
                            .foregroundColor(Color(UIColor.systemGray4))
                            .overlay(Text(self.triggerEdit ? "Done" : "Edit")
                                        .foregroundColor(.primary)
                                        .fontWeight(.semibold))
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom,  5)
                    ForEachWithIndex(self.tmp) { index, entry in
                        CustomEntryRowView(content: entry, deleteAction: {
                            self.tmp.remove(at: index)
                        }, editMode: self.$triggerEdit)
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.top, 25)
            .edgesIgnoringSafeArea(.bottom)
//        }.background(Color.gray)
        
    }
}

struct CustomListView_Previews: PreviewProvider {
    static var previews: some View {
        CustomListView(tmp: .constant(BillObject.sample[0].entries))
            .previewDevice(.init(stringLiteral: "iPhone 12"))
    }
}
