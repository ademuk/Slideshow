//
//  SlideshowItem.m
//  Slideshow
//
//  Created by Adem Gaygusuz on 05/10/2014.
//  Copyright (c) 2014 Adem Gaygusuz. All rights reserved.
//

#import "SlideshowItem.h"

@implementation SlideshowItem

- (id)initWithTitle:(NSString*)title image:(NSImage*)image url:(NSURL*)url
{
    self = [super init];
    if (self) {
        _title = title;
        _image = image;
        _imageURL = url;
    }
    
    return self;
}

@end
