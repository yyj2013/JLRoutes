//
//  JLRoute.h
//  JLRoutes
//
//  Created by Joel Levin on 9/17/15.
//  Copyright © 2015 Afterwork Studios. All rights reserved.
//

#import <Foundation/Foundation.h>


static NSString *__nonnull const JLRoutePatternKey = @"JLRoutePattern";
static NSString *__nonnull const JLRouteURLKey = @"JLRouteURL";
static NSString *__nonnull const JLRouteNamespaceKey = @"JLRouteNamespace";
static NSString *__nonnull const JLRouteWildcardComponentsKey = @"JLRouteWildcardComponents";
static NSString *__nonnull const JLRoutesGlobalNamespaceKey = @"JLRoutesGlobalNamespace";

static NSUInteger const JLRouteDefaultPriority = 0;


@class JLRoutes;

@interface JLRoute : NSObject

@property (nonatomic, weak, nullable) JLRoutes *parentRoutesController;

@property (nonatomic, strong, readonly, nonnull) NSString *path;
@property (nonatomic, strong, readonly, nonnull) NSArray <NSString *> *pathComponents;
@property (nonatomic, strong, readonly, nonnull) BOOL (^handler)(NSDictionary *__nonnull parameters);
@property (nonatomic, readonly) NSUInteger priority;

- (nonnull instancetype)initWithPath:(nullable NSString *)path priority:(NSUInteger)priority handler:(nullable BOOL (^)(NSDictionary *__nonnull parameters))handlerBlock NS_DESIGNATED_INITIALIZER;

/// Try to match with the given URL components. Returns nil if a match couldn't be made, or the match result if it could.
- (nonnull NSDictionary *)matchWithURLComponentsIfPossible:(nonnull NSArray<NSString *> *)URLComponents;

@end
