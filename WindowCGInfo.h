// -------------------------------------------------------
// WindowCGInfo.h
//
// Copyright (c) 2022 Jakub Suder <jakub.suder@gmail.com>
// Licensed under WTFPL license
// -------------------------------------------------------

#import <Foundation/Foundation.h>

@interface WindowCGInfo : NSObject

@property (copy) NSString *name;
@property (strong) NSNumber *pid;

- (id) initWithName:(NSString *)name pid:(NSNumber *)pid;

@end
