import 'package:axa_driver/core/theme/apptheme.dart';
import 'package:axa_driver/leave/controller/leave_controller.dart';
import 'package:axa_driver/leave/model/leave_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class LeaveFormView extends StatefulWidget {
  const LeaveFormView({super.key});

  @override
  State<LeaveFormView> createState() => _LeaveFormViewState();
}

class _LeaveFormViewState extends State<LeaveFormView> {
  final _formKey = GlobalKey<FormState>();
  final _reasonCtrl = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  String _status = 'pending';

  final controller = Get.find<LeaveController>();
  LeaveModel? _existingLeave;

  @override
  void initState() {
    super.initState();
    if (Get.arguments != null && Get.arguments is LeaveModel) {
      _existingLeave = Get.arguments as LeaveModel;
      _reasonCtrl.text = _existingLeave!.reason;
      _status = _existingLeave!.status;

      try {
        _startDate = DateTime.parse(_existingLeave!.startDate);
      } catch (_) {}
      try {
        _endDate = DateTime.parse(_existingLeave!.endDate);
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? _startDate ?? DateTime.now()),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      Get.snackbar(
        'Error',
        'Please select both start and end dates',
        backgroundColor: AppColors.statusCancelled,
        colorText: Colors.white,
      );
      return;
    }

    final leave = LeaveModel(
      id: _existingLeave?.id,
      startDate: DateFormat('yyyy-MM-dd').format(_startDate!),
      endDate: DateFormat('yyyy-MM-dd').format(_endDate!),
      reason: _reasonCtrl.text.trim(),
      status: _status,
    );

    if (_existingLeave != null) {
      await controller.updateLeave(_existingLeave!.id!, leave);
    } else {
      await controller.createLeave(leave);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = _existingLeave != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Leave' : 'Apply Leave',
          style: AppTextStyles.headingMedium,
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dates
              Row(
                children: [
                  Expanded(
                    child: _DatePickerField(
                      label: 'Start Date',
                      date: _startDate,
                      onTap: () => _selectDate(context, true),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _DatePickerField(
                      label: 'End Date',
                      date: _endDate,
                      onTap: () => _selectDate(context, false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Status Readonly
              Text(
                'Status',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Text(
                  _status.toUpperCase(),
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _status.toLowerCase() == 'approved'
                        ? AppColors.statusApproved
                        : _status.toLowerCase() == 'rejected'
                        ? AppColors.statusRejected
                        : AppColors.statusProcessing,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Reason
              Text(
                'Reason',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _reasonCtrl,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Enter reason for leave...',
                  filled: true,
                  fillColor: AppColors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.divider),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.divider),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                ),
                validator: (val) => val == null || val.trim().isEmpty
                    ? 'Please enter a reason'
                    : null,
              ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: Obx(
                  () => ElevatedButton(
                    onPressed: controller.isSubmitting.value ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: controller.isSubmitting.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: AppColors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            isEditing ? 'Update Leave' : 'Submit Leave',
                            style: AppTextStyles.buttonSmall,
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  const _DatePickerField({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date != null
                      ? DateFormat('dd MMM yyyy').format(date!)
                      : 'Select Date',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: date != null
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
                const Icon(
                  Icons.calendar_month_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
