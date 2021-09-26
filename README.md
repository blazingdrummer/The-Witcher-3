Initial commit for the project, primarily for the sake of backup since the final results of my custom work are not currently being stored outside of the game files themselves.

Does `NOT` currently include the user settings, since I need to figure out if I can use symlinks for that.

Custom Work:
Includes the custom version of Crossbow&Torch, which was manually modified to use different keybinds (based on the changes made by Lazarus). Its strings have also been edited to use "Lamp" instead of "Torch" where applicable in the menus.
Also includes the custom version of Thoughtful Roach that includes HUD messages clarifying which mode you are in.

Note that very little of the final product is currently stored outside of the game files, thus my concerns for making this backup before I make any major changes.

Tasks:
- [X] test if TW3 will allow the Documents folder (user settings) to be a symlink, and store the files in the repo instead
	- same approach I used for RoR2
- [ ] update Modular Eyes
	- should also check if tools have been updated
- [X] edit the difficulty names to be less offensive :P
- [ ] check time ratio (default for W3EE should be 1:15) and tweak if necessary
	- the code to edit is mentioned on the W3EE page, Lazarus uses a 1:4 ratio
	- one hour should be about a day's work?
	- tweak meditation acceleration accordingly

menu edits
- [ ] clean up menu strings
  - potentially edit tutorial messages to better explain mechanics
  - clarify what "Witcher 2 Save Sim" means
  - [X] remove menu options for new game besides "Fresh Start"
- [ ] add custom presets for easy setup
  - could remove existing defaults in favor of my own
- [ ] clean up default user settings
  - e.g. the DLC popups are cleared by default, tutorials might be as well
  - enable DLC Gwent Cards
- [ ] create a comprehensive guide explaining behavior of all included mods
  - made up terms to explain:
    - Anarchy Tax (when guards knock you out)
