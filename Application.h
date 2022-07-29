// -------------------------------------------------------
// Application.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under WTFPL license
// -------------------------------------------------------

#import <Foundation/Foundation.h>

@interface Application : NSObject {
  NSString *name;
  NSNumber *pid;
  NSImage *icon;
}

@property (copy) NSString *name;
@property (strong) NSNumber *pid;
@property (strong) NSImage *icon;

@end
