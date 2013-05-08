//
//  BPOAppDelegate.m
//  BPODial
//
//  Created by Martin Höller on 06.05.13.
//  Copyright (c) 2013 BYTEPOETS GmbH. All rights reserved.
//

#import "BPOAppDelegate.h"
#import "BPODial.h"

@implementation BPOAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}


- (void)awakeFromNib
{
    self.dial.numberOfTickMarks = 7;
    self.dial.tickMarkRadius = 3.0f;
    self.dial.apertureInDegrees = 90.0f;
    self.dial.minLabel = @"0";
    self.dial.maxLabel = @"100";
}


- (IBAction)valueChanged:(NSSlider *)sender
{
    self.label.stringValue = [NSString stringWithFormat:@"Value: %ld", sender.integerValue];
}
@end
