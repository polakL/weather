//
//  TodayViewController.h
//  Weather
//
//  Created by Ludvik Polak on 26.10.14.
//  Copyright (c) 2014 com.ludvikpolak. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TodayViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *imageBigSymbol;
@property (weak, nonatomic) IBOutlet UILabel *labelLocation;
@property (weak, nonatomic) IBOutlet UIImageView *imageCurrentIcon;
@property (weak, nonatomic) IBOutlet UILabel *labelWeatherText;
@property (weak, nonatomic) IBOutlet UILabel *labelPresure;
@property (weak, nonatomic) IBOutlet UILabel *labelPrecipMM;
@property (weak, nonatomic) IBOutlet UILabel *labelHumidity;
@property (weak, nonatomic) IBOutlet UILabel *labelWindSpeedKmph;
@property (weak, nonatomic) IBOutlet UILabel *labelWindDir16Point;


@end
