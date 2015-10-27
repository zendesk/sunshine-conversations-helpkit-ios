//
//  SHKMockApiClientBuilder.h
//  Smooch
//
//  Created by Mike Spensieri on 2014-07-16.
//  Copyright (c) 2015 Smooch Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OCMock.h"

@interface SHKMockApiClientBuilder : NSObject

+(id)newMockedClientforMethod:(NSString*)method withError:(NSError*)error andResponseObject:(id)responseObject;
+(instancetype)builder;

-(instancetype)addExpectationForMethod:(NSString*)method withError:(NSError*)error;
-(instancetype)addExpectationForMethod:(NSString*)method withResponseObject:(id)responseObject;
-(instancetype)addExpectationForMethod:(NSString*)method withError:(NSError*)error andResponseObject:(id)responseObject;

-(id)build;

@end
