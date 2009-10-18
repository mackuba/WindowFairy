// -------------------------------------------------------
// WindowFairyAppDelegate.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// -------------------------------------------------------

#import "WindowFairyAppDelegate.h"

@implementation WindowFairyAppDelegate

@synthesize window;

- (void) applicationDidFinishLaunching: (NSNotification *) aNotification {

  NSInteger windowCount;
  NSCountWindows(&windowCount);
  NSLog(@"AppKit NSCountWindows() => %d", windowCount);

  NSInteger *windowList = malloc(windowCount * sizeof(NSInteger));
  NSWindowList(windowCount, windowList);
  NSMutableArray *nsa = [NSMutableArray arrayWithCapacity: windowCount];
  for (NSInteger i = 0; i < windowCount; i++) {
    [nsa addObject: [NSNumber numberWithInt: windowList[i]]];
  }
  NSLog(@"AppKit NSWindowList() =>\n%@", [nsa componentsJoinedByString: @", "]);

  CFArrayRef windowList2 = CGWindowListCreate(kCGWindowListOptionOnScreenOnly | kCGWindowListExcludeDesktopElements, kCGNullWindowID); // All, OnScreenOnly, ExcludeDesktopElements
  NSMutableArray *nsa2 = [NSMutableArray arrayWithCapacity: CFArrayGetCount(windowList2)];
  for (NSInteger i = 0; i < CFArrayGetCount(windowList2); i++) {
    [nsa2 addObject: [NSNumber numberWithInt: (NSInteger) CFArrayGetValueAtIndex(windowList2, i)]];
  }

  NSLog(@"CGWindow CGWindowListCreate() => %d entries:\n%@", CFArrayGetCount(windowList2), [nsa2 componentsJoinedByString: @", "]);

  CFArrayRef hashList = CGWindowListCreateDescriptionFromArray(windowList2);
  //NSLog(@"CGWindowListCreateDescriptionFromArray() => %@", hashList);

  NSMutableArray *hashList2 = [NSMutableArray array];
  for (NSInteger i = 0; i < CFArrayGetCount(hashList); i++) {
    CFDictionaryRef dict = CFArrayGetValueAtIndex(hashList, i);
    if (CFDictionaryGetValue(dict, kCGWindowWorkspace) && CFDictionaryGetValue(dict, kCGWindowName)) {
      [hashList2 addObject: (NSDictionary *) dict];
    }
  }

  NSLog(@"CGWindowListCreateDescriptionFromArray() filtered => %d entries:\n%@", [hashList2 count], hashList2);

  NSMutableArray *pids = [NSMutableArray array];
  for (NSInteger i = 0; i < CFArrayGetCount(hashList); i++) {
    CFDictionaryRef d = CFArrayGetValueAtIndex(hashList, i);
    //NSLog(@"dict = %@", d);
    CFNumberRef pidcfn = CFDictionaryGetValue(d, kCGWindowOwnerPID);
    NSInteger pidint;
    CFNumberGetValue(pidcfn, kCFNumberIntType, &pidint);
    
    NSNumber *pidn = [NSNumber numberWithInt: pidint];
    //NSLog(@"num = %@", pidn);
    if (CFDictionaryGetValue(d, kCGWindowWorkspace) && CFDictionaryGetValue(d, kCGWindowName) && ![pids containsObject: pidn]) {
      [pids addObject: pidn];
    }
  }
  
  NSLog(@"pids = %@", [pids componentsJoinedByString: @", "]);

  //for (NSNumber *pid in pids) {
  for (NSDictionary *dict in [[NSWorkspace sharedWorkspace] launchedApplications]) {
    NSNumber *pid = [dict objectForKey: @"NSApplicationProcessIdentifier"];
    AXUIElementRef app = AXUIElementCreateApplication([pid intValue]);
    CFTypeRef value, value2;
    AXError result = AXUIElementCopyAttributeValue(app, kAXWindowsAttribute, &value);
    AXError result2 = AXUIElementCopyAttributeValue(app, kAXTitleAttribute, &value2);
    NSArray *appWindowList = (NSArray *) value;
    NSString *appName = (NSString *) value2;
    // TODO: have to filter out minimized windows! or not
    //NSLog(@"windows for %@(%@): %@", appName, pid, appWindowList);
    NSLog(@"windows for %@(%@):", appName, pid);
    // show iconForFile: for NSApplicationPath key from this hash

    CFArrayRef attributes, attributes2;

    //result = AXUIElementCopyAttributeNames(app, &attributes);
    //NSLog(@"app attr names = %@", (NSArray *) attributes);

    //result = AXUIElementCopyMultipleAttributeValues(app, attributes, 0, &attributes2);
    //NSLog(@"app attr values = %@", (NSArray *) attributes2);

    for (id w in appWindowList) {
      AXUIElementRef wnd = (AXUIElementRef) w;

      //result = AXUIElementCopyAttributeNames(w, &attributes);
      //NSLog(@"window attr names = %@", (NSArray *) attributes);

      //result = AXUIElementCopyMultipleAttributeValues(w, attributes, 0, &attributes2);
      //NSLog(@"window attr values = %@", (NSArray *) attributes2);

      CFTypeRef v;
      AXError result3 = AXUIElementCopyAttributeValue(wnd, kAXMinimizedAttribute, &v);
      if (v && CFBooleanGetValue(v) == NO) {
        //NSLog(@"window %@, minimized = %@", wnd, v);
        NSLog(@"window %@", wnd);
      }
    }
  }

  NSLog(@"launched applications = %@", [[NSWorkspace sharedWorkspace] launchedApplications]);

  /*
	// Insert code here to initialize your application 
  AXUIElementRef systemWide = AXUIElementCreateSystemWide();
  CFArrayRef attributes, attributes2;

  AXError result = AXUIElementCopyAttributeNames(systemWide, &attributes);
  NSLog(@"result = %d", result);
  NSLog(@"glob attr names = %@", (NSArray *) attributes);

  result = AXUIElementCopyActionNames(systemWide, &attributes);
  NSLog(@"result = %d", result);
  NSLog(@"glob action names = %@", (NSArray *) attributes);
  
  //NSInteger myPid = [[NSProcessInfo processInfo] processIdentifier];
  NSInteger myPid = 451;
  
  AXUIElementRef app = AXUIElementCreateApplication(myPid);

  result = AXUIElementCopyAttributeNames(app, &attributes);
  NSLog(@"result = %d", result);
  NSLog(@"app attr names = %@", (NSArray *) attributes);

  result = AXUIElementCopyActionNames(app, &attributes);
  NSLog(@"result = %d", result);
  NSLog(@"app action names = %@", (NSArray *) attributes);

  CFTypeRef value;
  result = AXUIElementCopyAttributeValue(app, kAXWindowsAttribute, &value);
  NSLog(@"result = %d", result);
  NSLog(@"value type id = %ld", CFGetTypeID(value));
  NSLog(@"axui type id = %d", AXUIElementGetTypeID());
  NSLog(@"cfarray type id = %d", CFArrayGetTypeID());

  NSArray *windowList = (NSArray *) value;
  NSLog(@"array length = %d", [windowList count]);
  AXUIElementRef window1 = (AXUIElementRef) [windowList objectAtIndex: 0];

  result = AXUIElementCopyAttributeNames(window1, &attributes);
  NSLog(@"result = %d", result);
  NSLog(@"window attr names = %@", (NSArray *) attributes);

  result = AXUIElementCopyMultipleAttributeValues(window1, attributes, 0, &attributes2);
  NSLog(@"result = %d", result);
  NSLog(@"window attr values = %@", (NSArray *) attributes2);

  result = AXUIElementCopyActionNames(window1, &attributes);
  NSLog(@"result = %d", result);
  NSLog(@"window action names = %@", (NSArray *) attributes);
  */
}

@end
