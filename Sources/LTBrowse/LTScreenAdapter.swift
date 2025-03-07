import UIKit

// 设备类型枚举
public enum LTDeviceType {
    case iPhone_Small      // SE系列
    case iPhone_Standard   // 标准尺寸 iPhone
    case iPhone_Plus      // Plus系列
    case iPhone_Pro       // Pro系列
    case iPhone_ProMax    // Pro Max系列
    case iPad_Standard    // 标准iPad
    case iPad_Pro_11      // iPad Pro 11
    case iPad_Pro_12_9    // iPad Pro 12.9
    case unknown
    
    // 基准设计尺寸
    var baseSize: CGSize {
        switch self {
        case .iPhone_Small:
            return CGSize(width: 375, height: 667)  // iPhone SE2
        case .iPhone_Standard:
            return CGSize(width: 390, height: 844)  // iPhone 12/13/14
        case .iPhone_Plus:
            return CGSize(width: 428, height: 926)  // iPhone 14 Plus
        case .iPhone_Pro:
            return CGSize(width: 393, height: 852)  // iPhone 14 Pro
        case .iPhone_ProMax:
            return CGSize(width: 430, height: 932)  // iPhone 14 Pro Max
        case .iPad_Standard:
            return CGSize(width: 810, height: 1080) // iPad Air
        case .iPad_Pro_11:
            return CGSize(width: 834, height: 1194) // iPad Pro 11
        case .iPad_Pro_12_9:
            return CGSize(width: 1024, height: 1366) // iPad Pro 12.9
        case .unknown:
            return CGSize(width: 390, height: 844)  // 默认使用标准iPhone尺寸
        }
    }
}

@MainActor
public class LTScreenAdapter {
    // 单例
    public static let shared = LTScreenAdapter()
    
    // 当前设备类型
    private let deviceType: LTDeviceType
    
    // 当前设备屏幕尺寸
    private let screenWidth: CGFloat
    private let screenHeight: CGFloat
    
    // 缩放比例
    private let widthScale: CGFloat
    private let heightScale: CGFloat
    
    // 是否是iPad
    public let isPad: Bool
    
    private init() {
        let bounds = UIScreen.main.bounds
        screenWidth = bounds.width
        screenHeight = bounds.height
        isPad = UIDevice.current.userInterfaceIdiom == .pad
        
        // 确定设备类型
        deviceType = LTScreenAdapter.detectDeviceType()
        
        let baseSize = deviceType.baseSize
        widthScale = screenWidth / baseSize.width
        heightScale = screenHeight / baseSize.height
    }
    
    
    
    
    // 检测设备类型
    private static func detectDeviceType() -> LTDeviceType {
        let device = UIDevice.current
        let screen = UIScreen.main
        
        if device.userInterfaceIdiom == .pad {
            let screenSize = screen.bounds.size
            if screenSize.width >= 1024 {
                return .iPad_Pro_12_9
            } else if screenSize.width >= 834 {
                return .iPad_Pro_11
            } else {
                return .iPad_Standard
            }
        }
        
        // iPhone设备识别
        let screenHeight = max(screen.bounds.width, screen.bounds.height)
        switch screenHeight {
        case 667:
            return .iPhone_Small      // iPhone SE2
        case 812:
            return .iPhone_Standard   // iPhone X/XS/11 Pro
        case 844, 852:
            return .iPhone_Standard   // iPhone 12/13/14
        case 896:
            return .iPhone_Plus      // iPhone XR/XS Max/11
        case 926:
            return .iPhone_Plus      // iPhone 14 Plus
        case 932:
            return .iPhone_ProMax    // iPhone 14 Pro Max
        default:
            return .unknown
        }
    }
    
    // 获取设备类型
    public func getCurrentDeviceType() -> LTDeviceType {
        return deviceType
    }
    
    // 字体大小适配（考虑设备类型）
    public func setFont(size: CGFloat) -> CGFloat {
        let scale = min(widthScale, heightScale)
        if isPad {
            // iPad上字体稍大一些
            return size * scale * 1.2
        }
        return size * scale
    }
    
    // 宽度适配（考虑设备类型）
    public func setWidth(_ width: CGFloat) -> CGFloat {
        if isPad {
            // iPad上控件相对更大
            return width * widthScale * 1.3
        }
        return width * widthScale
    }
    
    // 高度适配（考虑设备类型）
    public func setHeight(_ height: CGFloat) -> CGFloat {
        if isPad {
            // iPad上控件相对更大
            return height * heightScale * 1.3
        }
        return height * heightScale
    }
    
    // 获取相对宽度（考虑设备类型）
    public func getRelativeWidth(_ ratio: CGFloat) -> CGFloat {
        return screenWidth * ratio
    }
    
    // 获取相对高度（考虑设备类型）
    public func getRelativeHeight(_ ratio: CGFloat) -> CGFloat {
        return screenHeight * ratio
    }
    
    // 等比例缩放尺寸（考虑设备类型）
    public func setSize(size: CGFloat) -> CGFloat {
        let scale = min(widthScale, heightScale)
        if isPad {
            return size * scale * 1.3
        }
        return size * scale
    }
    
    // 获取安全区域
    public func getSafeAreaInsets() -> UIEdgeInsets {
        guard let window = UIApplication.shared.windows.first else {
            return .zero
        }
        return window.safeAreaInsets
    }
    
    // 获取状态栏高度
    public func getStatusBarHeight() -> CGFloat {
        return getSafeAreaInsets().top
    }
    
    // 获取底部安全区域高度（刘海屏的底部区域）
    public func getBottomSafeAreaHeight() -> CGFloat {
        return getSafeAreaInsets().bottom
    }
} 

public extension LTScreenAdapter {
    static let SCRE_H = UIScreen.main.bounds.height
    static let SCRE_W = UIScreen.main.bounds.width
}
