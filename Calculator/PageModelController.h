//
//  PageModelController.h
//  Calculator
//
//  Created by Kumangus on 2013/12/29.
//  Copyright (c) 2013年 Kumangus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageContentViewController.h"


@interface PageModelController : UIViewController <UIPageViewControllerDataSource>

- (IBAction)startWalkthrough:(id)sender;
@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSArray *pageTitles;
@property (strong, nonatomic) NSArray *pageImages;

@end