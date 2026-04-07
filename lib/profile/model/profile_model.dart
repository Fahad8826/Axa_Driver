class ProfileModel {
  final int    driverId;
  final String name;
  final String email;
  final String phoneNumber;
  final String? profilePicture;

  // Vehicle
  final String vehicleNumber;
  final String vehicleModel;
  final String vehicleOwner;

  // Bank
  final String accountNumber;
  final String bankName;
  final String branchName;
  final String ifscCode;

  const ProfileModel({
    required this.driverId,
    required this.name,
    required this.email,
    required this.phoneNumber,
    this.profilePicture,
    required this.vehicleNumber,
    required this.vehicleModel,
    required this.vehicleOwner,
    required this.accountNumber,
    required this.bankName,
    required this.branchName,
    required this.ifscCode,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      driverId:       json['driver_id']       as int,
      name:           json['name']            as String,
      email:          json['email']           as String,
      phoneNumber:    json['phone_number']    as String,
      profilePicture: json['profile_picture'] as String?,
      vehicleNumber:  json['vehicle_number']  as String,
      vehicleModel:   json['vehicle_model']   as String,
      vehicleOwner:   json['vehicle_owner']   as String,
      accountNumber:  json['account_number']  as String,
      bankName:       json['bank_name']       as String,
      branchName:     json['branch_name']     as String,
      ifscCode:       json['ifsc_code']       as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'driver_id':       driverId,
    'name':            name,
    'email':           email,
    'phone_number':    phoneNumber,
    'profile_picture': profilePicture,
    'vehicle_number':  vehicleNumber,
    'vehicle_model':   vehicleModel,
    'vehicle_owner':   vehicleOwner,
    'account_number':  accountNumber,
    'bank_name':       bankName,
    'branch_name':     branchName,
    'ifsc_code':       ifscCode,
  };
}