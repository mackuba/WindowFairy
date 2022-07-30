// -------------------------------------------------------
// WindowManager.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under WTFPL license
// -------------------------------------------------------

#import "Window.h"
#import "WindowCGInfo.h"
#import "WindowManager.h"

@implementation WindowManager

- (void) reloadWindowList {
  // collect the data we will need
  NSDictionary *pidToApplicationMap = [self getPIDToApplicationMap];
  NSArray *cgWindowList = [self getCGWindowList];

  NSMutableDictionary *windowIndexes = [[NSMutableDictionary alloc] init];
  NSMutableArray *windows = [[NSMutableArray alloc] init];

  // iterate over both window lists (single list from CGWindow and per-application lists from AX API)
  // create Window records using matching CGWindow hashes and AXUIElement records

  for (WindowCGInfo *windowInfo in cgWindowList) {
    // find the window's Application
    NSRunningApplication *application = [pidToApplicationMap objectForKey:windowInfo.pid];

    if (application) {
      // get a matching accessibility API entry
      NSNumber *index = [windowIndexes objectForKey:windowInfo.pid];
      NSInteger position = index ? [index intValue] : 0;

      // create a Window object
      Window *window = [[Window alloc] init];
      window.name = windowInfo.name;
      window.application = application;
      window.position = position;

      [windows addObject: window];
      [windowIndexes setObject: [NSNumber numberWithInteger:(position + 1)] forKey:windowInfo.pid];
    }
  }

  windowList = windows;
}

- (NSDictionary *) getPIDToApplicationMap {
  NSMutableDictionary *pidMap = [[NSMutableDictionary alloc] init];

  for (NSRunningApplication *application in [[NSWorkspace sharedWorkspace] runningApplications]) {
    [pidMap setObject:application forKey:@(application.processIdentifier)];
  }

  return pidMap;
};

- (NSArray *) getCGWindowList {
  [self requestScreenAccess];

  // get a list of dictionaries for each window on screen from CGWindow API
  CGWindowListOption queryOptions = kCGWindowListOptionOnScreenOnly | kCGWindowListExcludeDesktopElements;
  CFArrayRef windowIdArray = CGWindowListCreate(queryOptions, kCGNullWindowID);
  CFArrayRef windowInfoArray = CGWindowListCreateDescriptionFromArray(windowIdArray);
  NSArray *windowInfos = (NSArray *) CFBridgingRelease(windowInfoArray);
  CFRelease(windowIdArray);

  // filter out items like menu bar icons, menu bar itself, dock etc.

  NSMutableArray *windows = [[NSMutableArray alloc] init];
  BOOL namesFound = NO;

  for (NSDictionary *info in windowInfos) {
    NSString *windowName = [info objectForKey:(NSString *)kCGWindowName];
    NSNumber *windowLayer = [info objectForKey:(NSString *)kCGWindowLayer];

    if (windowName && ![windowName isEqual:@"Menubar"]) {
      namesFound = YES;
    }

    if ([windowLayer integerValue] == NSNormalWindowLevel) {
      NSNumber *applicationPid = [info objectForKey:(NSString *)kCGWindowOwnerPID];
      WindowCGInfo *windowInfo = [[WindowCGInfo alloc] initWithName:windowName pid:applicationPid];

      [windows addObject: windowInfo];
    }
  }

  if (!namesFound) {
    NSRunAlertPanel(@"Error",
                    @"Screen recording access needs to be enabled for this app in System Preferences.",
                    @"OK",
                    nil,
                    nil);
  }

  return windows;
}

- (void) requestScreenAccess {
  if (@available(macOS 10.15, *)) {
    // hack to request access to screen recording
    // https://stackoverflow.com/a/60773696

    CGImageRef screenshot = CGWindowListCreateImage(
      CGRectMake(0, 0, 1, 1),
      kCGWindowListOptionOnScreenOnly,
      kCGNullWindowID,
      kCGWindowImageDefault
    );
    CFRelease(screenshot);
  }
}

- (NSArray *) getAccessibilityWindowDataForPID: (pid_t) pid {
  AXError result;
  CFTypeRef value;

  AXUIElementRef applicationElement = AXUIElementCreateApplication(pid);
  result = AXUIElementCopyAttributeValue(applicationElement, kAXWindowsAttribute, &value);
  CFRelease(applicationElement);

  if (result == kAXErrorSuccess) {
    CFArrayRef applicationWindows = (CFArrayRef) value;
    NSInteger windowCount = CFArrayGetCount(applicationWindows);

    // filter out fake window records and minimized windows (minimized attribute is null or true)
    CFMutableArrayRef visibleWindows = CFArrayCreateMutable(NULL, windowCount, &kCFTypeArrayCallBacks);
    for (NSInteger i = 0; i < windowCount; i++) {
      AXUIElementRef windowElement = CFArrayGetValueAtIndex(applicationWindows, i);

      result = AXUIElementCopyAttributeValue(windowElement, kAXMinimizedAttribute, &value);
      if (result == kAXErrorSuccess && value) {
        if (CFBooleanGetValue(value) == NO) {
          CFArrayAppendValue(visibleWindows, windowElement);
        }

        CFRelease(value);
      } else {
        NSLog(@"Error loading application info (minimized): %d", result);
      }
    }

    CFRelease(applicationWindows);
    return CFBridgingRelease(visibleWindows);
  } else if (result == kAXErrorAPIDisabled) {
    NSRunAlertPanel(@"Error",
                    @"Accessibility access needs to be enabled for this app in System Preferences.",
                    @"OK",
                    nil,
                    nil);
    return nil;
  } else {
    NSLog(@"Error loading application windows: %d", result);
    return nil;
  }
}

- (void) switchToWindowAtIndex: (NSInteger) index {
  Window *window = [windowList objectAtIndex: index];

  pid_t pid = window.application.processIdentifier;
  NSArray *windowsInfo = [self getAccessibilityWindowDataForPID:pid];

  if (windowsInfo) {
    AXUIElementRef windowElement = (__bridge AXUIElementRef) [windowsInfo objectAtIndex:window.position];
    AXUIElementPerformAction(windowElement, kAXRaiseAction);
  } else {
    NSLog(@"Can't switch to window %@, no AX info available", window.name);
  }

  ProcessSerialNumber process;
  GetProcessForPID(pid, &process);
  SetFrontProcessWithOptions(&process, kSetFrontProcessFrontWindowOnly);
}

- (Window *) windowAtIndex: (NSInteger) index {
  return [windowList objectAtIndex: index];
}

- (NSInteger) windowCount {
  return windowList.count;
}

@end
