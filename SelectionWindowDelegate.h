// -------------------------------------------------------
// SelectionWindowDelegate.h
//
// Copyright (c) 2022 Jakub Suder <jakub.suder@gmail.com>
// Licensed under WTFPL license
// -------------------------------------------------------

@protocol SelectionWindowDelegate

- (void) moveCursorDown;
- (void) moveCursorUp;
- (void) performSwitch;

@end
