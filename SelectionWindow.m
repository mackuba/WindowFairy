// -------------------------------------------------------
// SelectionWindow.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under WTFPL license
// -------------------------------------------------------

#import "SelectionWindow.h"
#import "WindowFairyAppDelegate.h"

@implementation SelectionWindow

- (id) initWithView: (NSView *) view {
  self = [super initWithContentRect: NSMakeRect(300, 250, 1000, 500) // TODO: dynamic size
                          styleMask: NSBorderlessWindowMask
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
  id delegate = [NSApp delegate];

  // TODO: handle press-and-hold

  if (modifierFlags & NSAlternateKeyMask) {
    switch (keyCode) {
      case 53: // esc
        [delegate closeWithoutSwitching];
        return;
      case 36: // enter
        [delegate performSwitch];
        return;
      case 123: // left arrow
      case 126: // up arrow
        [delegate moveCursorUp];
        return;
      case 125: // down arrow
      case 124: // right arrow
        [delegate moveCursorDown];
        return;
      default:
        return;
    }
  } else {
    // alt was released - theoretically this shouldn't happen (we should get flagsChanged first)
    [delegate performSwitch];
  }
}

- (void) flagsChanged: (NSEvent *) event {
  NSUInteger modifierFlags = [event modifierFlags];
  if (!(modifierFlags & NSAlternateKeyMask)) {
    // alt released
    [(WindowFairyAppDelegate *) [NSApp delegate] performSwitch];
  }
}

@end
