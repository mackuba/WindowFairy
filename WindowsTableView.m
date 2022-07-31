// -------------------------------------------------------
// WindowsTableView.m
//
// Copyright (c) 2022 Kuba Suder
// Licensed under WTFPL license
// -------------------------------------------------------

#import "WindowsTableView.h"

@implementation WindowsTableView

- (void)drawRow:(NSInteger)rowIndex clipRect:(NSRect)clipRect {
  NSInteger selectedRowIndex = [self selectedRow];
  if (rowIndex == selectedRowIndex) {
    [[NSColor colorWithWhite:0.7 alpha:1.0] setFill];

    NSRect rect = [self rectOfRow:rowIndex];
    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:rect xRadius:5.0 yRadius:5.0];
    [path fill];
  }

  [super drawRow:rowIndex clipRect:clipRect];
}

@end
