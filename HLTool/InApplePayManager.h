//
//  InApplePayManager.h
//  KuKuxiu
//
//  Created by 123456 on 16/3/29.
//  Copyright © 2016年 KuXing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@protocol KXInAppPurchaseDelegate;

@interface InApplePayManager : NSObject<SKProductsRequestDelegate,SKPaymentTransactionObserver>

+ (InApplePayManager *)shareApplePayInstance;

- (BOOL)canMakePayments;

- (void)payWithProductIdentifier:(NSString *)productIdentifier;

- (void)payWithProductIdentifier:(NSString *)productIdentifier withCount:(int)count;

@property (nonatomic,assign) id<KXInAppPurchaseDelegate> delegate;

@end

@protocol KXInAppPurchaseDelegate <NSObject>

//获得商品列表(yes)
- (void)KXInAppPurchase:(InApplePayManager *)purchase withProductCout:(NSArray *)products;
//购买失败，没有获得商品列表(yes)
- (void)KXInAppPurchase:(InApplePayManager *)purchase didFailWithError:(NSError *)Error;
//商品添加入列表中开始购买(yes)
- (void)KXInAppPurchase:(InApplePayManager *)purchase didAddList:(SKPaymentTransaction *)transaction;
//购买成功(yes)
- (void)KXInAppPurchase:(InApplePayManager *)purchase didPurchasedSuccess:(SKPaymentTransaction *)transaction;
//商品购买失败 (yes)
- (void)KXInAppPurchase:(InApplePayManager *)purchase didPurchasedFail:(SKPaymentTransaction *)transaction;

@optional
//购买队列结束 购买成功
- (void)KXInAppPurchase:(InApplePayManager *)purchase didPurchasedQueueSuccess:(SKPaymentQueue *)queue;
//购买队列结束 购买失败
- (void)KXInAppPurchase:(InApplePayManager *)purchase didPurchasedQueueFail:(SKPaymentQueue *)queue withError:(NSError *)error;
//此商品已经购买过
- (void)KXInAppPurchase:(InApplePayManager *)purchase didHadPurchased:(SKPaymentTransaction *)transaction;
@end
