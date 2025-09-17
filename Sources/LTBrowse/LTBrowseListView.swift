//
//  LTBrowseListView.swift
//  LTBrowse
//
//  Created by K YTYan on 2025/3/5.
//


import SwiftUI
import Kingfisher
import Combine

 
public struct ProducModel: Identifiable, Hashable {
    public  let id = UUID()
   /// 分类目录ID/产品类型
   var typeId: Int  = 0
   /// 产品ID
   var productId: Int = 0
   var name: String = ""// 名称
   var icon: String = ""  // 图片
   var createdAt: Int = 0
   var parameter: String = "" // 产品参数
   var other: String = ""  //其他信息
   var des: String = "描述"
   var title: String = "详情页面"
    
   var specifications: [SpecificationsItem] = []
   public init(_ typeId: Int = 0, productId: Int = 0, name: String = "", icon: String = "", at: Int = 0, parameter: String = "", other: String = "", des: String = "", title: String = "", _ specifications: [SpecificationsItem] = []) {
        self.typeId = typeId
        self.productId = productId
        self.name = name
        self.icon = icon
        self.parameter = parameter
        self.other = other
        self.des = des
        self.title = title
        self.createdAt = at
        self.specifications = specifications
    }
    
    
   // 转出字符串
   func recoverJSONString() -> String  {
       let dict: [String: Any] = [
           "id": id.uuidString,
           "typeId": typeId,
           "productId": productId,
           "name": name,
           "icon": icon,
           "createdAt": createdAt,
           "parameter": parameter,
           "des": des,
           "title": title
       ]
       
   
       do {
           let jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
           return String(data: jsonData, encoding: .utf8)  ?? ""
       } catch {
           print("JSON 转换失败: \(error)")
           return ""
       }
        

       
  }
}

 
public struct ProducType: Identifiable, Hashable {
 
    public let id = UUID()
    public var typeId: Int = 0
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
    @State private var tabItems: [ProducType] = []
    /// 产品数据 - 不能去了
    @State private var productsByCategory: [[ProducModel]] = []
    // 添加滚动视图的引用
    @Namespace private var animation
    @State private var scrollViewProxy: ScrollViewProxy? = nil
    
    @State private var goDetails: Bool = false
    @State private var listCancellables = Set<AnyCancellable>()
    ///订阅标记
    @State private var didSetupListener = false
    
    @EnvironmentObject private var dataCenter: LTBrowseDataCenter
    @Environment(\.presentationMode) var presentationMode
   
    var onTabChange: ((_ indx:Int, _ tId:Int) -> Void)?
    var onClickDetails:((Int,ProducModel) -> Void)?
    
