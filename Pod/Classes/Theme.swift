//
//  Theme.swift
//  Pods
//
//  Created by Illanes, Juan Pablo on 4/24/16.
//
//

import Foundation
typealias RPThemeDict = [String:[String:AnyObject]]

internal class Theme {
    internal var theme : String
    private var themeDict : RPThemeDict!
    
    init(themeString: String)
    {
        theme = themeString
        
    }
    
    private func stripTheme(themeString : String) -> [String:[String:String]]
    {
        let objcString = (themeString as NSString)
        let cssRegex = try! NSRegularExpression(pattern: "(?:(\\.[a-zA-Z0-9\\-_]*(?:[, ]\\.[a-zA-Z0-9\\-_]*)*)\\{[^\\}]*?((?:color:[a-zA-Z0-9:#]+)|(?:font-weight:[a-zA-Z0-9]+)|(?:font-style:[a-zA-Z0-9]+))?[^\\}]*?((?:color:[a-zA-Z0-9:#]+)|(?:font-weight:[a-zA-Z0-9]+|(?:font-style:[a-zA-Z0-9]+)))[^\\}]*?\\})", options:[.CaseInsensitive])
        
        let results = cssRegex.matchesInString(themeString,
                                               options: [.ReportCompletion],
                                               range: NSMakeRange(0, objcString.length))
        
        var resultDict = [String:[String:String]]()
        
        for result in results {
            if(result.numberOfRanges > 1)
            {
                var attr = [String:String]()
                for i in 2...result.numberOfRanges-1 {
                    let range = result.rangeAtIndex(i)
                    if(objcString.length > range.length+range.location)
                    {
                        let cssPropComp = objcString.substringWithRange(result.rangeAtIndex(i)).componentsSeparatedByString(":")
                        if(cssPropComp.count == 2)
                        {
                            attr[cssPropComp[0]] = cssPropComp[1]
                        }
                        
                    }
                }
                if attr.count > 0
                {
                    resultDict[objcString.substringWithRange(result.rangeAtIndex(1))] = attr
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
    
    private func strippedThemeToString(theme: [String:[String:String]]) -> String
    {
        var resultString = ""
        for (key, props) in theme {
            resultString += key+"{"
            for (cssProp, val) in props
            {
                resultString += "\(cssProp):\(val);"
            }
            resultString+="}"
        }
        return resultString
    }
    
    private func strippedThemeToTheme(theme: [String:[String:String]]) -> RPThemeDict
    {
        var theme = RPThemeDict()
        for (className, props) in theme
        {
            var keyProps = [String:AnyObject]()
            for (key, prop) in props
            {
                switch key
                {
                case "color":
                    keyProps[key] = colorWithHexString(prop as! String)
                    break
                case "font-style":
                    
                    break
                case "font-weight":
                    
                    break
                default:
                    break
                }
            }
            theme[className] = keyProps
        }
        return theme
    }
    
    private func colorWithHexString (hex:String) -> RPColor {
        var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).uppercaseString
        
        if (cString.hasPrefix("#")) {
            cString = (cString as NSString).substringFromIndex(1)
        }
        
        if (cString.characters.count != 6) {
            return RPColor.grayColor()
        }
        
        let rString = (cString as NSString).substringToIndex(2)
        let gString = ((cString as NSString).substringFromIndex(2) as NSString).substringToIndex(2)
        let bString = ((cString as NSString).substringFromIndex(4) as NSString).substringToIndex(2)
        
        var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
        NSScanner(string: rString).scanHexInt(&r)
        NSScanner(string: gString).scanHexInt(&g)
        NSScanner(string: bString).scanHexInt(&b)
        
        
        return RPColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(1))
    }
    

}