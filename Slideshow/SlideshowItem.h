//
//  SlideshowItem.h
//  Slideshow
//
//  Created by Adem Gaygusuz on 05/10/2014.
//  Copyright (c) 2014 Adem Gaygusuz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SlideshowItem : NSObject
@property NSString *title;
@property NSImage *image;
@property NSURL *imageURL;

- (id)initWithTitle:(NSString*)title image:(NSImage*)image url:(NSURL*)url;

@end
