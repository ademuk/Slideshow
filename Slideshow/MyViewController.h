//
//  MyViewController.h
//  Slideshow
//
//  Created by Adem Gaygusuz on 25/09/2014.
//  Copyright (c) 2014 Adem Gaygusuz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface IconViewBox : NSBox
@end

@interface MyScrollView : NSScrollView
@end

@interface MyViewController : NSViewController <NSCollectionViewDelegate>
{
    IBOutlet NSCollectionView *collectionView;
    IBOutlet NSArrayController *arrayController;
    NSMutableArray *images;
    
    NSUInteger sortingMode;
}

@property (retain) NSMutableArray *images;
@property (nonatomic, assign) NSUInteger sortingMode;

@end
