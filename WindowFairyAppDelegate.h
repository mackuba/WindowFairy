// -------------------------------------------------------
// WindowFairyAppDelegate.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under GPL v3 license
// -------------------------------------------------------

#import <Cocoa/Cocoa.h>

@class WindowManager;

@interface WindowFairyAppDelegate : NSObject {
  NSView *view;
  NSTableView *tableView;
  WindowManager *windowManager;
}

- (IBAction) switchButtonClicked: (id) sender;
- (IBAction) refreshButtonClicked: (id) sender;

@property IBOutlet NSView *view;
@property IBOutlet WindowManager *windowManager;
@property IBOutlet NSTableView *tableView;

@end
