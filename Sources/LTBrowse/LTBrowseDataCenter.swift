// The Swift Programming Language
// https://docs.swift.org/swift-book
// ⚠️数据中心设置的数据等级最高
//#if canImport(UIKit)
import UIKit
//#endif

import SwiftUI
import Combine
 
@MainActor
let LTB_SCRE_H = UIScreen.main.bounds.height
@MainActor
let LTB_SCRE_W = UIScreen.main.bounds.width

// 背景颜色
let LTB_BG_Color = Color(UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1))

// 解析错误类型
enum ParseError: Error, LocalizedError {
    case invalidJSONString
    case typeMismatch
    case invalidInputType
    
    var errorDescription: String? {
        switch self {
        case .invalidJSONString: return "无效的JSON字符串"
        case .typeMismatch: return "类型不匹配"
        case .invalidInputType: return "无效的输入类型"
        }
    }
}

/// 展示模型
public struct BrowseViewItem: Hashable, Identifiable {
    public var id = UUID()
    var pId: Int = 0
    var title: String
    var icon: String
    var theme: Color = .white
    /// 额外补充的值（建议是Json 字符串）
    var carrying: String = ""
    public init(pId: Int = 0,title: String, icon: String, theme: Color = .white, _ carrying: String = "") {
        self.pId = pId
        self.title = title
        self.icon = icon
        self.theme = theme
        self.carrying = carrying
    }
}
 
 

@MainActor
public enum LTBrowseTitlsKey {
    case ListViewTitle
    case DetailsViewTitle
    case DetailsViewSpecifications
        
    var keyValue: String {
        switch self {
        case .ListViewTitle:
            return "ListViewTitle"
        case .DetailsViewTitle:
            return "DetailsViewTitle"
        case .DetailsViewSpecifications:
            return "DetailsViewSpecifications"
        }
    }
}


@MainActor
public class WrapperModel: ObservableObject {
    @Published var pageName: String =  ""
    @Published var pageState: Bool = false
 
}

/// 数据管理中心 -  ⚠️数据中心设置的数据等级最高
@MainActor
public class LTBrowseDataCenter: ObservableObject {
    public static let shared = LTBrowseDataCenter()
    
    
    @Published var currentLanguage: String = "cn" {
         didSet {
             // 这里可以添加持久化语言的逻辑
             
         }
     }
    @Published var titls: [String:String] = [LTBrowseTitlsKey.ListViewTitle.keyValue: "产品列表",
                                             LTBrowseTitlsKey.DetailsViewTitle.keyValue: "详情",
                                             LTBrowseTitlsKey.DetailsViewSpecifications.keyValue: "产品规格"]
    /// 首页走马灯列表
    @Published var headIconData: [BrowseViewItem] = []
    /// 首页菜单列表
    @Published var menuListData:[BrowseViewItem] = []
    /// 首页内容列表
    @Published var contentListData: [BrowseViewItem] = []
 
    /// 产品分类-选项卡
    @Published var producTypes: [ProducType] = []
    /// 产品 - 内容 - `ProducType.typeId` : `[ProducModel]` 属于列表
    @Published var productsByCategoryData: [Int:[ProducModel]] = [:]
    
    @Published var specificationsData: [SpecificationsItem] = []
    
    /// 产品信息（适用于首页跳转详情时使用）
    @Published var productsDetailsData: ProducModel? = nil
    
    /// 文件路径
    @Published var fileUrlString = "http://oss.ltwoo-app.top/"
    
    // 新增：用于发布操作结果的Publisher

    private let operationResultSubject = PassthroughSubject<(String,Bool), Never>()
    var operationResultPublisher: AnyPublisher<(String,Bool), Never> {
          operationResultSubject.eraseToAnyPublisher()
    }
    /// 操作首页跳转至(name= 列表List /详情 Details )
    public  func notifyOperationResult(_ success: (name:String,state:Bool)) {
          operationResultSubject.send(success)
    }
    
    // 去详情页的状态操作
    private let operationDetailsResultSubject = PassthroughSubject<Bool, Never>()
    var operationDetailsResultPublisher: AnyPublisher<Bool, Never> {
        operationDetailsResultSubject.eraseToAnyPublisher()
    }
    /// 操作列表跳转至详情
    public  func notifyOperationDetailsResult(_ success: Bool) {
        operationDetailsResultSubject.send(success)
    }
    
    
    // 语言设置
    private let operationLanguageResultSubject = PassthroughSubject<String, Never>()
    var operationLanguageResultPublisher: AnyPublisher<String, Never> {
        operationLanguageResultSubject.eraseToAnyPublisher()
    }
    /// 操作列表跳转至详情
    public  func notifyOperationLanguageResult(_ language: String) {
        operationLanguageResultSubject.send(language)
    }
    
    
//    public func setLanguage(_ l: String) {
//        self.currentLanguage = l
//    }
//    
    
