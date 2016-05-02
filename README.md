# Highlightr

[![CI Status](http://img.shields.io/travis/Illanes, Juan Pablo/Highlightr.svg?style=flat)](https://travis-ci.org/Illanes, Juan Pablo/Highlightr)
[![Version](https://img.shields.io/cocoapods/v/Highlightr.svg?style=flat)](http://cocoapods.org/pods/Highlightr)
[![License](https://img.shields.io/cocoapods/l/Highlightr.svg?style=flat)](http://cocoapods.org/pods/Highlightr)
[![Platform](https://img.shields.io/cocoapods/p/Highlightr.svg?style=flat)](http://cocoapods.org/pods/Highlightr)

Highlightr is an iOS & OSX syntax highlighter built with Swift. It uses [highlight.js](https://highlightjs.org/) as it core, supports 152 languages and comes with 72 styles. 

Takes your lame code (String) and returns an NSAttributtedString with proper syntax highlighting.

The current version is under development but is functional.

## JavaScript?

Yes, Highlightr relies on iOS & OSX [JavaScriptCore](https://developer.apple.com/library/ios/documentation/Carbon/Reference/WebKit_JavaScriptCore_Ref/index.html#//apple_ref/doc/uid/TP40004754) to parse the code using highlight.js. This is actually quite fast!

## Performance

It will never be as fast as a native solution, but it's fast enough to be used on a real time editor. 

It comes with a custom made HTML parser for creating NSAttributtedStrings, is pre-processing the themes and is preloading the JS libraries. As result its taking around of 50 ms on my iPhone 6s for processing 500 lines of code.

## License

Highlightr is available under the MIT license. See the LICENSE file for more info.
