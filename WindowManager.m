// -------------------------------------------------------
// WindowManager.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// -------------------------------------------------------

#import "Application.h"
#import "Window.h"
#import "WindowManager.h"

@interface WindowManager ()
- (NSArray *) getApplicationListAndStoreMapping: (NSDictionary **) mapping;
- (NSArray *) getCGWindowList;
- (NSDictionary *) getAccessibilityWindowDataForApplications: (NSArray *) applications;
@end


@implementation WindowManager

@synthesize windowList;

- (void) reloadWindowList {
  // collect the data we will need
  NSDictionary *pidToApplicationMapping;
  NSArray *applicationList = [self getApplicationListAndStoreMapping: &pidToApplicationMapping];
  NSLog(@"applicationList = ", applicationList);
  for (Application *app in applicationList) { NSLog(@"app %@ (%@)", app.name, app.pid); }
  NSLog(@"mapping = %@", pidToApplicationMapping);
  NSArray *cgWindowList = [self getCGWindowList];
  NSLog(@"cgWindowList = %@", cgWindowList);
  NSDictionary *accessibilityWindowsForApps = [self getAccessibilityWindowDataForApplications: applicationList];
  NSLog(@"accessibilityWindowsForApps = %@", accessibilityWindowsForApps);
  NSMutableDictionary *windowIndexes = [[NSMutableDictionary alloc] init];
  NSMutableArray *windows = [[NSMutableArray alloc] init];

  // iterate over both window lists (single list from CGWindow and per-application lists from AX API)
  // create Window records using matching CGWindow hashes and AXUIElement records

  for (NSDictionary *cgWindowHash in cgWindowList) {
    // find the window's Application
    NSNumber *applicationPid = [cgWindowHash objectForKey: @"pid"];
    Application *application = [pidToApplicationMapping objectForKey: applicationPid];
    if (application) {
      // get a matching accessibility API entry
      NSNumber *index = [windowIndexes objectForKey: applicationPid];
      NSInteger position = (index) ? [index intValue] : 0;
      CFArrayRef applicationWindows = (CFArrayRef) [accessibilityWindowsForApps objectForKey: applicationPid];
      AXUIElementRef windowElement = (AXUIElementRef) CFArrayGetValueAtIndex(applicationWindows, position);

      // create a Window object
      Window *window = [[Window alloc] init];
      window.name = [cgWindowHash objectForKey: @"name"];
      window.application = application;
      window.accessibilityElement = windowElement;
      
      [windows addObject: window];
      [windowIndexes setObject: [NSNumber numberWithInt: (position + 1)] forKey: applicationPid];
    }
  }

  self.windowList = windows;
}

- (NSArray *) getApplicationListAndStoreMapping: (NSDictionary **) mapping {
  // get a list of dictionaries for each launched application
  NSArray *applicationHash = [[NSWorkspace sharedWorkspace] launchedApplications];

  // create an array of Application records based on the dictionaries
  NSMutableArray *applications = [[NSMutableArray alloc] init];
  NSMutableDictionary *pidMapping = [[NSMutableDictionary alloc] init];
  for (NSDictionary *info in applicationHash) {
    Application *application = [[Application alloc] init];
    application.pid = [info objectForKey: @"NSApplicationProcessIdentifier"];
    application.name = [info objectForKey: @"NSApplicationName"];
    [applications addObject: application];
    [pidMapping setObject: application forKey: application.pid];
  }

  if (mapping) {
    *mapping = pidMapping;
  }

  return applications;
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

    // filter out fake entries (system tray icons, menu, dock, window drawers, etc.)
    if (CFDictionaryGetValue(info, kCGWindowWorkspace) && CFDictionaryGetValue(info, kCGWindowName)) {
      NSString *windowName = (NSString *) CFDictionaryGetValue(info, kCGWindowName);
      NSNumber *applicationPid = (NSNumber *) CFDictionaryGetValue(info, kCGWindowOwnerPID);
      NSDictionary *windowInfo = [NSDictionary dictionaryWithObjectsAndKeys: windowName, @"name",
                                                                             applicationPid, @"pid",
                                                                             nil];
      [windows addObject: windowInfo];
    }
  }

  return windows;
}

- (NSDictionary *) getAccessibilityWindowDataForApplications: (NSArray *) applications {
  // create a dictionary mapping each Application to a list of AXUIElement records of all its windows
  NSMutableDictionary *windowLists = [[NSMutableDictionary alloc] init];
  for (Application *application in applications) {
    AXUIElementRef applicationElement = AXUIElementCreateApplication([application.pid intValue]);
    CFTypeRef value;
    AXError result = AXUIElementCopyAttributeValue(applicationElement, kAXWindowsAttribute, &value);
    if (result == kAXErrorSuccess) {
      
      CFArrayRef attributes, values;
      result = AXUIElementCopyAttributeNames(applicationElement, &attributes);
      NSLog(@"app attr names = %@", [(NSArray *) attributes componentsJoinedByString: @", "]);
      result = AXUIElementCopyMultipleAttributeValues(applicationElement, attributes, 0, &values);
      NSLog(@"app attr values = %@", [(NSArray *) values componentsJoinedByString: @", "]);
      
      CFArrayRef applicationWindows = (CFArrayRef) value;
      NSInteger windowCount = CFArrayGetCount(applicationWindows);

      // filter out fake window records and minimized windows (minimized attribute is null or true)
      CFMutableArrayRef visibleWindows = CFArrayCreateMutable(NULL, windowCount, NULL);
      for (NSInteger i = 0; i < windowCount; i++) {
        AXUIElementRef windowElement = CFArrayGetValueAtIndex(applicationWindows, i);

        result = AXUIElementCopyAttributeNames(windowElement, &attributes);
        NSLog(@"window attr names = %@", [(NSArray *) attributes componentsJoinedByString: @", "]);
        result = AXUIElementCopyMultipleAttributeValues(windowElement, attributes, 0, &values);
        NSLog(@"window attr values = %@", [(NSArray *) values componentsJoinedByString: @", "]);


        result = AXUIElementCopyAttributeValue(windowElement, kAXMinimizedAttribute, &value);
        if (value && CFBooleanGetValue(value) == NO) {
          CFArrayAppendValue(visibleWindows, windowElement);
        }
      }

      [windowLists setObject: (NSArray *) visibleWindows forKey: application.pid];
    }
  }

  return windowLists;
}

@end
