//
//  AppDelegate.m
//  Slideshow
//
//  Created by Adem Gaygusuz on 25/09/2014.
//  Copyright (c) 2014 Adem Gaygusuz. All rights reserved.
//

#import "AppDelegate.h"
#import "SlideshowViewController.h"

@interface AppDelegate ()
    @property (strong, nonatomic) SlideshowViewController *viewController;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    self.viewController = [[SlideshowViewController alloc] init];
    
    [self.window.contentView addSubview:self.viewController.view];
    [self.viewController.view setFrameSize:self.window.frame.size];
    
    NSRect screenSize = [[NSScreen mainScreen] frame];
    
    CGFloat percent = 0.6;
    CGFloat offset = (1.0 - percent) / 2.0;
    
    [self.window setFrame:NSMakeRect(screenSize.size.width * offset, screenSize.size.height * offset, screenSize.size.width * percent, screenSize.size.height * percent) display:YES];
    
    NSResponder *aNextResponder = [self.window nextResponder];
    
    [self.window setNextResponder:self.viewController];
    [self.viewController setNextResponder:aNextResponder];
}

@end
