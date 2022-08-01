// -------------------------------------------------------
// StatusBarController.m
//
// Copyright (c) 2022 Kuba Suder
// Licensed under WTFPL license
// -------------------------------------------------------

#import "WindowFairyAppDelegate.h"
#import "LoginItemController.h"
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

  NSMenuItem *runAtLogin = [[NSMenuItem alloc] init];
  [runAtLogin setTitle:@"Launch at Login"];
  [runAtLogin bind:@"value"
          toObject:[LoginItemController sharedController]
       withKeyPath:@"loginItemEnabled"
           options:nil];

  [menu addItem:runAtLogin];

  NSMenuItem *showWindow = [[NSMenuItem alloc] init];
  showWindow.title = @"Show Window List";
  showWindow.action = @selector(showMainWindow);
  showWindow.target = [NSApp delegate];
  [menu addItem:showWindow];

  NSMenuItem *quit = [[NSMenuItem alloc] init];
  quit.title = @"Quit WindowFairy";
  quit.action = @selector(quit);
  quit.target = self;
  [menu addItem:quit];

  return menu;
}

- (void) quit {
  [NSApp terminate:self];
}

@end
