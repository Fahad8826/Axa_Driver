import 'package:axa_driver/core/network/dioclient.dart';
import 'package:axa_driver/core/theme/utils/app_error_handler.dart';
import 'package:axa_driver/core/theme/utils/appfeedback.dart';
import 'package:axa_driver/leave/model/leave_model.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';

class LeaveController extends GetxController {
  final Dio _dio = DioClient.dio;

  final RxList<LeaveModel> leaves = <LeaveModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxString error = ''.obs;
  final RxString selectedFilter = 'All'.obs;

  List<LeaveModel> get filteredLeaves {
    if (selectedFilter.value.toLowerCase() == 'all') {
      return leaves;
    }
    return leaves
        .where(
          (element) =>
              element.status.toLowerCase() ==
              selectedFilter.value.toLowerCase(),
        )
        .toList();
  }

  @override
  void onInit() {
    super.onInit();
    fetchLeaves();
  }

  Future<void> fetchLeaves() async {
    try {
      isLoading(true);
      error('');
      final response = await _dio.get('/api/driver/apply-leaves/');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        leaves.value = data.map((e) => LeaveModel.fromJson(e)).toList();
      }
    } on DioException catch (e) {
      final appError = AppErrorHandler.fromDioException(e);
      error(appError.message);
      AppFeedback.fromError(appError);
    } catch (_) {
      final appError = AppErrorHandler.generic();
      error(appError.message);
      AppFeedback.fromError(appError);
    } finally {
      isLoading(false);
    }
  }

  Future<void> filterAndSortLeaves() async {
    // Optional helper
  }

  Future<void> createLeave(LeaveModel leave) async {
    try {
      isSubmitting(true);
      final response = await _dio.post(
        '/api/driver/apply-leaves/',
        data: leave.toJson(),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        AppFeedback.success('Leave applied successfully');
        await fetchLeaves();
        Get.back();
      }
    } on DioException catch (e) {
      AppFeedback.fromError(AppErrorHandler.fromDioException(e));
    } catch (_) {
      AppFeedback.fromError(AppErrorHandler.generic());
    } finally {
      isSubmitting(false);
    }
  }

  Future<void> updateLeave(int id, LeaveModel leave) async {
    try {
      isSubmitting(true);
      final response = await _dio.put(
        '/api/driver/apply-leaves/$id/',
        data: leave.toJson(),
      );
      if (response.statusCode == 200) {
        AppFeedback.success('Leave updated successfully');
        await fetchLeaves();
        Get.back();
      }
    } on DioException catch (e) {
      AppFeedback.fromError(AppErrorHandler.fromDioException(e));
    } catch (_) {
      AppFeedback.fromError(AppErrorHandler.generic());
    } finally {
      isSubmitting(false);
    }
  }

  Future<bool> deleteLeave(int id) async {
    try {
      final response = await _dio.delete('/api/driver/apply-leaves/$id/');
      if (response.statusCode == 200 || response.statusCode == 204) {
        AppFeedback.success('Leave deleted successfully');
        leaves.removeWhere((element) => element.id == id);
        return true;
      }
    } on DioException catch (e) {
      AppFeedback.fromError(AppErrorHandler.fromDioException(e));
    } catch (_) {
      AppFeedback.fromError(AppErrorHandler.generic());
    }
    return false;
  }
}
