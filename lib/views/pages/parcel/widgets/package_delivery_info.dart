import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/models/delivery_address.dart';
import 'package:fuodz/view_models/new_parcel.vm.dart';
import 'package:fuodz/views/pages/parcel/widgets/form_step_controller.dart';
import 'package:fuodz/views/pages/parcel/widgets/list_item/package_stop_recipient.view.dart';
import 'package:fuodz/views/pages/parcel/widgets/parcel_stops.view.dart';
import 'package:fuodz/views/pages/parcel/widgets/single_parcel_stop.view.dart';
import 'package:fuodz/widgets/custom_list_view.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class PackageDeliveryInfo extends StatelessWidget {
  const PackageDeliveryInfo({this.vm, Key key}) : super(key: key);

  final NewParcelViewModel vm;
  @override
  Widget build(BuildContext context) {
    return Form(
      key: vm.deliveryInfoFormKey,
      child: VStack(
        [
          //
          VStack(
            [
              "Delivery Info".tr().text.xl.medium.make().py20(),
              //show who is payout

              Visibility(
                visible: !AppStrings.enableParcelMultipleStops,
                child: SingleParcelDeliveryStopsView(vm),
              ),
              Visibility(
                visible: AppStrings.enableParcelMultipleStops,
                child: ParcelDeliveryStopsView(vm),
              ),
            ],
          ).scrollVertical().expand(),
    

          //
          // FormStepController(
          //   onPreviousPressed: () => vm.nextForm(2),
          //   onNextPressed: vm.validateRecipientInfo,
          // ),
          //
          FormStepController(
            onPreviousPressed: () => vm.nextForm(0),
            onNextPressed: vm.validateDeliveryInfo,
          ),
        ],
      ),
    );
  }
}
