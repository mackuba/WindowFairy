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

static NSInteger const WindowMaxWidth = 1000;
static NSInteger const WindowMaxHeight = 800;
static NSInteger const WindowScreenXMargin = 50;
static NSInteger const WindowScreenYMargin = 50;
static NSInteger const TableViewPadding = 20;
static NSInteger const WarningLabelMargin = 20;

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
    [tableView sizeLastColumnToFit];
    self.window = window;

    self.warningLabelWrapper.layer.backgroundColor = NSColor.systemOrangeColor.CGColor;
    self.warningLabelWrapper.layer.cornerRadius = 8.0;
  }

  if (!self.window.isVisible) {
    [NSApp activateIgnoringOtherApps:YES];

    [windowListManager reloadList];
    [tableView reloadData];
    [self moveCursorToRow:0];
    [self updateWarningLabel];
    [self resizeWindow];

    [self.window makeKeyAndOrderFront:nil];
    [self.window makeFirstResponder:contentView];
    [(SelectionWindow *)self.window setTransient:YES];
  }
}

- (void) showSelectionWindowPermanent {
  [self showSelectionWindow];
  [(SelectionWindow *)self.window setTransient:NO];
}

- (void) updateWarningLabel {
  if (windowListManager.error) {
    self.warningLabelWrapper.hidden = NO;
    self.warningLabel.stringValue = [@"⚠️ " stringByAppendingString: windowListManager.error.localizedDescription];
    self.scrollViewToTopConstraint.active = NO;
  } else {
    self.warningLabelWrapper.hidden = YES;
    self.scrollViewToTopConstraint.active = YES;
  }
}

- (void) resizeWindow {
  NSScreen *screen = [NSScreen mainScreen];
  CGFloat maxWidth = MIN(WindowMaxWidth, screen.frame.size.width - WindowScreenXMargin);
  CGFloat maxHeight = MIN(WindowMaxHeight, screen.frame.size.height - WindowScreenYMargin);

  NSRect lastRow = [tableView rectOfRow:(tableView.numberOfRows - 1)];
  CGFloat contentHeight = lastRow.origin.y + lastRow.size.height;

  NSRect frame = self.window.frame;
  frame.size.width = maxWidth;
  frame.size.height = MIN(contentHeight + 2 * TableViewPadding, maxHeight);

  if (!self.warningLabelWrapper.hidden) {
    frame.size.height += WarningLabelMargin + self.warningLabelWrapper.frame.size.height;
  }

  [self.window setFrame:frame display:YES];
  [self.window center];
}

- (IBAction) showSystemPreferencesPanel:(id)sender {
  NSString *urlString;
  NSInteger errorCode = windowListManager.error.code;

  if (errorCode == AccessibilityAccessError) {
    urlString = @"x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility";
  } else if (errorCode == ScreenRecordingAccessError) {
    urlString = @"x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture";
  }

  if (urlString) {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:urlString]];
    [self.window close];
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
  currentRow = (currentRow + windowListManager.windowCount - 1) % windowListManager.windowCount;
  [self moveCursorToRow: currentRow];
}

- (void) performSwitch {
  NSInteger row = [tableView selectedRow];

  if (row > -1) {
    [windowListManager switchToWindowAtIndex: MAX(row, 0)];
  }

  [self.window close];
}

- (void) closeWithoutSwitching {
  // we need to restore focus to the app & window that was originally selected
  if (windowListManager.windowCount > 0) {
    [windowListManager switchToWindowAtIndex: 0];
  }

  [self.window close];
}

@end
