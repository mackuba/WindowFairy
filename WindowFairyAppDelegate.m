// -------------------------------------------------------
// WindowFairyAppDelegate.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under GPL v3 license
// -------------------------------------------------------

#import "Application.h"
#import "SelectionWindow.h"
#import "Window.h"
#import "WindowFairyAppDelegate.h"
#import "WindowManager.h"

@interface WindowFairyAppDelegate ()
- (void) reloadView;
@end

@implementation WindowFairyAppDelegate

@synthesize view, windowManager, tableView;

- (void) awakeFromNib {
  [self reloadView];
  SelectionWindow *window = [[SelectionWindow alloc] initWithView: view];
  [window makeKeyAndOrderFront: nil];
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
