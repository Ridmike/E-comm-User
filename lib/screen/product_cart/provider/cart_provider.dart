import 'dart:developer';
import 'package:e_com_user/models/api_response.dart';
import 'package:e_com_user/services/http_service.dart';
import 'package:e_com_user/utility/snackbar_helper.dart';
import 'package:e_com_user/utility/utility_extention.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../models/coupon.dart';
import '../../login_screen/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cart/flutter_cart.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../utility/constants.dart';

class CartProvider extends ChangeNotifier {
  HttpService service = HttpService();
  final box = GetStorage();
  Razorpay razorpay = Razorpay();
  final UserProvider _userProvider;
  var flutterCart = FlutterCart();
  List<CartModel> myCartItems = [];

  final GlobalKey<FormState> buyNowFormKey = GlobalKey<FormState>();
  TextEditingController phoneController = TextEditingController();
  TextEditingController streetController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController postalCodeController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  TextEditingController couponController = TextEditingController();
  bool isExpanded = false;

  Coupon? couponApplied;
  double couponCodeDiscount = 0;
  String selectedPaymentOption = 'prepaid';

  CartProvider(this._userProvider) {
    // Load saved coupon when CartProvider is initialized
    loadSavedCoupon();
  }

  //  Update Cart
  void updateCart(CartModel cartItem, int quantity) {
    quantity = cartItem.quantity + quantity;
    flutterCart.updateQuantity(cartItem.productId, cartItem.variants, quantity);
    notifyListeners();
  }

  //  Get Cart SubTotal
  double getCartSubTotal() {
    return flutterCart.subtotal;
  }

  //  Get Grand Total
  double getCartGrandTotal() {
    double grandTotal = getCartSubTotal() - couponCodeDiscount;
    return grandTotal;
  }

  //  Get Cart Items
  getCartItems() {
    myCartItems = flutterCart.cartItemsList;
    notifyListeners();
  }

  //  Clear Cart Items
  clearCartItems() {
    flutterCart.clearCart();
    notifyListeners();
  }

  // Constants for storage keys
  static const String COUPON_DATA_KEY = 'CART_COUPON_DATA';
  static const String COUPON_DISCOUNT_KEY = 'CART_COUPON_DISCOUNT';

  // Load saved coupon data on initialization
  void loadSavedCoupon() {
    try {
      final savedCouponJson = box.read(COUPON_DATA_KEY);
      if (savedCouponJson != null) {
        couponApplied = Coupon.fromJson(savedCouponJson);
        couponCodeDiscount = getCouponDiscountAmount(couponApplied!);
        notifyListeners();
      }
    } catch (e) {
      log('Error loading saved coupon: $e');
    }
  }

  // Save coupon data
  void saveCouponData(Coupon coupon) {
    try {
      box.write(COUPON_DATA_KEY, coupon.toJson());
      couponApplied = coupon;
      couponCodeDiscount = getCouponDiscountAmount(coupon);
      notifyListeners();
    } catch (e) {
      log('Error saving coupon data: $e');
    }
  }

  //  Check Coupon Is Valid
  Future<void> checkCoupon() async {
    try {
      if (couponController.text.isEmpty) {
        SnackBarHelper.showErrorSnackBar('Please enter coupon code');
        return;
      }

      final double subtotal = getCartSubTotal();
      List<String> productIds = myCartItems
          .map((cartItem) => cartItem.productId)
          .toList();

      Map<String, dynamic> couponData = {
        "couponCode": couponController.text,
        "purchaseAmount": subtotal,
        "productIds": productIds,
      };

      final response = await service.addItem(
        endpointUrl: 'couponCodes/check-coupon',
        itemData: couponData,
      );

      if (response.isOk) {
        final ApiResponse<Coupon> apiResponse = ApiResponse<Coupon>.fromJson(
          response.body,
          (json) => Coupon.fromJson(json as Map<String, dynamic>),
        );

        if (apiResponse.success == true && apiResponse.data != null) {
          Coupon coupon = apiResponse.data!;

          // Check if coupon is active
          if (coupon.status?.toLowerCase() != 'active') {
            SnackBarHelper.showErrorSnackBar('This coupon has expired');
            return;
          }

          // Check minimum purchase amount
          if (subtotal < (coupon.minimumPurchaseAmount ?? 0)) {
            SnackBarHelper.showErrorSnackBar(
              'Minimum purchase amount should be \$${coupon.minimumPurchaseAmount}',
            );
            return;
          }

          // Check expiry date
          if (coupon.endDate != null) {
            final expiryDate = DateTime.parse(coupon.endDate!);
            if (DateTime.now().isAfter(expiryDate)) {
              SnackBarHelper.showErrorSnackBar('This coupon has expired');
              return;
            }
          }

          // Save and apply the coupon
          saveCouponData(coupon);
          SnackBarHelper.showSuccessSnackBar(
            'Coupon is applicable for all orders.',
          );
        } else {
          SnackBarHelper.showErrorSnackBar(
            apiResponse.message ?? 'Invalid coupon code',
          );
        }
      } else {
        SnackBarHelper.showErrorSnackBar('Error: ${response.statusText}');
      }
    } catch (e) {
      SnackBarHelper.showErrorSnackBar('Error checking coupon');
      log('Error checking coupon: $e');
    }
  }

