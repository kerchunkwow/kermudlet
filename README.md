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

## Notes

- `deprecated.lua` has a boat load of functions that are no longer relevant and/or were only needed for one-off or one-time needs; you will want to add `**/deprecated.lua` to `search.exclude` or whatever the equivalent is in your IDE so you don't get a ton of noise in your search results.
- Some functions are temporarily defined `local` because they aren't currently being used anywhere (but I wasn't quite ready to toss them into the deprecated bin).
- Use `refreshModuleXML()` to create `gizmudlet.lua`; the function will unpack the XML file from Mudlet's module file (`.mpackage`), then parse that into a Lua file which your IDE can use for syntax checking, verification, etc. (i.e., it makes in-client stuff available to your IDE).
