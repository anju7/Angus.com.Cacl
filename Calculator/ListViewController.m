//
//  ListViewController.m
//  Calculator
//
//  Created by mac on 13/11/27.
//  Copyright (c) 2013年 Kumangus. All rights reserved.
//

#import "ListViewController.h"
#import "Album.h"
#import "CoreDataHelper.h"

@interface ListViewController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,CollectionViewControllerDelegate,UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ListViewController
{
    NSMutableArray *albumArray;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    if ( self = [super initWithCoder:aDecoder]){
        albumArray = [@[] mutableCopy];
        
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];

    [self queryFromCoreData];
    self.tableView.dataSource=self;
    self.tableView.delegate=self;
}

//-(NSString *)docPath{//Document的位置
//    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectory = [paths objectAtIndex:0];
//    return documentsDirectory;
//}

//-(void)viewWillAppear:(BOOL)animated{
//    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:<#(CGFloat)#> green:<#(CGFloat)#> blue:<#(CGFloat)#> alpha:<#(CGFloat)#>]];
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [albumArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"AlbumCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    Album *album = albumArray[indexPath.row];
    cell.textLabel.text = album.albumName;
//    cell.imageView.image =
    
    return cell;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    //destination目的地
    if ([segue.identifier isEqualToString:@"albumtitle"]) {
        CollectionViewController *collectionViewController = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Album *album = albumArray[indexPath.row];
        collectionViewController.album = album;
        collectionViewController.title = album.albumName;
    }
    
    
}

#pragma mark UITableViewDelegate

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    
    Album*album=[albumArray objectAtIndex:sourceIndexPath.row];//取得移動的album
    [albumArray removeObjectAtIndex:sourceIndexPath.row]; //將album從原本的Array中移除
    [albumArray insertObject:album atIndex:destinationIndexPath.row];//新增到新的位置
    //step2 adjust seq field in core data
    if ( destinationIndexPath.row == 0  ){
        Album *firstAlbum = albumArray[1];
        album.seq = firstAlbum.seq - 1;
    }else if ( destinationIndexPath.row == albumArray.count-1){
        Album *previousOne = albumArray[destinationIndexPath.row-1];
        album.seq = previousOne.seq +1;
    }else{
        Album *previousOne = albumArray[destinationIndexPath.row-1];
        Album *afterOne = albumArray[destinationIndexPath.row+1];
        album.seq = (previousOne.seq + afterOne.seq)/2;
    }
    CoreDataHelper *helper = [CoreDataHelper sharedInstance];
    NSManagedObjectContext *context = helper.managedObjectContext;
    __autoreleasing NSError *error = nil;
    [context save:&error];
    
    [tableView moveRowAtIndexPath:sourceIndexPath toIndexPath:destinationIndexPath];
    //通知tableview進行位置變更
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(editingStyle== UITableViewCellEditingStyleDelete){//刪除
        Album *album =albumArray[indexPath.row];
        CoreDataHelper *help = [CoreDataHelper sharedInstance];
        NSManagedObjectContext *moc = help.managedObjectContext;
        [moc deleteObject:album];

        [albumArray removeObjectAtIndex:indexPath.row];
        [self saveToCoreData];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES; //是加入否滑動刪除
}


//點擊 選擇的右標
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSLog(@"%@",[NSString stringWithFormat:@"Cell %ld in Section %ld is selected",(long)indexPath.row,(long)indexPath.section]);

}

#pragma mark --ButtonAction

- (IBAction)editButtonAction:(id)sender {
    [self.tableView setEditing:!self.tableView.editing animated:YES];
}
- (IBAction)addButtonAction:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"新增相簿" message:@"請命名" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"確定", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *alertTextfild = [alertView textFieldAtIndex:0];
    alertTextfild.returnKeyType = UIReturnKeyDone;
    alertTextfild.clearButtonMode = UITextFieldViewModeAlways;
    alertTextfild.enablesReturnKeyAutomatically = YES;
    alertTextfild.delegate = self;
    [alertView show];
    
}
//對不同alert btn 作不同事件
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"clickButtonAtIndex:%d",buttonIndex);
    switch (buttonIndex) {
        case 0:
            NSLog(@"取消事件");
            
            break;
        case 1:
            NSLog(@"確定事件");
            CoreDataHelper*helper=[CoreDataHelper sharedInstance];
            Album *album=[NSEntityDescription insertNewObjectForEntityForName:@"Album" inManagedObjectContext:helper.managedObjectContext];
            
            UITextField *alertTextfild = [alertView textFieldAtIndex:0];
            album.albumName = alertTextfild.text;//****此處存入albumName****
            NSLog(@"使用者輸入 %@ 並送出",alertTextfild.text);
            //如果沒有folder 就用uuid當資料夾名稱
            if ( !album.folder ){
                NSString *uuidForFolder =[[NSUUID UUID]UUIDString];
                album.folder = uuidForFolder;//****此處存入albumName*****
            }
            
            if ( albumArray.count > 0 ){
                Album *lastAlbum = [albumArray lastObject];
                album.seq = lastAlbum.seq+1;
            }else{
                album.seq = 1.0;
            }
            [albumArray addObject:album];
            
            //生成存放照片的資料夾
            NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);//搜索Document目錄
            NSString *documentPath=paths[0];//取得Document目錄
            NSString *imageFilePath=[documentPath stringByAppendingPathComponent:album.folder];
            [[NSFileManager defaultManager] createDirectoryAtPath:imageFilePath withIntermediateDirectories:NO attributes:nil error:nil];
            
            [self saveToCoreData];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:albumArray.count-1 inSection:0];
            [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            
            
            //直接切換到CollectionView
            
            CollectionViewController *collectionVC = [self.storyboard instantiateViewControllerWithIdentifier:@"collectionID"];
            Album *albumSelectedRow = albumArray[indexPath.row];
            collectionVC.album = albumSelectedRow;
            collectionVC.title = albumSelectedRow.albumName;
            
            [self.navigationController pushViewController:collectionVC animated:YES];
            
            break;
    }
}

#pragma mark --TextField

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
	if (range.length != 1 && [text isEqualToString:@"\n"]) {//按下return鍵
        NSLog(@"按下return");
		return NO;
	} else {
		return YES;
	}
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
-(BOOL)textFieldShouldClear:(UITextField *)textField{
    return YES;
}
-(void)textFieldDidEndEditing:(UITextField *)textField{
    
}

#pragma mark --CoreData

-(void)queryFromCoreData{
    CoreDataHelper *helper=[CoreDataHelper sharedInstance];
    NSManagedObjectContext *moc=helper.managedObjectContext;
    NSFetchRequest *request=[[NSFetchRequest alloc]initWithEntityName:@"Album"];
    NSSortDescriptor *sortedDescriptor =[NSSortDescriptor sortDescriptorWithKey:@"seq" ascending:YES];//讀出seq排序
    [request setSortDescriptors:@[sortedDescriptor]];
    NSArray *results= [moc executeFetchRequest:request error:nil];
    [albumArray addObjectsFromArray:results];
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

@end
