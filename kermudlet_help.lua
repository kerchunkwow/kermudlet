cecho( f "\n\nGet help with <magenta>#help<reset>\n" )
cecho( f "\n\nFor offline Map only, type <yellow_green>mapsim<reset>\n" )

function getHelp( topic )
  if not topic then
    getHelpTopics()
    return
  end
end

function getHelpTopics()
  local structureHelp = [[
------------------------------------------------------------------------------------------------------------------------

<magenta>init<dim_grey>:
  kermudlet_init.lua provides a common entry point for all mudlet projects regardless of MUD; this is the "off-ramp"
  from Mudlet's built-in Editor; the only script in your client should be the one that runs this script.

<steel_blue>Standard Library<dim_grey>
  Attempt to establish a "standard library" for Mudlet that can be shared across MUDs and projects.
    <cyan>lib_std.lua<dim_grey>: core functions for running Lua, interacting with tables and variables
    <cyan>lib_gui.lua<dim_grey>: common GUI functions for creating and interacting with Mudlet UI components
    <cyan>lib_react.lua<dim_grey>: support for Mudlet "reactions" AKA triggers, aliases, timers, etc.
    <cyan>lib_string.lua<dim_grey>: basic string manipulations like trim, split, format, parsing, etc.
    <cyan>lib_wintin.lua<dim_grey>: create and interface with Wintin-compatible command strings

<orange>PC Status (Gizmo)<dim_grey>:
  Track, update, and report on PC status including health, mana, affects, etc. Heavy dependency on GUI elements.
    <dark_orange>status_update.lua<dim_grey>: maintains the pcStatus table w/ information about pc health, mana, etc.
    <dark_orange>status_sim.lua<dim_grey>: simulate gizmo MUD output for testing status tracking & updating functions [DEV]
    <dark_orange>status_parse_main.lua<dim_grey>: main session prompt parser, it can access the pcStatus table directly
    <dark_orange>status_parse_alt.lua<dim_grey>: alt session prompt parser, alts raise events to update the pcStatus table
    <dark_orange>status_affect.lua<dim_grey>: uses emoji strings to track status affects/uptime [PROTOTYPE]

<violet_red>React (Gizmo)<dim_grey>:
  Support Triggers, Aliases, Timers, etc. Keep as much of your logic as possible here and not in the client.
    <maroon>react_trigger.lua<dim_grey>: support triggers
    <maroon>react_alias.lua<dim_grey>: support aliases

<snow>Session (Gizmo)<dim_grey>:
  Implement support for main-alt session coordination using Mudlet's event engine.
    <gainsboro>session_main.lua<dim_grey>: main session scripts that interact directly with global tables
    <gainsboro>session_alt.lua<dim_grey>: alt-specific script (raise events instead of direct manipulations)
    <gainsboro>session_events.lua<dim_grey>: define the "event handling" logic to receive messages from alts
    <gainsboro>session_common.lua<dim_grey>: shared/common scripts that both main & alts use

<yellow_green>Map (Gizmo)<dim_grey>:
  Interface to Mudlet's Mapper UI; support for offline map simulation and in-game map following [WIP]
  <olive_drab>map_const.lua<dim_grey>: global constants & definitions for mapping
  <olive_drab>map_main.lua<dim_grey>: main map script for creation, tracking, pathfinding, etc.
  <olive_drab>map_ux.lua<dim_grey>: define & maintain Map style (fonts, colors, room highlighting, etc.)

<ansi_red>GUI (Gizmo)<dim_grey>:
  Create and maintain Chat & Info Windows, Party Console, PC Status gauges, labels, etc.
  <firebrick>gui.lua<dim_grey>: update & maintain GUI
  <firebrick>gui_create.lua<dim_grey>: initial creation of GUI components

<royal_blue>EQ (Gizmo)<dim_grey>:
  Interact with the equipment database and manage & track in-game player inventory (e.g., gear swaps)
  <dodger_blue>eq_db.lua<dim_grey>: equipment database
  <dodger_blue>eq_inventory.lua<dim_grey>: in-game equipment and item management

  ]]
  cecho( structureHelp )
end
