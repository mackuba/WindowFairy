// -------------------------------------------------------
// WindowFairyAppDelegate.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under GPL v3 license
// -------------------------------------------------------

// CARBON ALERT! BATTLESTATIONS! ;)
#import <Carbon/Carbon.h>

#import "Application.h"
#import "SelectionWindow.h"
#import "Window.h"
#import "WindowFairyAppDelegate.h"
#import "WindowManager.h"

#define SHOW_WINDOW_HOTKEY_ID         1
#define SHOW_WINDOW_HOTKEY_NAME       'show'
#define SHOW_WINDOW_HOTKEY_CODE       48   // tab
#define SHOW_WINDOW_HOTKEY_MODIFIERS  optionKey



@interface WindowFairyAppDelegate ()
- (void) reloadView;
- (void) installGlobalHotKey;
- (void) showSelectionWindow;
@end


OSStatus keyboardHandler(EventHandlerCallRef nextHandler, EventRef event, void *data) {
  [[NSApp delegate] showSelectionWindow];
  return noErr;
}


@implementation WindowFairyAppDelegate

@synthesize view, windowManager, tableView;

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

- (void) showSelectionWindow {
  [self reloadView];
  if (!window) {
    window = [[SelectionWindow alloc] initWithView: view];
    [window makeKeyAndOrderFront: nil];
  }
}

- (void) hideSelectionWindow {
  if (window) {
    [window orderOut: nil];
    window = nil;
  }
}

- (IBAction) cancelButtonClicked: (id) sender {
  [self hideSelectionWindow];
}

- (IBAction) switchButtonClicked: (id) sender {
  NSInteger row = [tableView selectedRow];
  if (row >= 0) {
    // bring selected window to front
    Window *selectedWindow = [windowManager windowAtIndex: row];
    [windowManager switchToWindow: selectedWindow];

    // refresh the list and reselect the window in new position
    [self reloadView];
    NSInteger newIndex = 0;
    NSInteger windowCount = windowManager.windowCount;
    while (newIndex < windowCount) {
      Window *w = (Window *) [windowManager windowAtIndex: newIndex];
      if ([w.name isEqualToString: selectedWindow.name]) {
        [tableView selectRowIndexes: [NSIndexSet indexSetWithIndex: newIndex] byExtendingSelection: NO];
        break;
      }
      newIndex++;
    }
  }
}

- (IBAction) refreshButtonClicked: (id) sender {
  [self reloadView];
}

- (void) reloadView {
  [windowManager reloadWindowList];
  [tableView reloadData];
}

- (NSInteger) numberOfRowsInTableView: (NSTableView *) view {
  return windowManager.windowCount;
}

- (id) tableView: (NSTableView *) view
       objectValueForTableColumn: (NSTableColumn *) column
       row: (NSInteger) row {
  Window *windowRecord = [windowManager windowAtIndex: row];
  NSString *columnName = (NSString *) [column identifier];
  if ([columnName isEqualToString: @"Icon"]) {
    return windowRecord.application.icon;
  } else if ([columnName isEqualToString: @"AppName"]) {
    return windowRecord.application.name;
  } else {
    return windowRecord.name;
  }
}

@end