  //  Get Coupon Discount Amount
  double getCouponDiscountAmount(Coupon coupon) {
    if (coupon.discountAmount == null) return 0;

    final subtotal = getCartSubTotal();
    final discountType = coupon.discountType?.toLowerCase() ?? 'fixed';

    if (discountType == 'fixed') {
      // Fixed amount discount
      return coupon.discountAmount!;
    } else if (discountType == 'percentage') {
      // Percentage based discount
      return (subtotal * coupon.discountAmount! / 100);
    }

    return 0;
  }

  //  Submit Order
  submitOrder(BuildContext context) async {
    if (selectedPaymentOption == 'cod') {
      addOrder(context);
    } else {
      await stripePayment(
        operation: () {
          addOrder(context);
        },
      );
    }
  }

  //  Add Order
  addOrder(BuildContext context) async {
    try {
      if (_userProvider.getLoginUsr()?.sId == null) {
        SnackBarHelper.showErrorSnackBar('User ID is required');
        return;
      }

      if (myCartItems.isEmpty) {
        SnackBarHelper.showErrorSnackBar('Cart is empty');
        return;
      }

      if (!buyNowFormKey.currentState!.validate()) {
        SnackBarHelper.showErrorSnackBar('Please fill in all address fields');
        return;
      }

      Map<String, dynamic> order = {
        "userID": _userProvider.getLoginUsr()?.sId,
        "orderStatus": "pending",
        "items": cartItemToOrderItems(myCartItems),
        "totalPrice": getCartGrandTotal(),
        "shippingAddress": {
          "phone": phoneController.text,
          "street": streetController.text,
          "city": cityController.text,
          "state": stateController.text,
          "postalCode": postalCodeController.text,
          "country": countryController.text,
        },
        "paymentMethod": selectedPaymentOption,
        "orderTotal": {
          "subtotal": getCartSubTotal(),
          "discount": couponCodeDiscount,
          "total": getCartGrandTotal(),
        },
      };

      if (couponApplied?.sId != null) {
        order["couponCode"] = couponApplied?.sId;
      }
      final response = await service.addItem(
        endpointUrl: 'orders',
        itemData: order,
      );
      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if (apiResponse.success == true) {
          SnackBarHelper.showSuccessSnackBar('Order placed successfully');
          clearCouponDiscount();
          clearCartItems();
          Navigator.pop(context);
        } else {
          SnackBarHelper.showErrorSnackBar(
            'Failed to place order: ${apiResponse.message}',
          );
        }
      } else {
        SnackBarHelper.showErrorSnackBar('Error: ${response.statusText}');
      }
    } catch (e) {
      SnackBarHelper.showErrorSnackBar('Error placing order');
      log('Error placing order: $e');
    }
  }

  //  Cart Item To Order Item
  List<Map<String, dynamic>> cartItemToOrderItems(List<CartModel> cartItems) {
    return cartItems.map((cartItem) {
      return {
        "productId": cartItem.productId,
        "productName": cartItem.productName,
        "quantity": cartItem.quantity,
        "price": cartItem.variants.safeElementAt(0)?.price ?? 0,
        "variant": cartItem.variants.safeElementAt(0)?.color ?? '',
      };
    }).toList();
  }

  clearCouponDiscount() {
    couponApplied = null;
    couponCodeDiscount = 0;
    couponController.text = '';
    notifyListeners();
  }

  void retrieveSavedAddress() {
    phoneController.text = box.read(PHONE_KEY) ?? '';
    streetController.text = box.read(STREET_KEY) ?? '';
    cityController.text = box.read(CITY_KEY) ?? '';
    stateController.text = box.read(STATE_KEY) ?? '';
    postalCodeController.text = box.read(POSTAL_CODE_KEY) ?? '';
    countryController.text = box.read(COUNTRY_KEY) ?? '';
  }

  //  Stripe Payment
  Future<void> stripePayment({required void Function() operation}) async {
    try {
      Map<String, dynamic> paymentData = {
        "email": _userProvider.getLoginUsr()?.name,
        "name": _userProvider.getLoginUsr()?.name,
        "address": {
          "line1": streetController.text,
          "city": cityController.text,
          "state": stateController.text,
          "postal_code": postalCodeController.text,
          "country": "US",
        },
        "amount": getCartGrandTotal() * 100, // should complete amount grand total
        "currency": "usd",
        "description": "Your transaction description here",
      };
      Response response = await service.addItem(
        endpointUrl: 'payment/stripe',
        itemData: paymentData,
      );
      final data = await response.body;
      final paymentIntent = data['paymentIntent'];
      final ephemeralKey = data['ephemeralKey'];
      final customer = data['customer'];
      final publishableKey = data['publishableKey'];

      Stripe.publishableKey = publishableKey;
      BillingDetails billingDetails = BillingDetails(
        email: _userProvider.getLoginUsr()?.name,
        phone: '94766368845',
        name: _userProvider.getLoginUsr()?.name,
        address: Address(
          country: 'SL',
          city: cityController.text,
          line1: streetController.text,
          line2: stateController.text,
          postalCode: postalCodeController.text,
          state: stateController.text,
          // Other address details
        ),
        // Other billing details
      );
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          customFlow: false,
          merchantDisplayName: 'MOBIZATE',
          paymentIntentClientSecret: paymentIntent,
          customerEphemeralKeySecret: ephemeralKey,
          customerId: customer,
          style: ThemeMode.light,
          billingDetails: billingDetails,
          // googlePay: const PaymentSheetGooglePay(
          //   merchantCountryCode: 'US',
          //   currencyCode: 'usd',
          //   testEnv: true,
          // ),
          // applePay: const PaymentSheetApplePay(merchantCountryCode: 'US')
        ),
      );

      await Stripe.instance
          .presentPaymentSheet()
          .then((value) {
            log('payment success');
            //? do the success operation
            ScaffoldMessenger.of(
              Get.context!,
            ).showSnackBar(const SnackBar(content: Text('Payment Success')));
            operation();
          })
          .onError((error, stackTrace) {
            if (error is StripeException) {
              ScaffoldMessenger.of(Get.context!).showSnackBar(
                SnackBar(content: Text('${error.error.localizedMessage}')),
              );
            } else {
              ScaffoldMessenger.of(
                Get.context!,
              ).showSnackBar(SnackBar(content: Text('Stripe Error: $error')));
            }
          });
    } catch (e) {
      ScaffoldMessenger.of(
        Get.context!,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> razorpayPayment({required void Function() operation}) async {
    try {
      Response response = await service.addItem(
        endpointUrl: 'payment/razorpay',
        itemData: {},
      );
      final data = await response.body;
      String? razorpayKey = data['key'];
      if (razorpayKey != null && razorpayKey != '') {
        var options = {
          'key': razorpayKey,
          'amount': getCartGrandTotal() * 100, // should complete amount grand total
          'name': "user",
          "currency": 'INR',
          'description': 'Your transaction description',
          'send_sms_hash': true,
          "prefill": {
            "email": _userProvider.getLoginUsr()?.name,
            "contact": '',
          },
          "theme": {'color': '#FFE64A'},
          "image":
              'https://store.rapidflutter.com/digitalAssetUpload/rapidlogo.png',
        };
        razorpay.open(options);
        razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, (
          PaymentSuccessResponse response,
        ) {
          operation();
          return;
        });
        razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, (
          PaymentFailureResponse response,
        ) {
          SnackBarHelper.showErrorSnackBar('Error ${response.message}');
          return;
        });
      }
    } catch (e) {
      SnackBarHelper.showErrorSnackBar('Error$e');
      return;
    }
  }

  void updateUI() {
    notifyListeners();
  }
}
