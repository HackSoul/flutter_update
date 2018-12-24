#import "FlutterUpdatePlugin.h"
#import <StoreKit/StoreKit.h>

@implementation FlutterUpdatePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"flutter_update"
            binaryMessenger:[registrar messenger]];
  FlutterUpdatePlugin* instance = [[FlutterUpdatePlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"update" isEqualToString:call.method]) {
      
      NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%s",
                                         "https://itunes.apple.com/cn/app/%E9%82%BB%E9%87%8C%E4%BA%92%E5%8A%A8/id1441499804"]];
      if (@available(iOS 10.0, *)) {
          [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:NULL];
      } else {
          // Fallback on earlier versions
      }
      result([@"app_Version: " stringByAppendingString:[NSString stringWithFormat:@"%@", url]]);
  } else if ([@"canUpdate" isEqualToString:call.method]) {
      NSString *itunesUrl = [[NSString alloc] initWithFormat:@"http://itunes.apple.com/cn/lookup?id=%@",@"1441499804"];
      [self postpath: itunesUrl result: result];
  } else {
    result(FlutterMethodNotImplemented);
  }
}


-(void)postpath:(NSString *)path result:(FlutterResult)result
{
    
    NSURL *url = [NSURL URLWithString:path];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:10];
    
    [request setHTTPMethod:@"POST"];
    
    
    NSOperationQueue *queue = [NSOperationQueue new];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response,NSData *data,NSError *error){
        NSMutableDictionary *receiveStatusDic=[[NSMutableDictionary alloc]init];
        if (data) {
            
            NSDictionary *receiveDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            if ([[receiveDic valueForKey:@"resultCount"] intValue]>0) {
                
                [receiveStatusDic setValue:@"1" forKey:@"status"];
                [receiveStatusDic setValue:[[[receiveDic valueForKey:@"results"] objectAtIndex:0] valueForKey:@"version"]   forKey:@"version"];
            }else{
                
                [receiveStatusDic setValue:@"-1" forKey:@"status"];
            }
        } else {
            [receiveStatusDic setValue:@"-1" forKey:@"status"];
        }
        
        [self performSelectorOnMainThread:@selector(receiveData:) withObject:[NSArray arrayWithObjects:receiveStatusDic, result, nil] waitUntilDone:NO];
    }];
    
}


-(void)receiveData:(NSArray*)data
{
    NSMutableDictionary *receiveStatusDic = (NSMutableDictionary *) data[0];
    NSLog(@"receiveData=%@",receiveStatusDic);
    NSString *versionStr = [receiveStatusDic objectForKey: @"version"];
    NSLog(@"storeVersion=%@", versionStr);
    double version = [versionStr doubleValue];
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersionStr = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    double appVersion = [appVersionStr doubleValue];
    NSLog(@"app_Version=%@",appVersionStr);
    
    if (appVersion < version) {
        ((FlutterResult) data[1])([@"" stringByAppendingString:[NSString stringWithFormat:@"%s", "true"]]);
    } else {
        ((FlutterResult) data[1])([@"" stringByAppendingString:[NSString stringWithFormat:@"%s", "false"]]);
    }

}

@end
