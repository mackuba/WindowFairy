// -------------------------------------------------------
// SelectionWindowController.m
//
// Copyright (c) 2022 Kuba Suder
// Licensed under WTFPL license
// -------------------------------------------------------

#import "SelectionWindow.h"
#import "SelectionWindowController.h"
#import "Window.h"
#import "WindowListManager.h"

@interface SelectionWindowController () {
  WindowListManager *windowListManager;
}

@end

@implementation SelectionWindowController

@synthesize contentView, tableView;

- (void)awakeFromNib {
  windowListManager = [[WindowListManager alloc] init];
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
    [windowListManager reloadList];
    [tableView reloadData];
    [self moveCursorToRow:0];
    [self.window makeKeyAndOrderFront:nil];
    [self.window makeFirstResponder:contentView];
  }
}


#pragma mark - NSTableViewDataSource

- (NSInteger) numberOfRowsInTableView: (NSTableView *) view {
  return windowListManager.windowCount;
}

- (id) tableView: (NSTableView *) view
       objectValueForTableColumn: (NSTableColumn *) column
       row: (NSInteger) row {
  Window *windowRecord = [windowListManager windowAtIndex: row];
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
  [tableView scrollRowToVisible:row];
}

- (void) moveCursorDown {
  if (windowListManager.windowCount == 0) { return; }

  NSInteger currentRow = [tableView selectedRow];
  currentRow = (currentRow + 1) % windowListManager.windowCount;
  [self moveCursorToRow: currentRow];
}

- (void) moveCursorUp {
  if (windowListManager.windowCount == 0) { return; }

  NSInteger currentRow = [tableView selectedRow];
  currentRow = (currentRow - 1) % windowListManager.windowCount;
  [self moveCursorToRow: currentRow];
}

- (void) performSwitch {
  NSInteger row = [tableView selectedRow];

  if (row > -1) {
    [windowListManager switchToWindowAtIndex: MAX(row, 0)];
  }

  [self.window close];
}

@end
