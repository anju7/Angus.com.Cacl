//
//  DataViewController.m
//  Page
//
//  Created by mac on 13/12/5.
//  Copyright (c) 2013年 Kumangus. All rights reserved.
//

#import "DataViewController.h"
#import "UITabBarController+HideTabBar.h"
@interface DataViewController ()

@end

@implementation DataViewController{

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _scrollView.minimumZoomScale=1;//放大縮小的比例
    _scrollView.maximumZoomScale=2;
    _scrollView.delegate = self;
    
    UITapGestureRecognizer *singelTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTapGesture:)];
    singelTapGesture.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:singelTapGesture];
    
    //雙擊手勢
    UITapGestureRecognizer *doubelTapGesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapGesture:)];
    doubelTapGesture.numberOfTapsRequired=2;
    //[_dataImage addGestureRecognizer:doubelGesture];
    [self.view addGestureRecognizer:doubelTapGesture];
    [singelTapGesture requireGestureRecognizerToFail:doubelTapGesture];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.dataImage.image = [UIImage imageWithContentsOfFile:[self.dataObject description]];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.navigationController setToolbarHidden:YES animated:YES];
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.dataImage;//告訴程式是哪個要放大縮小
}


#pragma mark -TapGesture Action
-(void)singleTapGesture:(UIGestureRecognizer *)tapGestureRecognizer
{
    NSLog(@"單擊手勢");
    if (![self.navigationController isNavigationBarHidden]) {
        //[self.tabBarController setTabBarHidden:YES animated:YES];
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [self.navigationController setToolbarHidden:YES animated:YES];
    }else{
        //[self.tabBarController setTabBarHidden:NO animated:YES];
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        [self.navigationController setToolbarHidden:NO animated:YES];
    }
}

-(void)doubleTapGesture:(UIGestureRecognizer *)tapGestureRecognizer
{
    NSLog(@"雙擊手勢");
    
    if (self.scrollView.zoomScale == self.scrollView.minimumZoomScale) {
        // Zoom in
        CGPoint center = [tapGestureRecognizer locationInView:self.scrollView];
        CGSize size = CGSizeMake(self.scrollView.bounds.size.width / self.scrollView.maximumZoomScale,
                                 self.scrollView.bounds.size.height / self.scrollView.maximumZoomScale);
        CGRect rect = CGRectMake(center.x - (size.width / 2.0), center.y - (size.height / 2.0), size.width, size.height);
        [self.scrollView zoomToRect:rect animated:YES];
    }
    else {
        // Zoom out
        [self.scrollView zoomToRect:self.scrollView.bounds animated:YES];
    }
    
}


- (BOOL)prefersStatusBarHidden {
    return YES;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}







@end
