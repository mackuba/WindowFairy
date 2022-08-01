// -------------------------------------------------------
// LoginItemController.m
//
// Copyright (c) 2022 Kuba Suder
// Licensed under WTFPL license
// -------------------------------------------------------

#import "LoginItemController.h"

@implementation LoginItemController

+ (instancetype)sharedController {
  static LoginItemController *instance = nil;

  static dispatch_once_t token;
  dispatch_once(&token, ^{
    instance = [[self alloc] init];
  });

  return instance;
}

// YOLO
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

- (BOOL) loginItemEnabled {
  LSSharedFileListRef list = [self createLoginItemList];
  LSSharedFileListItemRef item = [self findApplicationInLoginList:list];

  CFRelease(list);

  if (item) {
    CFRelease(item);
    return true;
  } else {
    return false;
  }
}

- (void) setLoginItemEnabled: (BOOL) enabled {
  LSSharedFileListRef list = [self createLoginItemList];

  if (enabled) {
    [self addApplicationToLoginList:list];
  } else {
    LSSharedFileListItemRef item = [self findApplicationInLoginList:list];
    if (item) {
      LSSharedFileListItemRemove(list, item);
      CFRelease(item);
    }
  }

  CFRelease(list);
}

- (void) addApplicationToLoginList: (LSSharedFileListRef) list {
  CFURLRef url = (__bridge CFURLRef) [self applicationURL];
  LSSharedFileListItemRef item =
    LSSharedFileListInsertItemURL(list, kLSSharedFileListItemLast, NULL, NULL, url, NULL, NULL);

  if (item) {
    CFRelease(item);
  } else {
    NSLog(@"Error: WindowFairy could not be added to login items.");
  }
}

- (LSSharedFileListItemRef) findApplicationInLoginList: (LSSharedFileListRef) list {
  NSURL *applicationURL = [self applicationURL];
  CFURLRef url;

  CFArrayRef array = LSSharedFileListCopySnapshot(list, NULL);
  NSInteger itemCount = CFArrayGetCount(array);

  for (NSInteger i = 0; i < itemCount; i++) {
    LSSharedFileListItemRef item = (LSSharedFileListItemRef) CFArrayGetValueAtIndex(array, i);
    if (LSSharedFileListItemResolve(item, 0, &url, NULL) == noErr) {
      NSURL *nsURL = (NSURL *) CFBridgingRelease(url);
      if ([nsURL isEqual:applicationURL]) {
        CFRetain(item);
        CFRelease(array);
        return item;
      }
    }
  }

  CFRelease(array);
  return nil;
}

#pragma clang diagnostic pop

- (LSSharedFileListRef) createLoginItemList {
  return LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
}

- (NSURL *) applicationURL {
  return [[NSBundle mainBundle] bundleURL];
}

@end
