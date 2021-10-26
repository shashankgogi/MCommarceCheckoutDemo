//
//  ConstantAttributes.swift
//  M-Commerce_DashBoard_Plug
//
//  Created by admin on 07/02/19.
//  Copyright © 2019 admin. All rights reserved.
//

import UIKit
import SystemConfiguration

class GeneralClass: NSObject {
    /// Used to check connectivity
    ///
    /// - Returns: flag
    static func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        // Working for Cellular and WIFI
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let isConnected = (isReachable && !needsConnection)
        
        return isConnected
    }
    
}


// MARK: - Shimmer View Animation Related

var associateObjectValue: Int = 0

// MARK: - UIView Extension
extension UIView {
    fileprivate var isAnimate: Bool {
        get {
            return objc_getAssociatedObject(self, &associateObjectValue) as? Bool ?? false
        }
        set {
            return objc_setAssociatedObject(self, &associateObjectValue, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    @IBInspectable var shimmerAnimation: Bool {
        get {
            return isAnimate
        }
        set {
            self.isAnimate = newValue
        }
    }
    func subviewsRecursive() -> [UIView] {
        return subviews + subviews.flatMap { $0.subviewsRecursive() }
    }
}

//// MARK: - UI Related
//extension UIViewController {
//    func prepareUI() {
//    }
//}

// MARK: - Animation Related
extension UIViewController {
    func startAnimation() {
        for animateView in getSubViewsForAnimate() {
            animateView.clipsToBounds = true
            let gradientLayer = CAGradientLayer()
            gradientLayer.colors = [UIColor.clear.cgColor, UIColor.white.withAlphaComponent(0.8).cgColor, UIColor.clear.cgColor]
            gradientLayer.startPoint = CGPoint(x: 0.7, y: 1.0)
            gradientLayer.endPoint = CGPoint(x: 0.0, y: 0.8)
            gradientLayer.frame = animateView.bounds
            animateView.layer.mask = gradientLayer
            
            let animation = CABasicAnimation(keyPath: "transform.translation.x")
            animation.duration = 1.5
            animation.fromValue = -animateView.frame.size.width
            animation.toValue = animateView.frame.size.width
            animation.repeatCount = .infinity
            
            gradientLayer.add(animation, forKey: "")
        }
    }
    
    func stopAnimation() {
        for animateView in getSubViewsForAnimate() {
            animateView.layer.removeAllAnimations()
            animateView.layer.mask = nil
        }
    }
}

// MARK: - ShimerView animation
extension UIViewController {
    func getSubViewsForAnimate() -> [UIView] {
        var obj: [UIView] = []
        for objView in view.subviewsRecursive() {
            obj.append(objView)
        }
        return obj.filter({ (obj) -> Bool in
            obj.shimmerAnimation
        })
    }
}


// MARK: - extension UIColor
// Converting hex colour into UI colour
extension UIColor {
    public convenience init?(hexString: String) {
        let r, g, b, a: CGFloat
        
        if hexString.hasPrefix("#") {
            let start = hexString.index(hexString.startIndex, offsetBy: 1)
            var hexColor = String(hexString[start...])
            
            if hexColor.count == 6 {
                hexColor = hexColor + "ff"
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255
                    
                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }
        
        return nil
    }
}

// MARK: - extension String
// Used to remove blankspace
extension String
{
    func trim() -> String
    {
        return self.trimmingCharacters(in: NSCharacterSet.whitespaces)
    }
}

// MARK: - UIImageView
extension UIImageView {
    func setImageColor(color: UIColor) {
        let templateImage = self.image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        self.image = templateImage
        self.tintColor = color
    }
}

// MARK: - String
extension String {
    func size(OfFont font: UIFont) -> CGSize {
        return (self as NSString).size(withAttributes: [NSAttributedString.Key.font: font])
    }
}

class ThemeClass{
    static let currencySymbol = "₹"
    static let primaryColor = UIColor.purple
    static let secondaryColor = UIColor.blue
    static let textColor = UIColor.black
    static let navigationColor = UIColor.brown
}

/// Alert title and messages
enum AlertTitleNMessage : String{
    case FAILURE_TITLE = "Oops"
    case SOMETHING_WRONG_MESSAGE = "Something went wrong. Please contact to your Admin!"
    case NOINTERNET_TITLE = "No Internet !"
    case NOINTERNET_MESSAGE = "No internet available. Please check your connection."
    case CONT_SHOPING_MESSAGE = "This is a checkout plug which creates only UI based on server response."
}

/// General messages
enum GeneralMessages : String {
    case COMMUNICATION_ERROR_TITLE = "communication error!"
    case SOMETHING_WENT_WRONG = "Something went wrong, please try after some time."
    case NO_DATA_FOUND_TITLE = "Ooops! No Results found"
    case NO_DATA_FOUND_DESC = "Please try again later or try something else"
    case NO_DATAILS_FOUND_FPR_PRODUCT_TITLE = "Ooops! No details for product"

    case NAME_VALIDATION_MESSAGE = "Please enter name."
    case EMAIL_VALIDATION_MESSAGE = "Please enter email."
    case EMAIL_VALIDATION_ALERT = "Please enter valid emailId."
    case MOMILE_NUMBER_VALIDATION_MESSAGE = "Please enter mobile number."
    case MOMILE_NUMBER_VALIDATION_ALERT = "Please enter 10 digit mobile number."
    case ADDRESS_VALIDATION_MESSAGE = "Please enter address."
    case CITY_VALIDATION_MESSAGE = "Please enter city."
    case POSTALCODE_VALIDATION_MESSAGE = "Please enter postal code."
    case POSTALCODE_VALIDATION_ALERT = "Please enter a valid postal code."
}
