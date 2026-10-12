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
 

@available(iOSApplicationExtension,unavailable)
@MainActor
public struct LTBrowseDetailsView: View {
    
    @State var produc: ProducModel
    @State private var specifications: Array<SpecificationsItem>
    @State private var isShowingImagePreview = false
    @EnvironmentObject private var dataCenter: LTBrowseDataCenter
    @Environment(\.presentationMode) var presentationMode
    
    private let adapter = LTScreenAdapter.shared
    public init(produc: ProducModel) {
        self.produc = produc
        self._specifications = State(initialValue: produc.specifications)
    }
    public var body: some View {

        VStack {
            // Big picture
            VStack(alignment: .center) {
                let fullURLString = produc.icon.lowercased().hasPrefix("http")
                    ? produc.icon
                    : dataCenter.fileUrlString + produc.icon
                    if let urlIcon = URL(string: fullURLString) {
                       KFImage(urlIcon)
                           .resizable()
                           .frame(width: LTB_SCRE_W * 0.9, height: LTB_SCRE_W * 0.9)

                    }else if  let image = UIImage(named: produc.icon) {
                        Image(uiImage: image)
                            .resizable()
                            .frame(width: LTB_SCRE_W * 0.9, height: LTB_SCRE_W * 0.9)
                        
                    }else {
                       // 显示默认图片或占位符
                       Rectangle()
                           .fill(Color.gray.opacity(0.2))
                           .frame(width: LTB_SCRE_W * 0.9, height: LTB_SCRE_W * 0.9)
                   }
 
            }
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 1)
            .contentShape(Rectangle())
            .onTapGesture {
                guard !produc.icon.isEmpty else { return }
                isShowingImagePreview = true
            }
            
            // title
            Text(produc.name).frame(width: LTB_SCRE_W * 0.8).multilineTextAlignment(.center)
            
            // parameter
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
        .fullScreenCover(isPresented: $isShowingImagePreview) {
            LTBrowseImagePreview(icon: produc.icon)
        }
       // .environment(\.locale, .init(identifier: dataCenter.currentLanguage))
        
    }
    
    @ViewBuilder
    private func setCell(item: SpecificationsItem) -> some View {
        VStack(spacing: 2) {
            HStack(alignment: .center, spacing: 12) {
                Text(item.title)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(displayDes(item.des))
            }
            .frame(minHeight: 44)
            
            if item != specifications.last {
                Divider()
            }
        }
        .padding(.vertical, 2)
        .padding(.horizontal, 25)
        .foregroundColor(.black)
    }
    
    private func displayDes(_ des: String) -> String {
        switch des.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
        case "true":
            return "✅"
        case "false":
            return "❌"
        default:
            return des
        }
    }
}

@available(iOSApplicationExtension, unavailable)
private struct LTBrowseImagePreview: View {
    let icon: String
    @Environment(\.presentationMode) private var presentationMode
    
    @State private var scale: CGFloat = 1
    @State private var lastScale: CGFloat = 1
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            previewImage
                .scaleEffect(scale)
                .offset(offset)
                .gesture(doubleTapGesture)
                .simultaneousGesture(magnificationGesture)
                .simultaneousGesture(dragGesture)
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: dismiss) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(Color.white.opacity(0.25))
                            .clipShape(Circle())
                    }
                    .padding(.trailing, 20)
                    .padding(.top, 16)
                }
                Spacer()
            }
        }
    }
    
    @ViewBuilder
    private var previewImage: some View {
        if let url = URL(string: icon), !icon.isEmpty {
            KFImage(url)
                .resizable()
                .scaledToFit()
        } else if let image = UIImage(named: icon) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
        }
    }
    
    private var magnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                scale = min(max(lastScale * value, 1), 5)
            }
            .onEnded { _ in
                lastScale = scale
                if scale <= 1 {
                    resetZoom()
                }
            }
    }
    
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                if scale > 1 {
                    offset = CGSize(
                        width: lastOffset.width + value.translation.width,
                        height: lastOffset.height + value.translation.height
                    )
                } else {
                    offset = CGSize(width: 0, height: value.translation.height)
                }
            }
            .onEnded { value in
                if scale <= 1 {
                    if value.translation.height > 100 {
                        dismiss()
                    } else {
                        withAnimation(.easeOut(duration: 0.2)) {
                            resetZoom()
                        }
                    }
                } else {
                    lastOffset = offset
                }
            }
    }
    
    private var doubleTapGesture: some Gesture {
        TapGesture(count: 2).onEnded {
            withAnimation(.easeInOut(duration: 0.25)) {
                if scale > 1 {
                    resetZoom()
                } else {
                    scale = 2.5
                    lastScale = 2.5
                }
            }
        }
    }
    
    private func resetZoom() {
        scale = 1
        lastScale = 1
        offset = .zero
        lastOffset = .zero
    }
    
    private func dismiss() {
        presentationMode.wrappedValue.dismiss()
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
    LTBrowseDetailsView(produc: ProducModel(productId: 0, name: "eRX电子液压碟刹afefawefawwwefaefaeafefaefaefaefaefafdafeawefawefawefaewfaewfaefawefawefawefawefaefawefaewfawefawefawefawefawefa", icon: "", TestItems)).environmentObject(LTBrowseDataCenter.shared)
}
 
