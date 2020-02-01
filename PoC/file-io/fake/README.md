# FAKE Plugin

A proof of concept plugin that simulates saving images to a fake file format (ext. "`.fake`") and demonstrates how to use the logger module for debugging the plugin functions calls.


-----

**Table of Contents**

<!-- MarkdownTOC autolink="true" bracket="round" autoanchor="false" lowercase="only_ascii" uri_encoding="true" levels="1,2,3" -->

- [Files](#files)
- [Introduction](#introduction)
- [License](#license)

<!-- /MarkdownTOC -->

-----

# Files

- [`dummy-image.fake`][dummy-image]
- [`FakePlugin.pb`][FakePlugin]
- [`LICENSE`][LICENSE]

# Introduction

At Pro Motion launch time, when the FAKE Plugin is registered/initialized, it adds a floating logger window that will persist for the whole session, providing debug info about the plugin calls and data exchanges:

![screenshot log window][screenshot logger]

The plugin also adds a new fake file format to the save/export dialogs:

![screenshot fake save][screenshot save dialog]

When saving/exporting to the FAKE format no actual images are saved to disk. Instead, all the functions calls to the plugin DLL are logged in the plugin logging window.

This plugin was intended both as a practical example on how to use the PureBasic file I/O boilerplate, as well as an experimental learning tool for plugins developers, to study the order of functions calls associated with each operation in the PM user interface, and to track the details of data exchanges between PM and its plugins.

In the future this plugin might be improved by adding support for fake image load/import, and adding fake animations load/save.

# License

- [`LICENSE`][LICENSE]

The "FAKE Plugin" is released under the MIT License.

> __IMPORTANT__ — If you distribute the "FAKE Plugin" in precompiled DLL form, then _you must_ include the full [`LICENSE`][LICENSE] file, which contains also the licenses of third party components used by the PureBasic compiler. If you're just redistributing the source code, the MIT License below is sufficient.

```
MIT License

Copyright (C) 2019 Tristano Ajmone <tajmone@gmail.com>
                   https://github.com/tajmone

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```


<!-----------------------------------------------------------------------------
                               REFERENCE LINKS
------------------------------------------------------------------------------>

[dummy-image]: ./dummy-image.fake "View file"
[FakePlugin]: ./FakePlugin.pb "View source file"
[LICENSE]: ./LICENSE "Read full license"

<!-- screenshots -->

[screenshot logger]: ./screenshot_logger.png "Screenshot of the FAKE plugin log window"
[screenshot save dialog]: ./screenshot_save.png "Screenshot of the FAKE file format in the Save dialog"

<!-- EOF -->
