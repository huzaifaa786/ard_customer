import 'package:fuodz/constants/api.dart';
import 'package:fuodz/models/api_response.dart';
import 'package:fuodz/models/flash_sale.dart';
import 'package:fuodz/models/product.dart';
import 'package:fuodz/services/http.service.dart';

class FlashSaleRequest extends HttpService {
  Future<List<FlashSale>> getFlashSales({
    Map<String, dynamic> queryParams,
  }) async {
    Map<String, dynamic> params = {
      ...(queryParams != null ? queryParams : {}),
    };

    final apiResult = await get(
      Api.flashSales,
      queryParameters: params,
    );

    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return (apiResponse.body as List)
          .map((jsonObject) => FlashSale.fromJson(jsonObject))
          .toList();
    }

    throw apiResponse.message;
  }

  //
  Future<List<Product>> getProdcuts({
    Map<String, dynamic> queryParams,
    int page = 1,
  }) async {
    Map<String, dynamic> params = {
      ...(queryParams != null ? queryParams : {}),
      "page": "$page",
    };

    final apiResult = await get(
      Api.flashSales,
      queryParameters: params,
    );

    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return apiResponse.data
          .map((jsonObject) => Product.fromJson(jsonObject["item"]))
          .toList();
    }

    throw apiResponse.message;
  }
}
