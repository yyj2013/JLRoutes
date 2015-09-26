/*
 Copyright (c) 2015, Joel Levin
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 Neither the name of JLRoutes nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "JLRoutes.h"


static NSMutableDictionary *routers = nil;
static Class defaultRouterClass = Nil;
static BOOL verboseLoggingEnabled = NO;
static BOOL shouldDecodePlusSymbols = YES;
static JLRoutesLogLevel logLevel = JLRoutesLogLevelInfo;


void JLRoutesLog(JLRoutesLogLevel level, NSString *__nonnull format, ...)
{
    if (level == JLRoutesLogLevelNone || level > logLevel || format.length == 0)
    {
        return; // suppress
    }
    
    va_list argsList;
    va_start(argsList, format);
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wformat-nonliteral"
    
    NSString *formattedLogMessage = [[NSString alloc] initWithFormat:format arguments:argsList];
    
#pragma clang diagnostic pop
    
    va_end(argsList);
    
    NSLog(@"[JLRoutes]: %@", formattedLogMessage);
}


@implementation JLRoutes

#pragma mark - Router management

+ (nonnull __kindof JLURLRouter *)defaultRouter
{
	return [self routerForScheme:JLRoutesGlobalScheme];
}

+ (nonnull __kindof JLURLRouter *)routerForScheme:(nonnull NSString *)scheme
{
    if (scheme.length == 0)
    {
        return [self defaultRouter];
    }
    
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		routers = [[NSMutableDictionary alloc] init];
        if (defaultRouterClass == Nil)
            defaultRouterClass = [JLURLRouter class];
	});
    
    JLURLRouter *router = routers[scheme];
	
	if (router == nil)
    {
		router = [[defaultRouterClass alloc] initWithScheme:scheme];
		routers[scheme] = router;
	}
	
	return router;
}

+ (void)unregisterRouterForScheme:(nonnull NSString *)scheme
{
    [self unregisterRouter:[self routerForScheme:scheme]];
}

+ (void)unregisterRouter:(nonnull __kindof JLURLRouter *)router
{
    if (router == nil)
        return;
    
    [routers removeObjectForKey:router.scheme];
}

#pragma mark - Convenience

+ (BOOL)canRouteURL:(nonnull NSURL *)URL
{
    NSParameterAssert(URL != nil);
    
    JLURLRouter *router = [self firstEligibleRouterForURL:URL];
    
    return router != nil;
}

+ (BOOL)routeURL:(nonnull NSURL *)URL
{
    NSParameterAssert(URL != nil);
    return [self routeURL:URL userInfo:nil];
}

+ (BOOL)routeURL:(nonnull NSURL *)URL userInfo:(nullable NSDictionary *)userInfo
{
    return NO;
}

+ (JLURLRouter *)firstEligibleRouterForURL:(nonnull NSURL *)URL
{
    JLURLRouter *eligibleRouter = nil;
    
    //JLURLRouter *router = [self routerForScheme:URL.scheme] ?: [self defaultRouter];
    
    
    return eligibleRouter;
}

#pragma mark - Settings

+ (void)setLogLevel:(JLRoutesLogLevel)level
{
    logLevel = level;
}

+ (JLRoutesLogLevel)logLevel
{
    return logLevel;
}

+ (BOOL)isVerboseLoggingEnabled
{
    return verboseLoggingEnabled;
}

+ (void)setShouldDecodePlusSymbols:(BOOL)shouldDecode
{
    shouldDecodePlusSymbols = shouldDecode;
}

+ (BOOL)shouldDecodePlusSymbols
{
    return shouldDecodePlusSymbols;
}

+ (void)setURLRouterClass:(Class)routerClass
{
    NSParameterAssert([routerClass isSubclassOfClass:[JLURLRouter class]]);
    defaultRouterClass = routerClass;
}

+ (Class)URLRouterClass
{
    return defaultRouterClass;
}

@end
