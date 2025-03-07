//
//  StaggeredGrid.swift
//  LTBrowse
//
//  Created by K YTYan on 2025/3/5.
//

import SwiftUI


public struct StaggeredGrid<Content: View, T : Identifiable>: View where T: Hashable {

    // 列……
    var columns : Int
    var spacing : CGFloat
    // 属性
    var showsIndicators : Bool
    var list : [T]
    // 它将从集合中返回每个对象来构建视图…
    var content: (T) -> Content
    
    @State private var heights: [AnyHashable: CGFloat] = [:]
    
    // 提供构造函数的闭包
    public init(columns: Int, showsIndicators: Bool = false,spacing : CGFloat = 10, list:[T], @ViewBuilder content: @escaping(T)->Content){
        self.content = content
        self.list = list
        self.spacing = spacing
        self.showsIndicators = showsIndicators
        self.columns = columns
    }

    
    public var body: some View {
        let width = (UIScreen.main.bounds.width * 0.9 - spacing * CGFloat(columns - 1)) / CGFloat(columns)
        
        ScrollView(.vertical, showsIndicators: showsIndicators) {
            LazyVGrid(columns: Array(repeating: GridItem(.fixed(width), spacing: spacing), count: columns),
                     spacing: spacing) {
                ForEach(Array(list.enumerated()), id: \.element.id) { index, item in
                    content(item)
                        .frame(width: width)
                        .background(GeometryReader { proxy in
                            Color.clear
                                .preference(key: HeightPreferenceKey.self,
                                            value: [AnyHashable(item.id): proxy.size.height])
                        })
                }
            }
            //.padding(.horizontal, spacing)
        }
        .onPreferenceChange(HeightPreferenceKey.self) { preferences in
            for (id, height) in preferences {
                heights[id] = height
            }
        }
    }
}



 

// 修改 HeightPreferenceKey 的定义
@MainActor
struct HeightPreferenceKey: @preconcurrency PreferenceKey {
     static var defaultValue: [AnyHashable: CGFloat] = [:]
    
    static func reduce(value: inout [AnyHashable: CGFloat], nextValue: () -> [AnyHashable: CGFloat]) {
        value.merge(nextValue()) { $1 }
    }
}
