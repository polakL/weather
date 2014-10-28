//
//  ForecastViewController.h
//  Weather
//
//  Created by Ludvik Polak on 26.10.14.
//  Copyright (c) 2014 com.ludvikpolak. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ForecastViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;


@end
