import 'package:flutter/material.dart';
import 'package:fuodz/models/delivery_address.dart';
import 'package:fuodz/view_models/new_parcel.vm.dart';
import 'package:fuodz/views/pages/parcel/widgets/form_step_controller.dart';
import 'package:fuodz/views/pages/parcel/widgets/list_item/package_stop_recipient.view.dart';
import 'package:fuodz/widgets/custom_list_view.dart';
import 'package:fuodz/widgets/list_items/parcel_vendor.list_item.dart';
import 'package:fuodz/widgets/states/vendor.empty.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class VendorPackageTypeSelector extends StatelessWidget {
  const VendorPackageTypeSelector({this.vm, Key key}) : super(key: key);

  final NewParcelViewModel vm;
  @override
  Widget build(BuildContext context) {
    return Form(
      key: vm.recipientInfoFormKey,
    child: VStack(
      [
        //
        "Select Courier Vendor".tr().text.xl.medium.make().py20(),
        //package type
        CustomListView(
          isLoading: vm.busy(vm.vendors),
          dataSet: vm.vendors,
          emptyWidget: EmptyVendor(showDescription: false),
          noScrollPhysics: true,
          itemBuilder: (context, index) {
            //
            final vendor = vm.vendors[index];
            return ParcelVendorListItem(
              vendor,
              selected: vm.selectedVendor == vendor,
              onPressed: () => vm.changeSelectedVendor(vendor),
              vm: vm,
            );
          },
        ).box.make().py20().scrollVertical().expand(),
        "Enter Contact Info".tr().text.xl.medium.make().py20(),
        CustomListView(
          dataSet: vm.recipientNamesTEC,
          itemBuilder: (context, index) {
            DeliveryAddress stop;
            if (index == 0) {
              stop = vm.packageCheckout.pickupLocation;
            } else {
              stop =
                  vm.packageCheckout.stopsLocation[index - 1].deliveryAddress;
            }
            final recipientNameTEC = vm.recipientNamesTEC[index];
            final recipientPhoneTEC = vm.recipientPhonesTEC[index];
            final noteTEC = vm.recipientNotesTEC[index];
            //
            return PackageStopRecipientView(
              stop,
              recipientNameTEC,
              recipientPhoneTEC,
              noteTEC,
              isOpen: index == vm.openedRecipientFormIndex,
              index: index + 1,
            );
          },
          padding: EdgeInsets.only(top: Vx.dp16),
        ).box.make().expand(),

        //
        FormStepController(
          onPreviousPressed: () => vm.nextForm(1),
          onNextPressed:
              vm.selectedVendor != null ?  vm.validateRecipientInfo: null,
        ),
      ],
    ));
  }
}
