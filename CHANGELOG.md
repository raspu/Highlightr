2.1.0 Release notes (2018-3-7)
=============================================================

### Enhancements

* Ported to swift 4.2.
* highlight.js updated to version 9.13.1.
* Added ability to specify a different highlight.min.js file than the one included. 

### Bugfixes

* Removed unneeded language files.


2.0.1 Release notes (2018-3-7)
=============================================================

### Bugfixes

* Now is possible to use fonts without an italic variation.

2.0.0 Release notes (2018-1-16)
=============================================================

### Enhancements

* Ported to swift 4.
* highlight.js updated to version 9.12.0.

### Bugfixes

* Possible crash in Highlightr when not using fast render .

1.1.0 Release notes (2016-12-30)
=============================================================

### Enhancements

* highlight.js updated to version 9.9.0.
* Added language automatic detection.

1.0.0 Release notes (2016-11-02)
=============================================================

### Enhancements

* highlight.js updated to version 9.8.0.
* Updated to Swift 3 and Xcode 8 compatibility

### Breaking changes

* Adopted Swift 3 API Design Guidelines
    - `highlightr.highlight("swift", code: code, fastRender: true)` -> `highlightr.highlight(code, as: "swift")` *`fastRender` is now optional and defaults to true*
    - `highlightr.setTheme("paraiso-dark")` -> `highlightr.setTheme(to: "paraiso-dark")`

0.9.3 Release notes (2016-09-04)
=============================================================

### Enhancements

* highlight.js updated to version 9.6.0.
* Added callback that notifies changes of the theme.
* Changing the theme updates the currenlty highlighted code (CodeAttributedString)

0.9.2 Release notes (2016-07-07)
=============================================================

### Enhancements

* highlight.js updated to version 9.5.0.

0.9.1 Release notes (2016-05-29)
=============================================================

### API breaking changes

* CodeAttributedString API was restructured.

### Enhancements

* CodeAttributedString declares a delegate that gets notified of highlighting events.
* Better documentation.

### Bugfixes

* Possible crash in CodeAttributedString when no language is specified.
