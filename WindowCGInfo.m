// -------------------------------------------------------
// WindowCGInfo.m
//
// Copyright (c) 2022 Kuba Suder
// Licensed under WTFPL license
// -------------------------------------------------------

#import "WindowCGInfo.h"

@implementation WindowCGInfo

- (id) initWithName:(NSString *)name pid:(NSNumber *)pid {
  self = [super init];

  if (self) {
    self.name = name;
    self.pid = pid;
  }

  return self;
}

@end
