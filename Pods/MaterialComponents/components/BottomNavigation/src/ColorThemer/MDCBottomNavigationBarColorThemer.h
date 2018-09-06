/*
 Copyright 2017-present the Material Components for iOS authors. All Rights Reserved.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "MaterialColorScheme.h"
#import "MaterialBottomNavigation.h"

/**
 The Material Design color system's themer for instances of MDCBottomNavigationBar.
 */
@interface MDCBottomNavigationBarColorThemer : NSObject

/**
 Applies a color scheme's properties to an MDCBottomNavigationBar.

 @param colorScheme The color scheme to apply to the component instance.
 @param bottomNavigation A component instance to which the color scheme should be applied.
 */
+ (void)applySemanticColorScheme:(nonnull id<MDCColorScheming>)colorScheme
              toBottomNavigation:(nonnull MDCBottomNavigationBar *)bottomNavigation;

@end

@interface MDCBottomNavigationBarColorThemer (ToBeDeprecated)

/**
 Applies a color scheme to theme a MDCBottomNavigationBar.

 @warning This method will soon be deprecated. Consider using
 @c +applySemanticColorScheme:toBottomNavigation: instead. Learn more at
 components/schemes/Color/docs/migration-guide-semantic-color-scheme.md

 @param colorScheme The color scheme to apply to MDCBottomNavigationBar.
 @param bottomNavigationBar A MDCBottomNavigationBar instance to apply a color scheme.
 */
+ (void)applyColorScheme:(nonnull id<MDCColorScheme>)colorScheme
    toBottomNavigationBar:(nonnull MDCBottomNavigationBar *)bottomNavigationBar;

@end