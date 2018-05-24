//
//  IFAFormatterTextField.m
//  TextFieldFormatter
//
//  Created by fx on 2018/5/24.
//  Copyright © 2018年 fx. All rights reserved.
//

#import "IFAFormatterTextField.h"
#import "MessageInterceptor.h"

@interface IFAFormatterTextField ()<UITextFieldDelegate>
{
    MessageInterceptor * delegateInterceptor;
}
@property (nonatomic,strong)NSArray *blankLocations;

@property (nonatomic,assign,getter=isFormatter)BOOL formatter;

@property (nonatomic, strong) UIButton *XButton;
@property (nonatomic, assign) BOOL willShowKeyboard;
@property (nonatomic, assign) BOOL displayingKeyboard;
@property (nonatomic, strong) NSNotification *notification;
@end

@implementation IFAFormatterTextField
- (NSString *)textWithSpace:(BOOL)space
{
    if (space) {
        return self.text;
    }else{
        return [self.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
}

- (id)delegate
{
    return delegateInterceptor.receiver;
}
- (void)setDelegate:(id<UITextFieldDelegate>)delegate
{
    if(delegateInterceptor) {
        super.delegate = nil;
        delegateInterceptor.receiver = delegate;
        super.delegate = (id)delegateInterceptor;
    }
    else {
        super.delegate = delegate;
    }
}

- (void)dealloc {
    self.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initPro];
    }
    return self;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    [self initPro];
}

- (void)initPro{
    delegateInterceptor = [[MessageInterceptor alloc] initWithInterceptedProtocol:@protocol(UITextFieldDelegate)];
    delegateInterceptor.middleMan = self;
    delegateInterceptor.receiver = self.delegate;
    super.delegate = (id)delegateInterceptor;
    
    self.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.maxLength = 20;
    self.formatter = NO;
}

- (void)setType:(IFAFormatterTextFieldType)type{
    _type = type;
    if (type == IFAFormatterTextFieldTypeNumber) {
        self.keyboardType = UIKeyboardTypeNumberPad;
    }else if (type == IFAFormatterTextFieldTypeASCII) {
        self.keyboardType = UIKeyboardTypeASCIICapable;
    }
}

- (void)setFormaterType:(IFAFormatterTextFieldFormatterType)formaterType{
    _formaterType = formaterType;
    if (formaterType == IFAFormatterTextFieldFormatterTypeNone) {
        self.keyboardType = UIKeyboardTypeASCIICapable;
        self.formatter = NO;
    }else if (formaterType == IFAFormatterTextFieldFormatterTypePhone) {
        self.keyboardType = UIKeyboardTypeNumberPad;
        self.maxLength = 11;
        self.formatter = YES;
        self.blankLocations = @[@3,@8];
    }else if (formaterType == IFAFormatterTextFieldFormatterTypeIDCard) {
        self.keyboardType = UIKeyboardTypeNumberPad;
        self.maxLength = 18;
        self.formatter = NO;
        [self configX];
    }else if (formaterType == IFAFormatterTextFieldFormatterTypeBankCard) {
        self.keyboardType = UIKeyboardTypeNumberPad;
        self.maxLength = 19;
        self.formatter = YES;
        self.blankLocations = @[@4,@9,@14,@19];//@24
    }
}

#pragma mark -- UITextField Delegate ---
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *text = textField.text;
    if ([string isEqualToString:@""]) {
        if (self.formatter) {
            if (range.length == 1) {
                if (range.location == text.length-1) {
                    return YES;
                } else {
                    NSInteger offset = range.location;
                    if (range.location < text.length && [text characterAtIndex:range.location] == ' ' && [textField.selectedTextRange isEmpty]) {
                        [textField deleteBackward];
                        offset --;
                    }
                    [textField deleteBackward];
                    
                    textField.text = [self refreshLayoutFormatter:textField.text];
                    [textField setSelectedRange:NSMakeRange(offset, 0)];
                    return NO;
                }
            } else if (range.length > 1) {
                BOOL lastOne = NO;
                if (range.location + range.length == text.length) {
                    lastOne = YES;
                }
                [textField deleteBackward];
                textField.text = [self refreshLayoutFormatter:textField.text];
                NSInteger offset = range.location;
                
                if (lastOne) {
                } else {
                    [textField setSelectedRange:NSMakeRange(offset, 0)];
                }
                return NO;
            } else {
                return YES;
            }
        }else{
            return YES;
        }
    }else if(string.length > 0){
        
        if (self.isFormatter) {
            if (_maxLength) {
                if ([self removeBlankString:text].length + string.length - range.length > _maxLength ) {
                    return NO;
                }
            }
            
            BOOL access = [self checkoutInsertString:string];
            if (!access) {
                return NO;
            }
            
            
            text = textField.text;
            NSInteger oldSpace=0;
            for(NSUInteger i=range.location; i<range.length; i++){
                unichar ch = [text characterAtIndex:i];
                if (ch==32) {
                    oldSpace++;
                }
            }
            
            [textField insertText:string];
            textField.text = [self refreshLayoutFormatter:textField.text];
            
            text = textField.text;
            NSInteger offset = range.location + string.length - range.length;
            if (offset<=0) {
                offset = range.location;
            }
            
            NSInteger newSpace=0;
            for(NSUInteger i=range.location; i<offset; i++){
                unichar ch = [text characterAtIndex:i];
                if (ch==32) {
                    newSpace++;
                }
            }
            offset+=(newSpace-oldSpace);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [textField setSelectedRange:NSMakeRange(offset, 0)];
            });
            return NO;
        }else{
            if ([self removeBlankString:text].length + string.length - range.length > _maxLength ) {
                return NO;
            }else{
                BOOL access = [self checkoutInsertString:string];
                if (!access) {
                    return NO;
                }
                return YES;
            }
        }
    }else{
        return YES;
    }
}

