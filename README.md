# Kermudlet Project

## Introduction
A personal project leveraging Lua 5.1 scripts for the Mudlet client to enhance and automate MUD gameplay. Incorporates Python for utility scripts, focusing on a small team of collaborators.

## Project Structure

### gizmo Directory
Central hub for Lua scripts related to Mudlet functionalities.
- **config/**: Contains settings and configuration scripts.
- **data/**: Houses database files and mapping data.
- **eq/**: Scripts for equipment management.
- **gui/**: Components for the graphical user interface.
- **map/**: Utilities and data for in-game mapping.
- **react/**: Aliases and triggers for game reactions.
- **status/**: Tracks player and game status.

### lib Directory
Shared libraries for common functionalities.
- Example: `lib_string.lua` for string operations.

### Utilities
- `parse_xml.py`: Converts Mudlet's XML profiles to Lua for easier handling in IDEs.

### Deprecated Components
Notes on deprecated functions and their locations.

## Key Functionalities
Overview of core project functionalities.
- Automated gameplay enhancements.
- SQLite integration for game data management.
- Custom GUI components for a better user experience.

## Development Notes
- Focus on performance optimization and code reuse.
- Coding conventions: camelCase for variables and functions.

## Script and Function Catalog
Quick reference to critical scripts/functions, including dependencies.

## Future Enhancements
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


