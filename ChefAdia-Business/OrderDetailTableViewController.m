//
//  OrderDetailTableViewController.m
//  ChefAdia-Business
//
//  Created by 宋 奎熹 on 2016/12/12.
//  Copyright © 2016年 宋 奎熹. All rights reserved.
//

#import "OrderDetailTableViewController.h"
#import "AFNetworking.h"
#import "OrderDetailTableViewCell.h"

#define ORDER_DETAIL_URL @"http://139.196.179.145/ChefAdia-1.0-SNAPSHOT/shop/getOrder"
#define CHANGE_STATUS_URL @"http://139.196.179.145/ChefAdia-1.0-SNAPSHOT/shop/setState"

@interface OrderDetailTableViewController ()

@end

@implementation OrderDetailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.orderIDLabel setText:self.orderID];
    
    [self loadOrderDetail];
}

- (void)loadOrderDetail{
    self.foodArr = [[NSMutableArray alloc] init];
    
    __weak typeof(self) weakSelf = self;
    
    NSDictionary *getDict = @{
                              @"orderid" : self.orderID,
                              };
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:
                                                         @"text/plain",
                                                         @"text/html",
                                                         nil];
    [manager GET:ORDER_DETAIL_URL
      parameters:getDict
        progress:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
             NSDictionary *resultDict = (NSDictionary *)responseObject;
             if([[resultDict objectForKey:@"condition"] isEqualToString:@"success"]){
                 
                 NSDictionary *subResultDict = (NSDictionary *)[resultDict objectForKey:@"data"];
                 
                 [self.timeLabel setText:[subResultDict objectForKey:@"time"]];
                 [self.addressLabel setText:[subResultDict objectForKey:@"addr"]];
                 [self.userNameLabel setText:[subResultDict objectForKey:@"username"]];
                 [self.phoneLabel setText:[subResultDict objectForKey:@"phone"]];
                 [self.priceLabel setText:[NSString stringWithFormat:@"$%.2f", [[subResultDict objectForKey:@"price"] doubleValue]]];
                 
                 if([[subResultDict objectForKey:@"isfinish"] intValue] == 0){
                     [self.isFinishedLabel setText:@"Not Finished"];
                     [self.isFinishedLabel setTextColor:[UIColor redColor]];
                     [self.changeStatusButton setTitle:@"Set Finished" forState:UIControlStateNormal];
                 }else{
                     [self.isFinishedLabel setText:@"Finished"];
                     [self.isFinishedLabel setTextColor:[UIColor greenColor]];
                     [self.changeStatusButton setTitle:@"Set Not Finished" forState:UIControlStateNormal];
                 }
                 
                 [self.foodArr addObjectsFromArray:(NSArray *)[subResultDict objectForKey:@"food_list"]];
                 
                 [weakSelf.tableView reloadData];
       
             }else{
                 NSLog(@"Error, MSG: %@", [resultDict objectForKey:@"msg"]);
             }
         }
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             NSLog(@"%@",error);
         }];
}

- (IBAction)changeStatusAction:(id)sender{
    
    NSNumber *state;
    if([[self.isFinishedLabel text] isEqualToString:@"Finished"]) {
        state = [NSNumber numberWithInt:0];
    }else{
        state = [NSNumber numberWithInt:1];
    }
    
    NSDictionary *getDict = @{
                              @"orderid" : self.orderID,
                              @"state" : state,
                              };
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:
                                                         @"text/plain",
                                                         @"text/html",
                                                         nil];
    [manager GET:CHANGE_STATUS_URL
      parameters:getDict
        progress:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
             NSDictionary *resultDict = (NSDictionary *)responseObject;
             if([[resultDict objectForKey:@"condition"] isEqualToString:@"success"]){
                 
                 [self loadOrderDetail];
                 
             }else{
                 NSLog(@"Error, MSG: %@", [resultDict objectForKey:@"msg"]);
             }
         }
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             NSLog(@"%@",error);
         }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 1:
            return [self.foodArr count];
        default:
            return 8;
    }
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        return 10;
    }else{
        return [super tableView:tableView indentationLevelForRowAtIndexPath:indexPath];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0){
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }else{
        return 44;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 1){
        static NSString *CellIdentifier = @"OrderDetailTableViewCell";
        UINib *nib = [UINib nibWithNibName:@"OrderDetailTableViewCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
        OrderDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OrderDetailTableViewCell" forIndexPath:indexPath];
        
        NSDictionary *foodDict = self.foodArr[indexPath.row];
        
        [cell.nameLabel setText:[foodDict objectForKey:@"name"]];
        [cell.numLabel setText:[NSString stringWithFormat:@"%d", [[foodDict objectForKey:@"num"] intValue]]];
        [cell.priceLabel setText:[NSString stringWithFormat:@"$%.2f", [[foodDict objectForKey:@"price"] doubleValue]]];
        
        return cell;
    }else{
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
}

@end