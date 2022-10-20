import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/constants/home_screen.config.dart';
import 'package:fuodz/models/user.dart';
import 'package:fuodz/services/auth.service.dart';
import 'package:fuodz/services/navigation.service.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/utils/utils.dart';
import 'package:fuodz/view_models/welcome.vm.dart';
import 'package:fuodz/views/pages/vendor/widgets/banners.view.dart';
import 'package:fuodz/widgets/cards/custom.visibility.dart';
import 'package:fuodz/widgets/custom_list_view.dart';
import 'package:fuodz/widgets/finance/wallet_management.view.dart';
import 'package:fuodz/widgets/list_items/vendor_type.list_item.dart';
import 'package:fuodz/widgets/list_items/vendor_type.vertical_list_item.dart';
import 'package:fuodz/widgets/states/loading.shimmer.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:masonry_grid/masonry_grid.dart';
import 'package:velocity_x/velocity_x.dart';

class EmptyWelcome extends StatelessWidget {
  const EmptyWelcome({this.vm, Key key}) : super(key: key);

  final WelcomeViewModel vm;
  @override
  Widget build(BuildContext context) {
    return Stack(
      key: vm.genKey,
      fit: StackFit.expand,
      children: [
        VxBox(
          child: SafeArea(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: !Utils.isArabic
                  ? Alignment.centerLeft
                  : Alignment.centerRight,
              child: VStack(
                [
                  //welcome intro and loggedin account name
                  StreamBuilder(
                    stream: AuthServices.listenToAuthState(),
                    builder: (ctx, snapshot) {
                      //
                      String introText = "Welcome".tr();
                      String fullIntroText = introText;
                      //
                      if (snapshot.hasData) {
                        return FutureBuilder<User>(
                            future: AuthServices.getCurrentUser(),
                            builder: (ctx, snapshot) {
                              if (snapshot.hasData) {
                                fullIntroText =
                                    "$introText ${snapshot.data.name}";
                              }
                              return fullIntroText.text.white.xl3.semiBold
                                  .make();
                            });
                      }
                      return fullIntroText.text.white.xl3.semiBold.make();
                    },
                  ),
                  //

                  "How can I help you today?".tr().text.white.xl.medium.make(),
                  UiSpacer.verticalSpace(),
                ],
              ).py12(),
            ),
          ),
        ).color(AppColor.primaryColor).p20.make().wFull(context).positioned(
              height: (context.percentHeight * 22),
              left: 0,
              right: 0,
              top: 0,
            ),

        //
        VStack(
          [
            //finance section
            CustomVisibilty(
              visible: HomeScreenConfig.showWalletOnHomeScreen ?? true,
              child: WalletManagementView().px20(),
            ),
            //
            //top banner
            CustomVisibilty(
              visible: HomeScreenConfig.showBannerOnHomeScreen &&
                  HomeScreenConfig.isBannerPositionTop,
              child: VStack(
                [
                  UiSpacer.verticalSpace(),
                  Banners(
                    null,
                    featured: true,
                  ).py12(),
                ],
              ),
            ),
            //
            VStack(
              [
                HStack(
                  [
                    "I want :".tr().text.xl.medium.make().expand(),
                    CustomVisibilty(
                      visible: HomeScreenConfig.isVendorTypeListingBoth,
                      child: Icon(
                        vm.showGrid
                            ? FlutterIcons.grid_fea
                            : FlutterIcons.list_fea,
                      ).p2().onInkTap(
                        () {
                          vm.showGrid = !vm.showGrid;
                          vm.notifyListeners();
                        },
                      ),
                    ),
                  ],
                  crossAlignment: CrossAxisAlignment.center,
                ).py4(),
                
                //list view
                CustomVisibilty(
                  visible: (HomeScreenConfig.isVendorTypeListingBoth &&
                          !vm.showGrid) ||
                      (!HomeScreenConfig.isVendorTypeListingBoth &&
                          HomeScreenConfig.isVendorTypeListingListView),
                  child: CustomListView(
                    noScrollPhysics: true,
                    dataSet: vm.vendorTypes,
                    isLoading: vm.isBusy,
                    loadingWidget: LoadingShimmer().px20(),
                    itemBuilder: (context, index) {
                      final vendorType = vm.vendorTypes[index];
                      return VendorTypeListItem(
                        vendorType,
                        onPressed: () {
                          NavigationService.pageSelected(vendorType,
                              context: context);
                        },
                      );
                    },
                    separatorBuilder: (context, index) => UiSpacer.emptySpace(),
                  ),
                ),
                //gridview
                CustomVisibilty(
                  visible: HomeScreenConfig.isVendorTypeListingGridView &&
                      vm.showGrid &&
                      vm.isBusy,
                  child: LoadingShimmer().px20().centered(),
                ),
                CustomVisibilty(
                  visible: HomeScreenConfig.isVendorTypeListingGridView &&
                      vm.showGrid &&
                      !vm.isBusy,
                  child: AnimationLimiter(
                    child: MasonryGrid(
                      column: HomeScreenConfig.vendorTypePerRow ?? 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      children: List.generate(
                        vm.vendorTypes.length ?? 0,
                        (index) {
                          final vendorType = vm.vendorTypes[index];
                          return VendorTypeVerticalListItem(
                            vendorType,
                            onPressed: () {
                              NavigationService.pageSelected(vendorType,
                                  context: context);
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ).p20(),

            //botton banner
            CustomVisibilty(
              visible: HomeScreenConfig.showBannerOnHomeScreen &&
                  !HomeScreenConfig.isBannerPositionTop,
              child: Banners(
                null,
                featured: true,
              ).py12().pOnly(bottom: context.percentHeight * 10),
            ),
          ],
        )
            .scrollVertical()
            .box
            .color(context.backgroundColor)
            .topRounded(value: 25)
            .make()
            .positioned(
              top: (context.percentHeight * 22) - 30,
              left: 0,
              right: 0,
              bottom: 0,
            ),
      ],
    );
  }
}
