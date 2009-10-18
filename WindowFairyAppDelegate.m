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
  
}

- (IBAction) refreshButtonClicked: (id) sender {
  [windowManager reloadWindowList];
  NSLog(@"windows:");
  for (Window *wnd in windowManager.windowList) {
    NSLog(@"window \"%@\" of application %@ (%@)", wnd.name, wnd.application.name, wnd.application.pid);
  }
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
