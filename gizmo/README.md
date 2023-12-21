# Wiki Contents

- [Main How-To](#gizmudlet-for-mudlet-for-gizmo-dikumud)
- [Update December 2023](#update-december-2023)

# Gizmudlet for Mudlet for Gizmo DikuMUD

[Mudlet](https://www.mudlet.org/) is a toolkit like CMUD and WINTIN to enhance MUD gameplay.

[Gizmudlet](gizmudlet.mpackage) is a Mudlet module that contains the triggers, aliases, and supporting Lua scripts that
I personally use to play the game. I have made efforts to develop Gizmudlet to be easily portable and adaptable to new
parties; while it is not quite up to "plug-and-play" status quite yet, it should give you an excellent place to start
exploring Mudlet if you are interested.

In the future, this project could grow to become a collaborative effort for creating and sharing new Mudlet tools and
features for Gizmo. Mudlet's Lua integration and the Package and Module features presents a lot of opportunity to build
tools in a way that's modular and easily customizable.

For now, you can use this guide to walk through the basic steps of getting Mudlet and Gizmudlet set up for Gizmo:

- [Installing](#install-mudlet) the Mudlet client
- Creating & configuring [sessions](#set-up-sessions)
- [Uninstalling](#uninstall-preinstalled-packages) basic pre-installed packages
- Installing [Gizmudlet](#gizmudlet) with the Module Manager
- [Configuring](#configuring-gizmudlet-for-you) Gizmudlet for your party
- Ideas for basic [versioning](#versioning)

## Mudlet

### Install Mudlet

Download the [Mudlet client](https://www.mudlet.org/download/) and install; it doesn't allow customized installation;
mine ended up in :file_folder:`C:\Users\<Username>\AppData\Local\Mudlet`; pin a shortcut to this location as you will
be visiting here often.

Another important location: :file_folder:`C:\Users\<Username>\.config\mudlet`. Your session files exist here as well as
backups of them and the Gizmudlet package (your local copy of it anyway). There does not seem to be a limit to the
number of backups that Mudlet creates here, so you may want to stop by periodically to clean them up. I created
a [batch file](assets/tools/backup.bat) to delete old backups and archive recent ones.

### Set Up Sessions

Run Mudlet and create four sessions for your PCs named '1' through '4'. You can jump right in with just four vanilla
profiles and skip down to the [Preinstalled Packages](#uninstall-preinstalled-packages) section, but...

:white_check_mark: my personal recommendation is to create your '1' profile and then spend a little time configuring
this session to your personal tastes so you can use 'Copy settings only' on the 'Copy' button to create the other
sessions which inherit your preferences.

![Session Setup](/assets/wiki/session_setup.png)

There are a few settings you might want to customize on a per-session basis, but most of the basics are great to share
this way as it can save a lot of clicking (especially if you like to customize the ANSI colors like me).

:white_check_mark: Another tip from this menu: With 'Connect' you can select a session and then click 'Offline' in order
to load that session without connecting to Gizmo; this is helpful when configuring things or when you're developing and
testing new features.

If you do take the 'Copy Settings' approach, here are some of my personal suggestions for settings to take note of
first:

- On the `Input line` tab you can set the default behavior for command echo and clear as well as setting the command
  separator. The default is ';;' unlike the ';' separator many of us are used to.

- The `Main display` tab has some basic formatting options; I had never used the built-in font 'Bitstream Vera Sans
  Mono' before but it has really grown on me. At 14 point, it has been super easy on my rapidly aging eyes (don't snitch
  on me to the DMV).

- The `Editor` tab allows you to choose the syntax highlighting scheme for the Lua editor you will use to write your
  scripts; my favorite is 'Monokai', but more :triangular_flag_on_post: important to note here that I _strongly_
  recommend the first thing you do after creating your other sessions is to go into each individual session and change
  this value to a different color scheme which is very distinct from your main session. When you read about the "Sync"
  feature later, it should be clear why it's important to know which editor you're in. If you make changes in a session
  other than your own, they're almost certainly going to end up overwritten by a later Sync from the main session.

- The `Color view` tab lets you modify some basic color values; once you get all of your sessions setup I recommend
  setting command line colors that correlate to each of your pcs - both foreground and background. This gives you a
  subtle but noticeable indicator for which window you're in should you find the need to swap between them:

![Sample Command Lines](/assets/wiki/commandlines.png)

This tab also lets you modify the value of the basic ANSI color set which I really appreciate. I find the standard set
to be very dark on my display. Unfortunately you cannot adjust the background color because Gizmo enforces #000000
behind all of its output, but I did configure a set of "brighter" ANSI colors which I'll share here if you want to try
them too:

- Black `#000000`
- Light Black `#7D7D7D`
- Red `#DC0014`
- Light Red `#FA003C`
- Green `#50C800`
- Light Green `#78f000`
- Yellow `#d2dc00`
- Light Yellow `#f0fa00`
- Blue `#0050fa`
- Light Blue `#007dfa`
- Magenta `#c800b4`
- Light Magenta `#fa00e1`
- Cyan `#00c8d2`
- Light Cyan `#00f0fa`

### Uninstall Preinstalled Packages

New Mudlet sessions come pre-installed with a few "packages." You can see these by opening the Package Manager; packages
are simply pre-written aliases and triggers and the team has incorporated a few that over the years became very popular
and have some universal applicability.

For now I recommend manually uninstalling all of the pre-installed packages for two reasons: 1) Some of this basic
functionality has been rewritten in Gizmudlet and I have no idea how things might behave if both are active at the same
time and 2) you can always go out and find these packages later if you think one might contain something you want to
use.

You will need to remove the packages from all four sessions.

## Gizmudlet

### Get Gizmudlet

Gizmudlet itself is just a bunch of `.lua` scripts and some supporting assets, so there's no need to do anything
fancy in terms of actually 'installing' the Module on your machine. Just pick a home for Gizmudlet on your machine
like `C:\Gizmo` orso, then use one of two simple install methods. By far the simplest is to install git, navigate
to the folder and run:

`git clone https://github.com/kerchunkwow/gizmudlet.git gizmudlet`

This will create a subdirectoy named `gizmudlet` with the contents of the project. Alternatively, you can choose to
'Download ZIP' from the 'Code' dropdown menu and manually unpack the contents to the folder where you want gizmudlet
to reside.

:warning: Keep in mind that (for now) there's no mechanism built-in to get updates to Gizmudlet from within the client.
If I post a new version later that you want to try it, cloning the repository again or unpacking another `.zip` will
overwrite your local copy including any changes you have made to it in the meantime. See the section on versioning(
#versioning) for some thoughts on how to account for this.

`.mpackage` files are renamed `.zip` files; you can view the contents by changing the extension. Inside is a
configuration file and a `.lua` file containing all of the scripts, triggers, and aliases in the module.

### Installing the Gizmudlet Module

Once you have four clean sessions and have downloaded Gizmudlet, you're ready to install it with the 'Module Manager' in
Mudlet. From each session, you will need to open the Module Manager and 'Install' the Module as pictured below.

Once installed, check the 'Sync' option in your main session (**and _ONLY_ your main session**:exclamation:):

![Module Installation](/assets/wiki/module_manager.png)

I found the help language in the 'Module Manager' a little unclear, so to explain very simply: if you install Gizmudlet
in every session and tick the 'Sync' box in your main session, then any time you make changes to the module from the
main session _and write them to disk_, they will immediately be loaded by your other sessions without requiring any
further action on your part.

:warning: There are some important notes here:

It is not enough to 'Save Script' in order to propagate your changes to other sessions; this does not actually write
your changes to disk. You must use 'Save Profile' instead. I personally recommend getting into the habit of doing both.
Incidentally, the other reason to do this is that settings saved with 'Save Script' will not be preserved if you close
the application (or experience a crash) before executing 'Save Profile.' If you're familiuar with AutoHotKey, I wrote
a [script](/assets/tools/powersave.ahk) that automatically executes both 'Save Script' and 'Save Profile' with CTRL-S.

![Save Sync](/assets/wiki/save_sync.png)

Think of 'Save Script' more like '_Temporary Save_' or '_Local Save_' and 'Save Profile' like '_Permanently Save &
Share_' or '_Publish_' and get into the habit of using these regularly and liberally.

Mudlet considers everything under the 'gizmudlet' folder(s) to be a part of the module. If you create a new folder
outside of the Gizmudlet structure, it will not be subject to the 'Sync' behavior configured in the 'Module Manager' and
none of what you create there will appear in your other sessions. Although I highly recommend the "single module" design
approach I use with Gizmudlet, if you do decide you need aliases or triggers beyond the Gizmudlet umbrella then this is
how you create things that only the current session will have access to.

### Configuring Gizmudlet For You

The [gizmudlet_config.lua](config/config_common.lua) acts as an external configuration file for Gizmudlet; after a
session with the module installed loads and retrieves it's session number, it executes this file immediately using the
load_file function. This essentially runs all of the script in the file which you will see defines a bunch of global
variables for use throughout the project.

Most importantly if you want to get Gizmudlet to a point of basic functionality for your party you will want to:

- Update the `pc_names` and `short_names` tables; the short names in particular are important as these are the commands
  you will use to control other windows. For example, if I want Nadja to rest I can send `nad sit`; this relies on the
  session command alias and associated script to pass this command to Nadja's window via Mudlet's event engine.

- You will want to set up your own Login procedure either by using Mudlet's off-the-shelf configuration on the Session
  profile, or writing your own version of `login.lua` which is invoked by my login alias.

### Versioning

If you want to be able to check out new "versions" of Gizmudlet in the future, you will want to set up your local
version so it doesn't get overwritten by new copies. There are a few simple ways you could do this:

- Rename gizmudlet.mpackage and the associated folders within Mudlet; something like my_gizmudlet; this will allow
  you to import future versions of gizmudlet without overwriting your local changes.
- Create your own module separate from gizmudlet and simply treat Gizmudlet as an archive or "reference" library;
  you can even disable or deactivate the pieces of Gizmudlet you don't want and use them for reference

![Versioning Suggestions](/assets/wiki/versioning_suggestions.png)

# Update December 2023

One thing I have been trying to do since starting to use Mudlet was utilize an external IDE for organizing and editing
my scripts. I have achieved that in the latest version of Gizmudlet using a function named run_lua_file(). The project
is now setup so there is very little script "inside" the `.mpackage` file itself. Most of it has been migrated to
external `.lua` files which are loaded by the Mudlet script at startup using the run_lua_file() function like so:

![Loading External Lua](/assets/wiki/run_lua.png)

With all of these files external to the Mudlet editor, I now use an external IDE to work on the project. There are
a lot of options out there to do this, I would personally recommend using Pycharm with the EmmyLua plugin installed,
or Sublime Text with packages for Lua highlighting.

Emojis to steal:
:fire: :hocho: :star:
