// -------------------------------------------------------
// LoginItemController.h
//
// Copyright (c) 2022 Kuba Suder
// Licensed under WTFPL license
// -------------------------------------------------------

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LoginItemController : NSObject

+ (instancetype)sharedController;

@property BOOL loginItemEnabled;

@end

NS_ASSUME_NONNULL_END
