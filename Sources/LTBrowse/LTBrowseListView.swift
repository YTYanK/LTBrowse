//
//  LTBrowseListView.swift
//  LTBrowse
//
//  Created by K YTYan on 2025/3/5.
//


import SwiftUI

 
public struct ProducModel: Identifiable, Hashable {
    public  let id = UUID()
   var typeId: Int  = 0  // 产品类型
   var name: String // 名称
   var icon: String = ""  // 图片
   var parameter: String = "" // 产品参数
   var other: String = ""  //其他信息
   var des: String = "描述"
   var title: String = "详情页面"
    
    public init(_ typeId: Int = 0, name: String, icon: String = "", parameter: String = "", other: String = "", des: String = "", title: String = "") {
        self.typeId = typeId
        self.name = name
        self.icon = icon
        self.parameter = parameter
        self.other = other
        self.des = des
        self.title = title
    }
}

 
public struct ProducType: Identifiable, Hashable {
    public let id = UUID()
    var typeId: Int = 0
    var name: String
    var gearValue = ""
    public init(_ typeId: Int = 0, name: String, gearValue: String = "") {
        self.typeId = typeId
        self.name = name
        self.gearValue = gearValue
    }
}
  

@available(iOS 14.0, *)
public struct LTBrowseListView: View {
    
 
    @State var selectedTab: Int = 0
    @State private var tabItems: [ProducType]
    /// 产品数据
    @State private var productsByCategory: [[ProducModel]]
    // 添加滚动视图的引用
    @Namespace private var animation
    @State private var scrollViewProxy: ScrollViewProxy? = nil
  
    @EnvironmentObject private var dataCenter: LTBrowseDataCenter
    @Environment(\.presentationMode) var presentationMode
   
    
    public init(tabItems: [ProducType] = [], productsByCategory: [[ProducModel]] = [] ){
        
        
        let initialProductsTypes = LTBrowseDataCenter.isUseProducTypes ?  LTBrowseDataCenter.getProducTypes() :  tabItems
        let initialProductsByCategory = LTBrowseDataCenter.isUseProductsByCategory ?  LTBrowseDataCenter.getProductsByCategory() : productsByCategory
        
        self._tabItems = State(initialValue: initialProductsTypes)
        // 为每个分类创建对应的产品列表
        if initialProductsTypes.count == initialProductsByCategory.count {
            self._productsByCategory = State(initialValue: initialProductsByCategory)

        }else {
            var _pbCategory:[[ProducModel]] = []
            initialProductsTypes.forEach { item in
                if item.typeId < initialProductsByCategory.count {
                    _pbCategory.append(initialProductsByCategory[item.typeId])
                }else {
                    _pbCategory.append([])
                }
            }
            self._productsByCategory = State(initialValue: _pbCategory)
        }
    
 
 
    }
    
    private let adapter = LTScreenAdapter.shared
    let colorDF = Color(UIColor(red: 223/255, green:  223/255, blue:  223/255, alpha: 1))
    let _size = LTB_SCRE_W * 0.9
    public  var body: some View {

             GeometryReader { geometry in
                VStack(spacing: 5)  {
  
                        // 顶部标签滚动视图
                        ScrollViewReader { proxy in
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: adapter.setSize(size: 8)) {
                                    ForEach(Array(tabItems.enumerated()), id: \.element) { index, tab in
                                        TabItemView(
                                            tab: tab,
                                            isSelected: selectedTab == index,
                                            namespace: animation
                                        ) {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                selectedTab = index
                                                // 滚动到选中的标签
                                                withAnimation {
                                                    proxy.scrollTo(index, anchor: .center)
                                                }
                                            }
                                        }
                                        .id(index)
                                    }
                                }
                                .padding(.horizontal, adapter.setSize(size: 16))
                            }
                            .onAppear {
                                scrollViewProxy = proxy
                            }
                        }
           
                        TabView(selection: $selectedTab) {
                            ForEach(Array(productsByCategory.enumerated()), id: \.offset) { index, products in
                                ScrollView {
                                    StaggeredGrid(columns: 2, spacing: adapter.setSize(size: 10), list: products) { item in
                                        ProductItemView(item: item).environmentObject(self.dataCenter)
                                    }
                                    .padding(.horizontal, adapter.setSize(size: 16))
                                }
                                .tag(index)
                            }

                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never)) //添加联动
                        .onChange(of: selectedTab) { newValue in
                            // 当页面滑动改变时，同步滚动标签栏
                            withAnimation {
                                scrollViewProxy?.scrollTo(newValue, anchor: .center)
                            }
                        }
                    
                }
                
             }

        .background(LTB_BG_Color.edgesIgnoringSafeArea(.all))
        .navigationTitle( Text(dataCenter.titls["ListViewTitle"]!))
        .navigationBarItems(leading:   AnyView(UIView.returnNavLeftView({
            presentationMode.wrappedValue.dismiss()
        })))
        .onAppear {
          
        }
        .onReceive(dataCenter.$producTypes) { newValue in
            if  LTBrowseDataCenter.isUseProducTypes {
//                self.tabItems = newValue
                self.setupProductData(newValue, nil)
            }
        }
        .onReceive(dataCenter.$productsByCategoryData) { newValue in
            if LTBrowseDataCenter.isUseProductsByCategory {
//                self.productsByCategory = newValue
                self.setupProductData(nil, newValue)
            }
        }
