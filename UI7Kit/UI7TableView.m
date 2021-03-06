//
//  UI7TableView.m
//  FoundationExtension
//
//  Created by Jeong YunWon on 13. 6. 12..
//  Copyright (c) 2013 youknowone.org. All rights reserved.
//

#import "UI7Font.h"
#import "UI7Color.h"

#import "UI7TableView.h"

CGFloat UI7TableViewGroupedTableSectionSeperatorHeight = 28.0f;

@implementation UITableView (Patch)

- (id)__initWithCoder:(NSCoder *)aDecoder { assert(NO); return nil; }
- (id)__initWithFrame:(CGRect)frame { assert(NO); return nil; }
- (void)__setDelegate:(id<UITableViewDelegate>)delegate { assert(NO); return; }
- (UITableViewStyle)__style { assert(NO); return 0; }

- (void)_tableViewInit {

}

- (void)awakeFromNib { }

- (id)__dequeueReusableCellWithIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath {
    return [self dequeueReusableCellWithIdentifier:identifier];
}

@end


//@implementation NSCoder (UI7TableView)
//
//- (NSInteger)__decodeIntegerForKey:(NSString *)key { assert(NO); }
//
//- (NSInteger)_UI7TableView_decodeIntegerForKey:(NSString *)key {
//    if ([key isEqualToString:@"UIStyle"]) {
//        return (NSInteger)UITableViewStylePlain;
//    }
//    return [self __decodeIntegerForKey:key];
//}
//
//@end


@protocol UI7TableViewDelegate

- (UIView *)__tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;
- (UIView *)__tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section;
- (CGFloat)__tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
- (CGFloat)__tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section;

@end


@implementation UI7TableView

// TODO: implement 'setAccessoryType' to fake accessories.

UIColor *UI7TableViewGroupedViewPatternColor = nil;

+ (void)initialize {
    if (self == [UI7TableView class]) {
        Class target = [UITableView class];

        [target copyToSelector:@selector(__initWithCoder:) fromSelector:@selector(initWithCoder:)];
        [target copyToSelector:@selector(__initWithFrame:) fromSelector:@selector(initWithFrame:)];
        [target copyToSelector:@selector(__setDelegate:) fromSelector:@selector(setDelegate:)];
        [target copyToSelector:@selector(__style) fromSelector:@selector(style)];
    }
}

+ (void)patch {
    Class target = [UITableView class];

    [self exportSelector:@selector(initWithCoder:) toClass:target];
    [self exportSelector:@selector(initWithFrame:) toClass:target];
    [self exportSelector:@selector(awakeFromNib) toClass:target];
    [self exportSelector:@selector(setDelegate:) toClass:target];
    [self exportSelector:@selector(style) toClass:target];

    if (![target methodForSelector:@selector(dequeueReusableCellWithIdentifier:forIndexPath:)]) {
        [target addMethodForSelector:@selector(dequeueReusableCellWithIdentifier:forIndexPath:) fromMethod:[self methodForSelector:@selector(__dequeueReusableCellWithIdentifier:forIndexPath:)]];
    }
}

