// -------------------------------------------------------
// StatusBarController.m
//
// Copyright (c) 2022 Kuba Suder
// Licensed under WTFPL license
// -------------------------------------------------------

#import "StatusBarController.h"

@implementation StatusBarController {
  NSStatusItem *statusBarItem;
}

- (void) createStatusBarItem {
  statusBarItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];

  // TODO: add a custom icon
  statusBarItem.image = [NSImage imageNamed:NSImageNameFlowViewTemplate];
  statusBarItem.highlightMode = YES;
  statusBarItem.menu = [self createMenu];
}

- (NSMenu *) createMenu {
  NSMenu *menu = [[NSMenu alloc] initWithTitle:@"WindowFairy"];

  NSMenuItem *quit = [[NSMenuItem alloc] init];
  quit.title = @"Quit WindowFairy";
  quit.action = @selector(quit:);
  quit.target = self;
  [menu addItem:quit];

  return menu;
}

- (void) quit:(id)sender {
  [NSApp terminate:self];
}

@end
