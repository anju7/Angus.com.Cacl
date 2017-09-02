//
//  CollectionViewController.h
//  Calculator
//
//  Created by Kumangus on 2013/12/10.
//  Copyright (c) 2013年 Kumangus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Album.h"
#import "Photo.h"
#import "ImageCell.h"


@protocol CollectionViewControllerDelegate <NSObject>

    
@end


@interface CollectionViewController : UIViewController

@property (nonatomic)ImageCell *imgcell;
@property (nonatomic)Album *album;
@property (nonatomic)Photo *photo;

@property id<CollectionViewControllerDelegate> delegate;

@end
