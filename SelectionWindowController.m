// -------------------------------------------------------
// SelectionWindowController.m
//
// Copyright (c) 2022 Kuba Suder
// Licensed under WTFPL license
// -------------------------------------------------------

#import "SelectionWindow.h"
#import "SelectionWindowController.h"
#import "Window.h"
#import "WindowManager.h"

@interface SelectionWindowController () {
  WindowManager *windowManager;
}

@end

@implementation SelectionWindowController

@synthesize contentView, tableView;

- (void)awakeFromNib {
  windowManager = [[WindowManager alloc] init];
}

// TODO: use CoreAnimation fade-in and fade-out to show and hide the window

- (void) showSelectionWindow {
  if (!self.window) {
    SelectionWindow *window = [[SelectionWindow alloc] initWithView:contentView];
    [window setSelectionDelegate:self];
    [window center];
    [tableView sizeLastColumnToFit];
    self.window = window;
  }

  if (!self.window.isVisible) {
    [NSApp activateIgnoringOtherApps:YES];
    [windowManager reloadWindowList];
    [tableView reloadData];
    [self moveCursorToRow:0];
    [self.window makeKeyAndOrderFront:nil];
    [self.window makeFirstResponder:contentView];
  }
}


#pragma mark - NSTableViewDataSource

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


#pragma mark - SelectionWindowDelegate

- (void) moveCursorToRow: (NSInteger) row {
  [tableView selectRowIndexes:[NSIndexSet indexSetWithIndex: row] byExtendingSelection: NO];
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

  [self.window close];
}

@end
