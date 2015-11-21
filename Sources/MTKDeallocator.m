//
//  MTKDeallocator.m
//  Block Key-Value Observing
//
//  Created by Martin Kiss on 21.11.15.
//  Copyright © 2015 iMartin Kiss. All rights reserved.
//

#import "MTKDeallocator.h"
#import <objc/runtime.h>



@interface MTKDeallocator : NSObject

@property (readonly, unsafe_unretained) NSObject *owner;
@property (readonly) NSMutableArray<MTKDeallocatorCallback> *callbacks;

@end



@implementation MTKDeallocator


- (instancetype)initWithOwner:(NSObject*)owner {
    self = [super init];
    if (self) {
        self->_owner = nil;
        self->_callbacks = [NSMutableArray new];
    }
    return self;
}


- (void)addCallback:(MTKDeallocatorCallback)block {
    if (block)
        [self->_callbacks addObject:block];
}


- (void)dealloc {
    __unsafe_unretained NSObject *owner = self->_owner;
    for (MTKDeallocatorCallback block in self->_callbacks)
        block(owner);
    
    self->_owner = nil;
    self->_callbacks = nil;
}


@end



@implementation NSObject (MTKDeallocator)


- (void)mtk_addDeallocationCallback:(MTKDeallocatorCallback)block {
    @synchronized(self) {
        @autoreleasepool {
            MTKDeallocator *deallocator = objc_getAssociatedObject(self, _cmd);
            if ( ! deallocator) {
                deallocator = [[MTKDeallocator alloc] initWithOwner:self];
                objc_setAssociatedObject(self, _cmd, deallocator, OBJC_ASSOCIATION_RETAIN);
            }
            [deallocator addCallback:block];
        }
    }
}


@end


