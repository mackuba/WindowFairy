// -------------------------------------------------------
// Window.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under GPL v3 license
// -------------------------------------------------------

#import <Foundation/Foundation.h>

@class Application;

@interface Window : NSObject {
  NSString *name;
  Application *application;
  AXUIElementRef accessibilityElement;
}

@property (copy) NSString *name;
@property Application *application;
@property AXUIElementRef accessibilityElement;

@end