    public init(onTabChange: ((Int, Int) -> Void)? = nil, onClickDetails: ((Int,ProducModel) -> Void)? = nil) {
        self.onTabChange = onTabChange
        self.onClickDetails = onClickDetails
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
                                ForEach(Array(tabItems.enumerated()), id: \.element) { index, item in
                                    TabItemView(
                                        tab: item,
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
                    // 内容列表
                    TabView(selection: $selectedTab) {
                        ForEach(Array(productsByCategory.enumerated()), id: \.offset) { index, products in
                            ScrollView {
                                StaggeredGrid(columns: 2, spacing: adapter.setSize(size: 10), list: products) { item in
                                    ProductItemView(goToDetails: $goDetails,item: item, onClickDetails: { PId in
                                        self.onClickDetails?(PId,item)
                                    }).environmentObject(self.dataCenter)
                                    
                                }
                                .padding(.horizontal, adapter.setSize(size: 16))
                            }
                            .tag(index)
                        }
                        
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never)) //添加联动
                    .onChange(of: selectedTab) { newValue in
                        
                        onTabChange?(newValue, self.tabItems[newValue].typeId)
                        // 当页面滑动改变时，同步滚动标签栏
                        withAnimation {
                            scrollViewProxy?.scrollTo(newValue, anchor: .center)
                        }
                    }
                    
                }
                
         }
        .background(LTB_BG_Color.edgesIgnoringSafeArea(.all))
        .navigationBarHidden(false)
        .toolbar {
               ToolbarItem(placement: .principal) {
                   Text(dataCenter.titls[LTBrowseTitlsKey.ListViewTitle.keyValue]!)
                       .foregroundColor(.black).font(.system(size: 17, weight: .bold))  // 设置标题颜色
               }
           }
        .navigationBarItems(leading:  AnyView(UIView.returnNavLeftView(icon:"back_arrow",width: adapter.setSize(size: 18), height: adapter.setSize(size: 18) ,{
            dataCenter.notifyOperationResult(("List",false))
            listCancellables.removeAll()
            presentationMode.wrappedValue.dismiss()
            
        })))
        .onAppear {
            if !didSetupListener {
                self.setupOperationDetailsListener()
                didSetupListener = true
            }
        }
        .onReceive(dataCenter.$producTypes) { newValue in
            if  LTBrowseDataCenter.isUseProducTypes {
                self.setupProductTypeData(newValue)
            }
        }
        .onReceive(dataCenter.$productsByCategoryData) { newValue in
             if LTBrowseDataCenter.isUseProductsByCategory {
                 self.setupProductData(newValue)
             }
        }
//        .environment(\.locale, .init(identifier: currentLanguage()))
        
    }
 
    func setupProductTypeData(_ types: [ProducType]) {
         self.tabItems = types
         print("设置分类目录成功！")
       
    }
    // 设置产品数据
    func setupProductData(_ category:  [Int:[ProducModel]]) {
        var _types =  self.tabItems
        var _category: [[ProducModel]] =   Array(repeating: [], count: self.tabItems.count)
                 
        if !category.isEmpty {
            _types.enumerated().forEach { index, fruit in
                print("Index: \(index), Element: \(fruit)")
                if let _ary = category[fruit.typeId]   {
                    _category[index] = _ary
                }
            }
           self.productsByCategory = _category
        }
 
     }
 
    // 控制是否去详情页面
    private  func setupOperationDetailsListener() {
        dataCenter.operationDetailsResultPublisher
            .receive(on: DispatchQueue.main)
            .sink { success in
                goDetails = success // 直接更新状态
                print("list->操作完成，跳转状态: \(success)")
            }
            .store(in: &listCancellables)
    }
}


// 分类目录标签视图
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
                  .fontWeight(.bold)
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
  }
}


// 产品项视图
private struct ProductItemView: View {
    @Binding var goToDetails: Bool
    @State var item: ProducModel
    var onClickDetails: ((Int)-> Void)? = nil
    private let adapter = LTScreenAdapter.shared
    @State private var isAppeared = false
    @EnvironmentObject private var dataCenter: LTBrowseDataCenter
    var body: some View {
        
        ZStack {
            NavigationLink("_", isActive: $goToDetails) {
                LTBrowseDetailsView(produc: dataCenter.productsDetailsData ?? item).navigationBarBackButtonHidden().environmentObject(self.dataCenter)
            }.hidden()
            
            VStack(alignment: .center, spacing: adapter.setSize(size: 8)) {
                Group {
                  
                        if let urlIcon = URL(string: dataCenter.fileUrlString + item.icon) {
                            KFImage(urlIcon)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: adapter.setSize(size: 120), height:  adapter.setSize(size: 120))
           
                        }else if  let icon = UIImage(named: item.icon) {
                            Image(uiImage: icon)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: adapter.setSize(size: 120), height:  adapter.setSize(size: 120))
     
                        } else {
                           // 显示默认图片或占位符
                           Rectangle()
                               .fill(Color.gray.opacity(0.2))
                               .frame(width: adapter.setSize(size: 120), height:  adapter.setSize(size: 120))
 
                       }
              
                }
                 .background(Color.white)
                 .cornerRadius(adapter.setSize(size: 10))
                 .tag(item.typeId)
 
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
        .onTapGesture {
            self.onClickDetails?(item.productId)
        }
       // .offset(y: isAppeared ? 0 : 20)
        .onAppear {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8).delay(0.1)) {
                isAppeared = true
            }
        }
       // .environment(\.locale, .init(identifier: dataCenter.currentLanguage))
        
    }
}
