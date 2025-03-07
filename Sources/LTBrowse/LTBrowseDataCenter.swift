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

/// 展示模型
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
 
/// 数据管理中心
@MainActor
public class LTBrowseDataCenter: NSObject {
    public static let shared = LTBrowse()
    
    /// 首页数据-菜单列表
    private var menuListData:[BrowseViewItem] = []
    /// 首页数据-内容列表
    private var contentListData: [BrowseViewItem] = []
 
    /// 列表数据-选项卡
    private var tabItemsData: [ProducType] = []
    /// 列表数据 - 内容
    private var productsByCategoryData: [ProducModel] = []
    
    private var specificationsData: [SpecificationsItem] = []
    override init() {
        super.init()
    }
    
    // MARK: - Data Setters
        
        /// 设置首页菜单数据
        public func setMenuList(jsonString: String) {
            if let data = jsonString.data(using: .utf8) {
                do {
                    let decoded = try JSONDecoder().decode([MenuItemDTO].self, from: data)
                    self.menuListData = decoded.map { $0.toBrowseViewItem() }
                } catch {
                    print("Error decoding menu list: \(error)")
                }
            }
        }
        
        /// 设置首页内容列表数据
        public func setContentList(jsonString: String) {
            if let data = jsonString.data(using: .utf8) {
                do {
                    let decoded = try JSONDecoder().decode([ContentItemDTO].self, from: data)
                    self.contentListData = decoded.map { $0.toBrowseViewItem() }
                } catch {
                    print("Error decoding content list: \(error)")
                }
            }
        }
        
        /// 设置产品分类数据
        public func setProductCategories(jsonString: String) {
            if let data = jsonString.data(using: .utf8) {
                do {
                    let decoded = try JSONDecoder().decode([ProductCategoryDTO].self, from: data)
                    self.productsByCategoryData = decoded.map { $0.toProducModels() }
                } catch {
                    print("Error decoding product categories: \(error)")
                }
            }
        }
        
        /// 设置标签项数据
        public func setTabItems(jsonString: String) {
            if let data = jsonString.data(using: .utf8) {
                do {
                    let decoded = try JSONDecoder().decode([TabItemDTO].self, from: data)
                    self.tabItemsData = decoded.map { $0.toProducType() }
                } catch {
                    print("Error decoding tab items: \(error)")
                }
            }
        }
        
        /// 设置规格数据
        public func setSpecifications(jsonString: String) {
            if let data = jsonString.data(using: .utf8) {
                do {
                    let decoded = try JSONDecoder().decode([SpecificationDTO].self, from: data)
                    self.specificationsData = decoded.map { $0.toSpecificationsItem() }
                } catch {
                    print("Error decoding specifications: \(error)")
                }
            }
        }
        
        // MARK: - Data Getters
        
        public func getMenuList() -> [BrowseViewItem] {
            return menuListData
        }
        
        public func getContentList() -> [BrowseViewItem] {
            return contentListData
        }
        
        public func getProductsByCategory() -> [[ProducModel]] {
            return productsByCategoryData
        }
        
        public func getTabItems() -> [ProducType] {
            return tabItemsData
        }
        
        public func getSpecifications() -> [SpecificationsItem] {
            return specificationsData
        }
    
}


// MARK: - DTO Models
private struct MenuItemDTO: Codable {
    let title: String
    let icon: String
    let themeColor: ColorDTO?
    
    func toBrowseViewItem() -> BrowseViewItem {
        return BrowseViewItem(
            title: title,
            icon: icon,
            theme: themeColor?.toColor() ?? .white
        )
    }
}

private struct ContentItemDTO: Codable {
    let title: String
    let icon: String
    let themeColor: ColorDTO?
    
    func toBrowseViewItem() -> BrowseViewItem {
        return BrowseViewItem(
            title: title,
            icon: icon,
            theme: themeColor?.toColor() ?? .white
        )
    }
}

private struct ProductCategoryDTO: Codable {
    let products: [ProductDTO]
    
    func toProducModels() -> [ProducModel] {
        return products.map { $0.toProducModel() }
    }
}

private struct ProductDTO: Codable {
    let type: Int
    let name: String
    let icon: String
    let parameter: String?
    let other: String?
    let des: String?
    
    func toProducModel() -> ProducModel {
        return ProducModel(
            type,
            name: name,
            icon: icon,
            parameter: parameter ?? "",
            other: other ?? "",
            des: des ?? ""
        )
    }
}

private struct TabItemDTO: Codable {
    let typeId: Int
    let name: String
    let gearValue: String
    
    func toProducType() -> ProducType {
        return ProducType(typeId, name: name, gearValue: gearValue)
    }
}

private struct SpecificationDTO: Codable {
    let title: String
    let des: String
    
    func toSpecificationsItem() -> SpecificationsItem {
        return SpecificationsItem(title: title, des: des)
    }
}

private struct ColorDTO: Codable {
    let red: Double
    let green: Double
    let blue: Double
    let alpha: Double
    
    func toColor() -> Color {
        return Color(UIColor(red: CGFloat(red),
                           green: CGFloat(green),
                           blue: CGFloat(blue),
                           alpha: CGFloat(alpha)))
    }
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
 
