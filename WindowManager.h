// -------------------------------------------------------
// WindowManager.h
//
// Copyright (c) 2009 Kuba Suder
// Licensed under WTFPL license
// -------------------------------------------------------

#import <Foundation/Foundation.h>

@interface WindowManager : NSObject

- (void) reloadWindowList;
- (void) switchToWindowAtIndex: (NSInteger) index;
- (Window *) windowAtIndex: (NSInteger) index;

@property (readonly) NSInteger windowCount;

@end
