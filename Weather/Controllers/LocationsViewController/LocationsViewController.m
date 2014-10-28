//
//  LocationsViewController.m
//  Weather
//
//  Created by Ludvik Polak on 28.10.14.
//  Copyright (c) 2014 com.ludvikpolak. All rights reserved.
//

#import "LocationsViewController.h"
#import "WeatherDataObject.h"
#import "LocationsTableCellController.h"
#import "LocationFindViewController.h"

@interface LocationsViewController ()

@end

@implementation LocationsViewController

-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDataWithNotification:) name:LOCATIONS_NOTIFICATION_UPDATED object:nil];
    
    [self updateData];
}

-(void)viewDidDisappear:(BOOL)animated{
    
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)updateDataWithNotification:(NSNotification*)Notification{
    
    // if error occured in server request, ignore update
    if([Notification.object isKindOfClass:[NSError class]] == NO)
        [self updateData];
}

-(void)updateData{
    
    NSLog(@"GetWeatherData:\n%@",[[WeatherDataObject Shared] GetWeatherData]);
    [self.tableView reloadData];
}

- (IBAction)buttonAddTap:(id)sender {
    
    LocationFindViewController * screen = [[LocationFindViewController alloc] initWithNibName:@"LocationFindViewController" bundle:nil];
    screen.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:screen animated:YES];
    screen = nil;

}

- (IBAction)buttonDeleteTap:(id)sender {
    
    [self.tableView setEditing:YES animated:YES];
}

#pragma mark - Table -
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [[[WeatherDataObject Shared] GetLocations] count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    LocationsTableCellController * cell = (LocationsTableCellController*)[tableView dequeueReusableCellWithIdentifier:@"locationCell"];
    if(cell == nil){
        [tableView registerNib:[UINib nibWithNibName:@"LocationsTableCellController" bundle:nil] forCellReuseIdentifier:@"locationCell"];
        cell = (LocationsTableCellController*)[tableView dequeueReusableCellWithIdentifier:@"locationCell"];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(editingStyle == UITableViewCellEditingStyleDelete){
        NSLog(@"delete");
        [self.tableView setEditing:NO animated:YES];
        [[WeatherDataObject Shared] RemoveLocationAtIndex:indexPath.row];
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if([cell isKindOfClass:[LocationsTableCellController class]]){
        
        NSDictionary * item = [[[WeatherDataObject Shared] GetLocations] objectAtIndex:indexPath.row];
        
        if(item){
            
            NSString * weatherText = @"- - -";
            if([item objectForKey:@"weatherDesc"])
                weatherText = [NSString stringWithFormat:@"%@",[item objectForKey:@"weatherDesc"]];
            
            NSString * placeName = @"- - -";
            if([item objectForKey:@"areaName"])
                placeName = [NSString stringWithFormat:@"%@",[item objectForKey:@"areaName"]];
            
            UIImage * weatherSymbol = nil;
            NSInteger code = [[item objectForKey:@"weatherCode"] integerValue];
            
            if(code < 116){
                weatherSymbol = [UIImage imageNamed:@"Sun_Big"];
            }
            else if(code < 299){
                weatherSymbol = [UIImage imageNamed:@"Cloudy_Big"];
            }
            else{
                weatherSymbol = [UIImage imageNamed:@"Lightning_Big"];
            }
            
            NSString * temp = @"-";
            if([item objectForKey:@"areaName"])
                temp = [NSString stringWithFormat:@"%@°",[item objectForKey:@"tempC"]];
            
            ((LocationsTableCellController*)cell).labelTempC.text = temp;
            ((LocationsTableCellController*)cell).labelPlaceName.text = placeName;
            ((LocationsTableCellController*)cell).labelWeatherDescription.text = weatherText;
            ((LocationsTableCellController*)cell).imageIcon.image = weatherSymbol;
            [UIView animateWithDuration:.3 delay:.0 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
                ((LocationsTableCellController*)cell).imageSelected.alpha = [[item objectForKey:@"selected"] boolValue] ? 1.0 : 0.0;
            } completion:^(BOOL finished) {
                
            }];
            
        }
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self performSelector:@selector(selectItemAtIndex:) withObject:[NSNumber numberWithInteger:indexPath.row] afterDelay:.3];
}

-(void)selectItemAtIndex:(NSNumber*)Index{
    
    [[WeatherDataObject Shared] SelectLocationAtIndex:[Index integerValue]];
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
