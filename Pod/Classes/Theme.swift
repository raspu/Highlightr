//
//  Theme.swift
//  Pods
//
//  Created by Illanes, J.P. on 4/24/16.
//
//

import Foundation

#if os(iOS) || os(tvOS)
    import UIKit
    /// Typealias for UIColor
    public typealias RPColor = UIColor
    /// Typealias for UIFont
    public typealias RPFont = UIFont
#else
    import AppKit
    /// Typealias for NSColor
    public typealias RPColor = NSColor
    /// Typealias for NSFont
    public typealias RPFont = NSFont
#endif

fileprivate typealias RPThemeDict = [String: [AnyHashable: AnyObject]]
fileprivate typealias RPThemeStringDict = [String: [String: String]]

/// Theme parser, can be used to configure the theme parameters. 
open class Theme {
    
    internal let theme: String
    internal var lightTheme: String!
    
    class font {
        
        /// Regular font to be used by this theme
        public static var regular: RPFont!
        /// Bold font to be used by this theme
        public static var bold: RPFont!
        /// Italic font to be used by this theme
        public static var italic: RPFont!
        
    }
    
    private var themeDict: RPThemeDict!
    private var strippedTheme: RPThemeStringDict!
    
    /// Default background color for the current theme.
    open var themeBackgroundColor: RPColor!
    
    /// Initialize the theme with the given theme name.
    ///
    /// - Parameter fileName: Theme to use.
    init(cssFileNamed fileName: String) {
        theme = fileName
        setSyntax(font: RPFont(name: "Courier", size: 14)!)
        strippedTheme = stripTheme(fileName)
        lightTheme = strippedThemeToString(strippedTheme)
        themeDict = strippedThemeToTheme(strippedTheme)
        
        var bkgColorHex = strippedTheme[".hljs"]?["background"]
        
        if(bkgColorHex == nil) {
            bkgColorHex = strippedTheme[".hljs"]?["background-color"]
        }
        
        if let bkgColorHex = bkgColorHex {
            if(bkgColorHex == "white") {
                themeBackgroundColor = RPColor(white: 1, alpha: 1)
            } else if(bkgColorHex == "black") {
                themeBackgroundColor = RPColor(white: 0, alpha: 1)
            } else {
                let range = bkgColorHex.range(of: "#")
                let str = String(bkgColorHex[(range?.lowerBound)!...])
                themeBackgroundColor = colorWithHexString(str)
            }
        } else {
            themeBackgroundColor = RPColor.white
        }
    }
    
    /// Changes the theme font. This will try to automatically populate the codeFont, boldCodeFont and italicCodeFont properties based on the provided font.
    ///
    /// - Parameter newFont: UIFont (iOS or tvOS) or NSFont (OSX).
    open func setSyntax(font newFont: RPFont) {
        font.regular = newFont
        
        #if os(iOS) || os(tvOS)
        let boldDescriptor = UIFontDescriptor(fontAttributes: [UIFontDescriptor.AttributeName.family: newFont.familyName,
                                                               UIFontDescriptor.AttributeName.face: "Bold"])
        let italicDescriptor = UIFontDescriptor(fontAttributes: [UIFontDescriptor.AttributeName.family: newFont.familyName,
                                                                 UIFontDescriptor.AttributeName.face: "Italic"])
        let obliqueDescriptor = UIFontDescriptor(fontAttributes: [UIFontDescriptor.AttributeName.family: newFont.familyName,
                                                                  UIFontDescriptor.AttributeName.face: "Oblique"])
        #else
        let boldDescriptor = NSFontDescriptor(fontAttributes: [.family: font.bold.familyName!,
                                                               .face: "Bold"])
        let italicDescriptor = NSFontDescriptor(fontAttributes: [.family: font.italic.familyName!,
                                                                 .face: "Italic"])
        let obliqueDescriptor = NSFontDescriptor(fontAttributes: [.family: font.regular.familyName!,
                                                                  .face: "Oblique"])
        #endif
        
        font.bold = RPFont(descriptor: boldDescriptor, size: newFont.pointSize)
        font.italic = RPFont(descriptor: italicDescriptor, size: newFont.pointSize)
        
        if font.italic == nil || font.italic.familyName != newFont.familyName {
            font.italic = RPFont(descriptor: obliqueDescriptor, size: newFont.pointSize)
        }
        if font.italic == nil {
            font.italic = newFont
        }
        
        if font.bold == nil {
            font.bold = newFont
        }

        if themeDict != nil {
            themeDict = strippedThemeToTheme(strippedTheme)
        }
    }
    
    internal func applyStyleToString(_ string: String, styleList: [String]) -> NSAttributedString {
        let returnString: NSAttributedString
        
        if styleList.count > 0 {
            var attrs = [AttributedStringKey: Any]()
            attrs[.font] = font.regular
            
            for style in styleList {
                if let themeStyle = themeDict[style] as? [AttributedStringKey: Any] {
                    for (attrName, attrValue) in themeStyle {
                        attrs.updateValue(attrValue, forKey: attrName)
                    }
                }
            }
            
            returnString = NSAttributedString(string: string, attributes:attrs)
        } else {
            returnString = NSAttributedString(string: string, attributes:[AttributedStringKey.font: font.regular as Any])
        }
        
        return returnString
    }
    
