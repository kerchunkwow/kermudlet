## Mudlet/Lua Tips & Tricks

### Gating/Throttling Triggers
- Use quick & diry semaphores to gate or throttle functions that might be called repeatedly under certain conditions (usually by triggers).

```
-- Don't let this happen more than once per 5s interval
if not semaphore and someCondition then
  semaphore = true
  someFunction()
  tempTimer( 5, [[semaphore = nil]])
end
```
### Temporary Data Capture Triggers
- Certain triggers are only useful when capturing data from a specific command like score; for efficiency, leaves these off by default and use an Alias to turn them on temporarily prior to issuing the command in question. You can either leave them on for a set period of time (enough to ensure the output is done parsing), or use some component of the output to trigger the disable. Here's an example of how to enable a temporary trigger to capture 'aff' data from all sessions.
```
-- Called by 'aff'; turns on temporary affect capturing triggers for all sessions to update affect status strings
function aliasAffectCapture()
  -- Reset the affect table so missing affects are properly dropped
  resetAffects()
  -- Turn on the affect capturing trigger for three seconds
  expandAlias( [[all lua tempEnableTrigger( 'AffectCapture', 3 )]], false )
  -- Issue 'aff' in all profiles
  expandAlias( 'all aff', false )
end
```

## Notes

- `deprecated.lua` has a boat load of functions that are no longer relevant and/or were only needed for one-off or one-time needs; you will want to add `**/deprecated.lua` to `search.exclude` or whatever the equivalent is in your IDE so you don't get a ton of noise in your search results.
- Some functions are temporarily defined `local` because they aren't currently being used anywhere (but I wasn't quite ready to toss them into the deprecated bin).
- Use `refreshModuleXML()` to create `gizmudlet.lua`; the function will unpack the XML file from Mudlet's module file (`.mpackage`), then parse that into a Lua file which your IDE can use for syntax checking, verification, etc. (i.e., it makes in-client stuff available to your IDE).
