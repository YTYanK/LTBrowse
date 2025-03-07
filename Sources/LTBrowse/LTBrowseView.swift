//
//  SwiftUIView.swift
//  LTBrowse
//
//  Created by K YTYan on 2025/3/5.
//

import SwiftUI


//@available(iOS 13.0, *)
//struct PowerMeterListsModel: Equatable, Identifiable {
//    static func == (lhs: PowerMeterListsModel, rhs: PowerMeterListsModel) -> Bool {
//        return lhs.id == rhs.id
//    }
//    var id = UUID()
//    var title: String
//    var content: String = ""
//    var showArrow: Bool = false
//    var isEvent: Bool = true
//    
//    //var operateBlock: ((String)->Void)? = nil
//    
//}






class LTBrowseViewModel: ObservableObject {
    @Published var headIcon: String = ""
}


@available(iOS 14.0, *)
public struct LTBrowseView: View {
    
    @State var headIcon: [String]
    @State var menuList: [BrowseViewItem]
    @State var contentList: [BrowseViewItem]
    var toggleCange:((String, Bool)->Void)? = nil
    var operateBlock: ((String)->Void)? = nil
    
    @StateObject var viewModel = LTBrowseViewModel()
    @State private var currentPage = 0
    
    private let adapter = LTScreenAdapter.shared
    
    public init(headIcons: [String], menus: [BrowseViewItem] , contents: [BrowseViewItem], toggleCange: ((String, Bool)->Void)?, operateBlock: ((String)->Void)?) {
        self.menuList = menus
        self.contentList = contents
        self.headIcon = headIcons
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
                                ForEach(0..<headIcon.count, id: \.self) { index in
                                    ZStack {
                                        if let image = UIImage(named: headIcon[index]) {
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
                                ForEach(self.menuList, id: \.self) { menu in
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
 
 