    /// 判断是否使用首页走马灯列表
    public static var isUseHeadIcon: Bool = false
 
    /// 判断是否使用首页菜单列表
    public static var isUseMenuList: Bool = false
 
    /// 判断是否使用首页内容列表
    public static var isUseContentList: Bool = false
 
    /// 判断是否使用产品类型下的分类数据
    public static var isUseProductsByCategory: Bool = false
 
    /// 判断是否使用产品类型数据
    public static var isUseProducTypes: Bool = false
 
    /// 判断是否使用规格数据
    public static var isUseSpecifications: Bool = false
    

    
    private init() {  }
    
    // MARK: - Data Setters
    /// 设置页面标题
    public func setTitles(_ key:LTBrowseTitlsKey, value: String) {
          self.titls[key.keyValue] = value
    }
    
    /// 设置文件路径
    public func setFileUrl(_ url: String) {
        self.fileUrlString = url
    }
    
    /// 设置首页走马灯列表
    public func setHeadIcon(_ data: Any) {
 
         setData(data, type: FirstBannerList.self) { $0.toBrowseViewItem() } completion: { result  in
            switch result {
            case .success(let items):
                LTBrowseDataCenter.shared.headIconData = items
                LTBrowseDataCenter.isUseHeadIcon = true
            case .failure(let err):
                print("Error decoding content list: \(err)")
                LTBrowseDataCenter.isUseHeadIcon = false
            }
        }
        
    }
 
    /**
     设置首页菜单数据
     例子：
     let menuJson = """
     [
         {
             "title": "ROAD公路",
             "icon": "icon1",
             "themeColor": {
                 "red": 0.0,
                 "green": 0.0,
                 "blue": 0.0,
                 "alpha": 1.0
             }
         }
     ]
     """
     let menuData = menuJson.data(using: .utf8)
     LTBrowseDataCenter.setMenuList(menuData as Any)
     */
    public static func setMenuList(_ data: Any) {
        LTBrowseDataCenter.shared.setData(data, type: FirstBannerList.self) { $0.toBrowseViewItem() } completion: { result  in
            switch result {
            case .success(let items):
                LTBrowseDataCenter.shared.menuListData = items
                LTBrowseDataCenter.isUseMenuList = true
            case .failure(let err):
                print("Error decoding content list: \(err)")
                LTBrowseDataCenter.isUseMenuList = false
            }
        }
    }
    
    /// 设置首页内容列表数据
    public func setContentList(_ data: Any) {
        setData(data, type: FirstBannerList.self) { $0.toBrowseViewItem() } completion: { result  in
            switch result {
            case .success(let items):
                self.contentListData = items
                LTBrowseDataCenter.isUseContentList = true
            case .failure(let err):
                print("Error decoding content list: \(err)")
                LTBrowseDataCenter.isUseContentList = false
            }
        }

    }
 
    /// 一次性加载首页数据设置
    public func setHompageData(json: String) {
        LTBrowseDataCenter.shared.setData(json, type: HomepageModel.self, transform: { homepageModel in
            return homepageModel
        }, completion: { result  in
            switch result {
            case .success((let items)):
                
               self.headIconData = items[0].firstBannerList.map { $0.toBrowseViewItem() }
               self.menuListData = items[0].categoryList.map {$0.toBrowseViewItem() }
               self.contentListData = items[0].secondBannerList.map { $0.toBrowseViewItem() }
               LTBrowseDataCenter.isUseHeadIcon = true
               LTBrowseDataCenter.isUseMenuList = true
               LTBrowseDataCenter.isUseContentList = true
                
              // 更新数据中心
              print("首页数据解析完成进行更新  : \(items)")
            case .failure(let error):
                print("首页数据解析失败: \(error.localizedDescription)")
                
            }
        })
    }
   
