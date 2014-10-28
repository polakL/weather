//
//  LocationFindViewController.m
//  Weather
//
//  Created by Ludvik Polak on 28.10.14.
//  Copyright (c) 2014 com.ludvikpolak. All rights reserved.
//

#import "LocationFindViewController.h"
#import "WeatherDataObject.h"

@interface LocationFindViewController ()

@property (nonatomic,strong) NSArray * tableData;

@end

@implementation LocationFindViewController

-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDataWithNotification:) name:SEARCHING_NOTIFICATION_DONE object:nil];
    
    [self updateData];
}

-(void)viewDidDisappear:(BOOL)animated{
    
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {

    [super viewDidLoad];
    
    [self.navigationItem setHidesBackButton:YES];
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.titleView = self.viewSearch;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonCloseTap:(id)sender {
    
    [self.textFieldSearch resignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - textField -

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(getServerLocations) object:nil];
    [self performSelector:@selector(getServerLocations) withObject:nil afterDelay:.5];
    
    return YES;
}

-(void)getServerLocations{
    
    [[WeatherDataObject Shared] GetServerLocationsForPlace:self.textFieldSearch.text];
    
}

-(void)updateDataWithNotification:(NSNotification*)Notification{
    
    // if error occured in server request, ignore update
    if([Notification.object isKindOfClass:[NSError class]] == NO){
     
        if([Notification.object isKindOfClass:[NSArray class]]){
            
            NSMutableArray * items = [NSMutableArray array];
            NSDictionary * data = nil;
            
            for (NSDictionary * item in Notification.object) {
                
                data = @{
                         @"areaName" : [[[item objectForKey:@"areaName"] objectAtIndex:0] objectForKey:@"value"],
                         @"country" : [[[item objectForKey:@"country"] objectAtIndex:0] objectForKey:@"value"],
                         @"region" : [[[item objectForKey:@"region"] objectAtIndex:0] objectForKey:@"value"],
                         };
                [items addObject:data];
            }
            
            self.tableData = [NSArray arrayWithArray:items];
            [self updateData];
        }
        
    }
}

-(void)updateData{
    
    NSLog(@"GetWeatherData:\n%@",[[WeatherDataObject Shared] GetWeatherData]);
    [self.tableView reloadData];
}

#pragma mark - Table -
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [self.tableData count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"findCell"];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"findCell"];
    }

    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UIColor * color = [UIColor colorWithRed:0x33 / 255.0 green:0x33 / 255.0 blue:0x33 / 255.0 alpha:1.0];
    NSDictionary *firstAttributes = @{NSForegroundColorAttributeName: color,
                                      NSFontAttributeName : [UIFont fontWithName:@"ProximaNova-Bold" size:16]
                                      };
    NSDictionary *secondAttributes = @{NSForegroundColorAttributeName: color,
                                       NSFontAttributeName : [UIFont fontWithName:@"ProximaNova-Regular" size:16]
                                       };
    
    NSDictionary * item = [self.tableData objectAtIndex:indexPath.row];
    NSString * place = [NSString stringWithFormat:@"%@, %@",[item objectForKey:@"areaName"], [item objectForKey:@"country"]];
    NSMutableAttributedString * attributed = [[NSMutableAttributedString alloc] initWithString:place];
    
    [attributed setAttributes:firstAttributes range:NSMakeRange(0, [[item objectForKey:@"areaName"] length] + 1)];
    [attributed setAttributes:secondAttributes range:NSMakeRange([[item objectForKey:@"areaName"] length] + 1 , [[item objectForKey:@"country"] length] + 1)];
    
    cell.textLabel.attributedText = attributed;
    
    cell.detailTextLabel.font = [UIFont fontWithName:@"ProximaNova-Light" size:8];
    cell.detailTextLabel.textColor = color;
    cell.detailTextLabel.text = [item objectForKey:@"region"];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary * item = [self.tableData objectAtIndex:indexPath.row];
    [[WeatherDataObject Shared] AddLocation:item];

    [self buttonCloseTap:nil];
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
