// -------------------------------------------------------
// WindowFairyAppDelegate.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// -------------------------------------------------------

#import <Cocoa/Cocoa.h>

@class WindowManager;

@interface WindowFairyAppDelegate : NSObject <NSApplicationDelegate> {
  NSWindow *window;
  NSTableView *tableView;
  WindowManager *windowManager;
}

- (IBAction) switchButtonClicked: (id) sender;
- (IBAction) refreshButtonClicked: (id) sender;

@property IBOutlet NSWindow *window;
@property IBOutlet WindowManager *windowManager;
@property IBOutlet NSTableView *tableView;

@end
