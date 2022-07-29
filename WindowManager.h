// -------------------------------------------------------
// WindowManager.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under WTFPL license
// -------------------------------------------------------

#import <Foundation/Foundation.h>

@interface WindowManager : NSObject {
  NSArray *windowList;
}

- (void) reloadWindowList;
- (void) switchToWindowAtIndex: (NSInteger) index;
- (Window *) windowAtIndex: (NSInteger) index;

@property (readonly) NSInteger windowCount;

@end
