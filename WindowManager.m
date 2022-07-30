// -------------------------------------------------------
// WindowManager.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under WTFPL license
// -------------------------------------------------------

#import "Window.h"
#import "WindowCGInfo.h"
#import "WindowManager.h"

@interface WindowManager ()
- (NSArray *) getCGWindowList;
- (NSDictionary *) getAccessibilityWindowDataForPIDs: (NSArray *) pids;
- (NSDictionary *) getPIDToApplicationMap;
@end


@implementation WindowManager

- (void) reloadWindowList {
  // collect the data we will need
  NSDictionary *pidToApplicationMap = [self getPIDToApplicationMap];
  NSArray *pids = [pidToApplicationMap allKeys];
  NSArray *cgWindowList = [self getCGWindowList];
  NSDictionary *accessibilityWindowsForApps = [self getAccessibilityWindowDataForPIDs:pids];

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
      CFArrayRef applicationWindows = (__bridge CFArrayRef) [accessibilityWindowsForApps objectForKey:windowInfo.pid];

      // create a Window object
      Window *window = [[Window alloc] init];
      window.name = windowInfo.name;
      window.application = application;

      if (applicationWindows) {
        window.accessibilityElement = (AXUIElementRef) CFArrayGetValueAtIndex(applicationWindows, position);
      }

      [windows addObject: window];
      [windowIndexes setObject: [NSNumber numberWithInt: (position + 1)] forKey:windowInfo.pid];
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
  // get a list of dictionaries for each window on screen from CGWindow API
  CGWindowListOption queryOptions = kCGWindowListOptionOnScreenOnly | kCGWindowListExcludeDesktopElements;
  CFArrayRef windowIdArray = CGWindowListCreate(queryOptions, kCGNullWindowID);
  CFArrayRef windowInfoArray = CGWindowListCreateDescriptionFromArray(windowIdArray);
  NSInteger windowCount = CFArrayGetCount(windowIdArray);

  // convert dictionaries and array to Cocoa equivalents
  NSMutableArray *windows = [NSMutableArray arrayWithCapacity: windowCount];
  for (NSInteger i = 0; i < windowCount; i++) {
    CFDictionaryRef info = CFArrayGetValueAtIndex(windowInfoArray, i);

    NSString *windowName = (NSString *) CFDictionaryGetValue(info, kCGWindowName);

    if (windowName && windowName.length > 0 && ![windowName isEqualToString:@"Dock"]) {
      NSNumber *applicationPid = (NSNumber *) CFDictionaryGetValue(info, kCGWindowOwnerPID);
      WindowCGInfo *windowInfo = [[WindowCGInfo alloc] initWithName:windowName pid:applicationPid];

      [windows addObject: windowInfo];
    }
  }

  return windows;
}

- (NSDictionary *) getAccessibilityWindowDataForPIDs: (NSArray *) pids {
  // create a dictionary mapping each Application to a list of AXUIElement records of all its windows
  NSMutableDictionary *windowLists = [[NSMutableDictionary alloc] init];

  AXUIElementRef applicationElement;
  AXError result;
  CFTypeRef value;

  for (NSNumber *pid in pids) {
    applicationElement = AXUIElementCreateApplication([pid intValue]);
    result = AXUIElementCopyAttributeValue(applicationElement, kAXHiddenAttribute, &value);
    
    // filter out applications which are hidden
    if (result == kAXErrorSuccess && CFBooleanGetValue(value) == NO) {
      result = AXUIElementCopyAttributeValue(applicationElement, kAXWindowsAttribute, &value);
      if (result == kAXErrorSuccess) {
        CFArrayRef applicationWindows = (CFArrayRef) value;
        NSInteger windowCount = CFArrayGetCount(applicationWindows);

        // filter out fake window records and minimized windows (minimized attribute is null or true)
        CFMutableArrayRef visibleWindows = CFArrayCreateMutable(NULL, windowCount, NULL);
        for (NSInteger i = 0; i < windowCount; i++) {
          AXUIElementRef windowElement = CFArrayGetValueAtIndex(applicationWindows, i);

          result = AXUIElementCopyAttributeValue(windowElement, kAXMinimizedAttribute, &value);
          if (result == kAXErrorSuccess && value && CFBooleanGetValue(value) == NO) {
            CFArrayAppendValue(visibleWindows, windowElement);
          } else {
            NSLog(@"Error loading application info (minimized): %d", result);
          }
        }

        [windowLists setObject:((NSArray *) CFBridgingRelease(visibleWindows)) forKey:pid];
      } else {
        NSLog(@"Error loading application info (hidden): %d", result);
      }
    } else if (result == kAXErrorAPIDisabled) {
      NSRunAlertPanel(@"Error",
                      @"Accessibility access needs to be enabled for this app in System Preferences.",
                      @"OK",
                      nil,
                      nil);
      return nil;
    } else {
      NSLog(@"Error loading application info (windows): %d", result);
    }
  }

  return windowLists;
}

- (void) switchToWindowAtIndex: (NSInteger) index {
  Window *window = [windowList objectAtIndex: index];

  if (window.accessibilityElement) {
    AXUIElementPerformAction(window.accessibilityElement, kAXRaiseAction);
  } else {
    NSLog(@"Can't switch to window %@, no AX element set", window.name);
  }

  ProcessSerialNumber process;
  GetProcessForPID(window.application.processIdentifier, &process);
  SetFrontProcessWithOptions(&process, kSetFrontProcessFrontWindowOnly);
}

- (Window *) windowAtIndex: (NSInteger) index {
  return [windowList objectAtIndex: index];
}

- (NSInteger) windowCount {
  return windowList.count;
}

@end
