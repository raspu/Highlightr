# Highlightr


[IMG](http://cocoapods.org/pods/Highlightr)
[IMG](http://cocoapods.org/pods/Highlightr)
[IMG](http://cocoapods.org/pods/Highlightr)

Highlightr is an iOS & OSX syntax highlighter built with Swift. It uses [highlight.js](https://highlightjs.org/) as it core, supports [152 languages and comes with 72 styles](https://highlightjs.org/static/demo/). 

Takes your lame string with code and returns an NSAttributtedString with proper syntax highlighting.

The current version is under development but is functional.

## Usage
Highlightr provides two way of highlighting: 

### Highlightr
This is the main class, you can use it to convert strings with code into NSAttributted strings.
´´´Swift
        let highlightr = Highlightr()
	    highlightr.setTheme("paraiso-dark")
	    let code = "let a = 1"
        let highlightedCode = highlightr.highlight("swift", code: code, fastRender: true)
´´´
### CodeAttributedString
A sublcass of NSTextStorage, you can use it to highlight text on real time. 
´´´Swift
		let textStorage = CodeAttributedString()
		textStorage.language = "Swift"
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)

        let textContainer = NSTextContainer(size: view.bounds.size)
        layoutManager.addTextContainer(textContainer)
        
        let textView = UITextView(frame: yourFrame, textContainer: textContainer)
´´´

## JavaScript?

Yes, Highlightr relies on iOS & OSX [JavaScriptCore](https://developer.apple.com/library/ios/documentation/Carbon/Reference/WebKit_JavaScriptCore_Ref/index.html#//apple_ref/doc/uid/TP40004754) to parse the code using highlight.js. This is actually quite fast!

## Performance

It will never be as fast as a native solution, but it's fast enough to be used on a real time editor. 

It comes with a custom made HTML parser for creating NSAttributtedStrings, is pre-processing the themes and is preloading the JS libraries. As result it's taking around of 50 ms on my iPhone 6s for processing 500 lines of code.

## License

Highlightr is available under the MIT license. See the LICENSE file for more info.