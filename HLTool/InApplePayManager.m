//
//  InApplePayManager.m
//  KuKuxiu
//
//  Created by 123456 on 16/3/29.
//  Copyright © 2016年 KuXing. All rights reserved.
//

#import "InApplePayManager.h"

static InApplePayManager *_instance = nil;

@interface InApplePayManager()

@property (nonatomic,assign) int productCount;

@property (nonatomic,copy) NSString *productIdentifier;

@property (nonatomic,strong) SKProductsRequest *productRequest;

@end

@implementation InApplePayManager

+ (InApplePayManager *)shareApplePayInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[InApplePayManager alloc] init];
    });
    
    return _instance;
}

- (id)init {
    self = [super init];
    if (self) {
        self.productCount = 1;
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    return self;
}

- (void)payWithProductIdentifier:(NSString *)productIdentifier {

    NSSet *set = [NSSet setWithArray:@[productIdentifier]];
    self.productIdentifier       = productIdentifier;
    self.productRequest          = [[SKProductsRequest alloc] initWithProductIdentifiers:set];
    self.productRequest.delegate = self;
    [self.productRequest start];
    
}

- (void)payWithProductIdentifier:(NSString *)productIdentifier withCount:(int)count {
    self.productCount      = count;
    self.productIdentifier = productIdentifier;
    NSSet *set             = [NSSet setWithArray:@[productIdentifier]];
    self.productRequest    = [[SKProductsRequest alloc] initWithProductIdentifiers:set];
    self.productRequest.delegate = self;
    [self.productRequest start];
    
}

- (BOOL)canMakePayments {
    return [SKPaymentQueue canMakePayments];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    
    NSArray *products = response.products;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(KXInAppPurchase:withProductCout:)]) {
        [self.delegate KXInAppPurchase:self withProductCout:products];
    }
    
    if (products.count > 0) {
        if (_productCount == 1) {
            SKPayment *payment = [SKPayment paymentWithProduct:products[0]];
            [[SKPaymentQueue defaultQueue] addPayment:payment];
            
        } else {
            SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:products[0]];
            payment.quantity          = 3;
            [[SKPaymentQueue defaultQueue] addPayment:payment];
        }
    }
}


- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    
    for (SKPaymentTransaction *transaction in transactions) {
        
        switch (transaction.transactionState) {
                
            case SKPaymentTransactionStatePurchased://交易完成
            {
                
                if (self.delegate !=nil && [self.delegate respondsToSelector:@selector(KXInAppPurchase:didPurchasedSuccess:)]) {
                    [self.delegate KXInAppPurchase:self didPurchasedSuccess:transaction];
                }
                
                [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
                
            }
                break;
            case SKPaymentTransactionStateFailed://交易失败
            {
                if (self.delegate !=nil && [self.delegate respondsToSelector:@selector(KXInAppPurchase:didPurchasedFail:)]) {
                    [self.delegate KXInAppPurchase:self didPurchasedFail:transaction];
                }
                
                [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
            }
                break;
            case SKPaymentTransactionStateRestored://已经购买过该商品
            {
                if (self.delegate !=nil && [self.delegate respondsToSelector:@selector(KXInAppPurchase:didHadPurchased:)]) {
                    [self.delegate KXInAppPurchase:self didHadPurchased:transaction];
                }
            }
                break;
            case SKPaymentTransactionStatePurchasing://商品添加进列表
            {
                if (self.delegate !=nil && [self.delegate respondsToSelector:@selector(KXInAppPurchase:didAddList:)]) {
                    [self.delegate KXInAppPurchase:self didAddList:transaction];
                }
            }
                break;
            default:
                break;
        }
    }
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    if (self.delegate !=nil && [self.delegate respondsToSelector:@selector(KXInAppPurchase:didPurchasedQueueSuccess:)]) {
        [self.delegate KXInAppPurchase:self didPurchasedQueueSuccess:queue];
    }
    
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
    if (self.delegate !=nil && [self.delegate respondsToSelector:@selector(KXInAppPurchase:didPurchasedQueueFail:withError:)]) {
        [self.delegate KXInAppPurchase:self didPurchasedQueueFail:queue withError:error];
    }
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    if (self.delegate !=nil && [self.delegate respondsToSelector:@selector(KXInAppPurchase:didFailWithError:)]) {
        [self.delegate KXInAppPurchase:self didFailWithError:error];
    }
}


- (void)dealloc {
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

@end

