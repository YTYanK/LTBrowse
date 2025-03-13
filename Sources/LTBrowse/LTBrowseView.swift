//
//  SwiftUIView.swift
//  LTBrowse
//
//  Created by K YTYan on 2025/3/5.
//

import SwiftUI

//@MainActor
//public class LTBrowseViewModel: ObservableObject {
//    @Published var vm_headIcons: [BrowseViewItem]?
//    @Published var vm_menuList: [BrowseViewItem]?
//    @Published var vm_contentList: [BrowseViewItem]?
// 
//}


@available(iOS 14.0, *)
public struct LTBrowseView: View {
    
    @StateObject  private var dataCenter = LTBrowseDataCenter.shared
    
    @State private var headIcons: [BrowseViewItem]
    @State private var menuList: [BrowseViewItem]
    @State private var contentList: [BrowseViewItem]
    
    var toggleCange:((String, Bool)->Void)? = nil
    var operateBlock: ((String)->Void)? = nil
    
    @State private var isGotoList: Bool = false
    @State private var currentPage = 0
 
 
    private let adapter = LTScreenAdapter.shared
    
    public init(headIcons: [BrowseViewItem] = [], menus: [BrowseViewItem] = [], contents: [BrowseViewItem] = [], toggleCange: ((String, Bool)->Void)?, operateBlock: ((String)->Void)?) {
       
        let initialHeadIcons = LTBrowseDataCenter.isUseHeadIcon ?  LTBrowseDataCenter.getHeadIconData() :  headIcons
        let initialMenuList = LTBrowseDataCenter.isUseMenuList ?  LTBrowseDataCenter.getMenuList() : menus
        let  initialContentList = LTBrowseDataCenter.isUseMenuList ?  LTBrowseDataCenter.getContentList() :  contents
    
        self._headIcons = State(initialValue: initialHeadIcons)
        self._menuList = State(initialValue: initialMenuList)
        self._contentList = State(initialValue: initialContentList)
        self.toggleCange = toggleCange
        self.operateBlock = operateBlock
        
    }
    
    public var body: some View {
 
//        NavigationView {
            ZStack {
                NavigationLink("_", isActive: $isGotoList) {
                    LTBrowseListView().navigationBarBackButtonHidden().environmentObject(self.dataCenter)
                }.hidden()
                GeometryReader { geometry in
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack {
                            TabView(selection: $currentPage) {
                                ForEach(0..<headIcons.count, id: \.self) { index in
                                    ZStack {
                                        if let image = UIImage(named: headIcons[index].icon) {
                                            Image(uiImage: image)
                                                .resizable()
                                                .scaledToFill()
                                        }
                                        
                                        Button {
                                            self.isGotoList = true
                                            self.operateBlock?("HeadIcons\(index)")
                                        } label: {
                                            VStack {
                                                Text(headIcons[index].title) //查看详情
                                                    .font(.system(size: adapter.setFont(size: 16)))
                                                    .frame(width: adapter.getRelativeWidth(0.2),
                                                           height: adapter.setHeight(38))
                                                    .foregroundColor(headIcons[index].theme)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: adapter.setSize(size: 3))
                                                            .stroke(style: StrokeStyle(lineWidth: 1, dash: [4, 2], dashPhase: 0))
                                                            .foregroundColor(Color.white)
                                                    )
                                            }
                                        }.offset(y: adapter.getRelativeHeight(0.14) - adapter.setHeight(38))
                                    }
                                }
                            }
                            .frame(height: adapter.getRelativeHeight(0.34))
                            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                            
                            HStack {
                                ForEach(menuList, id: \.self) { menu in
                                    Button {
                                        self.isGotoList = true
                                    } label: {
                                        VStack {
                                           if  menu.icon != "" {
                                                Image(menu.icon)
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: adapter.setWidth(68),
                                                          height: adapter.setWidth(68))
                                           } else {
                                               // 显示默认图片或占位符
                                               Rectangle()
                                                   .fill(Color.gray.opacity(0.2))
                                                   .frame(width: adapter.setWidth(68),
                                                         height: adapter.setWidth(68))
                                                   .cornerRadius(adapter.setSize(size: 10))
                                           }
                                            
                                            Text(menu.title)
                                                .font(.system(size: adapter.setFont(size: 13), weight: .medium))
                                                .foregroundColor(menu.theme)
                                        }.padding(adapter.setSize(size: 6))
                                    }
                                }
                            }.padding(.vertical,adapter.setHeight(10))
                            
                            ForEach(self.contentList, id: \.self) { content in
 
                                NavigationLink {
                                    LTBrowseListView().navigationBarBackButtonHidden().environmentObject(self.dataCenter)
                                } label: {
                                    ZStack {
                                        Image(content.icon)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: adapter.getRelativeWidth(0.9))
     
                                        GeometryReader { itemGeometry in
                                                Text(content.title)
                                                    .font(.system(size: adapter.setFont(size: 12)))
                                                    .frame(width: adapter.getRelativeWidth(0.2),
                                                           height: adapter.setHeight(24))
                                                    .foregroundColor(content.theme)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: adapter.setSize(size: 1))
                                                            .stroke(style: StrokeStyle(lineWidth: 1, dash: [4, 2], dashPhase: 0))
                                                            .foregroundColor(content.theme)
                                                    )
                                                    .offset(x: adapter.getRelativeWidth(0.1),
                                                    y: itemGeometry.size.height - adapter.setHeight(48))
                                        }
                                    }
                                }
                                
                            }
                            
                            Spacer()
                        }
                    }
                }
               
               
 
            }
            .navigationBarHidden(true)
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                  print("??\(LTScreenAdapter.SCRE_H) -----------\(LTScreenAdapter.SCRE_W)")
               
            }
            .onReceive(dataCenter.$headIconData) { newValue in
                if  LTBrowseDataCenter.isUseHeadIcon   {
                    self.headIcons = newValue
                }
            }
            .onReceive(dataCenter.$menuListData) { newValue in
                if  LTBrowseDataCenter.isUseMenuList {
                    self.menuList = newValue
                }
            }
            .onReceive(dataCenter.$contentListData) { newValue in
                if LTBrowseDataCenter.isUseContentList {
                    self.contentList = newValue
                }
            }
//        }.environment(\.locale, .init(identifier: currentLanguage()))
    }
    
    
    func currentLanguage() -> String {
        if #available(iOS 16, *) {
            return Locale.current.language.languageCode?.identifier ?? "未知语言"
        } else {
            return "en"
        }
    }
}
 
 
public struct ConditionalNavigationLink<Destination: View>: View {
   // let destination: Destination
    @State var condition: Bool
    let destination: () -> Destination
    let label: () -> Text
    
//    @ViewBuilder destination: () -> Destination, @ViewBuilder label: () -> Label
    
    
    public var body: some View {
        Group {
            if condition {
                NavigationLink(destination: destination()) {
                    label()
                }
            } else {
                Button {
                    
                } label: {
                    label()
                }
 
            }
        }
    }
}
