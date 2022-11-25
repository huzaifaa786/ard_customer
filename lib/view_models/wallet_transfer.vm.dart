import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:cool_alert/cool_alert.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/models/api_response.dart';
import 'package:fuodz/models/user.dart';
import 'package:fuodz/models/wallet.dart';
import 'package:fuodz/requests/auth.request.dart';
import 'package:fuodz/requests/wallet.request.dart';
import 'package:fuodz/services/auth.service.dart';
import 'package:fuodz/traits/qrcode_scanner.trait.dart';
import 'package:fuodz/view_models/payment.view_model.dart';
import 'package:fuodz/widgets/bottomsheets/account_verification_entry.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class WalletTransferViewModel extends PaymentViewModel with QrcodeScannerTrait {
  //
  WalletTransferViewModel(BuildContext context, this.wallet) {
    this.viewContext = context;
  }

  //
  WalletRequest walletRequest = WalletRequest();
  Wallet wallet;
  User currentUser;
  var phone;
  User selectedUser;
  AuthRequest authRequest = AuthRequest();

  TextEditingController amountTEC = TextEditingController();
  TextEditingController passwordTEC = TextEditingController();

  //
  Future<List<User>> searchUsers(String keyword) async {
    if (keyword.isEmpty) {
      return [];
    }
    //
    ApiResponse apiResponse = await walletRequest.getWalletAddress(keyword);
    if (apiResponse.allGood) {
      //
      return (apiResponse.body["users"] as List)
          .map((e) => User.fromJson(e))
          .toList();
    } else {
      return [];
    }
  }

  void userSelected(suggestion) {
    selectedUser = suggestion;
    notifyListeners();
  }

  scanWalletAddress() async {
    final walletCode = await openScanner(viewContext);
    if (walletCode == null) {
      toastError("Operation failed/cancelled".tr());
    } else {
      selectedUser = User.fromJson(jsonDecode(walletCode));
      notifyListeners();
    }
  }

  //
  initiateWalletTransfer() async {
    //
    if (formKey.currentState.validate() && selectedUser != null) {
      setBusy(true);
      try {
        //
        ApiResponse apiResponse = await walletRequest.transferWallet(
          amountTEC.text,
          selectedUser.walletAddress,
        );
        //
        if (apiResponse.allGood) {
          toastSuccessful(apiResponse.message);
          viewContext.pop(true);
        } else {
          toastError(apiResponse.message);
        }
      } catch (error) {
        toastError("$error");
      }
      setBusy(false);
    } else if (selectedUser == null) {
      toastError("Please select reciepent".tr());
    }
  }

  void processOTP() async {
    currentUser = await AuthServices.getCurrentUser();
    phone = currentUser.phone;
    print(phone);
    //
   
    if (AppStrings.isFirebaseOtp) {
      processFirebaseOTPVerification();
    } else {
      processCustomOTPVerification();
    }
   
  }

  //PROCESSING VERIFICATION
  processFirebaseOTPVerification() async {
    // setBusyForObject(otpLogin, tru/e);
    //firebase authentication
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (PhoneAuthCredential credential) {
        // firebaseVerificationId = credential.verificationId;
        // verifyFirebaseOTP(credential.smsCode);
        print("verificationCompleted ==>  Yes");
        // finishOTPLogin(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        log("Error message ==> ${e.message}");
        if (e.code == 'invalid-phone-number') {
          viewContext.showToast(
              msg: "Invalid Phone Number".tr(), bgColor: Colors.red);
        } else {
          viewContext.showToast(msg: e.message, bgColor: Colors.red);
        }
        //
        // setBusyForObject(otpLogin, false);
      },
      codeSent: (String verificationId, int resendToken) async {
        firebaseVerificationId = verificationId;
        print("codeSent ==>  $firebaseVerificationId");
        showVerificationEntry();
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        print("codeAutoRetrievalTimeout called");
      },
    );
    // setBusyForObject(otpLogin, false);
  }

  processCustomOTPVerification() async {
    // setBusyForObject(otpLogin, true);
     setBusy(true);
    try {
      await authRequest.sendOTP(phone);
      // setBusyForObject(otpLogin, false);
      showVerificationEntry();
    } catch (error) {
      // setBusyForObject(otpLogin, false);
      viewContext.showToast(msg: "$error", bgColor: Colors.red);
    }
     setBusy(false);
  }

  //
  void showVerificationEntry() async {
    //
    setBusy(false);
    //
    await viewContext.push(
      (context) => AccountVerificationEntry(
        vm: this,
        phone: phone,
        onSubmit: (smsCode) {
          //
          if (AppStrings.isFirebaseOtp) {
            verifyFirebaseOTP(smsCode);
          } else {
            verifyCustomOTP(smsCode);
          }

          viewContext.pop();
        },
        onResendCode: AppStrings.isCustomOtp
            ? () async {
                try {
                  final response = await authRequest.sendOTP(
                    phone,
                  );
                  toastSuccessful(response.message);
                } catch (error) {
                  viewContext.showToast(msg: "$error", bgColor: Colors.red);
                }
              }
            : null,
      ),
    );
  }

  //
  void verifyFirebaseOTP(String smsCode) async {
    //
    // setBusyForObject(otpLogin, true);

    // Sign the user in (or link) with the credential
    try {
      // Create a PhoneAuthCredential with the code
      PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
        verificationId: firebaseVerificationId,
        smsCode: smsCode,
      );

      //
      await initiateWalletTransfer();
    } catch (error) {
      viewContext.showToast(msg: "$error", bgColor: Colors.red);
    }
    //
    // setBusyForObject(otpLogin, false);
  }

  void verifyCustomOTP(String smsCode) async {
    //
    setBusy(true);
    // Sign the user in (or link) with the credential
    try {
      final apiResponse = await authRequest.verifyOTP(
        phone,
        smsCode,
        isLogin: true,
      );

      if (apiResponse.hasError()) {
        //there was an error
        CoolAlert.show(
          context: viewContext,
          type: CoolAlertType.error,
          title: "Failed".tr(),
          text: apiResponse.message,
        );
      } else {
        await initiateWalletTransfer();
      }
    } catch (error) {
      viewContext.showToast(msg: "$error", bgColor: Colors.red);
    }
    //
    setBusy(false);
  }
}
