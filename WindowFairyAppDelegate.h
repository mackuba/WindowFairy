// -------------------------------------------------------
// WindowFairyAppDelegate.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under WTFPL license
// -------------------------------------------------------

#import <Cocoa/Cocoa.h>

@class SelectionWindowController;

@interface WindowFairyAppDelegate : NSObject <NSApplicationDelegate>

- (void) hotKeyActivated;

@property IBOutlet SelectionWindowController *windowController;

@end
