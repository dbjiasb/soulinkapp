import 'package:modules/base/api_service/api_service_export.dart';

class ReportItem {
  final Map data;
  bool isLast = false;
  ReportItem(this.data);

  int get id => data['id'] ?? 0;
  String get desc => data['desc'] ?? '';
}

class ReportManager {
  //生成单利
  static final ReportManager _instance = ReportManager._internal();

  factory ReportManager() {
    return _instance;
  }

  ReportManager._internal();

  static ReportManager get instance => _instance;

  List<ReportItem> reportItems = [];

  //查询举报选项
  Future<List<ReportItem>> getReportOptions() async {
    if (reportItems.isNotEmpty) {
      return reportItems;
    }
    ApiRequest request = ApiRequest('fetchTipOffOptions');
    ApiResponse response = await ApiService.instance.sendRequest(request);
    if (response.isSuccess) {
      List data = response.data['reasons'];
      reportItems = data.map((e) => ReportItem(e)).toList();
      return reportItems;
    } else {
      return [];
    }
  }

  //提交举报
  Future<ApiResponse> submitReport(int userId, int reasonId, {String extra = ''}) async {
    ApiRequest request = ApiRequest('tipOffUser', params: {'userId': userId, 'optionId': reasonId, 'additional': extra});
    ApiResponse response = await ApiService.instance.sendRequest(request);
    return response;
  }
}
