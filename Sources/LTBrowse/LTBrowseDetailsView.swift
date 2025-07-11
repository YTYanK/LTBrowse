//
//  SwiftUIView.swift
//  LTBrowse
//
//  Created by K YTYan on 2025/3/5.
//

import SwiftUI
import Kingfisher


//Product specifications
public struct SpecificationsItem: Identifiable,Hashable {
    public var id = UUID()
    // 产品id
    var pId: Int
    /// 标题
    var title: String
    /// 描述
    var des: String = ""
    public init(_ pID: Int = 0, title: String, des: String = "") {
        self.pId = pID
        self.title = title
        self.des = des
    }
}

/// 展示模型
//public struct DetailsViewModel: Hashable, Identifiable {
//   public  let id = UUID()
//   /// 分类目录ID/产品类型
//   var typeId: Int  = 0
//   /// 产品ID
//   var productId: Int
//   var name: String // 名称
//   var icon: String = ""  // 图片
//   var createdAt: Int = 0
//   var parameter: String = "" // 产品参数
//   var other: String = ""  //其他信息
//   var des: String = "描述"
//   var title: String = "详情页面"
//    var specifications: [SpecificationsItem]
//
//    public init(_ typeId: Int = 0, productId: Int = 0, name: String, icon: String = "", at: Int = 0, parameter: String = "", other: String = "", des: String = "", title: String = "") {
//        self.typeId = typeId
//        self.productId = productId
//        self.name = name
//        self.icon = icon
//        self.parameter = parameter
//        self.other = other
//        self.des = des
//        self.title = title
//        self.createdAt = at
//    }
//}



@available(iOSApplicationExtension,unavailable)
@MainActor
public struct LTBrowseDetailsView: View {
    
    @State var produc: ProducModel
    @State private var specifications: Array<SpecificationsItem>
    @EnvironmentObject private var dataCenter: LTBrowseDataCenter
    @Environment(\.presentationMode) var presentationMode
    
    private let adapter = LTScreenAdapter.shared
    public init(produc: ProducModel) {
        self.produc = produc
        self._specifications = State(initialValue: produc.specifications)
    }
    public var body: some View {

        VStack {
            // 大图
            VStack(alignment: .center) {
                
                if let image = UIImage(named: produc.icon) {
                   Image(uiImage: image)
                       .resizable()
                       .frame(width: LTB_SCRE_W * 0.9, height: LTB_SCRE_W * 0.9)
               }else if let urlIcon = URL(string: produc.icon) {
                   KFImage(urlIcon)
                       .resizable()  //.aspectRatio(contentMode: .fill)
                       .frame(width: LTB_SCRE_W * 0.9, height: LTB_SCRE_W * 0.9)

               } else {
                   // 显示默认图片或占位符
                   Rectangle()
                       .fill(Color.gray.opacity(0.2))
                       .frame(width: LTB_SCRE_W * 0.9, height: LTB_SCRE_W * 0.9)
               }
            
            }
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 1)
            
            /// 标题
            Text(produc.name).frame(width: LTB_SCRE_W * 0.8).multilineTextAlignment(.center)
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 2) {
                    HStack {
                        Text(dataCenter.titls[LTBrowseTitlsKey.DetailsViewSpecifications.keyValue]!).font(.system(size: 18, weight: .medium))
                        Spacer()
                    }.padding([.horizontal],20)
                        .padding(.top, 44)
                   
                    if specifications.isEmpty {
                        Spacer()
                    }else {
                        VStack {
                            
                            ForEach(specifications) {  item  in
                                setCell(item: item)
                            }
                            
                        }
                        .padding(.vertical, 10)
                        .frame(width: LTB_SCRE_W * 0.9)
                        .background(Color.white)
                        .cornerRadius(12.0)
                        .padding(.vertical,10)
                    }
                }
            }
        }
        .navigationBarHidden(false)
        .background(LTB_BG_Color.edgesIgnoringSafeArea(.all))
        .toolbar {
               ToolbarItem(placement: .principal) {
                   Text(dataCenter.titls[LTBrowseTitlsKey.DetailsViewTitle.keyValue]!)
                       .foregroundColor(.black).font(.system(size: 17, weight: .bold))  // 设置标题颜色
               }
           }
        .navigationBarItems(leading:  AnyView(UIView.returnNavLeftView(icon:"back_arrow",width: adapter.setSize(size: 18), height: adapter.setSize(size: 18) ,{
            dataCenter.notifyOperationResult(("Details",false))
            dataCenter.notifyOperationDetailsResult(false)
            presentationMode.wrappedValue.dismiss()
        })))
        .onAppear {
        }
//        .onReceive(dataCenter.$specificationsData) { newValue in
//            if LTBrowseDataCenter.isUseSpecifications {
//                self.specifications = newValue
//            }
//        }
    }
    
    @ViewBuilder
    private func setCell(item:SpecificationsItem) -> some View {
        let _item = item
        VStack(spacing: 2){
            HStack {
               Text(_item.title)
               Spacer()
               Text(_item.des)
            }.frame(height: 44)
            
            if item != specifications.last {
                Divider()
            }
        }
         .padding(.vertical,2)
         .padding(.horizontal, 25)
         .foregroundColor(.black)
    }
}

@MainActor let TestItems: Array<SpecificationsItem> = [
    SpecificationsItem(title:"型号1", des:"FD-R9101"),
    SpecificationsItem(title:"速别", des:"2速"),
    SpecificationsItem(title:"速别", des:"2速"),
    SpecificationsItem(title:"速别", des:"2速"),
    SpecificationsItem(title:"速别", des:"2速"),
    SpecificationsItem(title:"速别", des:"2速"),
    SpecificationsItem(title:"安装方式", des:"直装")
  
]

#Preview { //, specifications: TestItems
    LTBrowseDetailsView(produc: ProducModel(productId: 0, name: "eRX电子液压碟刹afefawefawwwefaefaeafefaefaefaefaefafdafeawefawefawefaewfaewfaefawefawefawefawefaefawefaewfawefawefawefawefawefa", icon: "", TestItems)).environmentObject(LTBrowseDataCenter.shared)
}
 
