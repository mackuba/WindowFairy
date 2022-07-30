// -------------------------------------------------------
// Window.h
//
// Copyright (c) 2009 Kuba Suder
// Licensed under WTFPL license
// -------------------------------------------------------

#import <Foundation/Foundation.h>

@interface Window : NSObject

@property (copy) NSString *name;
@property NSRunningApplication *application;
@property NSInteger position;

@end
