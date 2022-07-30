// -------------------------------------------------------
// WindowFairyAppDelegate.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under WTFPL license
// -------------------------------------------------------

// CARBON ALERT! BATTLESTATIONS! ;)
#import <Carbon/Carbon.h>

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
- (void) moveCursorToRow: (NSInteger) row;
@end


OSStatus keyboardHandler(EventHandlerCallRef nextHandler, EventRef event, void *data) {
  [[NSApp delegate] hotKeyActivated];
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

// TODO: use CoreAnimation fade-in and fade-out to show and hide the window

- (void) showSelectionWindow {
  if (!window) {
    [NSApp activateIgnoringOtherApps: YES];
    window = [[SelectionWindow alloc] initWithView: view];
    [self reloadView];
    [self moveCursorToRow: 0];
    [window makeKeyAndOrderFront: nil];
    [window makeFirstResponder: [window contentView]];
  }
}

- (void) hideSelectionWindow {
  if (window) {
    [window close];
    window = nil;
  }
}

- (void) hotKeyActivated {
  if (!window) {
    [self showSelectionWindow];
  }
  [self moveCursorDown];
}

// TODO: handle "no windows" situation

- (void) moveCursorToRow: (NSInteger) row {
  [tableView selectRowIndexes: [NSIndexSet indexSetWithIndex: row] byExtendingSelection: NO];
}

- (void) moveCursorDown {
  if (windowManager.windowCount == 0) { return; }

  NSInteger currentRow = [tableView selectedRow];
  currentRow = (currentRow + 1) % windowManager.windowCount;
  [self moveCursorToRow: currentRow];
}

- (void) moveCursorUp {
  if (windowManager.windowCount == 0) { return; }

  NSInteger currentRow = [tableView selectedRow];
  currentRow = (currentRow - 1) % windowManager.windowCount;
  [self moveCursorToRow: currentRow];
}

- (void) performSwitch {
  NSInteger row = [tableView selectedRow];

  if (row > -1) {
    [windowManager switchToWindowAtIndex: MAX(row, 0)];
  }

  [self hideSelectionWindow];
}

- (void) closeWithoutSwitching {
  [windowManager switchToWindowAtIndex: 0];
  [self hideSelectionWindow];
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
    return windowRecord.application.localizedName;
  } else {
    return windowRecord.name;
  }
}

@end
