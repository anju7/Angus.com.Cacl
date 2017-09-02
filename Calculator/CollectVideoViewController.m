//
//  CollectVideoViewController.m
//  Calculator
//
//  Created by Kumangus on 2013/12/30.
//  Copyright (c) 2013年 Kumangus. All rights reserved.
//

#import "CollectVideoViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <MediaPlayer/MediaPlayer.h>
//#import "QBImagePickerController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "CoreDataHelper.h"
#import "Video.h"
#import "VideoCell.h"
#import <QuartzCore/QuartzCore.h>
#import "SVProgressHUD.h"
@interface CollectVideoViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@end

@implementation CollectVideoViewController{
    NSMutableArray *videoPathArray;
    MPMoviePlayerController *moviePlayer;

}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
         videoPathArray = [@[] mutableCopy];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.videoCollectionView.dataSource=self;
    self.videoCollectionView.delegate=self;
    [self loadFromFileManager];
}

//使用代理之後才會出現的內建函式

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    //取得使用的檔案格式
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    //使用的檔案格式是圖片
    if ([mediaType isEqualToString:@"public.image"]) {
        //使用先前的程式碼
    }
    //使用的檔案格式是影片
    if ([mediaType isEqualToString:@"public.movie"]) {
        //取得影片的位置
        NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
        //儲存影片於相簿中
        UISaveVideoAtPathToSavedPhotosAlbum(videoURL.path, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
    }
    //移除Picker
    [picker dismissViewControllerAnimated:YES completion:nil];
}










/*
#pragma mark - QBImagePickerControllerDelegate

- (void)imagePickerController:(QBImagePickerController *)imagePickerController didFinishPickingMediaWithInfo:(id)info
{
    CoreDataHelper*helper=[CoreDataHelper sharedInstance];
    Video *video = [NSEntityDescription insertNewObjectForEntityForName:@"Video" inManagedObjectContext:helper.managedObjectContext];
    
    NSLog(@"%@",info);
    NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
    
    
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);//搜索Document目錄
    NSString *documentPath=paths[0];//取得Document目錄
    
    NSString *videoUUID =[[NSUUID UUID]UUIDString];
    NSString *videoFileName=[NSString stringWithFormat:@"%@.mp4",videoUUID];
    
    NSString *videoFilePath=[documentPath stringByAppendingPathComponent:@"video"];
    videoFilePath = [videoFilePath stringByAppendingPathComponent:videoFileName];
    //Document/video/檔名.mp4
    
    video.videoPath =videoFilePath;
    
    NSData *videoData = [NSData dataWithContentsOfURL:videoURL];
    [videoData writeToFile:videoFilePath atomically:YES];//寫到檔案
    
    [videoPathArray addObject:videoFilePath];

    //    [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:0]]];
    
    [self.videoCollectionView reloadData];
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController{
    NSLog(@"已取消");
    [self dismissViewControllerAnimated:YES completion:NULL];
}

 - (NSString *)imagePickerController:(QBImagePickerController *)imagePickerController descriptionForNumberOfVideos:(NSUInteger)numberOfVideos{
 return [NSString stringWithFormat:@"影片%d部", numberOfVideos];
 }
*/


- (IBAction)addVideo:(id)sender {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
        imagePicker.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.mediaTypes =[UIImagePickerController availableMediaTypesForSourceType:imagePicker.sourceType];
    }
    imagePicker.delegate = self;
    imagePicker.allowsEditing = NO;
    [self presentViewController:imagePicker animated:YES completion:nil];

}

    
    
/*QB 寫法
    QBImagePickerController *imagePickerController = [[QBImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.filterType = QBImagePickerFil
 terTypeAllVideos;
    imagePickerController.allowsMultipleSelection = NO;
    
//    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);//搜索Document目錄
//    NSString *documentPath=paths[0];//取得Document目錄
//    NSString *videoFilePath=[documentPath stringByAppendingPathComponent:@"video"];
//    
//    //先在document資料夾中，生成資料夾"video"
//    if(![[NSFileManager defaultManager] fileExistsAtPath:videoFilePath]){
//        [[NSFileManager defaultManager] createDirectoryAtPath:videoFilePath withIntermediateDirectories:NO attributes:nil error:nil];
//    }
    
//    [videoPathArray addObject:self.video];

    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:imagePickerController];
    [self presentViewController:navigationController animated:YES completion:NULL];
 
}
 */



- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}






-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return videoPathArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * CellIdentifier = @"VideoCell";
    VideoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    NSString *videoPath= videoPathArray[indexPath.item];

    //利用MPMoviePlayerController截取影片的示意圖
    MPMoviePlayerController *player = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:videoPath]];
    player.shouldAutoplay = NO;
    //取得的影片示意圖
    
    //self.videoCell.videoImageView.image = [player thumbnailImageAtTime:0.0f timeOption:MPMovieTimeOptionNearestKeyFrame];
    
    cell.backgroundColor = [UIColor colorWithRed:((10 * indexPath.row) / 255.0) green:((20 * indexPath.row)/255.0) blue:((30 * indexPath.row)/255.0) alpha:1.0f];
    
    return cell;
}

#pragma mark -- UICollectionViewDelegate

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"選了第%d個影片",indexPath.item);
    
    UICollectionViewCell * cell = (UICollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];//用來知道目前有幾個item
    [self playVideo];
    
}

//是否可選
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}




- (void)playVideo
{
    moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:@"https://r20---sn-u2x76n7y.googlevideo.com/videoplayback?itag=18&expire=1388433103&ipbits=0&ip=110.29.193.142&key=yt5&ratebypass=yes&sver=3&fexp=933208%2C909717%2C924616%2C932295%2C936912%2C936910%2C923305%2C936913%2C907231%2C907240%2C921090%2C3300044%2C3300114%2C3300133%2C3300137%2C3300161%2C3310556%2C3310870&id=o-AEYyTibcxMncxktWs0vM5gfo7QRC9cM8LW_vh0MJNcKW&sparams=id%2Cip%2Cipbits%2Citag%2Cratebypass%2Csource%2Cupn%2Cexpire&upn=_HKOxlsiRxI&source=youtube&signature=382B5436A8C22B815D6DDE58B147AB04CBC47126.350EBFDEDE87477F46AFB900C25E98A4CAB927CB&redirect_counter=1&cms_redirect=yes&ms=nxu&mt=1388408661&mv=m"]];
    moviePlayer.controlStyle = MPMovieControlModeDefault;
    
    [moviePlayer play];
    NSLog(@"play video");
}



#pragma mark --自行建立判斷儲存成功與否的函式

- (void)video:(NSData *)video didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    
    
    
    UIAlertView *alert;
    
    
    
    //以error參數判斷是否成功儲存影像
    
    if (error) {
        
        alert = [[UIAlertView alloc] initWithTitle:@"錯誤"
                 
                                           message:[error description]
                 
                                          delegate:self
                 
                                 cancelButtonTitle:@"確定"
                 
                                 otherButtonTitles:nil];
        
    } else {
        
        alert = [[UIAlertView alloc] initWithTitle:@"成功"
                 
                                           message:@"影像已存入相簿中"
                 
                                          delegate:self
                 
                                 cancelButtonTitle:@"確定"
                 
                                 otherButtonTitles:nil];
        
    }
    
    
    
    //顯示警告訊息
    
    [alert show];
    
}



#pragma mark -- Data

-(void)loadFromFileManager{
    NSFileManager *fileManager = [NSFileManager defaultManager];//建立一個空白資料
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);//搜索Document目錄
    NSString *documentPath=paths[0];//取得Documents目錄
    NSString *folderPath =[documentPath stringByAppendingPathComponent:@"video"];
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:folderPath error:nil];
    [contents enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *videoFileName = obj;//圖檔名稱
        NSString *videoFilePath = [folderPath stringByAppendingPathComponent:videoFileName];
        [videoPathArray addObject:videoFilePath];
    }];
}

-(void)saveToCoreData{
    CoreDataHelper * helper =[CoreDataHelper sharedInstance];
    NSManagedObjectContext *moc =helper.managedObjectContext;
    __autoreleasing NSError *error = nil;
    [moc save:&error];//指標的指標
    if ( error ){
        NSLog(@"錯誤：在儲存 %@ 發生錯誤。",error);
    }
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
