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
 

/// 事件消息标签
public enum EventMessageTags {
    case EMT_Tab
    /// 列表页-事件
    case EMT_ListIcons
    /// 首页-顶部banner
    case EMT_HeadIcons
    /// 首页-内容列表事件
    case EMT_ContentIcons
    /// 首页-菜单事件
    case EMT_MenuIcons
    /// 标签内容
    public  var content: String {
        switch self {
        case .EMT_Tab:
            return "tab"
        case .EMT_ListIcons:
            return "listIcons"
        case .EMT_HeadIcons:
            return "headIcons"
        case .EMT_ContentIcons:
            return "contentIcons"
        case .EMT_MenuIcons:
            return "menuIcons"
        }
    }
}

@available(iOS 14.0, *)
public struct LTBrowseView: View {
    
    @StateObject  private var dataCenter = LTBrowseDataCenter.shared
    
    @State private var headIcons: [BrowseViewItem]
    @State private var menuList: [BrowseViewItem]
    @State private var contentList: [BrowseViewItem]
    
    /// 切换返回 tab-index-id
    var toggleCange:((String, Bool)->Void)? = nil
    var operateBlock: ((String)-> Void)? = nil
    
    @State private var isGotoList: Bool = false
    
    @State private var isHomeGotoDetails: Bool = false
    @State private var currentPage = 0
    @State private var  productsDetailsData: ProducModel = ProducModel()
    // 订阅标记
    @State private var didSetupListener = false
    @State private  var homeCancellables = Set<AnyCancellable>()
    
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
                    LTBrowseListView(onTabChange: { newTab, newTId  in
                        self.toggleCange?("\(EventMessageTags.EMT_Tab.content)-\(newTab)-\(newTId)", true)
                    }, onClickDetails: { newPId in
                        self.handleOperation(tag: EventMessageTags.EMT_ListIcons.content, id: newPId) //Details
                    }).navigationBarBackButtonHidden().environmentObject(self.dataCenter)
                }.hidden()
                
                NavigationLink("_", isActive: $isHomeGotoDetails) {
                     LTBrowseDetailsView(produc: productsDetailsData ).navigationBarBackButtonHidden().environmentObject(self.dataCenter)
                    
                }.hidden()
  
                GeometryReader { geometry in
                    ScrollView(.vertical, showsIndicators: false) {
                        // 首页- bann
                        VStack {
                            TabView(selection: $currentPage) {
                                ForEach(headIcons, id: \.self) { head in
                                    LTImageView(tag: EventMessageTags.EMT_HeadIcons.content, icon: head.icon, pId: head.pId) { curId, curTag in
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
                                   LTImageView(tag: EventMessageTags.EMT_MenuIcons.content, icon: menu.icon, pId: menu.pId, operateBlock: { curId, curTag in
                                            self.handleOperation(tag: curTag, id: curId)
                                        })
                                        .background(Color.red)
                                        .frame(width: adapter.setWidth(68), height: adapter.setWidth(68))

                                        Text(menu.title)
                                            .font(.system(size: adapter.setFont(size: 13), weight: .medium))
                                            .foregroundColor(menu.theme)
                                            .onTapGesture {
                                                self.handleOperation(tag: EventMessageTags.EMT_MenuIcons.content, id: menu.pId)
                                            }
                                    }.padding(adapter.setSize(size: 6))
                            }
                        }.padding(.vertical,adapter.setHeight(10))
 
                        // 首页-列表
                        ForEach(contentList, id: \.self) { content in
                            LTImageView(tag: EventMessageTags.EMT_ContentIcons.content, icon: content.icon, pId: content.pId, operateBlock: { curId, curTag in
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
                if !didSetupListener {
                    self.setupOperationListener()
                    didSetupListener = true
                }
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
            .onReceive(dataCenter.$productsDetailsData) { newValue in
                 if newValue != nil {
                     self.productsDetailsData = newValue!
                 }
            }
 
    }
    
    private  func setupOperationListener() {
        LTBrowseDataCenter.shared.operationResultPublisher
            .receive(on: DispatchQueue.main)
            .sink { success in
                if success.0 == "List" {
                    isGotoList = success.1
                }else {
                    isHomeGotoDetails = success.1
                }// 直接更新状态
                print("home->操作完成，跳转状态: \(success)")
            }
            .store(in: &homeCancellables)
    }
    
    // 新增：统一处理操作逻辑
    private func handleOperation(tag: String, id: Int) {
           print("操作触发: \(tag)-\(id), 跳转状态:")
           operateBlock?("\(tag)-\(id)")
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
