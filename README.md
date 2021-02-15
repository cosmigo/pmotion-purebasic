# Pro Motion PureBasic

[![Pro Motion NG Version][PMNG badge]][Pro Motion NG]&nbsp;
[![PureBasic Version][PB badge]][PureBasic]&nbsp;
[![MIT License][License badge]][MIT License]&nbsp;
[![Build Status][Travis badge]][Travis link]

Cosmigo [Pro Motion NG] plugins interfaces in [PureBasic].

- https://github.com/tajmone/pmotion-purebasic

Copyright © 2019-2021 Tristano Ajmone, [MIT License].


-----

**Table of Contents**

<!-- MarkdownTOC autolink="true" bracket="round" autoanchor="false" lowercase="only_ascii" uri_encoding="true" levels="1,2,3" -->

- [Introduction](#introduction)
- [Project Contents](#project-contents)
    - [The File I/O Boilerplates](#the-file-io-boilerplates)
    - [The Logger Module](#the-logger-module)
    - [Plugin Examples](#plugin-examples)
- [Project Status](#project-status)
    - [About the Alpha Stage and Branch](#about-the-alpha-stage-and-branch)
- [System Requirements](#system-requirements)
    - [Compiling File I/O Plugins](#compiling-file-io-plugins)
- [License](#license)
- [References](#references)
    - [Plugins Documentation](#plugins-documentation)
    - [Official Cosmigo References](#official-cosmigo-references)

<!-- /MarkdownTOC -->

-----

# Introduction

The goal of this project is to provide PureBasic boilerplates for creating Pro Motion NG plugins, starting with the file I/O interfaces and, later on, also cover the image manipulation interface (aka DDE plugin).

# Project Contents

- [`/PoC/`][PoC] — proof of concept plugins:
    + [`/file-io/`][PoC file-io] — file I/O plugins:
        * [`/fake/`][PoC fake] — "FAKE" plugin example.
- [`/tests/`][tests] — misc. modules tests.
- [`pmotion_file-io.pb`][fileio pb] — file I/O plugin boilerplate.
- [`pmotion_file-io_barebones.pb`][fileio bbones pb] — file I/O plugin boilerplate, bare-bones version.
- [`mod_logger.pbi`][mod_logger] — a developers' module that adds a log window to plugins.
- [`LICENSE`][LICENSE] — MIT License.
- [`validate.sh`][validate.sh] — validate code styles.

## The File I/O Boilerplates

- [`pmotion_file-io.pb`][fileio pb] — standard boilerplate v0.0.3
- [`pmotion_file-io_barebones.pb`][fileio bbones pb] — bare-bones boilerplate v0.0.3

The boilerplate is a code template on top of which you can develop your custom file I/O.
Although you can successfully compile the boilerplate into a DLL, it won't do anything useful unless you add to it some meaningful code (and most likely PMNG will complain about it when trying to register it, and fail to do so).

There are two versions of the boilerplate: the standard boilerplate and the bare-bones version.
The former contains useful comments and macros to facilitate newbies creating their first plugins, whereas the latter is a stripped down version for those who already know their way through plugins development.

Even though the standard boilerplate source code contains some useful comments, you'll still need to study the [File I/O Plugin Interface] documentation in order to create a plugin.
Providing such documentation is currently beyond the scope of this project — but in the future we might add to this project a plugins documentation specifically written for PureBasic.

## The Logger Module

- [`mod_logger.pbi`][mod_logger] — v0.0.5
- [`mod_logger.md`][mod_logger Doc] — module documentation.

This module provides file I/O plugins with a logger window that can be used to debug internal states and events during plugin development.
The module exposes a few simple procedure to control the logger and print text to it.

For a practical example of its usage, see the ["FAKE" plugin][PoC fake]:

![screenshot log window][screenshot logger]

## Plugin Examples

Currently there's only the ["FAKE" plugin][PoC fake] example, mainly intended as a proof of concept demo and a reference for developers.

# Project Status

Currently the project is in Alpha stage for the file I/O boilerplate hasn't been yet fully tested (although some working proof of concept plugins have already been created with it).
Also, PMNG plugin interface and its documentation are undergoing some improvements.
Until some demo plugins will be ready, and the whole boilerplate has been put to test, the project will remain in Alpha stage.
This doesn't mean that the boilerplate is not usable, but it might still need fixes — it still provides a solid base to start from.

Right now, the difficult part is working on a boilerplate which, by itself doesn't do anything, and at the same time work on some demo plugins to test its code — which requires updating the code on all sides as the works proceeds.

## About the Alpha Stage and Branch

For the whole duration of the Alpha development stage all commits will be in the `alpha` branch, which will ultimately be squashed into `master` when the first stable release is reached.

Furthermore, the Alpha branch will contain the binary DLLs of the compiled demo plugins, to compensate the lack of releases (which on GitHub allow attaching archives with precompiled binaries).
Before squashing into `master` all binaries will be deleted and the project will ignore them from thereon.

# System Requirements

To create PMNG plugins with these boilerplates you'll need the 32-bit edition of [PureBasic] for Windows, which is a commercial product by Fantaisie Software.

## Compiling File I/O Plugins

File I/O plugins must be compiled with the following settings in the PureBasic IDE (or the command line):

- Windows x86 (32 bit)
- DLL executable, non thread-safe.

Once you've compiled your plugin DLL, you only need to copy it into the `plugins` subfolder in the installation directory of Pro Motion.
Depending on the bitness of your Windows operating system, the path of the `plugins` folder will be either:

- 32 bit OS: `%ProgramFiles%\cosmigo\Pro Motion NG\plugins\`
- 64 bit OS: `%ProgramFiles(x86)%\cosmigo\Pro Motion NG\plugins\`

Any plugins inside that folder will be automatically detected when Pro Motion is launched, and made available in the file load/save and import/export dialogs according to where the plugin functionality fits in PMNG context.
This means that during development, whenever you updated/recompile your DLL you'll have to close and restart PM.

Since PM is a 32 bit application, the plugin DLL must also be compiled as 32 bit.

# License

- [`LICENSE`][LICENSE]

This project is released under the MIT License.

```
MIT License

Copyright (C) 2019-2021 Tristano Ajmone <tajmone@gmail.com>
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

# References

For a discussion regarding PMNG plugin development, see the following threads on [Cosmigo community forum]:

- [Amiga IFF Support]
- [File I/O Plugins Questions]
- [File I/O Plugins: A Language Agnostic Guide]

## Plugins Documentation

- [Developer Interface] — full documentation by [Jan Zimmerman].
- [File I/O Plugin Interface] — a language agnostic presentation.


## Official Cosmigo References

- [Cosmigo website][Cosmigo]
- [Pro Motion Community Forum][PM Forum]
- [Pro Motion NG Documentation][PM Docs]
- [Pro Motion NG Blog][PM Blog]

<!-----------------------------------------------------------------------------
                               REFERENCE LINKS
------------------------------------------------------------------------------>

[PureBasic]: https://www.purebasic.com/ "Visit PureBasic website"
[MIT License]: ./LICENSE "View MIT License file"

<!-- badges -->

[License badge]: https://img.shields.io/badge/License-MIT-blue
[PB badge]: https://img.shields.io/badge/PureBasic-5.73%20LTS-yellow
[PMNG badge]: https://img.shields.io/badge/Pro%20Motion%20NG-7.2.7.0-yellow
[Travis badge]: https://travis-ci.com/tajmone/pmotion-purebasic.svg?branch=alpha
[Travis link]: https://travis-ci.com/tajmone/pmotion-purebasic "Travis CI: EditorConfig validation status"

<!-- project folders -->

[PoC]: ./PoC/ "Navigate to folder"
[PoC fake]: ./PoC/file-io/fake/ "Navigate to folder"
[PoC file-io]: ./PoC/file-io/ "Navigate to folder"
[tests]: ./tests/ "Navigate to folder"

<!-- project files -->

[.editorconfig]: ./.editorconfig "View EditorConfig settings file"
[.gitattributes]: ./.gitattributes "View Git attributes settings file"
[.gitignore]: ./.gitignore "View Git ignore settings file"
[.travis.yml]: ./.travis.yml "View Travis CI settings file"
[LICENSE]: ./LICENSE "View MIT License file"
[fileio pb]: ./pmotion_file-io.pb "View PureBasic boilerplate source"
[fileio bbones pb]: ./pmotion_file-io_barebones.pb "View PureBasic boilerplate source"
[mod_logger Doc]: ./mod_logger.md "Read the documentation of Logger Module"
[mod_logger]: ./mod_logger.pbi "View PureBasic source file"
[validate.sh]: ./validate.sh "View source script for code style validation"

<!-- screenshots -->

[screenshot logger]: ./PoC/file-io/fake/screenshot_logger.png "Screenshot of the logger module window in the FAKE plugin"

<!-- Cosmigo & PM -->

[Cosmigo GmbH]: https://www.cosmigo.com/pixel_animation_software/support "More info about Cosmigo GmbH"
[Cosmigo]: https://www.cosmigo.com/ "Visit Cosmigo website"
[Pro Motion NG]: https://www.cosmigo.com/ "Visit Pro Motion NG website"
[Pro Motion]: https://www.cosmigo.com/ "Visit Pro Motion website"

[PM Docs]: https://www.cosmigo.com/promotion/docs/onlinehelp/main.htm "View Pro Motion NG documentation on-line"
[PM Forum]: https://community.cosmigo.com/ "Visit the Cosmigo community forum"
[PM Blog]: https://www.cosmigo.com/blog "Visit Cosmigo official blog"

<!-- Cosmigo Pro Motion Assets -->

[pmotion-assets]: https://github.com/tajmone/pmotion-assets "Visit the Cosmigo Pro Motion Assets repository on GitHub"
[pmotion-assets www]: https://tajmone.github.io/pmotion-assets/ "Visit the Cosmigo Pro Motion Assets website"
[Cosmigo Pro Motion Assets]: https://github.com/tajmone/pmotion-assets "Visit the Cosmigo Pro Motion Assets repository on GitHub"

<!-- documentation -->

[File I/O Plugin Interface]: https://tajmone.github.io/pmotion-assets/File-IO_Agnostic-Interface.html
[Developer Interface]: https://tajmone.github.io/pmotion-assets/Developer_Interface.html

<!-- Cosmigo forum -->

[Cosmigo community forum]: https://community.cosmigo.com/

[Amiga IFF Support]: https://community.cosmigo.com/t/amiga-iff-support/523
[File I/O Plugins Questions]: https://community.cosmigo.com/t/file-i-o-plugins-questions/465
[File I/O Plugins: A Language Agnostic Guide]: https://community.cosmigo.com/t/file-i-o-plugins-a-language-agnostic-guide/486

<!-- people -->

[Jan Zimmerman]: https://github.com/jan-cosmigo "Visit Jan Zimmerman's GitHub profile"
[Tristano Ajmone]: https://github.com/tajmone "Visit Tristano Ajmone's profile on GitHub"

<!-- EOF -->