#pragma mark --- private method ----
- (BOOL)checkoutInsertString:(NSString *)string{
    NSCharacterSet *set = nil;
    if (_formaterType == IFAFormatterTextFieldFormatterTypePhone || _formaterType ==  IFAFormatterTextFieldFormatterTypeBankCard) {
        set = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
    }else if(_formaterType == IFAFormatterTextFieldFormatterTypeIDCard){
        set = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789X"] invertedSet];
    }else if(_formaterType == IFAFormatterTextFieldFormatterTypeNone){
        if (_type == IFAFormatterTextFieldTypeNumber) {
            set = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
        }else if(_type == IFAFormatterTextFieldTypeASCII) {
            set = [[NSCharacterSet alphanumericCharacterSet] invertedSet];//数字和字母(大小写)
        }
    }

    BOOL access = YES;
    if (set) {
        NSRange range;
        for(int i=0; i<string.length; i+=range.length){
            range = [string rangeOfComposedCharacterSequenceAtIndex:i];
            NSString *sub = [string substringWithRange:range];
            if ([[sub componentsSeparatedByCharactersInSet:set] componentsJoinedByString:@""].length) {
                NSLog(@"sub = %@",sub);
            }else{
                access=NO;
                break;
            }
        }
        return access;
    }else{
        return YES;
    }
}

- (NSString *)refreshLayoutFormatter:(NSString*)text{
    if (!text) {
        return nil;
    }
    NSMutableString* mutableString = [NSMutableString stringWithString:[text stringByReplacingOccurrencesOfString:@" " withString:@""]];
    for (NSNumber *location in _blankLocations) {
        if (mutableString.length > location.integerValue) {
            [mutableString insertString:@" " atIndex:location.integerValue];
        }
    }
    return  mutableString;
}

- (NSString *)removeBlankString:(NSString*)string {
    return [string stringByReplacingOccurrencesOfString:@" " withString:@""];
}


#pragma mark ----  X -----
#define iPhoneX ([UIScreen mainScreen].bounds.size.height == 812)
- (void)configX{
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeginShow:) name:UITextFieldTextDidBeginEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillEndShow:) name:UITextFieldTextDidEndEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillBeginShow:(NSNotification *)notification {
    if (self.keyboardType != UIKeyboardTypeNumberPad) return;
    self.willShowKeyboard = notification.object == self;
    if (self.willShowKeyboard) {
        if (@available(iOS 11.0, *)) {
            if (self.notification) {
                [self setupDownKey];}
        }
        if ([[[UIDevice currentDevice] systemVersion] floatValue] < 9.0) {
            if (self.notification) {
                [self setupDownKey];
            }
        }
    }
}

- (void)keyboardWillEndShow:(NSNotification *)notification {
    if (self.keyboardType != UIKeyboardTypeNumberPad) return;
    self.willShowKeyboard = NO;
    
    NSDictionary *userInfo = [notification userInfo];
    CGFloat animationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    NSInteger animationCurve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    self.XButton.transform = CGAffineTransformIdentity;
    [self.XButton removeFromSuperview];
    [UIView commitAnimations];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    if (self.keyboardType != UIKeyboardTypeNumberPad) return;
    UIWindow *tempWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:1];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0) {
        tempWindow = [[[UIApplication sharedApplication] windows] lastObject];
    }
    self.notification = notification;
    [self setupDownKey];
}

