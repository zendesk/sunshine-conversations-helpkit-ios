//
//  SHKMockApiClientBuilder.m
//  Smooch
//
//  Created by Mike Spensieri on 2014-07-16.
//  Copyright (c) 2015 Smooch Technologies. All rights reserved.
//

#import "SHKMockApiClientBuilder.h"
#import "OCMock.h"
#import "SHKApiClient.h"

@interface SHKMockApiClientBuilder()

@property id mockClient;

@end

@implementation SHKMockApiClientBuilder

+(id)newMockedClientforMethod:(NSString*)method withError:(NSError*)error andResponseObject:(id)responseObject;
{
    id mockBuilder = [[self builder] addExpectationForMethod:method withError:error andResponseObject:responseObject];
    
    return [mockBuilder build];
}

+(instancetype)builder
{
    return [[self alloc] init];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _mockClient = [OCMockObject mockForClass:[SHKApiClient class]];
        [[[_mockClient stub] ignoringNonObjectArgs] setExpectJSONResponse:YES];
    }
    return self;
}

-(instancetype)addExpectationForMethod:(NSString*)method withError:(NSError*)error
{
    return [self addExpectationForMethod:method withError:error andResponseObject:nil];
}

-(instancetype)addExpectationForMethod:(NSString*)method withResponseObject:(id)responseObject
{
    return [self addExpectationForMethod:method withError:nil andResponseObject:responseObject];
}

-(instancetype)addExpectationForMethod:(NSString*)method withError:(NSError*)error andResponseObject:(id)responseObject
{
    void (^doBlock)(NSInvocation *) = ^(NSInvocation *invocation) {
        id mockTask = [OCMockObject mockForClass:[NSURLSessionDataTask class]];
        [[[mockTask stub] andReturnValue:OCMOCK_VALUE(NSURLSessionTaskStateCompleted)] state];
        
        SHKApiClientCompletionBlock completionBlock;
        [invocation getArgument: &completionBlock atIndex: 4];
        
        [[[mockTask stub] andReturn:[[NSHTTPURLResponse alloc] initWithURL:[NSURL new] statusCode:200 HTTPVersion:nil headerFields:nil]] response];
        completionBlock(mockTask, error, responseObject);
    };
    
    if([method isEqualToString:@"GET"]){
        [[[self.mockClient expect] andDo:doBlock] GET:OCMOCK_ANY parameters:OCMOCK_ANY completion:OCMOCK_ANY];
    }else{
        [[[self.mockClient expect] andDo:doBlock] requestWithMethod:method url:OCMOCK_ANY parameters:OCMOCK_ANY completion:OCMOCK_ANY];
    }
    
    return self;
}

-(id)build
{
    return self.mockClient;
}

@end
