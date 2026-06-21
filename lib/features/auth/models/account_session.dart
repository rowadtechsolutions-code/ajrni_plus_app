import '../../../core/enums/enums.dart';
import '../../offices/models/office_model.dart';
import 'user_model.dart';

class AccountSession {
  final AccountType type;
  final UserModel? user;
  final OfficeModel? office;

  const AccountSession.user(this.user) : type = AccountType.user, office = null;

  const AccountSession.office(this.office)
    : type = AccountType.office,
      user = null;

  String get id => user?.id ?? office?.id ?? '';
  String get email => user?.email ?? office?.email ?? '';
  String get displayName => user?.fullName ?? office?.officeName ?? '';
  String get country => user?.country ?? office?.country ?? '';
  String get city => user?.city ?? office?.city ?? '';
}
