//
//  CollectVideoViewController.h
//  Calculator
//
//  Created by Kumangus on 2013/12/30.
//  Copyright (c) 2013年 Kumangus. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "VideoCell.h"
#import "Video.h"

@interface CollectVideoViewController : UIViewController

@property (weak, nonatomic) IBOutlet UICollectionView *videoCollectionView;

@property (nonatomic)VideoCell *videoCell;
@property Video *video;

- (IBAction)addVideo:(id)sender;

@end
