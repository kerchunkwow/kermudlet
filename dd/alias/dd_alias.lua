function toggleDeveloperMode()
  developerMode = not developerMode
  if developerMode then
    enableAlias("DEV & QA")
  else
    disableAlias("DEV & QA")
  end
end
