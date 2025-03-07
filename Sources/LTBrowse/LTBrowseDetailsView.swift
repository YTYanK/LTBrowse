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
}

 


@available(iOSApplicationExtension,unavailable)
@MainActor
public struct LTBrowseDetailsView: View {
    @State var produc: ProducModel
    @State var items: Array<SpecificationsItem> =  []
    @State var title = "详情"
    @Environment(\.presentationMode) var presentationMode
    public init(produc: ProducModel,items: Array<SpecificationsItem> = []) {
        self.produc = produc
        self.items = items
    }
    public var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
          
            VStack(alignment: .leading) {
                Image(produc.icon).resizable().frame(width: LTB_SCRE_W * 0.9, height: LTB_SCRE_W * 0.9)
            }
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 1)
            Text(produc.name)
            
           
            
            VStack(spacing: 2) {
                HStack {
                    Text("产品规格").font(.system(size: 18, weight: .medium))
                    Spacer()
                }.padding([.horizontal],20)
                    .padding(.top, 44)
               
                VStack {
                   
                    ForEach(items) {  item  in
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
        //.frame(width: LTB_SCRE_W, height: LTB_SCRE_H)
        .background(LTB_BG_Color.edgesIgnoringSafeArea(.all))
        .navigationTitle(Text("\(self.title)"))
        .navigationBarItems(leading: AnyView(UIView.returnNavLeftView({
            presentationMode.wrappedValue.dismiss()
        })))
        .onAppear {
            self.items = TestItems
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
            
            if item != items.last {
                Divider()
            }
        }
         .padding(.vertical,2)
         .padding(.horizontal, 25)
         .foregroundColor(.black)
    }
}

@MainActor let TestItems: Array<SpecificationsItem> = [
    SpecificationsItem(title:"型号", des:"FD-R9101"),
    SpecificationsItem(title:"速别", des:"2速"),
    SpecificationsItem(title:"速别", des:"2速"),
    SpecificationsItem(title:"速别", des:"2速"),
    SpecificationsItem(title:"速别", des:"2速"),
    SpecificationsItem(title:"速别", des:"2速"),
    SpecificationsItem(title:"安装方式", des:"直装")
  
]

#Preview {
    LTBrowseDetailsView(produc: ProducModel(name: "eRX电子液压碟刹", icon: ""), items: TestItems)
}
 
