# Kermudlet Project

## Overview

### Project Summary
kermudlet seeks to optimize and automate Diku MUD gameplay using Lua 5.1 scripts and the [Mudlet](https://www.mudlet.org/)
client. Mudlet enhances play through the use of Aliases, Triggers, and Keybinds.

### SQLite Integration
Using Lua's sqlite3 library, kermudlet interacts with external databases that hold data related to the game world
including Items, Areas/Rooms, and Enemies (Mobs).

### Python Support
As needed, kermudlet will utilize Python scripts for supporting utilities in `./pyutils`. Currently, these include:
- `parse_xml.py`: Converts Mudlet's XML profiles to Lua for interpretation by the IDE
- `find_colors.py`: Search globally for references to Mudlet colors to aid refactoring
- `gizmogram.py`: Pass messages to a Telegram chatbot via command-line arguments (e.g., forward chat messages)

## Technical Details
- Primary scripts are [Lua 5.1](https://www.lua.org/manual/5.1/)
- IDE is VSCode with extensions [Lua by sumneko](https://luals.github.io/) and
[Mudlet Scripts SDK](https://marketplace.visualstudio.com/items?itemName=Delwing.mudlet-scripts-sdk) for interpreting
built-in Mudlet functions.
- Lua [sqlite3](http://lua.sqlite.org/index.cgi/doc/tip/doc/lsqlite3.wiki) library is used to interact wtih SQLite
databases; some database work will be done directly in SQL through [DBeaver](https://dbeaver.io/) 23.2.3

## Function Reference

### trim(s)

Trims leading and trailing whitespace from a string.
Usage: trim(" example ") -- returns "example"
### fill(number, char, color)

Outputs number of char in a specified color. Useful for adding padding with colored characters.
Defaults: color = "<black>", char = "."
Usage: fill(10, ".", "<red>") -- returns "<red>..........</reset>"
### getMaxStringLength(stringList)

Returns the length of the longest string in a list.
Usage: getMaxStringLength({"one", "three", "twenty"}) -- returns 6
### split(s, delim)

Splits a string s at each occurrence of delim and returns a list of substrings.
Usage: split("a,b,c", ",") -- returns {"a", "b", "c"}
### capitalize(s)

Capitalizes the first letter of a string.
Usage: capitalize("hello") -- returns "Hello"
### startsWith(str, start)

Checks if a string str starts with the substring start.
Usage: startsWith("hello", "he") -- returns true
### endsWith(str, ending)

Checks if a string str ends with the substring ending.
Usage: endsWith("world", "ld") -- returns true
### toTitleCase(str)

Converts a string to title case (each word capitalized).
Usage: toTitleCase("hello world") -- returns "Hello World"
### tableLength(tbl)

Returns the length of a table.
Usage: tableLength({1, 2, 3}) -- returns 3
### tableKeys(tbl)
- Returns a list of keys from a table.
- Usage: tableKeys({a=1, b=2}) -- returns {"a", "b"}

### tableValues(tbl)
- Returns a list of values from a table.
- Usage: tableValues({a=1, b=2}) -- returns {1, 2}

### deepCopy(original)
- Creates a deep copy of a table.
- Usage: deepCopy({a={1,2}}) -- returns a new table with the same structure

### mergeTables(t1, t2)
- Merges two tables, t2 into t1.
- Usage: mergeTables({a=1}, {b=2}) -- returns {a=1, b=2}

### printTable(tbl, indent)
- Recursively prints a table for debugging.
- Usage: printTable({a=1, b={c=2}}) -- prints the structure of the table

### getCurrentTime()
- Returns the current time as a string in the format YYYY-MM-DD HH:MM:SS.
- Usage: getCurrentTime() -- returns current timestamp

## Development Guidelines & Tips for ChatGPT
- Avoid rewriting entire modules or functions unless asked; limit changes to snippets whenever possible
- Provide "example usage" as commented script; never provide free script outside the scope of a function unless explicitly requested
- Do not include inline comments; all comments go on their own line
- Use lowerCamelCase for variables and function names
- Use UpperCamelCase for global variables and tables (NOTE: Mudlet has built-in global variables & tables which do not conform to the UpperCamelCase convention)
- Use UPPER_SNAKE_CASE for global constants
- Error handling is generally not needed as the Mudlet client clearly reports Lua errors in the console
- Do not use comments to refer to our chat interactions; for example, if I ask for a change don't comment `--changed this`
- Avoid using `print()`; use `cout()` or `iout()` for all output
- `cout()` and `iout()` both encapsulate argument interpolation; `cout( "{GlobalVariable}" )` is valid syntax and will print the value of that variable to the console; you should rarely if ever need to use Lua's concatenation operator `..`
- `cout()` and `iout()` take care of newlines, no need to include newline characters when calling these functions

- Mudlet supports color tags within strings in most contexts; the format for coloring strings is `<red>String<reset>`; do not use `<red>String</red>` or `<red>String</reset>` etc. there is no forward-slash closing tag syntax for Mudlet colors
- Do not modify the content of string literals in code that I provide unless explicitly necessary to accomplish the task requested; do not remove {arguments} from strings or replace them with Lua's concatenate operator `..`
- The following global constants can be used as shortened versions of their respective color tags:

## Custom Instructions
This is the content Kermudlet uses for the "Custom Instructions" configuration option for ChatGPT sessions.

### Provide Better Responses
- github project: https://github.com/kerchunkwow/kermudlet; README is designed primarily to inform GPT; refer to the README for comprehensive project description and specific development guidance; project uses Lua 5.1 scripts with Mudlet client to enhance and automate MUD gameplay with aliases, triggers, keybinds, and supporting functions; use sqlite3 to interact with SQLite databases for game data management like Items, Mobs, Areas; use Python for supporting utilities like parsing and heavy file I/O; emphasize reuse and performance to ensure optimal response time on critical triggers; avoid rewriting entire functions when modifying or updating functions; only provide full rewrites when explicitly asked; avoid superfluous comments and do not use comments to refer to interactions from our chat; comments should describe script and function logic only; do not use in-line comments; comments go on their own line; use camelCase for variables & functions, UpperCamelCase for globals, and UPPER_SNAKE_CASE for global constants; assume a basic knowledge of computer science; avoid lines in excess of 120 characters if possible; do not provide "example usage" in provided code; keep code in functions only

### How to Respond
- Refer to https://github.com/kerchunkwow/kermudlet; README is designed primarily to inform GPT; refer to the README for comprehensive project description and specific development guidance; provide code suggestions in the context of the entire project; use concise language; avoid being overly verbose; be critical of my code; point out mistakes or suggest improvements whenever possible; avoid apologizing when I point out mistakes or improvements in your work; interact with me like a trusted colleague; be honest and transparent; offer brief technical explanations when changing or improving sections of my code; suggest updates to project README or custom instructions to improve long-term performance and collaboration; use README to maintain adherence to naming and syntax conventions; support performance, optimization, and reuse; suggest alternative solutions if I provide code that is unnecessarily complicated or redundant

