// -------------------------------------------------------
// SelectionWindowDelegate.h
//
// Copyright (c) 2022 Kuba Suder
// Licensed under WTFPL license
// -------------------------------------------------------

@protocol SelectionWindowDelegate

- (void) moveCursorDown;
- (void) moveCursorUp;
- (void) performSwitch;
- (void) closeWithoutSwitching;

@end
