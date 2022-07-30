// -------------------------------------------------------
// Window.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under WTFPL license
// -------------------------------------------------------

#import <Foundation/Foundation.h>

@interface Window : NSObject

@property (copy) NSString *name;
@property NSRunningApplication *application;
@property AXUIElementRef accessibilityElement;

@end
