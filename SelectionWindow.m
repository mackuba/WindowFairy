// -------------------------------------------------------
// SelectionWindow.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under GPL v3 license
// -------------------------------------------------------

#import "SelectionWindow.h"

@implementation SelectionWindow

- (id) initWithView: (NSView *) view {
  self = [super initWithContentRect: NSMakeRect(300, 300, 1000, 400)
                          styleMask: NSBorderlessWindowMask
                            backing: NSBackingStoreBuffered
                              defer: YES];
  if (self) {
    [self setLevel: NSScreenSaverWindowLevel];
    [self setBackgroundColor: [NSColor colorWithDeviceRed: 0 green: 0 blue: 0 alpha: 0.7]];
    [self setOpaque: NO];
    [self setContentView: view];
  }
  return self;
}

- (BOOL) canBecomeKeyWindow {
  return YES;
}

- (BOOL) canBecomeMainWindow {
  return YES;
}

@end
