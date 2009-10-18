// -------------------------------------------------------
// WindowFairyAppDelegate.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// -------------------------------------------------------

#import "WindowFairyAppDelegate.h"
#import "WindowManager.h"

#import "Window.h"
#import "Application.h"

@implementation WindowFairyAppDelegate

@synthesize window;

- (void) applicationDidFinishLaunching: (NSNotification *) aNotification {
	// Insert code here to initialize your application
  WindowManager *manager = [[WindowManager alloc] init];
  [manager reloadWindowList];
  NSLog(@"windows:");
  for (Window *wnd in manager.windowList) {
    NSLog(@"window \"%@\" of application %@ (%@)", wnd.name, wnd.application.name, wnd.application.pid);
  }
}

@end