    private func stripTheme(_ themeString: String) -> [String: [String: String]] {
        let objcString = (themeString as NSString)
        let cssRegex = try! NSRegularExpression(pattern: "(?:(\\.[a-zA-Z0-9\\-_]*(?:[, ]\\.[a-zA-Z0-9\\-_]*)*)\\{([^\\}]*?)\\})", options:[.caseInsensitive])
        
        let results = cssRegex.matches(in: themeString,
                                               options: [.reportCompletion],
                                               range: NSMakeRange(0, objcString.length))
        
        var resultDict = [String:[String:String]]()
        
        for result in results {
            if(result.numberOfRanges == 3) {
                var attributes = [String: String]()
                let cssPairs = objcString.substring(with: result.range(at: 2)).components(separatedBy: ";")
                for pair in cssPairs {
                    let cssPropComp = pair.components(separatedBy: ":")
                    if(cssPropComp.count == 2) {
                        attributes[cssPropComp[0]] = cssPropComp[1]
                    }
                }
                
                if attributes.count > 0 {
                    resultDict[objcString.substring(with: result.range(at: 1))] = attributes
                }
            }
        }
        
        var returnDict = [String: [String: String]]()
        
        for (keys,result) in resultDict {
            let keyArray = keys.replacingOccurrences(of: " ", with: ",").components(separatedBy: ",")
            
            for key in keyArray {
                var props: [String: String]?
                props = returnDict[key]
                
                if props == nil {
                    props = [String: String]()
                }
                
                for (pName, pValue) in result {
                    props!.updateValue(pValue, forKey: pName)
                }
                
                returnDict[key] = props!
            }
        }
        
        return returnDict
    }
    
    private func strippedThemeToString(_ theme: RPThemeStringDict) -> String {
        var resultString = ""
        
        for (key, props) in theme {
            resultString += key+"{"
            
            for (cssProp, val) in props {
                if key != ".hljs" || (cssProp.lowercased() != "background-color" && cssProp.lowercased() != "background") {
                    resultString += "\(cssProp):\(val);"
                }
            }
            resultString += "}"
        }
        return resultString
    }
    
    private func strippedThemeToTheme(_ theme: RPThemeStringDict) -> RPThemeDict {
        var returnTheme = RPThemeDict()
        
        for (className, props) in theme {
            var keyProps = [AttributedStringKey: AnyObject]()
            
            for (key, prop) in props {
                switch key {
                case "color":
                    keyProps[attributeForCSSKey(key)] = colorWithHexString(prop)
                case "font-style":
                    keyProps[attributeForCSSKey(key)] = fontForCSSStyle(prop)
                case "font-weight":
                    keyProps[attributeForCSSKey(key)] = fontForCSSStyle(prop)
                case "background-color":
                    keyProps[attributeForCSSKey(key)] = colorWithHexString(prop)
                default:
                    break
                }
            }
            
            if keyProps.count > 0 {
                let key = className.replacingOccurrences(of: ".", with: "")
                returnTheme[key] = keyProps
            }
        }
        
        return returnTheme
    }
    
    private func fontForCSSStyle(_ fontStyle: String) -> RPFont {
        switch fontStyle {
            case "bold", "bolder", "600", "700", "800", "900":
                return font.bold
            case "italic", "oblique":
                return font.italic
            default:
                return font.regular
        }
    }
    
    private func attributeForCSSKey(_ key: String) -> AttributedStringKey {
        switch key {
        case "color":
            return .foregroundColor
        case "font-weight":
            return .font
        case "font-style":
            return .font
        case "background-color":
            return .backgroundColor
        default:
            return .font
        }
    }
    
    private func colorWithHexString(_ hex: String) -> RPColor {
        var cString = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

        if cString.hasPrefix("#") {
            cString = (cString as NSString).substring(from: 1)
        } else {
            switch cString {
            case "white":
                return RPColor(white: 1, alpha: 1)
            case "black":
                return RPColor(white: 0, alpha: 1)
            case "red":
                return RPColor(red: 1, green: 0, blue: 0, alpha: 1)
            case "green":
                return RPColor(red: 0, green: 1, blue: 0, alpha: 1)
            case "blue":
                return RPColor(red: 0, green: 0, blue: 1, alpha: 1)
            default:
                return RPColor.gray
            }
        }
        
        if cString.count != 6 && cString.count != 3 {
            return RPColor.gray
        }
        
        var r: CUnsignedInt = 0
        var g: CUnsignedInt = 0
        var b:CUnsignedInt = 0
        var divisor : CGFloat
        
        if cString.count == 6 {
            let rString = (cString as NSString).substring(to: 2)
            let gString = ((cString as NSString).substring(from: 2) as NSString).substring(to: 2)
            let bString = ((cString as NSString).substring(from: 4) as NSString).substring(to: 2)
            
            Scanner(string: rString).scanHexInt32(&r)
            Scanner(string: gString).scanHexInt32(&g)
            Scanner(string: bString).scanHexInt32(&b)
            
            divisor = 255.0
        } else {
            let rString = (cString as NSString).substring(to: 1)
            let gString = ((cString as NSString).substring(from: 1) as NSString).substring(to: 1)
            let bString = ((cString as NSString).substring(from: 2) as NSString).substring(to: 1)
            
            Scanner(string: rString).scanHexInt32(&r)
            Scanner(string: gString).scanHexInt32(&g)
            Scanner(string: bString).scanHexInt32(&b)
            
            divisor = 15.0
        }
        
        return RPColor(red: CGFloat(r) / divisor, green: CGFloat(g) / divisor, blue: CGFloat(b) / divisor, alpha: CGFloat(1))
    }
    
}
