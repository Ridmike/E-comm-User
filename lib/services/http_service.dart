import 'dart:convert';
import 'package:e_com_user/utility/constants.dart';
import 'package:get/get_connect.dart';

class HttpService {
  final String baseUrl = MAIN_URL;

  Future<Response> getItems({required String endpointUrl}) async {
    try {
      return await GetConnect().get('$baseUrl$endpointUrl');
    } catch (e) {
      return Response(
        body: json.encode({'error': e.toString()}),
        statusCode: 500,
      );
    }
  }

  Future<Response> addItem({
    required String endpointUrl,
    required dynamic itemData,
  }) async {
    try {
      final response = await GetConnect().post(
        '$baseUrl/$endpointUrl',
        itemData,
      );
      return response;
    } catch (e) {
      return Response(
        body: json.encode({'error': e.toString()}),
        statusCode: 500,
      );
    }
  }

  Future<Response> updateItem({
    required String endpointUrl,
    required dynamic itemData,
    required String itemId,
  }) async {
    try {
      return await GetConnect().put(
        '$baseUrl/$endpointUrl/$itemId',
        itemData,
      );
    } catch (e) {
      return Response(
        body: json.encode({'error': e.toString()}),
        statusCode: 500,
      );
    }
  }

  Future<Response> deleteItem({
    required String endpointUrl,
    required String itemId,
  }) async {
    try {
      return await GetConnect().delete('$baseUrl/$endpointUrl/$itemId');
    } catch (e) {
      return Response(
        body: json.encode({'error': e.toString()}),
        statusCode: 500,
      );
    }
  }

}
