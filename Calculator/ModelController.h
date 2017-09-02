//
//  ModelController.h
//  Page
//
//  Created by mac on 13/12/5.
//  Copyright (c) 2013年 Kumangus. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DataViewController;

//@protocol ModelControllerDelegate <NSObject>
//
//@end

@interface ModelController : NSObject <UIPageViewControllerDataSource>

- (DataViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard;
- (NSUInteger)indexOfViewController:(DataViewController *)viewController;

@property (nonatomic) NSMutableArray *pageData;


//@property id<ModelControllerDelegate> delegate;


@end
