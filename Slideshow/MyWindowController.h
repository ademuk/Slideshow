//
//  MyWindowController.h
//  Slideshow
//
//  Created by Adem Gaygusuz on 25/09/2014.
//  Copyright (c) 2014 Adem Gaygusuz. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AVFoundation/AVFoundation.h>

#import "MyViewController.h"

@interface MyWindowController : NSWindowController
{
    MyViewController *viewController;
    IBOutlet NSView	*myTargetView;
}

- (IBAction)chooseSource:(id)sender;

@end
