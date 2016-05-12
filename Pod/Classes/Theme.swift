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
    public typealias RPColor = UIColor
    public typealias RPFont = UIFont
#else
    import AppKit
    public typealias RPColor = NSColor
    public typealias RPFont = NSFont

#endif

private typealias RPThemeDict = [String:[String:AnyObject]]
private typealias RPThemeStringDict = [String:[String:String]]

public class Theme {
    internal let theme : String
    internal var lightTheme : String!
    
    public var codeFont : RPFont!
    public var boldCodeFont : RPFont!
    public var italicCodeFont : RPFont!
    
    private var themeDict : RPThemeDict!
    private var strippedTheme : RPThemeStringDict!
    
        /// Default background color for the current theme.
    public var themeBackgroundColor : RPColor!
    
    init(themeString: String)
    {
        theme = themeString
        setCodeFont(RPFont(name: "Courier", size: 14)!)
        strippedTheme = stripTheme(themeString)
        lightTheme = strippedThemeToString(strippedTheme)
        themeDict = strippedThemeToTheme(strippedTheme)
        var bkgColorHex = strippedTheme[".hljs"]?["background"]
        if(bkgColorHex == nil)
        {
            bkgColorHex = strippedTheme[".hljs"]?["background-color"]
        }
        if let bkgColorHex = bkgColorHex
        {
            if(bkgColorHex == "white")
            {
                themeBackgroundColor = RPColor(white: 1, alpha: 1)
            }else if(bkgColorHex == "black")
            {
                themeBackgroundColor = RPColor(white: 0, alpha: 1)
            }else
            {
                let range = bkgColorHex.rangeOfString("#")
                let str = bkgColorHex.substringFromIndex((range?.startIndex)!)
                themeBackgroundColor = colorWithHexString(str)
            }
        }else
        {
            themeBackgroundColor = RPColor.whiteColor()
        }
    }
    
    /**
     Changes the theme font.
     
     - parameter font: UIFont (iOS or tvOS) or NSFont (OSX)
     */
    public func setCodeFont(font: RPFont)
    {
        codeFont = font
        
        #if os(iOS) || os(tvOS)
        let boldDescriptor = UIFontDescriptor(fontAttributes: [UIFontDescriptorFamilyAttribute:font.familyName,
                                                                UIFontDescriptorFaceAttribute:"Bold"])
        let italicDescriptor = UIFontDescriptor(fontAttributes: [UIFontDescriptorFamilyAttribute:font.familyName,
                                                                 UIFontDescriptorFaceAttribute:"Italic"])
        let obliqueDescriptor = UIFontDescriptor(fontAttributes: [UIFontDescriptorFamilyAttribute:font.familyName,
                                                                  UIFontDescriptorFaceAttribute:"Oblique"])
        #else
        let boldDescriptor = NSFontDescriptor(fontAttributes: [NSFontFamilyAttribute:font.familyName!,
                                                                NSFontFaceAttribute:"Bold"])
        let italicDescriptor = NSFontDescriptor(fontAttributes: [NSFontFamilyAttribute:font.familyName!,
                                                                NSFontFaceAttribute:"Italic"])
        let obliqueDescriptor = NSFontDescriptor(fontAttributes: [NSFontFamilyAttribute:font.familyName!,
                                                                NSFontFaceAttribute:"Oblique"])
        #endif
        
        boldCodeFont = RPFont(descriptor: boldDescriptor, size: font.pointSize)
        italicCodeFont = RPFont(descriptor: italicDescriptor, size: font.pointSize)
        
        if(italicCodeFont == nil || italicCodeFont.familyName != font.familyName)
        {
            italicCodeFont = RPFont(descriptor: obliqueDescriptor, size: font.pointSize)
        } else if(italicCodeFont == nil )
        {
            italicCodeFont = font
        }
        
        if(boldCodeFont == nil)
        {
            boldCodeFont = font
        }

        if(themeDict != nil)
        {
            themeDict = strippedThemeToTheme(strippedTheme)
        }
    }
    
    internal func applyStyleToString(string: String, styleList: [String]) -> NSAttributedString
    {
        let returnString : NSAttributedString
        
        if styleList.count > 0
        {
            var attrs = [String:AnyObject]()
            attrs[NSFontAttributeName] = codeFont
            for style in styleList
            {
                if let themeStyle = themeDict[style]
                {
                    for (attrName, attrValue) in themeStyle
                    {
                        attrs.updateValue(attrValue, forKey: attrName)
                    }
                }
            }
            
            returnString = NSAttributedString(string: string, attributes:attrs )
        }
        else
        {
            returnString = NSAttributedString(string: string, attributes:[NSFontAttributeName:codeFont] )
        }
        
        return returnString
    }
    
