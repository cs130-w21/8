//
//  Helper.swift
//  Dots
//
//  Created by Jack Zhao on 1/9/21.
//

import Foundation
import SwiftUI

// Screen size that is accessible through the entire program
let screen = UIScreen.main.bounds

let dotColors: [Color] = [
    Color(UIColor.systemRed),
    Color(UIColor.systemBlue),
    Color(UIColor.systemGreen),
    Color(UIColor.systemIndigo),
    Color(UIColor.systemOrange),
    Color(UIColor.systemPink),
    Color(UIColor.systemPurple),
    Color(UIColor.systemTeal),
    Color(UIColor.systemYellow),
    Color(UIColor.systemGray),
]


func haptic_one_click() {
    let generator = UIImpactFeedbackGenerator(style: .medium)
    generator.impactOccurred()
}

public struct ForEachWithIndex<Data: RandomAccessCollection, ID: Hashable, Content: View>: View {
    public var data: Data
    public var content: (_ index: Data.Index, _ element: Data.Element) -> Content
    var id: KeyPath<Data.Element, ID>

    public init(_ data: Data, id: KeyPath<Data.Element, ID>, content: @escaping (_ index: Data.Index, _ element: Data.Element) -> Content) {
        self.data = data
        self.id = id
        self.content = content
    }

    public var body: some View {
        ForEach(
            zip(self.data.indices, self.data).map { index, element in
                IndexInfo(
                    index: index,
                    id: self.id,
                    element: element
                )
            },
            id: \.elementID
        ) { indexInfo in
            self.content(indexInfo.index, indexInfo.element)
        }
    }
}

extension ForEachWithIndex where ID == Data.Element.ID, Content: View, Data.Element: Identifiable {
    public init(_ data: Data, @ViewBuilder content: @escaping (_ index: Data.Index, _ element: Data.Element) -> Content) {
        self.init(data, id: \.id, content: content)
    }
}

extension ForEachWithIndex: DynamicViewContent where Content: View {
}

private struct IndexInfo<Index, Element, ID: Hashable>: Hashable {
    let index: Index
    let id: KeyPath<Element, ID>
    let element: Element

    var elementID: ID {
        self.element[keyPath: self.id]
    }

    static func == (_ lhs: IndexInfo, _ rhs: IndexInfo) -> Bool {
        lhs.elementID == rhs.elementID
    }

    func hash(into hasher: inout Hasher) {
        self.elementID.hash(into: &hasher)
    }
}
