// -------------------------------------------------------
// WindowManager.h
//
// Copyright (c) 2009 Kuba Suder
// Licensed under WTFPL license
// -------------------------------------------------------

#import <Foundation/Foundation.h>

@interface WindowListManager : NSObject

- (void) reloadList;
- (void) switchToWindowAtIndex: (NSInteger) index;
- (Window *) windowAtIndex: (NSInteger) index;

@property (readonly) NSInteger windowCount;

@end
