import 'package:dsfulfill_cient_app/config/base_controller.dart';
import 'package:dsfulfill_cient_app/config/routers.dart';
import 'package:dsfulfill_cient_app/events/application_event.dart';
import 'package:dsfulfill_cient_app/events/change_page_index_event.dart';
import 'package:dsfulfill_cient_app/events/logined_event.dart';
import 'package:dsfulfill_cient_app/events/set_team_event.dart';
import 'package:dsfulfill_cient_app/models/home_model.dart';
import 'package:dsfulfill_cient_app/services/home_service.dart';
import 'package:dsfulfill_cient_app/state/app_state.dart';
import 'package:dsfulfill_cient_app/storage/common_storage.dart';
import 'package:get/get.dart';

class HomeController extends BaseController {
  final currencyModel = Get.find<AppState>().currencyModel;
  final token = Get.find<AppState>().token.obs;
  final homeModel = HomeModel(
    orderStatistics: null,
    expressLinesCount: 0,
    goodsCount: 0,
    orderCount: 0,
  ).obs;
  final orderListStatus = [
    {
      'label': '待报价',
      'status': 0,
      'count': 0,
    },
    {
      'label': '待申请运单',
      'status': 3,
      'count': 0,
    },
    {
      'label': '待配货',
      'status': 4,
      'count': 0,
    },
    {
      'label': '异常订单',
      'status': 'abnormal',
      'count': 0,
    },
  ].obs;

  @override
  void onInit() {
    super.onInit();
    ApplicationEvent.getInstance().event.on<LoginedEvent>().listen((event) {
      token.value = Get.find<AppState>().token;
      loadData();
    });
    ApplicationEvent.getInstance()
        .event
        .on<ChangePageIndexEvent>()
        .listen((event) {
      if (event.pageName == 'home') {
        homeModel.value = HomeModel(
          orderStatistics: null,
          expressLinesCount: 0,
          goodsCount: 0,
          orderCount: 0,
        );
        token.value = Get.find<AppState>().token;
      }
    });
    ApplicationEvent.getInstance().event.on<SetTeamEvent>().listen((event) {
      loadData();
    });

    loadData();
  }

  @override
  void onClose() {
    super.onClose();
  }

  getHomeData() async {
    var result = await HomeService.getHomeData();
    homeModel.value = result;
  }

  getOrderCount() async {
    var result = await HomeService.getOrderCount({
      'order_keyword_type': 1,
      'order_type': 1,
      'batch_keyword_type': 1,
      'product_keyword_type': 1,
      'status': 0,
      'page': 1,
      'size': 50,
      'total': 0,
      'sort': 1,
      'time_range_type': 1
    });
    // ignore: invalid_use_of_protected_member
    for (var element in orderListStatus.value) {
      final status = element['status'];
      element['count'] = result[status.toString()] ?? result[status] ?? 0;
    }
    orderListStatus.refresh();
  }

  Future<void> loadData() async {
    await getHomeData();
    await getOrderCount();
  }
}
