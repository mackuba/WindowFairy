// -------------------------------------------------------
// WindowFairyAppDelegate.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under WTFPL license
// -------------------------------------------------------

#import <Cocoa/Cocoa.h>

@class WindowManager;

@interface WindowFairyAppDelegate : NSObject {
  NSView *view;
  NSTableView *tableView;
  WindowManager *windowManager;
  SelectionWindow *window;
}

- (void) performSwitch;
- (void) closeWithoutSwitching;
- (void) moveCursorUp;
- (void) moveCursorDown;
- (void) hotKeyActivated;

@property IBOutlet NSView *view;
@property IBOutlet WindowManager *windowManager;
@property IBOutlet NSTableView *tableView;

@end
