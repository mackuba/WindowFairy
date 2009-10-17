// -------------------------------------------------------
// WindowFairyAppDelegate.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// -------------------------------------------------------

#import <Cocoa/Cocoa.h>

@interface WindowFairyAppDelegate : NSObject <NSApplicationDelegate> {
  NSWindow *window;
}

@property (assign) IBOutlet NSWindow *window;

@end
