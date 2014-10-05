//
//  SlideshowViewController.h
//  Slideshow
//
//  Created by Adem Gaygusuz on 04/10/2014.
//  Copyright (c) 2014 Adem Gaygusuz. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AVFoundation/AVFoundation.h>
#import <Quartz/Quartz.h>

#import "CNGridView.h"
#import "NSImage+NSImageResizeAdditions.h"

@interface SlideshowViewController : NSViewController <CNGridViewDataSource, CNGridViewDelegate>

@end
