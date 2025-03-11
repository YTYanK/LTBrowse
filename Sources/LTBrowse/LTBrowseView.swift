//
//  SwiftUIView.swift
//  LTBrowse
//
//  Created by K YTYan on 2025/3/5.
//

import SwiftUI


class LTBrowseViewModel: ObservableObject {
    @Published var headIcon: String = ""
}


@available(iOS 14.0, *)
public struct LTBrowseView: View {
    
    @State var headIcons: [String]
    @State var menuList: [BrowseViewItem]
    @State var contentList: [BrowseViewItem]  
    
    var toggleCange:((String, Bool)->Void)? = nil
    var operateBlock: ((String)->Void)? = nil
    
    //@StateObject var viewModel = LTBrowseViewModel()
    @State private var currentPage = 0
 
    private let adapter = LTScreenAdapter.shared
    
    public init(headIcons: [String] = [], menus: [BrowseViewItem] = [], contents: [BrowseViewItem] = [], toggleCange: ((String, Bool)->Void)?, operateBlock: ((String)->Void)?) {
        
        if LTBrowseDataCenter.isUseHeadIcon {
            self.headIcons =  LTBrowseDataCenter.getHeadIconData()
        }else {
            self.headIcons = headIcons
        }
        
        if LTBrowseDataCenter.isUseMenuList {
            self.menuList =  LTBrowseDataCenter.getMenuList()
        }else {
            self.menuList = menus
        }
        
        
        if LTBrowseDataCenter.isUseMenuList {
            self.contentList =  LTBrowseDataCenter.getContentList()
        }else {
            self.contentList = contents
        }
 
        self.toggleCange = toggleCange
        self.operateBlock = operateBlock
        
    }
    
    public var body: some View {
 
        NavigationView {
            ZStack {
                GeometryReader { geometry in
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack {
                            TabView(selection: $currentPage) {
                                ForEach(0..<headIcons.count, id: \.self) { index in
                                    ZStack {
                                        if let image = UIImage(named: headIcons[index]) {
                                            Image(uiImage: image)
                                                .resizable()
                                                .scaledToFill()
                                        }
                                        
                                        Button {
                                            
                                        } label: {
                                            VStack {
                                                Text("查看详情")
                                                    .font(.system(size: adapter.setFont(size: 16)))
                                                    .frame(width: adapter.getRelativeWidth(0.2),
                                                           height: adapter.setHeight(38))
                                                    .foregroundColor(Color.white)
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
                                        
                                    } label: {
                                        VStack {
                                            Image(menu.icon)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: adapter.setWidth(68),
                                                      height: adapter.setWidth(68))
                                            Text(menu.title)
                                                .font(.system(size: adapter.setFont(size: 13), weight: .medium))
                                                .foregroundColor(menu.theme)
                                        }.padding(adapter.setSize(size: 6))
                                    }
                                }
                            }.padding(.vertical,adapter.setHeight(10))
                            
                            ForEach(self.contentList, id: \.self) { content in
                                ZStack {
                                    Image(content.icon)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: adapter.getRelativeWidth(0.9))
 
                                    GeometryReader { itemGeometry in
                                        NavigationLink {
                                            LTBrowseListView().navigationBarBackButtonHidden()
                                        } label: {
                                            Text(content.title)
                                                .font(.system(size: adapter.setFont(size: 12)))
                                                .frame(width: adapter.getRelativeWidth(0.2),
                                                       height: adapter.setHeight(24))
                                                .foregroundColor(content.theme)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: adapter.setSize(size: 1))
                                                        .stroke(style: StrokeStyle(lineWidth: 1, dash: [4, 2], dashPhase: 0))
                                                        .foregroundColor(Color.white)
                                                )
                                        }
                                        .offset(x: adapter.getRelativeWidth(0.1),
                                                y: itemGeometry.size.height - adapter.setHeight(48))
                                    }
                                }
                            }
                            
                            Spacer()
                        }
                    }
                }
            }
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                  print("??\(LTScreenAdapter.SCRE_H) -----------\(LTScreenAdapter.SCRE_W)")
               
            }
        }.environment(\.locale, .init(identifier: currentLanguage()))
    }
    
    
    func currentLanguage() -> String {
        if #available(iOS 16, *) {
            return Locale.current.language.languageCode?.identifier ?? "未知语言"
        } else {
            return "en"
        }
    }
}
 
 
