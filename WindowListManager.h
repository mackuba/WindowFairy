// -------------------------------------------------------
// WindowManager.h
//
// Copyright (c) 2009 Kuba Suder
// Licensed under WTFPL license
// -------------------------------------------------------

#import <Foundation/Foundation.h>

extern NSErrorDomain const WindowListErrorDomain;
extern NSInteger const AccessibilityAccessError;
extern NSInteger const ScreenRecordingAccessError;

@interface WindowListManager : NSObject

- (void) reloadList;
- (void) switchToWindowAtIndex: (NSInteger) index;
- (Window *) windowAtIndex: (NSInteger) index;

@property (readonly) NSInteger windowCount;
@property (copy) NSError *error;

@end
