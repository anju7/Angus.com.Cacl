
//  CollectionViewController.m
//  Calculator
//
//  Created by Kumangus on 2013/12/10.
//  Copyright (c) 2013年 Kumangus. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "QBImagePickerController.h"
#import "DraggableCollectionViewFlowLayout.h"
#import "UICollectionView+Draggable.h"

#import "RootViewController.h"

#import "CollectionViewController.h"
#import "CoreDataHelper.h"

@interface CollectionViewController ()<QBImagePickerControllerDelegate,UICollectionViewDataSource_Draggable,UICollectionViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,rootViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation CollectionViewController{
    NSMutableArray *photoPathArray;
    //  teacher  NSUInteger *  改成 NSUInteger
    NSUInteger indexForPhoto;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    if ( self = [super initWithCoder:aDecoder]){
        photoPathArray = [@[] mutableCopy];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.collectionView.dataSource=self;
    self.collectionView.delegate=self;
    self.collectionView.draggable = YES;
    
    [self loadFromFileManager];

}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.navigationController setToolbarHidden:YES animated:YES];
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return photoPathArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * CellIdentifier = @"Cell";
    ImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    NSString *photoPath= photoPathArray[indexPath.item];
    UIImage *image=[UIImage imageWithContentsOfFile:photoPath];
    
    cell.imageView.image = [self toThumbnailImage:image scaledToSize:CGSizeMake(180, 180)];
    
    
    cell.backgroundColor = [UIColor colorWithRed:((10 * indexPath.row) / 255.0) green:((20 * indexPath.row)/255.0) blue:((30 * indexPath.row)/255.0) alpha:1.0f];

    return cell;
}

- (BOOL)collectionView:(LSCollectionViewHelper *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)collectionView:(LSCollectionViewHelper *)collectionView moveItemAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath{
    Photo *photo =[photoPathArray objectAtIndex:fromIndexPath.item];
    [photoPathArray removeObjectAtIndex:fromIndexPath.item];
    [photoPathArray insertObject:photo atIndex:toIndexPath.item];
    
    //寫排序 還沒寫完
//    if ( toIndexPath.item == 0  ){
//        Photo *firstPhoto = photoPathArray[1];
//        photo.seq = firstPhoto.seq - 1;
//    }else if ( toIndexPath.item == photoPathArray.count-1){
//        Photo *previousOne = photoPathArray[toIndexPath.item-1];
//        photo.seq = previousOne.seq +1;
//    }else{
//        Photo *previousOne = photoPathArray[toIndexPath.item-1];
//        Photo *afterOne = photoPathArray[toIndexPath.item+1];
//        photo.seq = (previousOne.seq + afterOne.seq)/2;
//    }
//    CoreDataHelper *helper = [CoreDataHelper sharedInstance];
//    NSManagedObjectContext *context = helper.managedObjectContext;
//    __autoreleasing NSError *error = nil;
//    [context save:&error];
    
}

#pragma mark -- UICollectionViewDelegate

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"selected item %d",indexPath.item);
    // teacher NSUInteger *  改成 NSUInteger
    indexForPhoto = (NSUInteger)indexPath.item;
    
    UICollectionViewCell * cell = (UICollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];//用來知道目前有幾個item
    
    RootViewController *pageViewController =  [self.storyboard instantiateViewControllerWithIdentifier:@"pageviewcontroller"];
    pageViewController.pageData = photoPathArray;
    //隱藏底下barbtn
    pageViewController.hidesBottomBarWhenPushed = YES;
    pageViewController.indexPage = indexForPhoto;
    
    [self.navigationController pushViewController:pageViewController animated:YES];
}


//是否可選
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}


