//
//  NSImage+NSImageResizeAdditions.h
//  Slideshow
//
//  Created by Adem Gaygusuz on 28/09/2014.
//  Copyright (c) 2014 Adem Gaygusuz. All rights reserved.
//

#import <AppKit/NSImage.h>

@interface NSImage (ResizeAdditions)
- (NSImage *)imageByScalingProportionallyToSize:(NSSize)targetSize;
@end