- (id)initWithCoder:(NSCoder *)aDecoder {
//    UITableViewStyle style = UITableViewStylePlain;
//    if ([aDecoder containsValueForKey:@"UIStyle"]) {
//        style = [aDecoder decodeIntegerForKey:@"UIStyle"];
//        if (style == UITableViewStyleGrouped) {
//            NSAMethod *decode = [aDecoder.class methodForSelector:@selector(decodeIntegerForKey:)];
//            [aDecoder.class methodForSelector:@selector(__decodeIntegerForKey:)].implementation = decode.implementation;
//            decode.implementation = [aDecoder.class methodForSelector:@selector(_UI7TableView_decodeIntegerForKey:)].implementation;
//        }
//    }
    self = [self __initWithCoder:aDecoder];
//    if (style == UITableViewStyleGrouped) {
//        NSAMethod *decode = [aDecoder.class methodForSelector:@selector(decodeIntegerForKey:)];
//        decode.implementation = [aDecoder.class methodImplementationForSelector:@selector(__decodeIntegerForKey:)];
//        if (self) {
//            [UI7TableViewStyleIsGrouped setObject:@(YES) forKey:self.pointerString];
//        }
//    }
    if (self) {
        if (self.__style == UITableViewStyleGrouped) {
            if (UI7TableViewGroupedViewPatternColor == nil) {
                UI7TableViewGroupedViewPatternColor = [[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped] autorelease].backgroundColor;
            }
            UIColor *color = [aDecoder decodeObjectForKey:@"UIBackgroundColor"];
            if (color == UI7TableViewGroupedViewPatternColor) {
                self.backgroundColor = [UI7Color groupedTableViewSectionBackgroundColor];
            }

            self.backgroundView = nil;
            if (self.separatorStyle == UITableViewCellSeparatorStyleSingleLineEtched) {
                self.separatorStyle = UITableViewCellSeparatorStyleNone;
            }
        }
        [self _tableViewInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [self __initWithFrame:frame];
    if (self) {
        [self _tableViewInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    self = [self __initWithFrame:frame];
    if (self) {
//        [UI7TableViewStyleIsGrouped setObject:@(YES) forKey:self.pointerString];
        [self _tableViewInit];
    }
    return self;
}

- (void)awakeFromNib {
    if (self.__style == UITableViewStyleGrouped && self.superview == nil && [self.backgroundColor isEqual:[UIColor clearColor]]) {
        self.backgroundColor = [UIColor whiteColor];
    }
}

- (UITableViewStyle)style {
    return UITableViewStylePlain;
}

CGFloat _UI7TableViewDelegateNoHeightForHeaderFooterInSection(id self, SEL _cmd, UITableView *tableView, NSUInteger section) {
    return -1.0f;
}

CGFloat _UI7TableViewDelegateHeightForHeaderInSection(id self, SEL _cmd, UITableView *tableView, NSUInteger section) {
    CGFloat height = [self __tableView:tableView heightForHeaderInSection:section];
    if (height != -1.0f) {
        return height;
    }
    height = .0f;
    NSString *title = [tableView.dataSource tableView:tableView titleForHeaderInSection:section];
//    if ([UI7TableViewStyleIsGrouped containsKey:tableView.pointerString]) {
    if (tableView.__style == UITableViewStyleGrouped) {
        if (title.length > 0) {
            height = UI7TableViewGroupedTableSectionSeperatorHeight + 20.0f;
        } else {
            height = UI7TableViewGroupedTableSectionSeperatorHeight;
        }
    } else {
        if (title.length > 0) {
            height = tableView.sectionHeaderHeight;
        }
    }
    return height;
}

CGFloat _UI7TableViewDelegateHeightForFooterInSection(id self, SEL _cmd, UITableView *tableView, NSUInteger section) {
    CGFloat height = [self __tableView:tableView heightForFooterInSection:section];
    if (height != -1.0f) {
        return height;
    }
    NSString *title = [tableView.dataSource tableView:tableView titleForFooterInSection:section];
    if (title.length > 0) {
        if (tableView.__style == UITableViewStyleGrouped) {
            return 25.0;
        }
        return tableView.sectionFooterHeight;
    }
    return .0;
}

UIView *_UI7TableViewDelegateNilViewForHeaderFooterInSection(id self, SEL _cmd, UITableView *tableView, NSUInteger section) {
    return nil;
}

UIView *_UI7TableViewDelegateViewForHeaderInSection(id self, SEL _cmd, UITableView *tableView, NSUInteger section) {
    UIView *view = [self __tableView:tableView viewForHeaderInSection:section];
    if (view) {
        return view;
    }
    BOOL grouped = tableView.__style == UITableViewStyleGrouped;
    CGFloat height = [tableView.delegate tableView:tableView heightForHeaderInSection:section];
    NSString *title = [tableView.dataSource tableView:tableView titleForHeaderInSection:section];
    if (title == nil) {
        if (grouped) {
            UIView *header = [[[UIView alloc] initWithFrame:CGRectMake(.0, .0, tableView.frame.size.width, UI7TableViewGroupedTableSectionSeperatorHeight)] autorelease];
            header.backgroundColor = [UI7Color groupedTableViewSectionBackgroundColor];
            return header;
        } else {
            return [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
        }
    }

    CGFloat groupHeight = grouped ? UI7TableViewGroupedTableSectionSeperatorHeight : .0f;
    UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(.0, groupHeight, tableView.frame.size.width, height - groupHeight)] autorelease];

    if (grouped) {
        label.text = [@"   " stringByAppendingString:[title uppercaseString]];
        label.font = [UI7Font systemFontOfSize:14.0 attribute:UI7FontAttributeNone];
        label.textColor = [UIColor colorWith8bitWhite:77 alpha:255];
        label.backgroundColor = [UI7Color groupedTableViewSectionBackgroundColor];
    } else {
        label.text = [@"    " stringByAppendingString:title];
        label.font = [UI7Font systemFontOfSize:14.0 attribute:UI7FontAttributeMedium];
        label.backgroundColor = [UIColor colorWith8bitRed:248 green:248 blue:248 alpha:255];
    }

    if (grouped) {
        view = [[[UIView alloc] initWithFrame:CGRectMake(.0, .0, tableView.frame.size.width, height)] autorelease];
        [view addSubview:label];
        view.backgroundColor = label.backgroundColor;
    } else {
        view = label;
    }
    return view;
}

UIView *_UI7TableViewDelegateViewForFooterInSection(id self, SEL _cmd, UITableView *tableView, NSUInteger section) {
    UIView *view = [self __tableView:tableView viewForFooterInSection:section];
    if (view) {
        return view;
    }
    CGFloat height = [tableView.delegate tableView:tableView heightForFooterInSection:section];
    NSString *title = [tableView.dataSource tableView:tableView titleForFooterInSection:section];
    if (title == nil) {
        return [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    }
    
    UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(.0, .0, tableView.frame.size.width, height)] autorelease];
    if (tableView.__style == UITableViewStyleGrouped) {
        label.text = [@"   " stringByAppendingString:title];
        label.font = [UI7Font systemFontOfSize:14.0 attribute:UI7FontAttributeNone];
        label.textColor = [UIColor colorWith8bitWhite:128 alpha:255];
        label.backgroundColor = [UI7Color groupedTableViewSectionBackgroundColor];
    } else {
        label.text = [@"    " stringByAppendingString:title]; // TODO: do this pretty later
        label.font = [UI7Font systemFontOfSize:14.0 attribute:UI7FontAttributeMedium];
        label.backgroundColor = [UIColor colorWith8bitRed:248 green:248 blue:248 alpha:255];
    }
    return label;
}

- (void)setDelegate:(id<UITableViewDelegate>)delegate {
    if (self.delegate) {
//        Class delegateClass = [(NSObject *)self.delegate class];
//        if ([delegateClass methodImplementationForSelector:@selector(tableView:viewForHeaderInSection:)] == (IMP)UI7TableViewDelegateViewForHeaderInSection) {
//            // TODO: probably we should remove this methods.
//            //            class_removeMethods(￼, ￼)
//        }
    }
    if (delegate) {
        Class delegateClass = [(NSObject *)delegate class];
        if ([self.dataSource respondsToSelector:@selector(tableView:titleForHeaderInSection:)]) {
            if ([delegate respondsToSelector:@selector(tableView:viewForHeaderInSection:)]) {
                if (![delegateClass methodForSelector:@selector(__tableView:viewForHeaderInSection:)]) {
                    [delegateClass addMethodForSelector:@selector(__tableView:viewForHeaderInSection:) fromMethod:[delegateClass methodForSelector:@selector(tableView:viewForHeaderInSection:)]];
                    [delegateClass addMethodForSelector:@selector(tableView:viewForHeaderInSection:) implementation:(IMP)_UI7TableViewDelegateViewForHeaderInSection types:@"@16@0:4@8i12"];
                    [delegateClass methodForSelector:@selector(tableView:viewForHeaderInSection:)].implementation = (IMP)_UI7TableViewDelegateViewForHeaderInSection;
                }
            } else {
                [delegateClass addMethodForSelector:@selector(__tableView:viewForHeaderInSection:) implementation:(IMP)_UI7TableViewDelegateNilViewForHeaderFooterInSection types:@"@16@0:4@8i12"];
                [delegateClass addMethodForSelector:@selector(tableView:viewForHeaderInSection:) implementation:(IMP)_UI7TableViewDelegateViewForHeaderInSection types:@"@16@0:4@8i12"];
            }
            if ([delegate respondsToSelector:@selector(tableView:heightForHeaderInSection:)]) {
                if (![delegateClass methodForSelector:@selector(__tableView:heightForHeaderInSection:)]) {
                    [delegateClass addMethodForSelector:@selector(__tableView:heightForHeaderInSection:) fromMethod:[delegateClass methodForSelector:@selector(tableView:heightForHeaderInSection:)]];
                    [delegateClass addMethodForSelector:@selector(tableView:heightForHeaderInSection:) implementation:(IMP)_UI7TableViewDelegateHeightForHeaderInSection types:@"@16@0:4@8i12"];
                    [delegateClass methodForSelector:@selector(tableView:heightForHeaderInSection:)].implementation = (IMP)_UI7TableViewDelegateHeightForHeaderInSection;
                }
            } else {
                [delegateClass addMethodForSelector:@selector(__tableView:heightForHeaderInSection:) implementation:(IMP)_UI7TableViewDelegateNoHeightForHeaderFooterInSection types:@"f16@0:4@8i12"];
                [delegateClass addMethodForSelector:@selector(tableView:heightForHeaderInSection:) implementation:(IMP)_UI7TableViewDelegateHeightForHeaderInSection types:@"f16@0:4@8i12"];
            }
        }
        if ([self.dataSource respondsToSelector:@selector(tableView:titleForFooterInSection:)]) {
            if ([delegate respondsToSelector:@selector(tableView:viewForFooterInSection:)]) {
                if (![delegateClass methodForSelector:@selector(__tableView:viewForFooterInSection:)]) {
                    [delegateClass addMethodForSelector:@selector(__tableView:viewForFooterInSection:) fromMethod:[delegateClass methodForSelector:@selector(tableView:viewForFooterInSection:)]];
                    [delegateClass addMethodForSelector:@selector(tableView:viewForFooterInSection:) implementation:(IMP)_UI7TableViewDelegateViewForFooterInSection types:@"@16@0:4@8i12"];
                    [delegateClass methodForSelector:@selector(tableView:viewForFooterInSection:)].implementation = (IMP)_UI7TableViewDelegateViewForFooterInSection;
                }
            } else {
                [delegateClass addMethodForSelector:@selector(__tableView:viewForFooterInSection:) implementation:(IMP)_UI7TableViewDelegateNilViewForHeaderFooterInSection types:@"@16@0:4@8i12"];
                [delegateClass addMethodForSelector:@selector(tableView:viewForFooterInSection:) implementation:(IMP)_UI7TableViewDelegateViewForFooterInSection types:@"@16@0:4@8i12"];
            }
            if ([delegate respondsToSelector:@selector(tableView:heightForFooterInSection:)]) {
                if (![delegateClass methodForSelector:@selector(__tableView:heightForFooterInSection:)]) {
                    [delegateClass addMethodForSelector:@selector(__tableView:heightForFooterInSection:) fromMethod:[delegateClass methodForSelector:@selector(tableView:heightForFooterInSection:)]];
                    [delegateClass addMethodForSelector:@selector(tableView:heightForFooterInSection:) implementation:(IMP)_UI7TableViewDelegateHeightForFooterInSection types:@"f16@0:4@8i12"];
                    [delegateClass methodForSelector:@selector(tableView:heightForFooterInSection:)].implementation = (IMP)_UI7TableViewDelegateHeightForFooterInSection;
                }
            } else {
                [delegateClass addMethodForSelector:@selector(__tableView:heightForFooterInSection:) implementation:(IMP)_UI7TableViewDelegateNoHeightForHeaderFooterInSection types:@"f16@0:4@8i12"];
                [delegateClass addMethodForSelector:@selector(tableView:heightForFooterInSection:) implementation:(IMP)_UI7TableViewDelegateHeightForFooterInSection types:@"f16@0:4@8i12"];
            }
        }
    }
    [self __setDelegate:delegate];
}

// TODO: ok.. do this next time.
//- (BOOL)_delegateWantsHeaderViewForSection:(NSUInteger)section {
//    return YES;
//}
//
//- (BOOL)_delegateWantsHeaderTitleForSection:(NSUInteger)section {
//    return YES;
//}
//
//- (UITableViewHeaderFooterView *)headerViewForSection:(NSInteger)section {
//    UITableViewHeaderFooterView *view = [super headerViewForSection:section];
//    
//    return view;
//}

@end


@interface UITableViewCell (Private)

- (void)setTableViewStyle:(int)style;
- (void)_setTableBackgroundCGColor:(CGColorRef)color withSystemColorName:(id)name;

@end


@implementation UITableViewCell (Patch)

- (id)__initWithCoder:(NSCoder *)aDecoder { assert(NO); return nil; }
- (id)__initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier { assert(NO); return nil; }
- (void)__setBackgroundColor:(UIColor *)backgroundColor { assert(NO); }
- (void)__setTableViewStyle:(int)style { assert(NO); }

- (void)_tableViewCellInitTheme {
    self.textLabel.font = [UI7Font systemFontOfSize:self.textLabel.font.pointSize attribute:UI7FontAttributeLight];
    self.detailTextLabel.font = [UI7Font systemFontOfSize:self.detailTextLabel.font.pointSize attribute:UI7FontAttributeNone];
}

- (void)_tableViewCellInit {
    self.textLabel.highlightedTextColor = self.textLabel.textColor;
    self.detailTextLabel.highlightedTextColor = self.detailTextLabel.textColor; // FIXME: not sure
    self.backgroundView = [[[UIView alloc] init] autorelease];
    self.selectedBackgroundView = [[[UIView alloc] init] autorelease];
    self.selectedBackgroundView.backgroundColor = [UIColor colorWith8bitWhite:217 alpha:255];
    self.textLabel.backgroundColor = [UIColor clearColor];
    self.detailTextLabel.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor whiteColor];
}

@end


@implementation UI7TableViewCell

+ (void)initialize {
    if (self == [UI7TableViewCell class]) {
        Class target = [UITableViewCell class];

        [target copyToSelector:@selector(__initWithCoder:) fromSelector:@selector(initWithCoder:)];
        [target copyToSelector:@selector(__initWithStyle:reuseIdentifier:) fromSelector:@selector(initWithStyle:reuseIdentifier:)];
        [target copyToSelector:@selector(__setBackgroundColor:) fromSelector:@selector(setBackgroundColor:)];
        [target copyToSelector:@selector(__setTableViewStyle:) fromSelector:@selector(setTableViewStyle:)];
    }
}

+ (void)patch {
    Class target = [UITableViewCell class];

    [self exportSelector:@selector(initWithCoder:) toClass:target];
    [self exportSelector:@selector(initWithStyle:reuseIdentifier:) toClass:target];
    [self exportSelector:@selector(setBackgroundColor:) toClass:target];
    [self exportSelector:@selector(setTableViewStyle:) toClass:target];
    [self exportSelector:@selector(_setTableBackgroundCGColor:withSystemColorName:) toClass:target];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [self __initWithCoder:aDecoder];
    if (self != nil) {
        UIColor *backgroundColor = [aDecoder decodeObjectForKey:@"UIBackgroundColor"];
        [self _tableViewCellInit];
        if (backgroundColor) {
            self.backgroundColor = backgroundColor;
        }
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [self __initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self != nil) {
        [self _tableViewCellInitTheme]; // not adjusted now
        [self _tableViewCellInit];
    }
    return self;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [self __setBackgroundColor:backgroundColor];
    self.backgroundView.backgroundColor = backgroundColor;
}

- (void)setTableViewStyle:(int)style {
    UIColor *backgroundColor = self.backgroundColor;
    [self __setTableViewStyle:style];
    self.backgroundColor = backgroundColor;
}

- (void)_setTableBackgroundCGColor:(CGColorRef)color withSystemColorName:(id)name {

}

@end


@implementation UI7TableViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    return self;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CGFloat height = [super tableView:tableView heightForHeaderInSection:section];
    return height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [super tableView:tableView viewForHeaderInSection:section];
    return view;
}

@end
