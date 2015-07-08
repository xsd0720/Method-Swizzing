//
//  UIViewController+MRCUMAnalytics.m
//  aaa
//
//  Created by wany on 15/7/8.
//  Copyright (c) 2015年 wany. All rights reserved.
//

//  官方文档types详细的说明地址(https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html#//apple_ref/doc/uid/TP40008048-CH100-SW1),
/*
 
 
 为啥要用Method swizzled
 例如要做统计 ，可以项目中每个viewWillAppear 中都要添加统计的代码, 如果界面多的话，那么就会产生大量的冗余代码
 所以就诞生了Method swizzled，我们希望在执行系统viewWillAppear的时候自动执行我们自定义的方法mrc_viewWillAppear
 
 一个category 就搞定了，不用建一个父类去写这些东西，也不用一个一个界面的viewWillAppear 去写统计代码
 
 
 */

#import "UIViewController+MRCUMAnalytics.h"
#import <objc/runtime.h>
@implementation UIViewController (MRCUMAnalytics)
+(void)load{
    static dispatch_once_t onceToken;
    
    
    /*
     +load 方法在类加载的时候会被 runtime 自动调用一次，但是它并没有限制程序员对 +load 方法的手动调用。什么？你说不会有程序员这么干？那可说不定，我还见过手动调用 viewDidLoad 方法的程序员，就是介么任性。而我们所能够做的就是尽可能地保证程序能够在各种情况下正常运行。
     */
    
    dispatch_once(&onceToken, ^{
        
        
        //        struct objc_method {
        //方法名
        //            SEL method_name                                          OBJC2_UNAVAILABLE;
        //方法参数
        //            char *method_types                                       OBJC2_UNAVAILABLE;
        //方法函数指针(oc 中调用方法名，通过IMP去查找方法，因为有了IMP 所以也就有了这个替换IMP 的Method swizzled)
        //            IMP method_imp                                           OBJC2_UNAVAILABLE;
        //        }
        
        //获取当前的类Class
        Class class = [self class];
        
        //创建方法名viewWillAppear:（注意是是方法名）
        SEL originalSelector = @selector(viewWillAppear:);
        //创建方法名mrc_viewWillAppear:
        SEL swizzledSelector = @selector(mrc_viewWillAppear:);
        
        
        /*
         Method class_getInstanceMethod(Class cls, SEL name)
         
         返回一个类实例方法（Method）
         参数cls:想要添加方法的类class
         参数name:想要添加的方法
         
         */
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        
        
        /*
         
         Bool class_addMethod(Class cls, SEL name, IMP imp, const char *types)
         返回添加是否成功(这可以通过注释下方的-(void)viewWillAppear:(BOOL)animated 方法查看效果，如果注释掉，返回成功，取消注释返回失败)
         参数cls: 想要添加方法的class，在这里就是[self class]，也就是当前ViewController 的class
         参数name: 要添加方法的方法名，方法名是唯一的，如果你在程序中写两个相同的方法名编译器是会报错的，就是这个原因，在这里我们要添加的方法是mrc_viewWillAppear
         参数imp: IMP 是什么?oc 中，当函数调用 (SEL name)中的name 的时候，真正执行的是imp所指向的方法，专业名字叫函数指针
         参数types:要添加的方法中的返回值,参数,官方文档有详细说明,本页最上面有地址,我这里简单说几个重要的,
         例如下面的一个方法
         int say(id self, SEL _cmd, NSString *str)
         {
         return 100;
         }
         如果要动态添加这个方法的参数列表,types 就应该这么写
         "i@:@"
         
         i：返回值类型int，若是v则表示void
         
         @：参数id(self)
         
         :：SEL(_cmd)
         
         @：id(str)
         还可以通过method_getTypeEncoding(Method m) 传入 Method 直接获取types
         通过  method_getImplementation(Method m) 传入Method 返回 改方法的IMP
         
         
         执行class_addMethod  方法 如果的当前类中存在这个方法名(originalSelector)就返回添加失败,为啥失败?因为一个类中不可能有两个相同的方法(完全相同，包括参数),如果改类中没有这个方法名(originalSelector) 就是添加成功
         
         */
        
        
        BOOL success = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
        if (success) {
            /*
             如果添加成功了,使用
             //替换方法名为 name 的IMP(替换方法名为name的函数实现或函数指针)，函数实现和函数指针其实是一个意识
             
             IMP class_replaceMethod(Class cls, SEL name, IMP imp,const char *types)
             
             返回值:-[ViewController mrc_viewWillAppear:] at ViewController.m:103),官方(The previous implementation of the method identified by name for the class identified by cls.),我也没弄明白这个
             参数cls:想要替换IMP的class，在这里就是[self class]，也就是当前ViewController 的class
             参数name:要替换IMP的方法名,这里是swizzledSelector
             参数IMP:要替换的IMP内容，使用method_getImplementation(originalMethod)获取IMP
             参数types 同上: 这里使用method_getTypeEncoding(originalMethod)  获取 originalMethod 的types
             
             */
            
            class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
            
            
            //            NSLog(@"%i",i);
        } else {
            /*
             如果添加失败了(说明当前类中已经存在viewwillapear 这个方法了)，使用method_exchangeImplementations 将两个方法的IMP 交换
             */
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
        
        
        
        /*
         补充一点，有同学可能会问,你这不就相当通过class_addMethod于给当前类添加一个名字是(viewWillAppear)IMP 是(mrc_viewWillAppear)的方法
         然后通过class_replaceMethod，把viewWillAppear 这个方法名的IMP 改成了viewWillAppear,为啥不能在直接在class_addMethod 的时候直接这样写
         
         class_addMethod(class, originalSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
         method_exchangeImplementations(originalMethod, swizzledMethod);
         
         
         如果当前类没有实现viewWillAppear这个方法，直接这么添加不行么？
         当然不行,如果这么写的话，viewWillAppear 这个方法是可以成功添加,但是swizzledMethod这个方法确一直没有被加到runtime中
         所以当执行viewWillAppear 这个方法时也就不会执行我们自定义mrc_viewWillAppear，也就到不到我们想要的效果,执行viewWillAppear 的时候同时执行 mrc_viewWillAppear
         
         */

        
    });
}
- (void)mrc_viewWillAppear:(BOOL)animated {
    /*
     诶,这里写[self mrc_viewWillAppear:animated]; 不就造成递归了么?
     难道你忘了，调用方法名，真正实现方法的跟这个方法名关联的IMP，而IMP  已经被我们改了，此时调用mrc_viewWillAppear 实际是调用viewWillAppear
     */
    
    
    [self mrc_viewWillAppear:animated];
    NSLog(@"mrc_viewWillAppear");
}

@end
