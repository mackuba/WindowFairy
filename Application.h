// -------------------------------------------------------
// Application.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// -------------------------------------------------------

#import <Foundation/Foundation.h>

@interface Application : NSObject {
  NSString *name;
  NSNumber *pid;
  NSImage *icon;
}

@property (copy) NSString *name;
@property (retain) NSNumber *pid;
@property (retain) NSImage *icon;

@end
