//
//  Highlightr.swift
//  Pods
//
//  Created by Illanes, Juan Pablo on 4/10/16.
//
//

import Foundation
import JavaScriptCore

#if os(iOS) || os(tvOS)
    import UIKit
    typealias RPColor = UIColor
    typealias RPFont = UIFont
#else
    import Cocoa
    typealias RPColor = NSColor
    typealias RPFont = NSFont
#endif


public class Highlightr
{
    let jsContext : JSContext
    let hljs = "window.hljs"
    let bundle : NSBundle
    
    let htmlStart = "<"
    let spanStart = "span class=\""
    let spanStartClose = "\">"
    let spanEnd = "/span>"
    
    public init?()
    {
        jsContext = JSContext()
        jsContext.evaluateScript("var window = {};")
        bundle = NSBundle(forClass: Highlightr.self)
        guard let hgPath = bundle.pathForResource("highlight.min", ofType: "js") else
        {
            return nil
        }
        
        let hgJs = try! String.init(contentsOfFile: hgPath)
        let value = jsContext.evaluateScript(hgJs)
        if !value.toBool()
        {
            return nil
        }
        
        guard let defTheme = bundle.pathForResource("pojoaque.min", ofType: "css") else
        {
            return nil
        }
        theme = try! String.init(contentsOfFile: defTheme)
        strippedTheme = self.strippedThemeToString(self.stripTheme(theme))
    }
    
    /**
     Set the theme to use for highlighting.
     
     - parameter name: String, theme name.
     
     - returns: true if it was posible to set the given theme, false otherwise.
     */
    public func setTheme(name: String) -> Bool
    {
        guard let defTheme = bundle.pathForResource(name+".min", ofType: "css") else
        {
            return false
        }
        theme = try! String.init(contentsOfFile: defTheme)
        
        return true
    }
    
    /**
     Takes a String and returns a NSAttributedString with the given language highlighted.
     
     - parameter languageName:   Language name or alias
     - parameter code:           Code to highlight
     
     - returns: NSAttributedString with the detected code highlighted.
     */
    public func highlight(languageName: String, code: String, fastRender: Bool) -> NSAttributedString?
    {
        var fixedCode = code.stringByReplacingOccurrencesOfString("\\",withString: "\\\\");
        fixedCode = fixedCode.stringByReplacingOccurrencesOfString("\'",withString: "\\\'");
        fixedCode = fixedCode.stringByReplacingOccurrencesOfString("\"", withString:"\\\"");
        fixedCode = fixedCode.stringByReplacingOccurrencesOfString("\n", withString:"\\n");
        fixedCode = fixedCode.stringByReplacingOccurrencesOfString("\r", withString:"");

        let command =  String.init(format: "%@.highlight(\"%@\",\"%@\").value;", hljs,languageName, fixedCode)
        let res = jsContext.evaluateScript(command)
        guard var string = res!.toString() else
        {
            return nil
        }
        
        let returnString : NSAttributedString
        if(fastRender)
        {
            returnString = processHTMLString(string)!
        }else
        {
             string = "<style>"+strippedTheme+"</style><pre><code class=\"hljs\">"+string+"</code></pre>"
             let opt = [
             NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
             NSCharacterEncodingDocumentAttribute: NSUTF8StringEncoding
             ]
            
             let data = string.dataUsingEncoding(NSUTF8StringEncoding)!
             returnString = try! NSMutableAttributedString(data:data,options:opt as! [String:AnyObject],documentAttributes:nil)

        }
        
        return returnString
    }
    
    /**
     Returns a list of all the themes available.
     
     - returns: Array of Strings
     */
    public func availableThemes() -> [String]
    {
        let paths = bundle.pathsForResourcesOfType("css", inDirectory: nil) as [NSString]
        var result = [String]()
        for path in paths {
            result.append(path.lastPathComponent.stringByReplacingOccurrencesOfString(".min.css", withString: ""))
        }
        
        return result
    }
    
    /**
     Returns a list of all supported languages.
     
     - returns: Array of Strings
     */
    public func supportedLanguages() -> [String]
    {
        let command =  String.init(format: "%@.listLanguages();", hljs)
        let res = jsContext.evaluateScript(command)
        return res.toArray() as! [String]
    }
    
    //Private & Internal
    private func processHTMLString(string: String) -> NSAttributedString?
    {
        let scanner = NSScanner(string: string)
        scanner.charactersToBeSkipped = nil
        var scannedString = NSString?()
        let resultString = NSMutableAttributedString(string: "")
        var propStack = [String]()
        
        while !scanner.atEnd {
            if scanner.scanUpToString(htmlStart, intoString: &scannedString) {
                if scanner.atEnd {
                    continue
                }
            }
            
            if scannedString != nil && scannedString!.length > 0 {
                let attrScannedString = applyStyleToString(scannedString! as String, styleList: propStack)
                resultString.appendAttributedString(attrScannedString)
            }
            
            scanner.scanLocation += 1
            
            let string = scanner.string as NSString
            let nextChar = string.substringWithRange(NSMakeRange(scanner.scanLocation, 1))
            if(nextChar == "s")
            {
                scanner.scanLocation += spanStart.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
                scanner.scanUpToString(spanStartClose, intoString:&scannedString)
                scanner.scanLocation += spanStartClose.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
                propStack.append(scannedString! as String)
            }
            else if(nextChar == "/")
            {
                scanner.scanLocation += spanEnd.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
                propStack.popLast()
            }else
            {
                let attrScannedString = applyStyleToString("<", styleList: propStack)
                resultString.appendAttributedString(attrScannedString)
                scanner.scanLocation += 1
            }
            
            scannedString = nil
        }

        return resultString
    }
    
    private func applyStyleToString(string: String, styleList: [String]) -> NSAttributedString
    {
        let returnString : NSAttributedString
        if styleList.count > 0
        {
            let color : RPColor
            if(styleList.count == 1)
            {
                color = RPColor.redColor()
            }else if (styleList.count == 2)
            {
                color = RPColor.blueColor()
            }else
            {
                color = RPColor.magentaColor()
            }
            returnString = NSAttributedString(string: string, attributes: [NSForegroundColorAttributeName:color])
        }
        else
        {
            returnString = NSAttributedString(string: string)
        }
        
        return returnString
    }
    
}
