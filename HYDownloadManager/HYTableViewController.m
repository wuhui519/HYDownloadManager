//
//  HYTableViewController.m
//  HYDownloadManager
//
//  Created by Faye on 2016/11/25.
//  Copyright © 2016年 CMCC. All rights reserved.
//

#import "HYTableViewController.h"
#import "HYImageTableViewCell.h"

@interface HYTableViewController ()
{
    NSArray *images;
}
@property (nonatomic, readonly) NSUInteger currentTabIndex;
@end

@implementation HYTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    UIEdgeInsets contentInset = self.tableView.contentInset;
    contentInset.bottom = self.tabBarController.tabBar.intrinsicContentSize.height;
    self.tableView.contentInset = contentInset;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setArrayForParallel:self.currentTabIndex == 0];
}

- (NSUInteger)currentTabIndex {
    UITabBarController *tabCtrl = self.tabBarController;
    if ([tabCtrl isKindOfClass:[UITabBarController class]]) {
        return tabCtrl.selectedIndex;
    }
    return 0;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)setArrayForParallel:(BOOL)parallel
{
    if (parallel)
    {
        images =
        @[
          [NSURL URLWithString:@"http://cdn-img.easyicon.net/png/11587/1158730.gif"],
          [NSURL URLWithString:@"http://cdn-img.easyicon.net/png/11578/1157866.gif"],
          [NSURL URLWithString:@"http://cdn-img.easyicon.net/png/11587/1158730.gif"],
          [NSURL URLWithString:@"http://cdn-img.easyicon.net/png/11578/1157866.gif"],
          [NSURL URLWithString:@"http://cdn-img.easyicon.net/png/11578/1157866.gif"],
          [NSURL URLWithString:@"http://cdn-img.easyicon.net/png/11578/1157866.gif"],
          [NSURL URLWithString:@"http://cdn-img.easyicon.net/png/11578/1157866.gif"],
          [NSURL URLWithString:@"http://cdn-img.easyicon.net/png/11523/1152396.gif"],
          [NSURL URLWithString:@"http://cdn-img.easyicon.net/png/11523/1152396.gif"],
          [NSURL URLWithString:@"http://cdn-img.easyicon.net/png/11523/1152396.gif"],
          [NSURL URLWithString:@"http://cdn-img.easyicon.net/png/11523/1152396.gif"],
          [NSURL URLWithString:@"http://cdn-img.easyicon.net/png/11523/1152396.gif"],
          [NSURL URLWithString:@"http://cdn-img.easyicon.net/png/11578/1157870.gif"],
          [NSURL URLWithString:@"http://cdn-img.easyicon.net/png/11522/1152213.gif"],
          [NSURL URLWithString:@"http://cdn-img.easyicon.net/png/11522/1152213.gif"],
          [NSURL URLWithString:@"http://cdn-img.easyicon.net/png/11523/1152396.gif"],
          [NSURL URLWithString:@"http://cdn-img.easyicon.net/png/11698/1169845.gif"],
          [NSURL URLWithString:@"http://cdn-img.easyicon.net/png/11604/1160442.gif"],
          [NSURL URLWithString:@"http://cdn-img.easyicon.net/png/11698/1169845.gif"],
          [NSURL URLWithString:@"http://cdn-img.easyicon.net/png/11733/1173353.gif"],
          [NSURL URLWithString:@"http://cdn-img.easyicon.net/png/11764/1176410.gif"],
          [NSURL URLWithString:@"http://cdn-img.easyicon.net/png/11760/1176056.gif"],
          [NSURL URLWithString:@"http://cdn-img.easyicon.net/png/11523/1152396.gif"],
          [NSURL URLWithString:@"http://cdn-img.easyicon.net/png/11733/1173353.gif"],
          [NSURL URLWithString:@"http://cdn-img.easyicon.net/png/11760/1176056.gif"],
          [NSURL URLWithString:@"http://cdn-img.easyicon.net/png/11587/1158730.gif"],
          [NSURL URLWithString:@"http://cdn-img.easyicon.net/png/11764/1176410.gif"]];
    }
    else
    {
        images =
        @[
          @[[NSURL URLWithString:@"http://cdn-img.easyicon.net/png/11578/1157866.gif"],
            [NSURL URLWithString:@"http://cdn-img.easyicon.net/png/11578/1157866.gif"],
            [NSURL URLWithString:@"http://cdn-img.easyicon.net/png/11578/1157866.gif"]],
          @[[NSURL URLWithString:@"http://cdn-img.easyicon.net/png/11587/1158730.gif"],
            [NSURL URLWithString:@"http://cdn-img.easyicon.net/png/11578/1157866.gif"],
            [NSURL URLWithString:@"http://cdn-img.easyicon.net/png/11578/1157870.gif"
             ]],
          @[[NSURL URLWithString:@"http://cdn-img.easyicon.net/png/11578/1157866.gif"],
            [NSURL URLWithString:@"http://cdn-img.easyicon.net/png/11523/1152396.gif"],
            [NSURL URLWithString:@"http://cdn-img.easyicon.net/png/11523/1152396.gif"]]
          ,
          @[[NSURL URLWithString:@"http://cdn-img.easyicon.net/png/11523/1152396.gif"],
            [NSURL URLWithString:@"http://cdn-img.easyicon.net/png/11523/1152396.gif"],
            [NSURL URLWithString:@"http://cdn-img.easyicon.net/png/11523/1152396.gif"]]
          ,
          @[[NSURL URLWithString:@"http://cdn-img.easyicon.net/png/11578/1157870.gif"],
            [NSURL URLWithString:@"http://cdn-img.easyicon.net/png/11522/1152213.gif"],
            [NSURL URLWithString:@"http://cdn-img.easyicon.net/png/11522/1152213.gif"]]
          ,
          @[[NSURL URLWithString:@"http://cdn-img.easyicon.net/png/11523/1152396.gif"],
            [NSURL URLWithString:@"http://cdn-img.easyicon.net/png/11698/1169845.gif"],
            [NSURL URLWithString:@"http://cdn-img.easyicon.net/png/11604/1160442.gif"]]
          ,
          @[[NSURL URLWithString:@"http://cdn-img.easyicon.net/png/11698/1169845.gif"],
            [NSURL URLWithString:@"http://cdn-img.easyicon.net/png/11733/1173353.gif"],
            [NSURL URLWithString:@"http://cdn-img.easyicon.net/png/11764/1176410.gif"]]
          ,
          @[[NSURL URLWithString:@"http://cdn-img.easyicon.net/png/11760/1176056.gif"],
            [NSURL URLWithString:@"http://cdn-img.easyicon.net/png/11523/1152396.gif"],
            [NSURL URLWithString:@"http://cdn-img.easyicon.net/png/11733/1173353.gif"]]
          ,
          @[[NSURL URLWithString:@"http://cdn-img.easyicon.net/png/11760/1176056.gif"],
            [NSURL URLWithString:@"http://cdn-img.easyicon.net/png/11587/1158730.gif"],
            [NSURL URLWithString:@"http://cdn-img.easyicon.net/png/11764/1176410.gif"]]
          ];
    }
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return images.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = @"cell";
    HYImageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[HYImageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    if (self.currentTabIndex == 0) {
        NSURL *url = images[indexPath.row];
        [cell setImageWithURL:url];
    }
    else {
        NSArray *urls = images[indexPath.row];
        [cell setImageWithURLs:urls];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    HYImageTableViewCell *cell = (HYImageTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    [cell stopDownloading];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
