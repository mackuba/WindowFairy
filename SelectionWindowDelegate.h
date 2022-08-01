// -------------------------------------------------------
// SelectionWindowDelegate.h
//
// Copyright (c) 2022 Kuba Suder
// Licensed under WTFPL license
// -------------------------------------------------------

@protocol SelectionWindowDelegate

- (void) moveCursorUp;
- (void) moveCursorDown;
- (void) moveCursorToBeginning;
- (void) moveCursorToEnd;
- (void) performSwitch;
- (void) closeWithoutSwitching;

@end
