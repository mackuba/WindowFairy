// -------------------------------------------------------
// SelectionWindowController.h
//
// Copyright (c) 2022 Kuba Suder
// Licensed under WTFPL license
// -------------------------------------------------------

#import <Cocoa/Cocoa.h>
#import "SelectionWindowDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@class WindowManager;

@interface SelectionWindowController : NSWindowController <NSTableViewDataSource, SelectionWindowDelegate>

@property IBOutlet NSView *contentView;
@property IBOutlet NSTableView *tableView;
@property IBOutlet WindowManager *windowManager;

- (void) showSelectionWindow;

@end

NS_ASSUME_NONNULL_END