    /// 设置产品分类目录下的数据
    public func setProductCategories(typeID: Int,jsonString: String) {
        if let data = jsonString.data(using: .utf8) {
            do {
                let decoded = try JSONDecoder().decode([ProductDTO].self, from: data)
                let ary: [ProducModel] = decoded.map { $0.toProducModel() }
                self.productsByCategoryData = [typeID:ary]
                LTBrowseDataCenter.isUseProductsByCategory = true
            } catch {
                print("Error decoding product categories: \(error)")
                LTBrowseDataCenter.isUseProductsByCategory = false
            }
        }
    }
  
    /// 设置标签项数据
    @discardableResult
    public func setProducTypes(jsonString: String) -> [ProducType]? {
        if let data = jsonString.data(using: .utf8) {
            do {
                let decoded = try JSONDecoder().decode([TabItemDTO].self, from: data)
                self.producTypes = decoded.map { $0.toProducType() }
                LTBrowseDataCenter.isUseProducTypes = true
                return self.producTypes
            } catch {
                print("Error decoding tab items: \(error)")
                LTBrowseDataCenter.isUseProducTypes = false
                return nil
            }
        }else {
            return nil
        }
    }

    /// 详情页数据参数设置
    public  func setSpecifications(_ data: Any, _ type: String = "") {
         setData(data, type: ProductDetailsDTO.self, transform: { model in
            return model
        }, completion: { result  in
            switch result {
            case .success((let items)):
                let _y = items[0].toProducModel()
                self.productsDetailsData = _y.pm
            case .failure(let error):
                print("详情数据解析失败: \(error.localizedDescription)")
            }
        })
        
    }
    

   
 
 
    // MARK: - Data Getters
    /// 获取首页走马灯列表
    public static func getHeadIconData() -> [BrowseViewItem]  {
        return shared.headIconData
    }
    /// 获取首页菜单列表
    public static func getMenuList() -> [BrowseViewItem] {
        return shared.menuListData
    }
    /// 获取首页内容列表
    public static func getContentList() -> [BrowseViewItem] {
        return shared.contentListData
    }
    /// 获取产品类型下的分类数据
    public static func getProductsByCategory() -> [Int:[ProducModel]] {
        return shared.productsByCategoryData
    }
    /// 获取产品类型数据
    public static func getProducTypes() -> [ProducType] {
        return shared.producTypes
    }
    /// 获取规格数据
    public static func getSpecifications() -> [SpecificationsItem] {
        return shared.specificationsData
    }

    
    
    
    //MARK: - 私有 - 统一的JSON 解析方法
    private func parseData<T: Codable, U>(_ data: Data, type: T.Type, transform: (T) -> U, completion: @escaping (Result<[U], Error>) -> Void) {
        do {
 
          // 否则按原逻辑解析
          if let singleObject = try? JSONDecoder().decode(T.self, from: data) {
              completion(.success([transform(singleObject)]))
              return
          }
          
          if let array = try? JSONDecoder().decode([T].self, from: data) {
              completion(.success(array.map(transform)))
              return
          }
          
          throw ParseError.typeMismatch
            
        } catch {
     
             
            print("Error 转换:\(error)")
            completion(.failure(error))
        }
    }
    private func setData<T: Codable, U>(_ data: Any, type: T.Type, transform:  @escaping (T) -> U, completion: @escaping (Result<[U],Error>) -> Void) {
        // 统一转换为Data进行处理
           let processData: (Data) -> Void = { data in
               self.parseData(data, type: type, transform: transform, completion: completion)
           }
           
           switch data {
           case let jsonString as String:
               guard let data = jsonString.data(using: .utf8) else {
                   completion(.failure(ParseError.invalidJSONString))
                   return
               }
               processData(data)
               
           case let jsonData as Data:
               processData(jsonData)
               
           case let array as [T]:
               // 直接复用parseData的成功路径
               do {
                   let data = try JSONEncoder().encode(array)
                   processData(data)
               } catch {
                   completion(.failure(error))
               }
               
           case let model as T:
               // 直接复用parseData的成功路径
               do {
                   let data = try JSONEncoder().encode(model)
                   processData(data)
               } catch {
                   completion(.failure(error))
               }
               
           default:
               completion(.failure(ParseError.invalidInputType))
           }
    }

}


