# Kermudlet Project

## Overview

### Project Summary
kermudlet seeks to optimize and automate Diku MUD gameplay using Lua 5.1 scripts and the [Mudlet](https://www.mudlet.org/)
client. Mudlet enhances play through the use of Aliases, Triggers, and Keybinds.

kermudlet leverages Mudlet's [event engine](https://wiki.mudlet.org/w/Manual:Event_Engine) to coordinate play across four
player characters simultaneously.

The design relies upon a single Main session and three Alternate (Alt) sessions which communicate using the event system.
The Main session maintains data tables that hold the status of Alt sessions and is responsible for creating and updating
various GUI elements that display this information to the user.

### SQLite Integration
Using Lua's sqlite3 library, kermudlet interacts with external databases that hold data related to the game world
including Items, Areas/Rooms, and Enemies (Mobs).

### Python Support
As needed, kermudlet will utilize Python scripts for supporting utilities. Currently, these include:
`parse_xml.py`: Converts Mudlet's XML profiles to Lua for interpretation by the IDE.

## Technical Details
- Primary scripts are [Lua 5.1](https://www.lua.org/manual/5.1/)
- IDE is VSCode with extensions [Lua by sumneko](https://luals.github.io/) and
[Mudlet Scripts SDK](https://marketplace.visualstudio.com/items?itemName=Delwing.mudlet-scripts-sdk) for interpreting
built-in Mudlet functions.
- Lua [sqlite3](http://lua.sqlite.org/index.cgi/doc/tip/doc/lsqlite3.wiki) library is used to interact wtih SQLite
databases; some database work will be done directly in SQL through [DBeaver](https://dbeaver.io/) 23.2.3

## Project Structure

### kermudlet_init.lua
This script is designed to act as a common entry point to kermudlet projects; currently the project is only being
used to play the Gizmo Diku MUD through use of scripts in the /gizmo directory, but ideally the project could
expand to support the play of any MUD while still benefitting from a set of common/reusable scripts and functions.

### /lib
The `lib` directory contains a collection of utility and helper scripts that provide foundational functionalities
across the kermudlet project. Each script is designed to offer reusable functions for different aspects of the game
client's operation, aiming to modularize common tasks and functionalities to support maintennance & extension.

- **lib_db.lua**: Support SQLite database integrations

- **lib_gui.lua**: Create and maintain various GUI and UX elements including player status gauges and console windows;
heavy use of Mudlet's built-in support for [Geyser](https://wiki.mudlet.org/w/Manual:Geyser)

- **lib_react.lua**: Generalized support for triggers & aliases

- **lib_script.lua**: Use Mudlet's built-in `sysPathChanged` event to trigger automatic reloading of externally-modified scripts

- **lib_std.lua**: Core functionality for running Lua commands/files fand manipulating basic data types

- **lib_string.lua**: String manipulation like trim & split

- **lib_wintin.lua**: Implements functions for creating and interpreting Wintin-style command strings

### /gizmo Directory
Specific functionality to support playing Gizmo Diku MUD.

- `gizmo_init.lua` This script is the entry point to the /gizmo section of the project where functionality that's specific to
playing the Gizmo Diku MUD is contained; this script defines the load order for scripts in the following directories as well
as dictating differences between the Main and Alt sessions.

- **config/**: Initial setup & configuration; `config_local_template.lua` is a template file designed to provide users a model
for their own local `config_local.lua` script which allows for customized configuration on a per-user basis outside the
github project structure.
- **data/**: Backup/redundancy for gizmo data including the Mudlet map
- **eq/**: Equipment and inventory management and monitoring (e.g., gear swapping)
- **gui/**: Create and update UX and GUI elements including the player status console
- **map/**: Map interactions
- **react/**: Support aliases and triggers (put script here instead of inside the Mudlet client)
- **status/**: Tracking player statuses (heavily used by the gui/party console)

### gizmudlet.lua
This is a "generated" script obtained using the `parse_xml.py` script to unpack and parse the Lua script from within Mudlet's
`.mpackage` file. The purpose of this is to provide the IDE with an interpretible Lua file in order to ensure consistency
in naming conventions between the external scripts and internal Lua (though ideally internal scripting is minimal).

### deprecated.lua
Script that's no longer in use but may come in handy later.

## Data Tables (Lua)
Within the project exist some pre-loaded data tables that are populated with information from external SQL databases in
order to circumvent the need to continually connect to and query these data sets (given that they are generally small).

### mobData

The `mobData` table serves as the primary repository for information on NPCs (mobs), combining both database attributes and computed metrics for enhanced gameplay analysis and interaction.

#### Direct Attributes
Includes:
- `rNumber`: Mob's unique identifier.
- `shortDescription`, `longDescription`, `keywords`: Descriptive attributes.
- `level`, `health`, `ac`, `gold`, `xp`: Combat and reward attributes.
- `alignment`, `flags`, `affects`: Behavioral and state indicators.
- `damageDice`, `damageSides`, `damageModifier`, `hitroll`: Attack mechanics.
- `roomVNumber`, `specialProcedure`: Location and custom behavior scripts.

#### Derived Metrics
Computed for each mob to facilitate analysis:
- `averageDamage`: Expected damage output per attack.
- `xpPerHealth`, `goldPerHealth`: Efficiency indicators for player encounters.

#### SpecialAttacks
An array detailing each mob's potential special actions, including:
- `chance`, `damageDice`, `damageSides`, `damageModifier`, `hitroll`: Mechanics.
- `target`, `type`, `description`: Targeting, category, and descriptive details.

#### Usage
- **Population**: Filled via `loadAllMobs`, pulling and processing data from the database.
- **Access**: Employed by `getMob` for data retrieval and `displayMob` for output, prioritizing data efficiency and minimizing direct database interactions.

This structure is designed for quick data access and comprehensive mob analysis, supporting backend functionality and AI-based game interactions.

### UNIQUE_ROOMS

`./gizmo/map/data/map_unique.lua`

The `UNIQUE_ROOMS` table maps room names as strings to the corresponding R-Numbers for any room whose name appears only once in the game; this allows
rapid synchronization of the Map to ensure it is accurately tracking/updating the player's location. The R-Number of the current room is stored in the
global `currentRoomNumber` variable and used by various built-in Mudlet functions including `centerview()` to keep the map up to date.

This table is populated at load time by `loadUniqueRooms()`. `isUnique( roomName )` implements a basic check against this table for room uniqueness.

### doorData

`./gizmo/map/data/map_doors.lua`

The `doorData` table contains data about every (mapped) door in the game. The table is indexed first by the R-Number of the room in which the door exists,
then by the direction in which the door leads being one of `'north', 'south', 'east', 'west', 'up', 'down'`. Every door has an `exitDest` and `exitKeyword`
property indicating where the door leads and how to interact with it using in-game commands like `open <keyword>`.

Some doors include an `exitDescription` with additional information and locked doors include an `exitKey` which corresponds to the in-game ID of the key
object needed to unlock the door.

The data in `doorData` is used when constructing paths such that appropriate unlock/open/close commands can be included in the paths to ensure smooth pathing.

### areaMap

Defined in `./gizmo/map/data/map_dirs.lua`, this table maps strings to the R-Number of corresponding areas; R-Numbers (areaRNumber in the SQL database)
uniquely identify areas as they do for Rooms, Mobs, and Items. This is otherwise just a basic "lookup" table used so players can issue commands to "go" to
certain areas by name rather than memorizing R-Numbers.

### areaDirs

Defined in `./gizmo/map/data/map_dirs.lua`, this table is used to travel to each area using the mapping provided by the `areaMap` table.

Each entry in this table defines the following properties:
- `cost`: The total number of "steps" in the path; can be used to decide if players have enough moves to complete the journey; some MUDs have different
costs based on terrain type so this design could be more useful there.
- `dirs`: A Wintin-compatible string of commands that can be used by the `doWintin()` function to travel to the area; this string will be inclusive of
any necessary door commands.
- `rawDirs`: The "raw" list of directions to the area; does not include door-related commands
- `roomName`: The name of the room you should end up in after following the path
- `roomNumber`: The R-Number of the destination room

## Development Guidance (notes for GPT)
- Avoid rewriting entire modules or functions unless asked; when modifying only a few lines, provide snippets instead of
entire functions.
- Do not provide "example usage" unless asked explicitly; script should only be provided within functions unless asked
- Do not use inline comments; all comments should be on their own line.
- Use camelCase for variables and functions, UPPER_CASE for globals and constants
- Mudlet supports f-string interpolation, but to not use it. Use string.format instead; when updating or modifying my scripts,
replace any f-string interpolation with string.format calls.
- When writing and testing new functions, include generous debug output using Mudlet's built-in `cecho()` function to send
details to the info window; follow this general format when sending debug/error messages:
`  local errstr = string.format( "\nMob with rNumber == <orange>%d<reset> not found.", rNumber )`
`  cecho( "info", errstr )`
- Do not include comments referring to interactions or exchanges within the chat session like `--fixed this`; comments
should only be used to describe or explain the script itself; keep commentary within chat sessions

## Key/Core Function Catalog
- `trim( s )` and `split( s, delim )` are defined in `lib_string.lua`
- Use `round( n, s )` from `lib_std.lua` to round values to 2.00 decimal places when displaying calculated values
- Use `expandNumber( n )` when displaying large values to add commas for readability
- Avoid using `print()`; use Mudlet's `cecho()` function with prepended newlines like `cecho( "\nMessage" )` (see Development Guidance)
- `sessionCommand()` and `aliasSessionCommand()` in `./gizmo/config/config_events.lua` work together to provide the main mechanism for
communication between sessions (player profiles). The local `registerEventHandlers()` function registers handlers for `event_command_all`
and `event_command_#` (where # corresponds to the tab/session number) at load time; thereafter, calls to `raiseEvent()` or `raiseGlobalEvent()`
passing these events will be heard by all sessions or the corresponding session number respectively.
- `raiseGlobalEvent()` is heard by all sessions EXCEPT the raising session; to truly raise an event to all sessions you have to call both
`raiseGlobalEvent()` and `raiseEvent()`

## Future Enhancements

1. **Affect Tracking Improvements:** Enhance `status_affect.lua` for robust tracking and reporting of magical affects. [Issue #1](https://github.com/kerchunkwow/kermudlet/issues/1)

2. **Command Directions Enhancement:** Update functions to include directions for commands like 'open door north' to handle multiple doors. [Issue #2](https://github.com/kerchunkwow/kermudlet/issues/2)

3. **Party Console Click Function Abstraction:** Make Party Console interactions in `gui.lua` more configurable to fit different party setups. [Issue #3](https://github.com/kerchunkwow/kermudlet/issues/3)

4. **Recall Scrolls Monitoring:** Implement mechanisms to monitor and manage recall scroll counts and warn of shortages. [Issue #4](https://github.com/kerchunkwow/kermudlet/issues/4)

5. **Map Initialization and Error Handling:** Improve map synchronization, especially on new session loads or disconnects. [Issue #5](https://github.com/kerchunkwow/kermudlet/issues/5)

6. **Following Map Synchronization:** Ensure map remains synchronized while following another player. [Issue #6](https://github.com/kerchunkwow/kermudlet/issues/6)

7. **Tick Tracking and Reporting:** Develop functionality for accurate tick tracking to optimize gameplay efficiency. [Issue #7](https://github.com/kerchunkwow/kermudlet/issues/7)

8. **Dynamic Mode Switching:** Automate switching between Solo/Group or Leader/Follower modes based on gameplay. [Issue #9](https://github.com/kerchunkwow/kermudlet/issues/9)

9. **Codebase Consistency:** Complete the transition to camelCase across all scripts for consistency. [Issue #10](https://github.com/kerchunkwow/kermudlet/issues/10)

10. **Terminology Corrections:** Update all instances of 'effects' to 'affects' where appropriate. [Issue #11](https://github.com/kerchunkwow/kermudlet/issues/11)

11. **Item Query Expansion:** Add support for +SKILL in `eq_db.lua` item queries. [Issue #12](https://github.com/kerchunkwow/kermudlet/issues/12)

12. **Party Console Group Info:** Expand the Party Console to display key group information. [Issue #13](https://github.com/kerchunkwow/kermudlet/issues/13)

13. **Relative Path Usage:** Update all references to use relative paths for greater flexibility in project location. [Issue #15](https://github.com/kerchunkwow/kermudlet/issues/15)


