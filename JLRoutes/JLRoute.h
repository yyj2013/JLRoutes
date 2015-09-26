/*
 Copyright (c) 2015, Joel Levin
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 Neither the name of JLRoutes nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import <Foundation/Foundation.h>


static NSUInteger const JLRouteDefaultPriority = 0;
static NSUInteger const JLRouteHighPriority = 1000;
static NSUInteger const JLRouteHighestPriority = 10000;


@class JLURLRouter;

@interface JLRoute : NSObject <NSCopying>

@property (nonatomic, weak, nullable) __kindof JLURLRouter *router;

@property (nonatomic, strong, readonly, nonnull) NSString *path;
@property (nonatomic, strong, readonly, nonnull) NSArray <NSString *> *pathComponents;
@property (nonatomic, strong, readonly, nonnull) BOOL (^handler)(NSDictionary <NSString *, id> *__nonnull parameters);
@property (nonatomic, readonly) NSUInteger priority;

/// Creates a route instance
- (nonnull instancetype)initWithPath:(nullable NSString *)path priority:(NSUInteger)priority handler:(nullable BOOL (^)(NSDictionary <NSString *, id> *__nonnull parameters))handlerBlock NS_DESIGNATED_INITIALIZER;

/// Try to match with the given path components. Returns nil if a match couldn't be made, or the match result if it could.
- (nonnull NSDictionary<NSString *, NSString *> *)matchWithPathComponentsIfPossible:(nonnull NSArray<NSString *> *)pathComponents;

@end
