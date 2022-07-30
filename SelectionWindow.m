// -------------------------------------------------------
// SelectionWindow.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under WTFPL license
// -------------------------------------------------------

#import "SelectionWindow.h"

@implementation SelectionWindow

@synthesize selectionDelegate;

- (id) initWithView: (NSView *) view {
  self = [super initWithContentRect: NSMakeRect(300, 250, 1000, 500) // TODO: dynamic size
                          styleMask: NSWindowStyleMaskBorderless
                            backing: NSBackingStoreBuffered
                              defer: YES];
  if (self) {
    [self setLevel: NSScreenSaverWindowLevel];
    [self setBackgroundColor: [NSColor colorWithDeviceRed: 0 green: 0 blue: 0 alpha: 0.7]];
    [self setOpaque: NO];
    [self setContentView: view];
    [self setReleasedWhenClosed: NO];
  }
  return self;
}

- (BOOL) canBecomeKeyWindow {
  return YES;
}

- (BOOL) canBecomeMainWindow {
  return YES;
}

- (void) keyDown: (NSEvent *) event {
  NSUInteger modifierFlags = [event modifierFlags];
  unsigned short keyCode = [event keyCode];

  // TODO: handle press-and-hold

  if (modifierFlags & NSEventModifierFlagOption) {
    switch (keyCode) {
      case 53: // esc
        [self close];
        return;
      case 36: // enter
        [selectionDelegate performSwitch];
        return;
      case 123: // left arrow
      case 126: // up arrow
        [selectionDelegate moveCursorUp];
        return;
      case 125: // down arrow
      case 124: // right arrow
        [selectionDelegate moveCursorDown];
        return;
      default:
        return;
    }
  } else {
    // alt was released - theoretically this shouldn't happen (we should get flagsChanged first)
    [selectionDelegate performSwitch];
  }
}

- (void) flagsChanged: (NSEvent *) event {
  NSUInteger modifierFlags = [event modifierFlags];
  if (!(modifierFlags & NSEventModifierFlagOption)) {
    // alt released
    [selectionDelegate performSwitch];
  }
}

@end
