//
//  SwiftUIView.swift
//  LTBrowse
//
//  Created by K YTYan on 2025/3/5.
//

import SwiftUI


//Product specifications
public struct SpecificationsItem: Identifiable,Hashable {
    public var id = UUID()
    /// 标题
    var title: String
    /// 描述
    var des: String = ""
    public init(title: String, des: String = "") {
        self.title = title
        self.des = des
    }
}

 


@available(iOSApplicationExtension,unavailable)
@MainActor
public struct LTBrowseDetailsView: View {
    
    @State var produc: ProducModel
    @State var specifications: Array<SpecificationsItem>
    @State var title = "详情"
 
    @Environment(\.presentationMode) var presentationMode
    public init(produc: ProducModel,specifications: [SpecificationsItem] = []) {
        self.produc = produc
      
        if LTBrowseDataCenter.isUseSpecifications {
            self.specifications =  LTBrowseDataCenter.getSpecifications()
        }else {
            self.specifications = specifications
        }
 
    }
    public var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
          
            VStack(alignment: .leading) {
                
                if let image = UIImage(named: produc.icon) {
                   Image(uiImage: image)
                       .resizable()
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
            Text(produc.name).frame(width: LTB_SCRE_W * 0.8).multilineTextAlignment(.center)
 
            VStack(spacing: 2) {
                HStack {
                    Text("产品规格").font(.system(size: 18, weight: .medium))
                    Spacer()
                }.padding([.horizontal],20)
                    .padding(.top, 44)
               
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
        .background(LTB_BG_Color.edgesIgnoringSafeArea(.all))
        .navigationTitle(Text("\(self.title)"))
        .navigationBarItems(leading: AnyView(UIView.returnNavLeftView({
            presentationMode.wrappedValue.dismiss()
        })))
        .onAppear {
        }
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

#Preview {
    LTBrowseDetailsView(produc: ProducModel(name: "eRX电子液压碟刹afefawefawwwefaefaeafefaefaefaefaefafdafeawefawefawefaewfaewfaefawefawefawefawefaefawefaewfawefawefawefawefawefa", icon: ""), specifications: TestItems)
 
}
 
