//
//  RootViewController.h
//  Page
//
//  Created by mac on 13/12/5.
//  Copyright (c) 2013年 Kumangus. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol rootViewControllerDelegate <NSObject>


@end

@interface RootViewController : UIViewController<UIPageViewControllerDelegate>

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (nonatomic) NSArray *pageData;
@property (nonatomic) NSUInteger indexPage;

@property id<rootViewControllerDelegate> delegate;
- (IBAction)trashAction:(id)sender;
- (IBAction)actionButton:(id)sender;

@end
