// -------------------------------------------------------
// WindowFairyAppDelegate.m
//
// Copyright (c) 2009 Kuba Suder
// Licensed under WTFPL license
// -------------------------------------------------------

// CARBON ALERT! BATTLESTATIONS! ;)
#import <Carbon/Carbon.h>

#import "SelectionWindowController.h"
#import "WindowFairyAppDelegate.h"

UInt32 const ShowWindowHotkeyID = 1;
OSType const ShowWindowHotkeyName = 'show';

UInt32 const ShowWindowHotkeyKeyCode = 48;  // tab
UInt32 const ShowWindowHotkeyModifiers = optionKey;


OSStatus keyboardHandler(EventHandlerCallRef nextHandler, EventRef event, void *data) {
  [(WindowFairyAppDelegate *) [NSApp delegate] hotKeyActivated];
  return noErr;
}


@implementation WindowFairyAppDelegate

@synthesize windowController;

- (void) awakeFromNib {
  [self installGlobalHotKey];
}

- (void) installGlobalHotKey {
  EventTypeSpec eventType;
  eventType.eventClass = kEventClassKeyboard;
  eventType.eventKind = kEventHotKeyPressed;
  InstallApplicationEventHandler(&keyboardHandler, 1, &eventType, NULL, NULL);

  EventHotKeyRef hotKeyRef;
  EventHotKeyID hotKeyID;
  hotKeyID.id = ShowWindowHotkeyID;
  hotKeyID.signature = ShowWindowHotkeyName;

  RegisterEventHotKey(ShowWindowHotkeyKeyCode, ShowWindowHotkeyModifiers, hotKeyID,
    GetApplicationEventTarget(), 0, &hotKeyRef);
}

- (void) hotKeyActivated {
  [windowController showSelectionWindow];
  [windowController moveCursorDown];
}

@end
