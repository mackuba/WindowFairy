// -------------------------------------------------------
// WindowFairyAppDelegate.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// -------------------------------------------------------

#import "WindowFairyAppDelegate.h"
#import "WindowManager.h"

#import "Window.h"
#import "Application.h"

@implementation WindowFairyAppDelegate

@synthesize window, windowManager, tableView;

- (void) awakeFromNib {
  [windowManager reloadWindowList];
  NSLog(@"windows:");
  for (Window *wnd in windowManager.windowList) {
    NSLog(@"window \"%@\" of application %@ (%@)", wnd.name, wnd.application.name, wnd.application.pid);
  }
}

- (IBAction) switchButtonClicked: (id) sender {
  NSInteger row = [tableView selectedRow];
  if (row >= 0) {
    Window *windowRecord = [windowManager.windowList objectAtIndex: row];
    AXUIElementPerformAction(windowRecord.accessibilityElement, kAXRaiseAction);
    [windowManager reloadWindowList];
    [tableView reloadData];
    NSInteger newIndex = 0;
    while ((newIndex < windowManager.windowList.count)
      && ![((Window *) [windowManager.windowList objectAtIndex: newIndex]).name isEqualTo: windowRecord.name])
      newIndex++;
    if (newIndex < windowManager.windowList.count) {
      [tableView selectRowIndexes: [NSIndexSet indexSetWithIndex: newIndex] byExtendingSelection: NO];
    }
  }
}

- (IBAction) refreshButtonClicked: (id) sender {
  [windowManager reloadWindowList];
  [tableView reloadData];
}

- (NSInteger) numberOfRowsInTableView: (NSTableView *) view {
  return windowManager.windowList.count;
}

- (id) tableView: (NSTableView *) view
       objectValueForTableColumn: (NSTableColumn *) column
       row: (NSInteger) row {
  Window *windowRecord = [windowManager.windowList objectAtIndex: row];
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