//        .environment(\.locale, .init(identifier: currentLanguage()))
        
    }
    
//    func currentLanguage() -> String {
//        return Locale.current.language.languageCode?.identifier ?? "未知语言"
//    }
    // 设置产品数据
    func setupProductData(_ types: [ProducType]? = nil, _ category:  [[ProducModel]]? = nil) {
                 var _types =  self.tabItems
                 var _category = self.productsByCategory
         
                 if types != nil  {
                     _types =  types!
                 }
                 if  category  != nil {
                     _category = category!
                 }
                 self.tabItems = _types
         
                 // 为每个分类创建对应的产品列表
                 if _types.count == _category.count {
                     self.productsByCategory = _category
         
                 }else {
                     var _pbCategory:[[ProducModel]] = []
                     _types.forEach { item in
                         if item.typeId < _category.count {
                             _pbCategory.append(_category[item.typeId])
                         }else {
                             _pbCategory.append([])
                         }
                     }
                     self.productsByCategory = _pbCategory
                 }
          
     }
 
}


// 分类标签视图
private struct TabItemView: View {
  let tab: ProducType
  let isSelected: Bool
  let namespace: Namespace.ID
  let action: () -> Void
  
  private let adapter = LTScreenAdapter.shared
  private let colorDF = Color(UIColor(red: 223/255, green: 223/255, blue: 223/255, alpha: 1))
  
  var body: some View {
      Button(action: action) {
          VStack(spacing: adapter.setSize(size: 4)) {
              Text(tab.name)
                  .font(.system(size: adapter.setFont(size: isSelected ? 18 : 15)))
                  .fontWeight(.bold) //isSelected ?
              Text(tab.gearValue)
                  .font(.system(size: adapter.setFont(size: 13)))
                  .fontWeight(.light)
          }
          .foregroundColor(isSelected ? .white : .black)
          .frame(width: adapter.setWidth(80),
                 height: adapter.setHeight(isSelected ? 65 : 55))
          .background(
              RoundedRectangle(cornerRadius: adapter.setSize(size: 12))
                  .fill(isSelected ? Color.black : colorDF)
          )
          // 添加过渡动画
         // .scaleEffect(isSelected ? 1.05 : 1.0)
          .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
          // 添加匹配几何效果
          .matchedGeometryEffect(id: "tab\(tab.id)", in: namespace, isSource: isSelected)
      }
      .buttonStyle(PlainButtonStyle())
//      .background(Color.red)
      //.animation(.spring(response: 0.2, dampingFraction: 0.7), value: isSelected)
  }
}


// 产品项视图
private struct ProductItemView: View {
    let item: ProducModel
    private let adapter = LTScreenAdapter.shared
    @State private var isAppeared = false
    @EnvironmentObject private var dataCenter: LTBrowseDataCenter
    var body: some View {
        NavigationLink {
            LTBrowseDetailsView(produc: item).navigationBarBackButtonHidden().environmentObject(self.dataCenter)
        } label: {
            VStack(alignment: .leading, spacing: adapter.setSize(size: 8)) {
                
                if  item.icon != "" {
                    Image(item.icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(adapter.setSize(size: 10))
               } else {
                   // 显示默认图片或占位符
                   Rectangle()
                       .fill(Color.gray.opacity(0.2))
                       .frame(maxWidth: .infinity)
                       .frame(height: adapter.setHeight(160))
                       .cornerRadius(adapter.setSize(size: 10))
               }
 
                    
                Text(item.name)
                    .font(.system(size: adapter.setFont(size: 14)))
                    .foregroundColor(.black)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(adapter.setSize(size: 8))
            .background(Color.white)
            .cornerRadius(adapter.setSize(size: 10))
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
        .opacity(isAppeared ? 1 : 0)
       // .offset(y: isAppeared ? 0 : 20)
        .onAppear {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8).delay(0.1)) {
                isAppeared = true
            }
        }
        
    }
}
