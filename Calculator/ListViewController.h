//
//  ListViewController.h
//  Calculator
//
//  Created by mac on 13/11/27.
//  Copyright (c) 2013年 Kumangus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CollectionViewController.h"

@class ListViewController;
@protocol ListViewControllerDelegate <NSObject>

-(void) listViewControllerDidClickedDismissButton:(ListViewController *)viewController;

@end


@interface ListViewController : UIViewController
@property (nonatomic, weak) id<ListViewControllerDelegate> delegate;

@end
