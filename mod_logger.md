# The Logger Module

- [`mod_logger.pbi`][mod_logger] — v.0.0.4

This module provides file I/O plugins with a logger window that can be used to debug internal states and events during plugin development.
The module exposes a few simple procedures to control the logger and print text to it.

-----

**Table of Contents**

<!-- MarkdownTOC autolink="true" bracket="round" autoanchor="false" lowercase="only_ascii" uri_encoding="true" levels="1,2" -->

- [Introduction](#introduction)
- [Usage Instructions](#usage-instructions)
    - [Logging Text](#logging-text)
    - [When to Open the Logger Window?](#when-to-open-the-logger-window)
- [Modules Procedures](#modules-procedures)
    - [Remarks](#remarks)

<!-- /MarkdownTOC -->

-----

# Introduction

During the development stage of a file I/O plugin it's useful to have a logger window to show debugging information of the plugin internal states, which procedure are being called and what information is being exchanged.

Since plugins can only be tested as compiled DLLs executed by PMNG, using PureBasic debug functionality is not an option.
For this reason I've created this PureBasic module to provide an _ad hoc_ logger window, along with some friendly logging procedures.

Here's a screenshot of a logger window used by the ["FAKE" plugin][PoC fake]:

![screenshot log window][screenshot logger]

The logged text can be freely selected with the mouse and copied into the clipboard via <kbd>Ctrl</kbd>+<kbd>C</kbd>.
The <kbd>&nbsp;COPY&nbsp;</kbd> button allows to quickly copy into the clipboard all of the logged contents; and the <kbd>&nbsp;CLEAR&nbsp;</kbd> button deletes all logged info, allowing users to restart tracking the plugin behaviour before import/export operations.

The possibility to dump into the Logger info on a plugin internal variables and states, and being able to quickly copy and paste as plain text the whole log, or specific selections thereof, all add up to making the Logger module an essential tool for File I/O plugins development.

# Usage Instructions

Using the Logger in your projects is simple:

1. Include the module.
2. Open the logger window.
3. Print to logger whatever text you need via the built-in procedure.

To include the Logger Module in your plugin project, just add an `XIncludeFile` at the beginning of your plugin source file:

```purebasic
XIncludeFile "mod_logger.pbi"
```

The module functionality will be then accessible via the `logger::` namespace prefix.

Some default settings controlling the aspect of the logger window can overridden via the `logger::Settings` structure:

```purebasic
XIncludeFile "mod_logger.pbi"
With logger::Settings
  \WinTitle = "Your Plugin Name"
  \WinWidth  = 600
  \WinHeight = 400
EndWith
```

You'll need to invoke `logger::OpenLogger()` to create the logger window:

```purebasic
result = logger::OpenLogger("optional title")
```

The Logger Module only supports opening a single window per plugin, and attempts to call `OpenLogger()` while a logger already exists will silently fail.

You can close the logger windows at any time via `logger::CloseLogger()`:

```purebasic
result = logger::CloseLogger()
```

## Logging Text

With the Logger in place, you can print text strings into it using various built-in procedures:

```purebasic
logger::PPrint("Print text to the logger window.")
logger::PPrint(~"Multi-line supported.\nNew log line.")
logger::TSPrint("Log text with a timestamp.")
```

The logging procedures will automatically handle `#LF$`/`~"\n"` sequences and split the input string into multiple lines.

The `TSPrint()` procedure adds a timestamp to the logged text, splitting the log in two columns, with the timestamp on left column.
The result is easy to read:

```
14:36:07 | setFilename( $0358E2AC )
         | | *filename_pnt <-- "D:\PMNG\MyBanner.pmp"
         | | FILE: MyBanner.pmp
         | | (same as before)
14:36:07 | canHandle
```

Notice in the above example how a second indentation pipe (`|`) was automatically added to extra lines from the same `TSPrint()` call; again, this feature is intended to improve log readability.

## When to Open the Logger Window?

You can either open the logger window once, when the plugin is first loaded by PM, and keep it open for the whole session; or you can open it only when certain plugin procedures are called by PM (e.g. when a file processing operation beings) and close it when a certain operation had ended.

It's entirely up to you which approach to use, but since the logger is usually only employed during development, keeping it open for the whole Pro Motion session is usually the best choice.

If you decide to keep the logger open for the whole PM session, you don't need to worry about closing it — when the DLL process is detached from PM, PureBasic will handle all the clean-up chores automatically.

# Modules Procedures


|           procedure            |            description             |
|--------------------------------|------------------------------------|
| `logger::OpenLogger([title$])` | Open logger window.                |
| `logger::CloseLogger()`        | Close logger window.               |
| `logger::ClearLogger()`        | Clear log contents.                |
| `logger::PPrint(text$)`        | Plain print `text$` to log.        |
| `logger::TSPrint(text$)`       | Print time-stamped `text$` to log. |

## Remarks

All procedures return either `#True` on success or `#False` otherwise; in most cases you can safely just ignore the returned result, unless you really need to check that the operation succeeded.

Only one logger window can be opened for each plugin; attempting to call `OpenLogger()` when a logger was already created will silently fail and return `#False`.

Likewise, attempting to close a non existing logger, will also fail silently, returning `#False`.

The same goes for using printing functions when no logger window is open.

The `Title$` parameter for `OpenLogger()` is optional; if no parameter is provided, the string stored in `logger::Settings\WinTitle` will be used as fall-back title (defaults to "Plugin Logger", unless you've overwritten it); if you pass a non-empty string parameter, it will be stored in `logger::Settings\WinTitle` and become the window title from now onward.

Usually you'll want to pass the plugin name as title, so that you can associate the logger to the plugin, especially if there's more than one plugin opening logger windows in the same PM session.

With printing functions, if the parameter string contains `#LF$`/`~"\n"` EOL sequences, it will be split across multiple log lines.
Printing functions that apply special formatting to the log text (e.g. `TSPrint()`) will take care of formatting the extra lines.

<!-----------------------------------------------------------------------------
                               REFERENCE LINKS
------------------------------------------------------------------------------>

<!-- project folders -->

[PoC fake]: ./PoC/file-io/fake/ "Navigate to folder"

<!-- project files -->

[mod_logger]: ./mod_logger.pbi "View source file"

<!-- screenshots -->

[screenshot logger]: ./PoC/file-io/fake/screenshot_logger.png "Screenshot of the logger module window in the FAKE plugin"

<!-- EOF -->
