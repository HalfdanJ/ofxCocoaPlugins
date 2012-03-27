Install ofxCocoaPlugins
==============

### Clone
Missing!

### Install OpenDMX 
Install the dmg file: http://code.google.com/p/linux-lighting/downloads/detail?name=OLA%200.8.9.dmg&can=1&q=dmg


### Create new project
1. Clear Prefix Header in build settings
2. Rename AppDelegate.m to AppDelegate.mm
3. Add ofxCocoaPlugins.framewok to project
4. Add #import <ofxCocoaPlugins/ofxCocoaPlugins.h> to AppDelegate.h (before Cocoa include)
5. Add Copy Files build phase, and set the destination to Frameworks and add ofxCocoaPlugins.framework



