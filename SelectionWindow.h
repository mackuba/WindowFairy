// -------------------------------------------------------
// SelectionWindow.h
//
// Copyright (c) 2009 Kuba Suder
// Licensed under WTFPL license
// -------------------------------------------------------

#import <Cocoa/Cocoa.h>
#import "SelectionWindowDelegate.h"

@interface SelectionWindow : NSWindow

- (id) initWithView: (NSView *) view;

@property (weak) id<SelectionWindowDelegate> selectionDelegate;
@property (getter=isTransient) BOOL transient;

@end