// MARK: - DTO Models
//MARK: -首页数据模型
public struct HomepageModel: Codable {
    var firstBannerList: [FirstBannerList]
    var secondBannerList: [FirstBannerList]
    var categoryList: [CategoryList]
    
    
    // 转换为新的 HomepageModel 或其他目标模型
    func toTransformedModel<U>(transform: (FirstBannerList) -> U, categoryTransform: (CategoryList) -> U) -> [U] {
        let firstBannerItems = firstBannerList.map(transform)
        let secondBannerItems = secondBannerList.map(transform)
         let categoryItems = categoryList.map(categoryTransform)
        return firstBannerItems + secondBannerItems + categoryItems
        
    }
 
}
 
//MARK: -首页数据模型 - 头部Banneer
public struct FirstBannerList:  Codable {
    var imageUrl: String
    var productId: Int
   // var themeColor: ColorDTO?
    /// 构建 BrowseViewItem 模型
     func toBrowseViewItem(_ theme:ColorDTO? = nil) -> BrowseViewItem {
        return BrowseViewItem(
            pId: productId,
            title: "",
            icon:  imageUrl, //LTBrowseDataCenter.shared.getFileUrl() +
            theme: theme?.toColor() ?? .blue
        )
    }
}

//MARK: -首页数据模型 - 分类
public struct CategoryList:  Codable {
    var categoryName: String = ""
    var imageUrl: String = ""
    var id: Int = 0
 
    func toBrowseViewItem(_ theme:ColorDTO? = nil) -> BrowseViewItem {
        return BrowseViewItem(
            pId: id,
            title: categoryName,
            icon:  imageUrl, //"http://oss.ltwoo-app.top/" +
            theme: theme?.toColor() ?? .blue
        )
    }
}
 


//MARK: - 分类目录数据模型
private struct TabItemDTO: Codable {
    let id: Int
    let categoryName: String
    let speedClass: String
    
    func toProducType() -> ProducType {
        return ProducType(id, name: categoryName, gearValue: speedClass)
    }
}

//MARK: - 产品模型(非详细)
private class ProductDTO: Codable {
    /// 产品id
    var id: Int
    /// 产品名称
    var productName: String
    /// 产品图片
    var imageUrl: String
    /// 分类目录id
    var productCategoryId: Int
    /// 分类目录名称
    var productCategoryName: String
    // 创建时间
    var createdAt: Int
 
    /// 产品参数
    let parameter: String?
    let other: String?
    let des: String?
    
    func toProducModel() -> ProducModel { //"http://oss.ltwoo-app.top/" + 
        return ProducModel(productCategoryId, productId: id, name: productName, icon: imageUrl, at: createdAt, parameter: parameter ?? "", other: other ?? "", des: des ?? "", title: productCategoryName)
        
    }
}

//MARK: - 产品模型（详细）
private struct ProductDetailsDTO: Codable {
    /// 产品id
    var id: Int
    /// 产品名称
    var productName: String
    /// 产品图片
    var imageUrl: String
    /// 分类目录id
    var productCategoryId: Int?
    /// 分类目录名称
    var productCategoryName: String?
 
    var specificationMap: String?
    
    var specificationList: [SpecificationDTO]
    ///
    func toProducModel() -> (pm:ProducModel, slist:[SpecificationsItem]) {
//        return SpecificationsItem(pId,title: key, des: value)
        let _list = specificationList.map { $0.toSpecificationsItem(pId: id) }  //("http://oss.ltwoo-app.top/" +
        let _pm  = ProducModel(productCategoryId ?? 0, productId: id ?? 0, name: productName  , icon:  imageUrl, at: 0, parameter: "", other:"", des: "", title: productCategoryName ?? "", _list)
        return (_pm, _list)
    }
 
}

//MARK: - 产品参数模型
private struct SpecificationDTO: Codable {
//    /// 产品ID
//    let pId: Int
    /// key
    let key: String
    /// value
    let value: String
    
    func toSpecificationsItem(pId: Int) -> SpecificationsItem {
        return SpecificationsItem(pId,title: key, des: value)
    }
}

 

public struct ColorDTO: Codable {
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
    static func returnNavLeftView(icon:String = "back", width: CGFloat, height: CGFloat, _ operate:(()-> Void)?) -> some View {
        return HStack {
            
            Button {
                operate?()
            } label: {
                HStack {
                    if #available(iOS 15.0, *) {
                        Image(icon).resizable().frame(width: width, height: height)
                            .scaledToFit()
                            .tint(.blue)
                    } else {
                        Image(icon).resizable().frame(width: width, height: height)
                            .scaledToFit()
                            .foregroundColor(.red)
                    }
                }
            }
        }
    }
}
 
