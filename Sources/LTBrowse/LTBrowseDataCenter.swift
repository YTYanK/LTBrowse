// The Swift Programming Language
// https://docs.swift.org/swift-book
// ⚠️数据中心设置的数据等级最高

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
 
/// 数据管理中心 -  ⚠️数据中心设置的数据等级最高
@MainActor
public class LTBrowseDataCenter: NSObject {
    public static let shared = LTBrowseDataCenter()
    /// 首页走马灯列表
    private var headIconData: [String] = []
    /// 首页菜单列表
    private var menuListData:[BrowseViewItem] = []
    /// 首页内容列表
    private var contentListData: [BrowseViewItem] = []
 
    /// 产品分类-选项卡
    private var producTypes: [ProducType] = []
    /// 产品 - 内容
    private var productsByCategoryData: [[ProducModel]] = []
    
    private var specificationsData: [SpecificationsItem] = []
    override init() {
        super.init()
    }
    
    // MARK: - Data Setters
    /// 设置首页走马灯列表
    public func setHeadIcon(jsonString: String) {
        if let data = jsonString.data(using: .utf8) {
            do {
                let decoded = try JSONDecoder().decode([String].self, from: data)
                self.headIconData = decoded.map { String($0) }
            } catch {
                print("Error decoding menu list: \(error)")
            }
        }
    }
    public func setHeadIcon(_ data: Any) {
        setData(data, type: String.self) { String($0) } completion: { [weak self] items in
            self?.headIconData = items
        }
    }
    

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
    /// 设置首页菜单数据
    public static func setMenuList(_ data: Any) {
        LTBrowseDataCenter.shared.setData(data, type: MenuItemDTO.self) { $0.toBrowseViewItem() } completion: { items in
            LTBrowseDataCenter.shared.menuListData = items
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
    public func setContentList(_ data: Any) {
        setData(data, type: ContentItemDTO.self, transform: { $0.toBrowseViewItem() }) { [weak self] items in
            self?.contentListData = items
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
    public func setProductCategories(_ data: Any) {
        setData(data, type: ProductCategoryDTO.self) { $0.toProducModels()
        } completion: { [weak self] items in
            self?.productsByCategoryData = items
        }

    }
    
    /// 设置标签项数据
    public func setProducTypes(jsonString: String) {
        if let data = jsonString.data(using: .utf8) {
            do {
                let decoded = try JSONDecoder().decode([TabItemDTO].self, from: data)
                self.producTypes = decoded.map { $0.toProducType() }
            } catch {
                print("Error decoding tab items: \(error)")
            }
        }
    }
    public func setProducTyes(_ data: Any) {
        setData(data, type: TabItemDTO.self, transform: { $0.toProducType()}) { [weak self] items in
            self?.producTypes = items
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
    public  func setSpecifications(_ data: Any) {
        setData(data, type: SpecificationDTO.self, transform: { $0.toSpecificationsItem() }) { [weak self] items in
            self?.specificationsData = items
        }
    }
    
    // 统一的JSON 解析方法
    private func parseJSON<T: Codable, U>(_ jsonString: String, type: T.Type, transform: (T) -> U, completion: @escaping ([U]) -> Void) {
        guard let data = jsonString.data(using: .utf8) else {
            print("Error: 无效的JSON 字符串")
            completion([])
            return
        }
        parseData(data, type: type, transform: transform, completion: completion)
    }
    
    private func parseData<T: Codable, U>(_ data: Data, type: T.Type, transform: (T) -> U, completion: @escaping ([U]) -> Void) {
        do {
            let decoded = try JSONDecoder().decode([T].self, from: data)
            completion(decoded.map(transform))
        } catch
        {
            print("Error 转换:\(error)")
            completion([])
        }
    }
    
    
    private func setData<T: Codable, U>(_ data: Any, type: T.Type, transform: (T) -> U, completion: @escaping ([U]) -> Void) {
        if let jsonString = data as? String {
            parseJSON(jsonString, type: type, transform: transform, completion: completion)
        }else if let jsonData = data as? Data {
            parseData(jsonData, type: type, transform: transform, completion: completion)
        }else if let array = data as? [T] {
            completion(array.map(transform))
        }
    }
    
    
    /// 批量设置
    public func setupAllData(headIcons: Any? = nil, menuList: Any? = nil, contentList: Any? = nil, productCategories: Any? = nil, producTypes: Any? = nil, specifications: Any? = nil) {
        if let _headIcons = headIcons {
            setHeadIcon(_headIcons)
        }
        if let _menuList = menuList {
            LTBrowseDataCenter.setMenuList(_menuList)
        }
        if let _contentList = contentList {
            setContentList(_contentList)
        }
        if let _productCategories = productCategories {
            setProductCategories(_productCategories)
        }
        if let _producTypes = producTypes {
            setProducTyes(_producTypes)
        }
        if let _specifications = specifications {
            setSpecifications(_specifications)
        }
    }
    



    // MARK: - Data Getters
    /// 获取首页走马灯列表
    public static func getHeadIconData() -> [String]  {
        return LTBrowseDataCenter.shared.headIconData
    }
    /// 获取首页菜单列表
    public static func getMenuList() -> [BrowseViewItem] {
        return LTBrowseDataCenter.shared.menuListData
    }
    /// 获取首页内容列表
    public static func getContentList() -> [BrowseViewItem] {
        return LTBrowseDataCenter.shared.contentListData
    }
    /// 获取产品类型下的分类数据
    public static func getProductsByCategory() -> [[ProducModel]] {
        return LTBrowseDataCenter.shared.productsByCategoryData
    }
    /// 获取产品类型数据
    public static func getProducTypes() -> [ProducType] {
        return LTBrowseDataCenter.shared.producTypes
    }
    /// 获取规格数据
    public static func getSpecifications() -> [SpecificationsItem] {
        return LTBrowseDataCenter.shared.specificationsData
    }
    
 
    
    /// 判断是否使用首页走马灯列表
    static var isUseHeadIcon: Bool {
        return !LTBrowseDataCenter.shared.headIconData.isEmpty
    }
    /// 判断是否使用首页菜单列表
    static var isUseMenuList: Bool {
        return !LTBrowseDataCenter.shared.menuListData.isEmpty
    }
    /// 判断是否使用首页内容列表
    static var isUseContentList: Bool {
        return !LTBrowseDataCenter.shared.contentListData.isEmpty
    }
    /// 判断是否使用产品类型下的分类数据
    static var isUseProductsByCategory: Bool {
        return !LTBrowseDataCenter.shared.productsByCategoryData.isEmpty
    }
    /// 判断是否使用产品类型数据
    static var isUseProducTypes: Bool {
        return !LTBrowseDataCenter.shared.producTypes.isEmpty
    }
    /// 判断是否使用规格数据
    static var isUseSpecifications: Bool {
        return !LTBrowseDataCenter.shared.specificationsData.isEmpty
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
            theme: themeColor?.toColor() ?? .black
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
    let typeId: Int
    let name: String
    let icon: String
    let parameter: String?
    let other: String?
    let des: String?
    
    func toProducModel() -> ProducModel {
        return ProducModel(
            typeId,
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
 
