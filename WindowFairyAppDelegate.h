// -------------------------------------------------------
// WindowFairyAppDelegate.h
//
// Copyright (c) 2009 Kuba Suder
// Licensed under WTFPL license
// -------------------------------------------------------

#import <Cocoa/Cocoa.h>

@class SelectionWindowController;

@interface WindowFairyAppDelegate : NSObject <NSApplicationDelegate>

- (void) hotKeyActivated;

@property IBOutlet SelectionWindowController *windowController;

@end
