// -------------------------------------------------------
// SelectionWindowController.h
//
// Copyright (c) 2022 Kuba Suder
// Licensed under WTFPL license
// -------------------------------------------------------

#import <Cocoa/Cocoa.h>
#import "SelectionWindowDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@class WindowListManager;

@interface SelectionWindowController : NSWindowController <NSTableViewDataSource, SelectionWindowDelegate>

@property IBOutlet NSView *contentView;
@property IBOutlet NSTableView *tableView;
@property IBOutlet NSTextField *warningLabel;
@property IBOutlet NSView *warningLabelWrapper;
@property IBOutlet NSLayoutConstraint *scrollViewToTopConstraint;

- (IBAction) showSystemPreferencesPanel:(id)sender;
- (IBAction) rowDoubleClicked:(id)sender;
- (void) showSelectionWindow;
- (void) showSelectionWindowPermanent;

@end

NS_ASSUME_NONNULL_END
