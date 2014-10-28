//
//  AFWeatherClient.h
//  weather
//
//  Created by Ludvik Polak on 26.10.14.
//  Copyright (c) 2014 cz.poly. All rights reserved.
//

#import "AFHTTPSessionManager.h"
#import <Foundation/Foundation.h>

@interface AFWeatherClient : AFHTTPSessionManager

+ (instancetype)sharedClientData;
+ (instancetype)sharedClientSearch;

@end
