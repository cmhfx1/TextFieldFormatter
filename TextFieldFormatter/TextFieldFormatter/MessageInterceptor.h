//
//  MessageInterceptor.h
//  TextFieldFormatter
//
//  Created by fx on 2018/5/24.
//  Copyright © 2018年 fx. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessageInterceptor : NSObject
@property (nonatomic, readonly, copy) NSArray * interceptedProtocols;
@property (nonatomic, weak) id receiver;
@property (nonatomic, weak) id middleMan;

- (instancetype)initWithInterceptedProtocol:(Protocol *)interceptedProtocol;
- (instancetype)initWithInterceptedProtocols:(Protocol *)firstInterceptedProtocol, ... NS_REQUIRES_NIL_TERMINATION;
- (instancetype)initWithArrayOfInterceptedProtocols:(NSArray *)arrayOfInterceptedProtocols;
@end
