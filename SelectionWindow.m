// -------------------------------------------------------
// SelectionWindow.m
//
// Copyright (c) 2009 Kuba Suder
// Licensed under WTFPL license
// -------------------------------------------------------

#import "SelectionWindow.h"

@implementation SelectionWindow

@synthesize selectionDelegate;

- (id) initWithView: (NSView *) view {
  self = [super initWithContentRect: NSMakeRect(300, 250, 1000, 500)
                          styleMask: NSWindowStyleMaskBorderless
                            backing: NSBackingStoreBuffered
                              defer: YES];
  if (self) {
    [self setLevel: NSScreenSaverWindowLevel];
    [self setBackgroundColor: [NSColor clearColor]];
    [self setOpaque: NO];
    [self setContentView: view];

    self.transient = YES;

    view.wantsLayer = YES;
    view.layer.backgroundColor = [[NSColor colorWithDeviceRed: 0 green: 0 blue: 0 alpha: 0.7] CGColor];
    view.layer.cornerRadius = 15.0;
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

  if (modifierFlags & NSEventModifierFlagOption || !self.transient) {
    switch (keyCode) {
      case 48: // tab
        if (modifierFlags & NSEventModifierFlagShift) {
          [selectionDelegate moveCursorUp];
        } else {
          [selectionDelegate moveCursorDown];
        }
        return;
      case 53: // esc
        [selectionDelegate closeWithoutSwitching];
        return;
      case 36: // enter
        [selectionDelegate performSwitch];
        return;
      case 123: // left arrow
      case 126: // up arrow
        if (modifierFlags & NSEventModifierFlagControl) {
          [selectionDelegate moveCursorToBeginning];
        } else {
          [selectionDelegate moveCursorUp];
        }
        return;
      case 125: // down arrow
      case 124: // right arrow
        if (modifierFlags & NSEventModifierFlagControl) {
          [selectionDelegate moveCursorToEnd];
        } else {
          [selectionDelegate moveCursorDown];
        }
        return;
      default:
        return;
    }
  }
}

- (void) flagsChanged: (NSEvent *) event {
  if (self.transient) {
    NSUInteger modifierFlags = [event modifierFlags];
    if (!(modifierFlags & NSEventModifierFlagOption)) {
      // alt released
      [selectionDelegate performSwitch];
    }
  }
}

@end
