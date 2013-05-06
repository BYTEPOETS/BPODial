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


- (IBAction)valueChanged:(NSSlider *)sender
{
    self.label.integerValue = sender.integerValue;
}
@end
