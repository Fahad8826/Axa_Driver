import 'package:axa_driver/core/network/dioclient.dart';
import 'package:axa_driver/core/theme/utils/app_error_handler.dart';
import 'package:axa_driver/core/theme/utils/snackbars.dart';
import 'package:axa_driver/leave/model/leave_model.dart';
import 'package:axa_driver/navbar/controller/bottomnav_controller.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LeaveController extends GetxController {
  final Dio _dio = DioClient.dio;

  final RxList<LeaveModel> leaves = <LeaveModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxString error = ''.obs;
  final RxString selectedFilter = 'All'.obs;

  // 0 = Home, 1 = Orders, 2 = Leave, 3 = Profile
  static const int _leaveNavIndex = 2;

  List<LeaveModel> get filteredLeaves {
    if (selectedFilter.value.toLowerCase() == 'all') {
      return leaves;
    }
    return leaves
        .where(
          (e) => e.status.toLowerCase() == selectedFilter.value.toLowerCase(),
        )
        .toList();
  }

  @override
  void onInit() {
    super.onInit();
    fetchLeaves();
  }

  void _goToLeaveList() {
    // Get.currentRoute is the active route name.
    // If it is NOT the bottom nav shell, there is a page on the stack to pop.
    // We use Get.key.currentState which gives direct access to the Navigator.
    final NavigatorState? nav = Get.key.currentState;

    if (nav != null && nav.canPop()) {
      // LeaveFormView is on the stack — pop it normally
      nav.pop();
    }

    // Always switch the IndexedStack tab to Leave (index 2)
    Get.find<BottomNavController>().onNavTap(_leaveNavIndex);
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
        _goToLeaveList();
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
        _goToLeaveList();
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