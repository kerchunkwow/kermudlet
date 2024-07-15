# Kermudlet Project

## Overview

### Project Summary
kermudlet seeks to optimize and automate Diku MUD gameplay using Lua 5.1 scripts and the [Mudlet](https://www.mudlet.org/)
client. Mudlet enhances play through the use of Aliases, Triggers, and Keybinds.

### Data Files & SQLite integration
Mudlet utilizes several external data sources to store game-related data for persistence across sessions. This data is stored in one of two formats:
- SQLite database named gizwrld.db
- Individual Lua files written by Mudlet's `table.save()` and loaded with `table.load()`
- Mudlet's proprietary map created by the Mudlet Mapper API

### Python Support
As needed, kermudlet will utilize Python scripts to maintain supporting utilities whenever Python is a more appropriate tool for the job.

## Technical Details
- Primary scripts are [Lua 5.1](https://www.lua.org/manual/5.1/)
- IDE is VSCode with extensions [Lua by sumneko](https://luals.github.io/) and
[Mudlet Scripts SDK](https://marketplace.visualstudio.com/items?itemName=Delwing.mudlet-scripts-sdk) for interpreting
built-in Mudlet functions.
- Lua [sqlite3](http://lua.sqlite.org/index.cgi/doc/tip/doc/lsqlite3.wiki) library is used to interact wtih SQLite
databases; some database work will be done directly in SQL through [DBeaver](https://dbeaver.io/) 23.2.3

## Guidance and Reference for ChatGPT
Below is documentation on many key functions available to kermudlet either through the Mudlet client API or from custom-built local libraries. Utilize these functions as needed when implementing new features and expand the list of custom functions with new utilities, helpers, or wrappers as opportunities arise.

### How to Respond to Prompts

#### General Guidance for Sending & Receiving Code
- Avoid unnecessary repetition when sending code. If I send you a function for reference or feedback, do not send it back to me unless you have modified it; once you send a function once, do not re-send it unless you have made changes; if I send a function and ask for help with a specific section such as a for-loop or if-block, limit your response to the script in question.
- Always try to use the most recent version of a function; if you send me a function and I send it back to you with modifications, assume I have made those modifications deliberately and "replace" your knowledge of that function with my version; never revert to a previously unmodified version unless I explicitly ask; put another way, avoid overwriting my changes by replacing them with older code of your own.
- Unless explicitly asked or when providing partial code like a snippet, never provide functional code outside the scope of a function. kermudlet automatically reloads modified files in real-time and any script outside of a function will immediately execute in the live client environment.
- Do not provide "example usage" or test cases unless explicitly asked; I will always specify when I want you to provide script to help test an existing function.
- Do not introduce error-handling unless explicitly requested; Mudlet provides real-time feedback on Lua errors within the Client so any additional error-handling within kermudlet is likely to be redundant and unnecessary.
- Do not include comments that refer to our interactions within a chat window; if you fix a problem or modify a line for example, do not include a comment like "-- Fixed the problem" or "-- This is different now." All comments should be relevant to the code or functionality they describe and they should make sense to someone who is not aware that they were written during our collaboration.
- Mudlet uses [Lua 5.1](https://www.lua.org/manual/5.1/); ensure code that you send does not depend upon functions added to Lua beyond this version.

#### Syntax Guidance for Sending & Receiving Code
- Use lowerCamelCase for variables and function names
- Use UpperCamelCase for global variables and global tables
- Use UPPER_SNAKE_CASE for global constants
- Mudlet's built-in API does not conform to all of these standards; if you see lower_snake_case for example, this is probably native Mudlet or Lua.
- Avoid in-line comments unless describing the individual properties of a large table or list of related elements; in most cases comments belong on their own line.
- Try to limit lines to 100 characters and under no circumstances exceed 120.
- For readability, include whitespace inside parantheses for function definitions and invocations like `function( parameter )` and between operators and operands like `(n * (s + 1) / 2) + m` or `if variable == conditional then`; use verticle whitespace in longer scripts to group related sections of code visually.
- In general, if I send you code you can assume it has been passed through my IDE's auto-formatting rules and therefore adheres to my preferred standards; try to emulate the style and syntax of the code you receive from me in your own.
- Avoiding using `print()` for console output; use Mudlet's `cecho()` function or kermudlet's `cout()` which wraps f-strings and newlines.
- Mudlet's Lua implementation supports f-string interpolation; avoid using `string.format()` when concatenating variables and string literals; Mudlet's f-string syntax mirrors Pythons like `cecho( f"This {variable} will be replaced." )`; if I send you code with f-strings, never replace them with your own calls to `string.format()`.
- Many Mudlet functions including `cecho()` support color tags, but the syntax is atypical; Mudlet color tags are closed with the `<reset>` which is equivalent to my global `RC` such that within an f-string `{RC}` is equivalent; avoid reverting to standard syntax for closing color tags like `</color>` or `</reset>`; it is not necessary to reset one color if another is used, so `this is an <green>acceptable <red>sequence <reset>of tags for Mudlet colorization`.

#### Behavior and Langauge Guidance
- Treat me as a trusted coworker
- Be openly critical of my code; if I make mistakes or implement inefficient solutions, do not hesitate to correct me or suggest an improved design.
- Avoid apologizing; do not apologize when I point out mistakes or inefficiencies in your code; do not apologize if I need to remind you of my response or syntax preferences; for the love of all thing's do not apologize for apologizing.
- kermudlet is a small, hobby project; there's usually no need to consider commercial or enterprise-level concerns like scalability, data security, or portability within the context of this project.

### API & Reference

#### Custom kermudlet functions
The following functions have been implemented locally in kermudlet and should be used as needed throughout the project; where there are custom kermudlet functions that seem to be redundant with existing Mudlet API or Lua 5.1 functions, assume the kermudlet version exists deliberately to add desirable distinctions between it and the natively-available version.

```lua
-- Split a string into a list of substrings at each occurrence of a delimiter
-- @param s The string to be split
-- @param delim The delimiter to split the string at
-- @return A table containing the substrings
function split( s, delim )

-- Trim leading and trailing whitespace from a string
-- @param s The string to be trimmed
-- @return The trimmed string
function trim( s )

-- Trim leading and trailing whitespace & condense internal whitespace
-- @param s The string to be trimmed and condensed
-- @return The trimmed and condensed string
function trimCondense( s )

-- Trim an article ("a", "an", "the") from the start of a string
-- @param s The string to be processed
-- @return The string without the leading article
function trimArticle( s )

-- Convert the first word of a string to lowercase if it is an article ("a", "an", "the")
-- @param str The string to be processed
-- @return The string with the first article converted to lowercase
function lowerArticles( str )

-- Abbreviate a large number as a string with a suffix (K, M, B)
-- @param numberString The number as a string to be abbreviated
-- @return The abbreviated number string
function abbreviateNumber( numberString )

-- Format a number with commas as thousands separators
-- @param n The number to be formatted
-- @return The formatted number string
function expandNumber( n )

-- Generate a string composed of a repeated character in a specified color
-- @param number The number of characters to generate
-- @param char The character to repeat (default is ".")
-- @param color The color code to apply (default is "<black>")
-- @return The generated string
function fill( number, char, color )

-- Get the length of the longest string in a list
-- @param stringList The list of strings
-- @return The length of the longest string
function getMaxStringLength( stringList )

-- Create a regex pattern to match a string as a standalone line of output
-- @param rawString The string to be matched
-- @return The regex pattern
function createLineRegex( rawString )

-- Calculate strlen excluding Mudlet color tags & adjusting for utf8
-- @param s The input string to be measured
-- @return The adjusted length of the string
function cLength( s )

```
#### Key kermudlet Global variables & CONSTANTS

```lua

-- Images & icons
ASSETS_PATH        = [[C:/Dev/mud/mudlet/gizmo/assets]]
-- Location of the SQLite database
DB_PATH            = [[C:/Dev/mud/gizmo/data/gizwrld.db]]
-- Project root/home
HOME_PATH          = [[C:/Dev/mud/mudlet]]
-- Where table.save() and table.load() keep their files
DATA_PATH          = [[C:/Dev/mud/mudlet/gizmo/data/]]

-- Shorthand color tags; use these to condense longer strings when outputting a lot of highlighted data
SC                 = "<cornflower_blue>" -- String Literals or Text
NC                 = "<orange>"          -- Numbers
VC                 = "<dark_violet>"     -- Non-Number Variable Values
EC                 = "<orange_red>"      -- Critical Errors & Warnings
DC                 = "<ansi_yellow>"     -- Derived or Calculated Values
FC                 = "<maroon>"          -- Magical Flags & Affects like 'Sanctuary'
MC                 = "<coral>"           -- Mob & mob-related activities (enemies)
SYC                = "<ansi_magenta>"    -- System Messages (Client Status, etc.)
RC                 = "<reset>"           -- Reset Color (do not use </reset> or </color> syntax)

```

#### Frequently-Used Mudlet Functions & Globals
These functions are part of the native Mudlet API but are used frequently enough throughout the kermudlet project to include here in addition to where they will be found in the API references below.

```lua

------------------------------------------------------------------------------------------------------------------------
-- Most basic way to issue commands to the MUD itself, equivalent to user input from the client command-line.
function send( command, showOnScreen )
end

-- Like send, but for Aliases that have been defined within the local client.
function expandAlias( command, echoBackToBuffer )
end

-- Sends output to the client main window which will be interpreted by the Mudlet client as having come from
-- the MUD itself; this is super useful for testing newly-created triggers or recreating scenarios that are
-- rare.
function cfeedTriggers( text )
end

-- These functions turn on/off Trigger processing for specific named Triggers; this is useful for functions
-- that only apply within a specific context. When used in conjunction with tempTimer or tempTrigger, certain
-- Triggers or groups of Triggers can be isolated.
function enableTrigger( name )
end

function disableTrigger( name )
end

-- Returns the current time on a named stopwatch which was started earlier, for kermudlet the named timer is
-- simply "timer" and is available everywhere in the project to get the current time to the milisecond; this
-- can be used to measure deltas between in-game events or time function executions.
function getStopWatchTime( timer )
end

-- Used in conjunction, these temporary Trigger/Timer functions are used frequently throughout kermudlet to
-- string together chains of related events or to temporarily enable or disable different functionality
-- throughout the project. These temp functions return integer IDs which must be stored in order to interact
-- with their respect timers and triggers in the future. Often a sequence of if timer/kill timer/start timer
-- will be used to "refresh" a timer in a situation where one may already exist for the same purpose and we
-- only want the result to happen once.
function tempTrigger( substring, code, expireAfter )
end

function tempRegexTrigger( regex, code, expireAfter )
end

function tempTimer( time, code_to_do, _repeating )
end

function killTimer( id )
end


--	This Lua table is being used by Mudlet in the context of triggers that use Perl regular expressions.
-- matches[1] holds the entire match, matches[2] holds the first capture group, matches[n] holds the nth-1 capture
-- group. If the Perl trigger indicated 'match all' (same effect as the Perl /g switch) to evaluate all possible
-- matches of the given regex within the current line, matches[n+1] will hold the second entire match, matches[n+2]
-- the first capture group of the second match and matches[n+m] the m-th capture group of the second match.
matches = {}

-- This table is being used by Mudlet in the context of multiline triggers that use Perl regular expression.
-- It holds the table matches[n] as described above for each Perl regular expression based condition of the
--  multiline trigger. multimatches[5][4] may hold the 3rd capture group of the 5th regex in the multiline
--  trigger. This way you can examine and process all relevant data within a single script.
multimatches = {{}}

--- Color definitions used by Geyser, cecho, and many other functions - see showColors(). The profile's color
-- preferences are also accessible under the ansi_ keys.
color_table = {}

```

#### Mudlet API Reference
The Mudlet Lua API is documented extensively on the [Mudlet wiki](wiki.mudlet.org). Use the following pages as reference when collaborating on the kermudlet project.

There may be functions native to Mudlet which appear redundant to custom functions built for kermudlet. If there is a native Mudlet function that is rewritten for kermudlet, prefer the kermudlet version. In most cases these have differences which have been added deliberately to distinguish the kermudlet version from the native functionality provided by Mudlet itself.

- [Global Variables](https://wiki.mudlet.org/w/Manual:Lua_Functions#Global_variables)
- [SQLite Database Integration](https://wiki.mudlet.org/w/Manual:Lua_Functions#Database_Functions)
- [SQLite Database Transactions](https://wiki.mudlet.org/w/Manual:Lua_Functions#Transaction_Functions)
- [Date & Time](https://wiki.mudlet.org/w/Manual:Lua_Functions#Date_.26_Time_Functions)
- [File System](https://wiki.mudlet.org/w/Manual:Lua_Functions#File_System_Functions)
- [Mudlet Mapper](https://wiki.mudlet.org/w/Manual:Lua_Functions#Mapper_Functions)
- [Mudlet Objects](https://wiki.mudlet.org/w/Manual:Lua_Functions#Mudlet_Object_Functions)
- [Networking](https://wiki.mudlet.org/w/Manual:Lua_Functions#Networking_Functions)
- [Miscellaneous](https://wiki.mudlet.org/w/Manual:Lua_Functions#Miscellaneous_Functions)
- [Strings](https://wiki.mudlet.org/w/Manual:Lua_Functions#String_Functions)
- [Tables](https://wiki.mudlet.org/w/Manual:Lua_Functions#Table_Functions)
- [User Interface](https://wiki.mudlet.org/w/Manual:Lua_Functions#UI_Functions)
