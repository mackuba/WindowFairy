// -------------------------------------------------------
// SelectionWindow.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under WTFPL license
// -------------------------------------------------------

#import <Cocoa/Cocoa.h>
#import "SelectionWindowDelegate.h"

@interface SelectionWindow : NSWindow

- (id) initWithView: (NSView *) view;

@property (weak) id<SelectionWindowDelegate> selectionDelegate;

@end
