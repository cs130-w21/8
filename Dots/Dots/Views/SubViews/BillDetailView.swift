//
//  BillDetailView.swift
//  Dots
//
//  Created by Jack Zhao on 1/24/21.
//

import SwiftUI



/// Displays the details of a bill
struct BillDetailView: View {
    /// the current bill chosen to display
    @Binding var chosenBill: BillObject
    var namespace: Namespace.ID
    let dismissBillDetail: () -> ()
    let animationDuration: Double
    let background: Color
    let topOffset: CGFloat

    @State var editingEntry: UUID? = nil
    @State var scrollOffset: CGFloat = .zero
    @State var selectedEntry: UUID? = nil
    @State var showEntryDetail: Bool = false
    
    @State var onRemoving: Bool = false
    @State var showEntries: Bool = false
    @State var showViewBackground: Bool = false
    @State var showBackground: Bool = false
    let pullToDismissDistance: CGFloat = 120.0
    
    struct ScrollOffsetPreferenceKey: PreferenceKey {
        typealias Value = [CGFloat]
        static var defaultValue: [CGFloat] = [0]
        static func reduce(value: inout [CGFloat], nextValue: () -> [CGFloat]) {
            value.append(contentsOf: nextValue())
        }
    }

    var body: some View {
        ZStack {
            BlurBackgroundView(style: .systemUltraThinMaterial)
                .opacity(self.showViewBackground ? 1 : 0)
                .onTapGesture {
                    tapToDismiss()
                }
            ZStack {
                background
                    .clipShape(RoundedRectangle(cornerRadius: 25.0, style: .continuous))
                    .scaleEffect(x: self.scrollOffset > 0 ? 1 - (self.scrollOffset/pullToDismissDistance)*0.1 : 1)
                    .shadow(radius: 10)
                    .opacity(self.showViewBackground ? Double((self.scrollOffset > 0 ? 1 - self.scrollOffset/self.pullToDismissDistance : 1)) : 0)
                    .animation(.linear(duration: self.scrollOffset > 0 ? 0.01 : 0.15))
                    .offset(x: 0, y: self.scrollOffset > 0 ? self.scrollOffset : 0)

                GeometryReader { outGeo in
                    ScrollView (.vertical, showsIndicators: false) {
                        VStack {
                            ZStack {
                                GeometryReader { innerProxy in
                                    Color.clear
                                        .preference(key: ScrollOffsetPreferenceKey.self, value: [self.getScrollViewOffset(outProxy: outGeo, innerProxy: innerProxy)])
                                }
                                GeometryReader { geo in
                                    HStack (spacing: 10) {
                                        CardItem(card: self.chosenBill)
                                            .frame(width: geo.size.width)
                                    }
                                }
                                .animation(.easeOut)
                                .matchedGeometryEffect(id: self.chosenBill.id, in: namespace)
                                .frame(height: 240)
                                //                                .onTapGesture {
                                //                                    tapToDismiss()
                                //                                }
                                if showEntries {
                                    VStack {
                                        HStack (alignment: .top) {
                                            Spacer()
                                            Button(action: tapToDismiss) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .font(.title)
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                        Spacer()
                                    }
                                    .padding(.top, topOffset > 0 ? 20 : 40)
                                    .padding(.horizontal)
                                    .animation(.easeOut)
                                }
                            }

//                            EntryListView(bill: self.$chosenBill, selectedEntry: self.$selectedEntry, show: self.$showEntry)
                            EntryListView(bill: self.$chosenBill, selectedEntry: self.$selectedEntry, showEntryDetail: self.$showEntryDetail, editingEntry: self.$editingEntry, taxRate: self.chosenBill.taxRate)
                                .opacity(self.showEntries ? Double((self.scrollOffset > 0 ? 1 - self.scrollOffset/self.pullToDismissDistance : 1)) : 0)
                                .animation(.easeOut(duration: animationDuration))
                        }
                        .scaleEffect(self.scrollOffset > 0 ? 1 - (self.scrollOffset/pullToDismissDistance)*0.1 : 1)
                    }
                    .onTapGesture {
                        withAnimation(.spring()) {
                            self.editingEntry = nil
                        }
                    }
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
                            withAnimation {
                                self.showViewBackground.toggle()
                                self.showBackground.toggle()
                            }
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration + 0.1) {
                            withAnimation {
                                self.showEntries.toggle()
                            }
                        }
                    }
                    .onDisappear {
                        withAnimation {
                            self.showBackground.toggle()
                            self.showViewBackground.toggle()
                            self.showEntries.toggle()
                        }
                    }
                    .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                        self.scrollOffset = value[0]
                    }
                }
            }
//            .clipShape(RoundedRectangle(cornerRadius: 25.0, style: .continuous))
            .sheet(isPresented: self.$showEntryDetail, content: {
                EntryDetailView(parentBill: self.$chosenBill, entryID: $selectedEntry, showSheetView: self.$showEntryDetail)
            })
            .padding(.top, topOffset)
            .edgesIgnoringSafeArea(.bottom)
            .frame(maxWidth: 650)
            .onChange(of: self.scrollOffset, perform: { value in
                if value > pullToDismissDistance {
                    if !onRemoving {
                        onRemoving = true
                        haptic_one_click()
                    }
                    dragToDismiss()
                }
            })
        }
        .ignoresSafeArea()
    }

    private func getScrollViewOffset(outProxy: GeometryProxy, innerProxy: GeometryProxy) -> CGFloat {
        return -outProxy.frame(in: .global).minY + innerProxy.frame(in: .global).minY
    }
    
    private func tapToDismiss() {
        withAnimation (.spring(response: 0.4, dampingFraction: 0.75, blendDuration: 0.2)) {
            dismissBillDetail()
        }
        haptic_one_click()
    }
    
    private func dragToDismiss() {
        withAnimation (.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0.2)) {
            dismissBillDetail()
        }
    }
}

struct BillDetailView_Preview: PreviewProvider {
    @Namespace static var namespace
    static var previews: some View {
        BillDetailView(chosenBill: .constant(BillObject.sample[1]), namespace: namespace, dismissBillDetail: {}, animationDuration: 0.3, background: Color.white, topOffset: 0, selectedEntry: .init())
//            .previewDevice("iPhone 12")
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.light)
    }
}
