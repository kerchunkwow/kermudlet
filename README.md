## Mudlet/Lua Tips & Tricks

- Use quick & diry semaphores to gate or throttle functions that might be called repeatedly under certain conditions (usually by triggers).

```
-- Don't let this happen more than once per 5s interval
if not semaphore and someCondition then
  semaphore = true
  someFunction()
  tempTimer( 5, [[semaphore = nil]])
end
```

## Quick Start

- Setup sessions
- Uninstall baseline packages

## Project Structure

1. kermudlet_init.lua: provides a common entry point for all mudlet projects regardless of MUD; this is the "off-ramp" from Mudlet's built-in Editor; the only script in your client should be the one that runs this script.

2. Standard Library: Attempt to establish a "standard library" for Mudlet that can be shared across MUDs and projects.
  - lib_std.lua: core functions for running Lua, interacting with tables and variables
  - lib_gui.lua: common GUI functions for creating and interacting with Mudlet UI components
  - lib_react.lua: support for Mudlet "reactions" AKA triggers, aliases, timers, etc.
  - lib_string.lua: basic string manipulations like trim, split, format, parsing, etc.
  - lib_wintin.lua: create and interface with Wintin-compatible command strings

3. PC Status (Gizmo): Track, update, and report on PC status including health, mana, affects, etc. Heavy dependency on GUI elements.
  - status_update.lua: maintains the pcStatus table w/ information about pc health, mana, etc.
  - status_sim.lua: simulate gizmo MUD output for testing status tracking & updating functions [DEV]
  - status_parse_main.lua: main session prompt parser, it can access the pcStatus table directly
  - status_parse_alt.lua: alt session prompt parser, alts raise events to update the pcStatus table
  - status_affect.lua: uses emoji strings to track status affects/uptime [PROTOTYPE]

4. React (Gizmo): Support Triggers, Aliases, Timers, etc. Keep as much of your logic as possible here and not in the client.
  - react_trigger.lua: support triggers
  - react_alias.lua: support aliases

5. Session (Gizmo): Implement support for main-alt session coordination using Mudlet's event engine.
  - session_main.lua: main session scripts that interact directly with global tables
  - session_alt.lua: alt-specific script (raise events instead of direct manipulations)
  - session_events.lua: define the "event handling" logic to receive messages from alts
  - session_common.lua: shared/common scripts that both main & alts use

6. Map (Gizmo): Interface to Mudlet's Mapper UI; support for offline map simulation and in-game map following [WIP]
  - map_const.lua: global constants & definitions for mapping
  - map_main.lua: main map script for creation, tracking, pathfinding, etc.
  - map_ux.lua: define & maintain Map style (fonts, colors, room highlighting, etc.)

7. GUI (Gizmo): Create and maintain Chat & Info Windows, Party Console, PC Status gauges, labels, etc.
  - gui.lua: update & maintain GUI
  - gui_create.lua: initial creation of GUI components

8. EQ (Gizmo): Interact with the equipment database and manage & track in-game player inventory (e.g., gear swaps)
  - eq_db.lua: equipment database
  - eq_inventory.lua: in-game equipment and item management


## Notes

- `deprecated.lua` has a boat load of functions that are no longer relevant and/or were only needed for one-off or one-time needs; you will want to add `**/deprecated.lua` to `search.exclude` or whatever the equivalent is in your IDE so you don't get a ton of noise in your search results.
- Some functions are temporarily defined `local` because they aren't currently being used anywhere but I wasn't quite ready to toss them into the deprecated bin.
- `gizmudlet.xml` should not be modified directly; it is just extracted from `gizmudlet.mpackage` so global searches will indicate any functions or variables that are referenced by in-client scripts (another good reason to keep them to a minimum).
