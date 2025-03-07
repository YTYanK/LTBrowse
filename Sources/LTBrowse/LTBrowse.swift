// The Swift Programming Language
// https://docs.swift.org/swift-book


import UIKit
import SwiftUI
 
@MainActor
let LTB_SCRE_H = UIScreen.main.bounds.height
@MainActor
let LTB_SCRE_W = UIScreen.main.bounds.width

// 背景颜色
let LTB_BG_Color = Color(UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1))


public struct BrowseViewItem: Hashable, Identifiable {
    public var id = UUID()
    var title: String
    var icon: String
    var theme: Color = .white
 
    public init(title: String, icon: String, theme: Color = .white) {
        self.title = title
        self.icon = icon
        self.theme = theme
    }
}
 

class LTBrowse: NSObject {
    override init() {}
}



extension CGFloat {
    
    // CGFloat(arc4random()) / CGFloat(UInt32.max)
    // 最大值UInt32是4,294,967,295(即2^32 - 1)
    static func randomUINT8() -> CGFloat {
        return  CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
    
    /// 获取状态栏高度
    @MainActor static func statusBarHeight() -> CGFloat {
        let window =  UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first?.windows.first
        return window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
 
    }
    
}

extension Color {
    /// 随机颜色
    static func randomColor() -> Color {
//        let _r = Double.random(in: 1...254.0)
//        let _g = Double.random(in: 1...254.0)
//        let _b = Double.random(in: 1...254.0)
//
//        return Color(red: _r, green: _g, blue: _b)
        return  Color(UIColor(red: .randomUINT8(), green: .randomUINT8(), blue: .randomUINT8(), alpha: 1.0))
    }
    
}
 
extension UIView {
    /// 自定义导航条按钮
    static func returnNavLeftView(_ operate: (()-> Void)?) -> some View {
        return HStack {
            
            Button {
                operate?()
            } label: {
                HStack {
                    Image("back").resizable().frame(width: 18, height: 18)
//                    Text("返回")
                }
            }
        }

    }
}



//@available(iOSApplicationExtension,unavailable)
//@MainActor
//@objcMembers open class LTBrowse {
//    
//}

//public struct BrowseHomeView: View {
//    public init() {}
//    
//    public var body: some View {
//        Text("Browse Home")
//    }
//}
//
//public struct BrowseDetailsView: View {
//    public init() {}
//    
//    public var body: some View {
//        Text("Browse Details")
//    }
//}
//
//public struct BrowseListView: View {
//    public init() {}
//    
//    public var body: some View {
//        Text("Browse List")
//    }
//}

//@available(iOSApplicationExtension, unavailable)
//@MainActor
//public struct LTBrowseView: View {
//    
//    let title: String
//    public init() {
//        title = "测试"
//    }
//    
//    public var body: some View {
//        Text("Hello, World! \(title)")
//    }
//}
//
//#Preview {
//    LTBrowseView()
//}
