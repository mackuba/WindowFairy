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

#define SHOW_WINDOW_HOTKEY_ID         1
#define SHOW_WINDOW_HOTKEY_NAME       'show'
#define SHOW_WINDOW_HOTKEY_CODE       48   // tab
#define SHOW_WINDOW_HOTKEY_MODIFIERS  optionKey


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
  hotKeyID.signature = SHOW_WINDOW_HOTKEY_NAME;
  hotKeyID.id = SHOW_WINDOW_HOTKEY_ID;
  RegisterEventHotKey(SHOW_WINDOW_HOTKEY_CODE, SHOW_WINDOW_HOTKEY_MODIFIERS, hotKeyID,
    GetApplicationEventTarget(), 0, &hotKeyRef);
}

- (void) hotKeyActivated {
  [windowController showSelectionWindow];
  [windowController moveCursorDown];
}

@end