- (IBAction)camera:(id)sender {
    
    QBImagePickerController *imagePickerController = [[QBImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.filterType = QBImagePickerFilterTypeAllPhotos;
    imagePickerController.allowsMultipleSelection = YES;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:imagePickerController];
    [self presentViewController:navigationController animated:YES completion:NULL];
}

#pragma mark --CoreData

-(void)loadFromFileManager{ //photoPathArray第一步加入所有位址並讀出
    
//    CoreDataHelper *helper=[CoreDataHelper sharedInstance];
//    NSManagedObjectContext *moc=helper.managedObjectContext;
//    NSFetchRequest *request=[[NSFetchRequest alloc]initWithEntityName:@"Photo"];
//    NSSortDescriptor *sortedDescriptor =[NSSortDescriptor sortDescriptorWithKey:@"seq" ascending:YES];//讀出seq排序
//    [request setSortDescriptors:@[sortedDescriptor]];
//    NSArray *results= [moc executeFetchRequest:request error:nil];
    
    
    NSFileManager *fileManager = [NSFileManager defaultManager];//建立一個空白資料
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);//搜索Document目錄
    NSString *documentPath=paths[0];//取得Document目錄
    NSString *folderPath =[documentPath stringByAppendingPathComponent:self.album.folder];
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:folderPath error:nil];
    [contents enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *imageFileName = obj;//圖檔名稱
        NSString *imageFilePath = [folderPath stringByAppendingPathComponent:imageFileName];
        [photoPathArray addObject:imageFilePath];//photoPathArray變成所有圖片的位址
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

#pragma mark - QBImagePickerControllerDelegate

- (void)imagePickerController:(QBImagePickerController *)imagePickerController didFinishPickingMediaWithInfo:(id)info
{
    CoreDataHelper*helper=[CoreDataHelper sharedInstance];
    Photo *photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:helper.managedObjectContext];
    
    NSArray *mediaInfoArray = (NSArray *)info;
    //做一個Array是info內容為（dic=相片）obj為Array中每個物件
    [mediaInfoArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *onePhotoInfo = obj;
        UIImage *image= onePhotoInfo[UIImagePickerControllerOriginalImage];
        
        photo.photoName =[[NSUUID UUID]UUIDString];    //****此處存入photoName*****
        
        NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);//搜索Document目錄
        NSString *documentPath=paths[0];//取得Document目錄
        NSString *imageFileName=[NSString stringWithFormat:@"%@.jpg",photo.photoName];
        NSString *imageFilePath=[documentPath stringByAppendingPathComponent:self.album.folder];
        imageFilePath = [imageFilePath stringByAppendingPathComponent:imageFileName];//doc/folder/檔名
        NSData *imageData=UIImageJPEGRepresentation(image, .8);//將image轉成NSData
        [imageData writeToFile:imageFilePath atomically:YES];//寫到檔案
        [photoPathArray addObject:imageFilePath];
    }];
    
//    [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:0]]];

    [self.collectionView reloadData];
    
    NSLog(@"Selected %d photos", mediaInfoArray.count);
    //NSLog(@"%@",info);
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController{
    NSLog(@"已取消");
    [self dismissViewControllerAnimated:YES completion:NULL];
}
- (NSString *)descriptionForSelectingAllAssets:(QBImagePickerController *)imagePickerController{
    return @"選擇全部";
}
- (NSString *)descriptionForDeselectingAllAssets:(QBImagePickerController *)imagePickerController{
    return @"取消所有選取";
}
- (NSString *)imagePickerController:(QBImagePickerController *)imagePickerController descriptionForNumberOfPhotos:(NSUInteger)numberOfPhotos{
    return [NSString stringWithFormat:@"照片%d張", numberOfPhotos];
}

- (UIImage*)toThumbnailImage:(UIImage*)image scaledToSize:(CGSize)newSize{
    float width,height;
    if (image.size.width<newSize.width && image.size.height<newSize.height){
        //如果已經小於newSize則不縮小
        width=image.size.width;
        height=image.size.height;
    }else if (image.size.height >= (newSize.height/newSize.width)*image.size.width){
        width=image.size.width/image.size.height*newSize.height;
        height=newSize.height;
    }else{
        height=image.size.height/image.size.width*newSize.height;
        width=newSize.width;
    }
    newSize.width=width;
    newSize.height=height;
    
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

//- (NSUInteger)indexOfPhotoarray:(NSMutableArray *)mutableArray{
//    mutableArray = photoPathArray;
//    return ;
//}

//
//#pragma mark - UIViewControllerTransitioningDelegate methods
//
//- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
//    if ([presented isKindOfClass:TGRImageViewController.class]) {
//        return [[TGRImageZoomAnimationController alloc] initWithReferenceImageView:self.imageButton.imageView];
//    }
//    return nil;
//}
//
//- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
//    if ([dismissed isKindOfClass:TGRImageViewController.class]) {
//        return [[TGRImageZoomAnimationController alloc] initWithReferenceImageView:self.imageButton.imageView];
//    }
//    return nil;
//}
//
//#pragma mark - Private methods
//
//- (IBAction)showImage {
//    TGRImageViewController *viewController = [[TGRImageViewController alloc] initWithImage:[self.imageButton imageForState:UIControlStateNormal]];
//    viewController.transitioningDelegate = self;
//    
//    [self presentViewController:viewController animated:YES completion:nil];
//}
//
//

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end