- (void)setupDownKey {
    if (!self.willShowKeyboard) {
        self.displayingKeyboard = YES;
        return;
    }
    [self.XButton removeFromSuperview];
    self.XButton = nil;
    
    NSDictionary *userInfo = [self.notification userInfo];
        CGFloat animationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGRect kbEndFrame = [self.notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat kbHeight = kbEndFrame.size.height;
    NSInteger animationCurve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    CGFloat XButtonX = 0;
    CGFloat XButtonW = 0;
    CGFloat XButtonH = 0;
    if ([UIScreen mainScreen].bounds.size.width == 320) {
        XButtonW = ([UIScreen mainScreen].bounds.size.width - 6) / 3;
        XButtonH = (kbHeight - 2) / 4;
    } else if ([UIScreen mainScreen].bounds.size.width == 375) {
        XButtonW = ([UIScreen mainScreen].bounds.size.width - 8) / 3;
        XButtonH = (kbHeight - 2) / 4;
    } else if ([UIScreen mainScreen].bounds.size.width == 414) {
        XButtonW = ([UIScreen mainScreen].bounds.size.width - 7) / 3;
        XButtonH = kbHeight / 4;
    }
    CGFloat XButtonY = 0;
    if (self.displayingKeyboard) {
        XButtonY = [UIScreen mainScreen].bounds.size.height - XButtonH;
    } else {
        XButtonY = [UIScreen mainScreen].bounds.size.height + kbHeight - XButtonH;
    }
    if (iPhoneX) {
        XButtonH = (kbHeight - 75 - 2) / 4;
        if (self.displayingKeyboard) {
            XButtonY = [UIScreen mainScreen].bounds.size.height - XButtonH;
        } else {
            XButtonY = [UIScreen mainScreen].bounds.size.height + kbHeight - XButtonH;
        }
        XButtonY -= 75;
    }
    UIButton *XButton = [[UIButton alloc] initWithFrame:CGRectMake(XButtonX, XButtonY, XButtonW, XButtonH)];
    
    XButton.titleLabel.font = [UIFont systemFontOfSize:27];
    [XButton setTitle:@"X" forState:(UIControlStateNormal)];
    [XButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    if (@available(iOS 11.0, *)) {
        if (self.displayingKeyboard) {
            XButton.alpha = 0.0;
            [UIView animateWithDuration:0.1 animations:^{
                XButton.alpha = 1.0;
            }];
        }
    } else {
        [XButton setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forState:UIControlStateHighlighted];
    }
    [XButton addTarget:self action:@selector(XButton:) forControlEvents:UIControlEventTouchUpInside];
    self.XButton = XButton;
    
    UIWindow *tempWindow = tempWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:1];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0) {
        tempWindow = [[[UIApplication sharedApplication] windows] lastObject];
    }
    
    [tempWindow addSubview:XButton];
    
    if (!self.displayingKeyboard) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:animationDuration];
        [UIView setAnimationCurve:animationCurve];
        XButton.transform = CGAffineTransformTranslate(XButton.transform, 0, -kbHeight);
        [UIView commitAnimations];
    }
    self.displayingKeyboard = YES;
}

- (void)keyboardWillHide:(NSNotification *)notification {
    if (self.keyboardType != UIKeyboardTypeNumberPad) return;
    self.displayingKeyboard = NO;
    self.notification = nil;
}

- (void)XButton:(UIButton *)XButton{
    NSUInteger insertIndex = [self selectedRange].location;
    
    if ([self.delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
        BOOL allowChange = [self.delegate textField:self shouldChangeCharactersInRange:NSMakeRange(insertIndex, 0) replacementString:XButton.currentTitle];
        if (!allowChange) {
            return;
        }
    }
    
    NSMutableString *string = [NSMutableString stringWithString:self.text];
    [string replaceCharactersInRange:self.selectedRange withString:XButton.currentTitle];
    
    self.text = string;
    [self setSelectedRange:NSMakeRange(insertIndex + 1, 0)];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[UIDevice currentDevice] playInputClick];
    });
}
@end



@implementation UITextField (fx_category)
- (NSRange)selectedRange {
    UITextPosition *beginning = self.beginningOfDocument;
    UITextRange *selectedRange = self.selectedTextRange;
    UITextPosition *selectionStart = selectedRange.start;
    UITextPosition *selectionEnd = selectedRange.end;
    
    const NSInteger location = [self offsetFromPosition:beginning toPosition:selectionStart];
    const NSInteger length = [self offsetFromPosition:selectionStart toPosition:selectionEnd];
    return NSMakeRange(location, length);
}
- (void)setSelectedRange:(NSRange)range
{
    UITextPosition *beginning = self.beginningOfDocument;
    UITextPosition *startPosition = [self positionFromPosition:beginning offset:range.location];
    UITextPosition *endPosition = [self positionFromPosition:beginning offset:range.location + range.length];
    
    UITextRange *selectionRange = [self textRangeFromPosition:startPosition toPosition:endPosition];
    [self setSelectedTextRange:selectionRange];
}
@end
@implementation UIImage (fx_catogory)
+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}
@end
