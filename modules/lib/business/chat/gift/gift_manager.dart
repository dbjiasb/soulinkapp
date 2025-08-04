import 'package:modules/base/api_service/api_service_export.dart';
import 'package:modules/base/buffer_queue/buffer_queue.dart';

class SendGiftData {
  int giftId = 0;
  int giftCount = 1;
  int recipient = 0;
  int receiverStatus = 0;
  int currencyType = 0;
  int balance = 0;
}

class SendGiftResponse {
  bool isSuccess = true;
  int giftId = 0;
  int balance = 0;
  int currencyType = 0;
  String errorMsg = '';
}

class GiftManager {
  //生成单利
  static final GiftManager _instance = GiftManager._internal();

  factory GiftManager() => _instance;

  GiftManager._internal();

  static GiftManager get instance => _instance;

  BufferQueue cache = BufferQueue(10);

  Future<ApiResponse> queryGifts(int recipient) async {
    ApiResponse? value = cache.getObject(recipient);
    if (value != null) {
      return value;
    }

    ApiRequest request = ApiRequest('queryPropList', params: {'targetUid': recipient});

    ApiResponse response = await ApiService.instance.sendRequest(request);
    if (response.isSuccess) {
      cache.setObject(recipient, response);
    }

    return response;
  }

  Future<SendGiftResponse> sendGift(SendGiftData data) async {
    ApiRequest request = ApiRequest(
      'sendGift',
      params: {'toUserId': data.recipient, 'giftId': data.giftId, 'giftCount': data.giftCount, 'targetAccountStatus': data.receiverStatus},
    );

    ApiResponse response = await ApiService.instance.sendRequest(request);
    if (response.isSuccess) {
      SendGiftResponse result = SendGiftResponse();
      result.isSuccess = true;
      result.giftId = data.giftId;
      result.balance = response.data['balance'];
      result.currencyType = data.currencyType;
      return result;
    } else {
      SendGiftResponse result = SendGiftResponse();
      result.isSuccess = false;
      result.errorMsg = response.data['statusInfo']?['msg'] ?? 'Failed to send gift';
      result.currencyType = data.currencyType;
      result.balance = data.balance;
      result.giftId = data.giftId;
      return result;
    }
  }
}