    private func stripTheme(themeString : String) -> [String:[String:String]]
    {
        let objcString = (themeString as NSString)
        let cssRegex = try! NSRegularExpression(pattern: "(?:(\\.[a-zA-Z0-9\\-_]*(?:[, ]\\.[a-zA-Z0-9\\-_]*)*)\\{([^\\}]*?)\\})", options:[.CaseInsensitive])
        
        let results = cssRegex.matchesInString(themeString,
                                               options: [.ReportCompletion],
                                               range: NSMakeRange(0, objcString.length))
        
        var resultDict = [String:[String:String]]()
        
        for result in results {
            if(result.numberOfRanges == 3)
            {
                var attributes = [String:String]()
                let cssPairs = objcString.substringWithRange(result.rangeAtIndex(2)).componentsSeparatedByString(";")
                for pair in cssPairs {
                    let cssPropComp = pair.componentsSeparatedByString(":")
                    if(cssPropComp.count == 2)
                    {
                        attributes[cssPropComp[0]] = cssPropComp[1]
                    }

                }
                if attributes.count > 0
                {
                    resultDict[objcString.substringWithRange(result.rangeAtIndex(1))] = attributes
                }
                
            }
            
        }
        
        var returnDict = [String:[String:String]]()
        
        for (keys,result) in resultDict
        {
            let keyArray = keys.stringByReplacingOccurrencesOfString(" ", withString: ",").componentsSeparatedByString(",")
            for key in keyArray {
                var props : [String:String]?
                props = returnDict[key]
                if props == nil {
                    props = [String:String]()
                }
                
                for (pName, pValue) in result
                {
                    props!.updateValue(pValue, forKey: pName)
                }
                returnDict[key] = props!
            }
        }
        
        return returnDict
    }
    
    private func strippedThemeToString(theme: RPThemeStringDict) -> String
    {
        var resultString = ""
        for (key, props) in theme {
            resultString += key+"{"
            for (cssProp, val) in props
            {
                if(key != ".hljs" || (cssProp.lowercaseString != "background-color" && cssProp.lowercaseString != "background"))
                {
                    resultString += "\(cssProp):\(val);"
                }
            }
            resultString+="}"
        }
        return resultString
    }
    
    private func strippedThemeToTheme(theme: RPThemeStringDict) -> RPThemeDict
    {
        var returnTheme = RPThemeDict()
        for (className, props) in theme
        {
            var keyProps = [String:AnyObject]()
            for (key, prop) in props
            {
                switch key
                {
                case "color":
                    keyProps[attributeForCSSKey(key)] = colorWithHexString(prop)
                    break
                case "font-style":
                    keyProps[attributeForCSSKey(key)] = fontForCSSStyle(prop)
                    break
                case "font-weight":
                    keyProps[attributeForCSSKey(key)] = fontForCSSStyle(prop)
                    break
                case "background-color":
                    keyProps[attributeForCSSKey(key)] = colorWithHexString(prop)
                    break
                default:
                    break
                }
            }
            if keyProps.count > 0
            {
                let key = className.stringByReplacingOccurrencesOfString(".", withString: "")
                returnTheme[key] = keyProps
            }
        }
        return returnTheme
    }
    
    private func fontForCSSStyle(fontStyle:String) -> RPFont
    {
        switch fontStyle
        {
            case "bold", "bolder", "600", "700", "800", "900":
                return boldCodeFont
            case "italic", "oblique":
                return italicCodeFont
            default:
                return codeFont
        }
    }
    
    private func attributeForCSSKey(key: String) -> String
    {
        switch key {
        case "color":
            return NSForegroundColorAttributeName
        case "font-weight":
            return NSFontAttributeName
        case "font-style":
            return NSFontAttributeName
        case "background-color":
            return NSBackgroundColorAttributeName
        default:
            return NSFontAttributeName
        }
    }
    
    private func colorWithHexString (hex:String) -> RPColor
    {
        var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).uppercaseString
        
        if (cString.hasPrefix("#"))
        {
            cString = (cString as NSString).substringFromIndex(1)
        }
        else
        {
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
                return RPColor.grayColor()
            }
        }
        
        if (cString.characters.count != 6 && cString.characters.count != 3 )
        {
            return RPColor.grayColor()
        }
        
        
        var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
        var divisor : CGFloat
        
        if (cString.characters.count == 6 )
        {
        
            let rString = (cString as NSString).substringToIndex(2)
            let gString = ((cString as NSString).substringFromIndex(2) as NSString).substringToIndex(2)
            let bString = ((cString as NSString).substringFromIndex(4) as NSString).substringToIndex(2)
            
            NSScanner(string: rString).scanHexInt(&r)
            NSScanner(string: gString).scanHexInt(&g)
            NSScanner(string: bString).scanHexInt(&b)
            
            divisor = 255.0
            
        }else
        {
            let rString = (cString as NSString).substringToIndex(1)
            let gString = ((cString as NSString).substringFromIndex(1) as NSString).substringToIndex(1)
            let bString = ((cString as NSString).substringFromIndex(2) as NSString).substringToIndex(1)
            
            NSScanner(string: rString).scanHexInt(&r)
            NSScanner(string: gString).scanHexInt(&g)
            NSScanner(string: bString).scanHexInt(&b)
            
            divisor = 15.0
        }
        
        return RPColor(red: CGFloat(r) / divisor, green: CGFloat(g) / divisor, blue: CGFloat(b) / divisor, alpha: CGFloat(1))        
        
    }
    

}
