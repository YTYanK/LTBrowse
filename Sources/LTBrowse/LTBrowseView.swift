//
//  SwiftUIView.swift
//  LTBrowse
//
//  Created by K YTYan on 2025/3/5.
//
/**
 // 语言设置操作： .environment(\.locale, .init(identifier: currentLanguage()))
 */


import SwiftUI
import Kingfisher
import Combine
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
    var operateBlock: ((String)-> Void)? = nil
    
    @State private var isGotoList: Bool = false
    @State private var currentPage = 0
 
 
    @State private  var cancellables = Set<AnyCancellable>()
    
    private let adapter = LTScreenAdapter.shared
    
    public init(headIcons: [BrowseViewItem] = [], menus: [BrowseViewItem] = [], contents: [BrowseViewItem] = [], toggleCange: ((String, Bool)->Void)?, operateBlock: ((String) -> Void)?) {
       
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
 

            ZStack {
                NavigationLink("_", isActive: $isGotoList) {
                    LTBrowseListView(onTabChange: { newTab in
                        print("切换到\(newTab)")
                        self.toggleCange?("tab-\(newTab)", true)
                    }).navigationBarBackButtonHidden().environmentObject(self.dataCenter)
                }.hidden()
                GeometryReader { geometry in
                    ScrollView(.vertical, showsIndicators: false) {
                        // 首页- bann
                        VStack {
                            TabView(selection: $currentPage) {
                                ForEach(headIcons, id: \.self) { head in
                                    LTImageView(tag: "headIcons", icon: head.icon, pId: head.pId) { curId, curTag in
//                                        self.operateBlock?("\(curTag)-\(curId)")
                                        self.handleOperation(tag: curTag, id: curId)
                                    }
                                }
 
                             }
                        }
                        .frame(height: adapter.getRelativeHeight(0.34))
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
 
                        // 首页-菜单
                        HStack {
                            ForEach(menuList, id: \.self) { menu in
                               VStack {
                                        LTImageView(tag: "MenuIcons", icon: menu.icon, pId: menu.pId, operateBlock: { curId, curTag in
//                                            self.isGotoList = true
//                                            self.operateBlock?("\(curTag)-\(curId)")
                                            self.handleOperation(tag: curTag, id: curId)
                                        })
                                        .background(Color.red)
                                        .frame(width: adapter.setWidth(68), height: adapter.setWidth(68))

                                        Text(menu.title)
                                            .font(.system(size: adapter.setFont(size: 13), weight: .medium))
                                            .foregroundColor(menu.theme)
                                            .onTapGesture {
//                                                self.isGotoList = true
//                                                self.operateBlock?("MenuIcons-\(menu.pId)")
                                                self.handleOperation(tag: "MenuIcons", id: menu.pId)
                                            }
                                    }.padding(adapter.setSize(size: 6))
                            }
                        }.padding(.vertical,adapter.setHeight(10))
 
                        // 首页-列表
                        ForEach(contentList, id: \.self) { content in

//                            NavigationLink {
//                                LTBrowseListView().navigationBarBackButtonHidden().environmentObject(self.dataCenter)
//                            } label: {
                                
                            LTImageView(tag: "ContentIcons", icon: content.icon, pId: content.pId, operateBlock: { curId, curTag in
//                                self.operateBlock?("\(curTag)-\(curId)")
                                self.handleOperation(tag: curTag, id: curId)
                            }).frame(width: adapter.getRelativeWidth(0.9))
 
                        }
                        
                        Spacer()
                  }
               }
            }
            .navigationBarHidden(true)
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                  print("查看页面尺寸\(LTScreenAdapter.SCRE_H) -----------\(LTScreenAdapter.SCRE_W)")
                self.setupOperationListener()
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

    }
    
    private  func setupOperationListener() {
        dataCenter.operationResultPublisher
            .receive(on: DispatchQueue.main)
            .sink { success in
                isGotoList = success // 直接更新状态
                print("操作完成，跳转状态: \(success)")
            }
            .store(in: &cancellables)
    }
    
    // 新增：统一处理操作逻辑
    private func handleOperation(tag: String, id: Int) {
           operateBlock?("\(tag)-\(id)")
         // 根据operateBlock的返回值控制isGotoList
//        self.isGotoList = operationResult
         
         // 如果需要，也可以在这里添加其他逻辑
         print("操作触发: \(tag)-\(id), 跳转状态:")
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


public struct LTImageView: View {
    
    let adapter = LTScreenAdapter.shared
    /// 字符串 标签
    @State var tag: String
    @State var icon: String = ""
    @State var pId: Int = 0
    var operateBlock: ((Int,String)->Void)? = nil
    public var body: some View {
        if let imageIcon = UIImage(named: icon) {
            Image(uiImage: imageIcon)
                .resizable()
                .scaledToFill()
                .tag(pId)
                .onTapGesture {
                    self.operateBlock?(pId,tag)
                }
        }else if let urlIcon = URL(string: icon) {
            KFImage(urlIcon)
                .resizable()
                .scaledToFill()
                .tag(pId)
                .onTapGesture {
                    self.operateBlock?(pId,tag)
                }
        }else {
            // 显示默认图片或占位符
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: adapter.setWidth(68),
                      height: adapter.setWidth(68))
                .cornerRadius(adapter.setSize(size: 10))
                .tag(pId)
                .onTapGesture {
                    self.operateBlock?(pId,tag)
                }
        }
    }
}
