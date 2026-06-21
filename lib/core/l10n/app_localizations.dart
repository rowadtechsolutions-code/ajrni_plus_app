import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In ar, this message translates to:
  /// **'أجرني بلس'**
  String get appName;

  /// No description provided for @tagline.
  ///
  /// In ar, this message translates to:
  /// **'استأجر سيارتك بسهولة من مكاتب موثوقة'**
  String get tagline;

  /// No description provided for @marketTagline.
  ///
  /// In ar, this message translates to:
  /// **'سيارات للإيجار اليومي والشهري في عُمان والخليج'**
  String get marketTagline;

  /// No description provided for @hire.
  ///
  /// In ar, this message translates to:
  /// **'استأجر'**
  String get hire;

  /// No description provided for @yourCarEasily.
  ///
  /// In ar, this message translates to:
  /// **'سيارتك بسهولة'**
  String get yourCarEasily;

  /// No description provided for @fromTrustedOffices.
  ///
  /// In ar, this message translates to:
  /// **'من مكاتب\nموثوقة'**
  String get fromTrustedOffices;

  /// No description provided for @logInToYourAccount.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول إلى حسابك'**
  String get logInToYourAccount;

  /// No description provided for @supTitleLogin.
  ///
  /// In ar, this message translates to:
  /// **'قم بإدخال بريدك الإلكتروني وكلمة المرور لتسجيل الدخول إلى حسابك.'**
  String get supTitleLogin;

  /// No description provided for @email.
  ///
  /// In ar, this message translates to:
  /// **'البريد الالكتروني'**
  String get email;

  /// No description provided for @password.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get password;

  /// No description provided for @didYouForgetYourPassword.
  ///
  /// In ar, this message translates to:
  /// **'هل نسيت كلمة المرور الخاصة بك؟'**
  String get didYouForgetYourPassword;

  /// No description provided for @login.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get login;

  /// No description provided for @register.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء حساب'**
  String get register;

  /// No description provided for @registerNow.
  ///
  /// In ar, this message translates to:
  /// **'سجل الأن'**
  String get registerNow;

  /// No description provided for @createNewAccountQues.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء حساب جديد؟'**
  String get createNewAccountQues;

  /// No description provided for @logInAsAVisitor.
  ///
  /// In ar, this message translates to:
  /// **'الدخول كزائر'**
  String get logInAsAVisitor;

  /// No description provided for @createNewAccount.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء حساب جديد'**
  String get createNewAccount;

  /// No description provided for @registerSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'أنشئ حسابك الآن واستمتع بتجربة استئجار سهلة وسريعة'**
  String get registerSubtitle;

  /// No description provided for @user.
  ///
  /// In ar, this message translates to:
  /// **'مستخدم'**
  String get user;

  /// No description provided for @officeOwner.
  ///
  /// In ar, this message translates to:
  /// **'مكتب تأجير'**
  String get officeOwner;

  /// No description provided for @fullName.
  ///
  /// In ar, this message translates to:
  /// **'اسم المستخدم'**
  String get fullName;

  /// No description provided for @commercialRegistration.
  ///
  /// In ar, this message translates to:
  /// **'رقم السجل التجاري'**
  String get commercialRegistration;

  /// No description provided for @phoneNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم الجوال'**
  String get phoneNumber;

  /// No description provided for @country.
  ///
  /// In ar, this message translates to:
  /// **'الدولة'**
  String get country;

  /// No description provided for @city.
  ///
  /// In ar, this message translates to:
  /// **'المدينة'**
  String get city;

  /// No description provided for @confirmPassword.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد كلمة المرور'**
  String get confirmPassword;

  /// No description provided for @createAccount.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء حساب'**
  String get createAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In ar, this message translates to:
  /// **'هل لديك حساب من قبل؟'**
  String get alreadyHaveAccount;

  /// No description provided for @welcomeBack.
  ///
  /// In ar, this message translates to:
  /// **'سعداء بوجودك معنا 👋'**
  String get welcomeBack;

  /// No description provided for @searchHint.
  ///
  /// In ar, this message translates to:
  /// **'بحث عن ...'**
  String get searchHint;

  /// No description provided for @nearbyCars.
  ///
  /// In ar, this message translates to:
  /// **'أحدث سيارات الإيجار القريبة منك'**
  String get nearbyCars;

  /// No description provided for @nearbyOffices.
  ///
  /// In ar, this message translates to:
  /// **'أحدث مكاتب الإيجار القريبة منك'**
  String get nearbyOffices;

  /// No description provided for @showAll.
  ///
  /// In ar, this message translates to:
  /// **'عرض الكل'**
  String get showAll;

  /// No description provided for @home.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get home;

  /// No description provided for @cars.
  ///
  /// In ar, this message translates to:
  /// **'السيارات'**
  String get cars;

  /// No description provided for @offices.
  ///
  /// In ar, this message translates to:
  /// **'المكاتب'**
  String get offices;

  /// No description provided for @favorites.
  ///
  /// In ar, this message translates to:
  /// **'المفضلة'**
  String get favorites;

  /// No description provided for @myAccount.
  ///
  /// In ar, this message translates to:
  /// **'حسابي'**
  String get myAccount;

  /// No description provided for @available.
  ///
  /// In ar, this message translates to:
  /// **'متاح'**
  String get available;

  /// No description provided for @bookNow.
  ///
  /// In ar, this message translates to:
  /// **'إحجز الآن'**
  String get bookNow;

  /// No description provided for @perDay.
  ///
  /// In ar, this message translates to:
  /// **'باليوم'**
  String get perDay;

  /// No description provided for @call.
  ///
  /// In ar, this message translates to:
  /// **'اتصال'**
  String get call;

  /// No description provided for @whatsapp.
  ///
  /// In ar, this message translates to:
  /// **'واتساب'**
  String get whatsapp;

  /// No description provided for @officeDetails.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل المكتب'**
  String get officeDetails;

  /// No description provided for @carDetails.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل السيارة'**
  String get carDetails;

  /// No description provided for @officeCars.
  ///
  /// In ar, this message translates to:
  /// **'سيارات المكتب'**
  String get officeCars;

  /// No description provided for @specifications.
  ///
  /// In ar, this message translates to:
  /// **'المواصفات'**
  String get specifications;

  /// No description provided for @model.
  ///
  /// In ar, this message translates to:
  /// **'الموديل'**
  String get model;

  /// No description provided for @year.
  ///
  /// In ar, this message translates to:
  /// **'السنة'**
  String get year;

  /// No description provided for @fuel.
  ///
  /// In ar, this message translates to:
  /// **'الوقود'**
  String get fuel;

  /// No description provided for @transmission.
  ///
  /// In ar, this message translates to:
  /// **'ناقل الحركة'**
  String get transmission;

  /// No description provided for @automatic.
  ///
  /// In ar, this message translates to:
  /// **'اوتوماتيك'**
  String get automatic;

  /// No description provided for @gasoline.
  ///
  /// In ar, this message translates to:
  /// **'بنزين'**
  String get gasoline;

  /// No description provided for @account.
  ///
  /// In ar, this message translates to:
  /// **'الحساب'**
  String get account;

  /// No description provided for @personalData.
  ///
  /// In ar, this message translates to:
  /// **'تعديل بياناتك الشخصية'**
  String get personalData;

  /// No description provided for @myRequests.
  ///
  /// In ar, this message translates to:
  /// **'طلباتي'**
  String get myRequests;

  /// No description provided for @language.
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get language;

  /// No description provided for @arabic.
  ///
  /// In ar, this message translates to:
  /// **'عربي'**
  String get arabic;

  /// No description provided for @accountSettings.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات الحساب'**
  String get accountSettings;

  /// No description provided for @changePassword.
  ///
  /// In ar, this message translates to:
  /// **'تغيير كلمة المرور'**
  String get changePassword;

  /// No description provided for @deleteAccount.
  ///
  /// In ar, this message translates to:
  /// **'حذف الحساب'**
  String get deleteAccount;

  /// No description provided for @noResults.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد نتائج متطابقة الآن'**
  String get noResults;

  /// No description provided for @noResultsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم العثور على بيانات مطابقة. استخدم البحث أو الفلاتر وحاول مرة أخرى.'**
  String get noResultsSubtitle;

  /// No description provided for @tryNow.
  ///
  /// In ar, this message translates to:
  /// **'تحقق الآن'**
  String get tryNow;

  /// No description provided for @officeName.
  ///
  /// In ar, this message translates to:
  /// **'مكتب الخليج'**
  String get officeName;

  /// No description provided for @officeDescription.
  ///
  /// In ar, this message translates to:
  /// **'مكتب الخليج أفضل مكتب لتأجير السيارات'**
  String get officeDescription;

  /// No description provided for @locationValue.
  ///
  /// In ar, this message translates to:
  /// **'مسقط - عمان'**
  String get locationValue;

  /// No description provided for @carName.
  ///
  /// In ar, this message translates to:
  /// **'هيونداي أفانتي 2024'**
  String get carName;

  /// No description provided for @dailyPrice.
  ///
  /// In ar, this message translates to:
  /// **'11 ر.ع'**
  String get dailyPrice;

  /// No description provided for @userDisplayName.
  ///
  /// In ar, this message translates to:
  /// **'سعيد بن محمد'**
  String get userDisplayName;

  /// No description provided for @emailHint.
  ///
  /// In ar, this message translates to:
  /// **'أدخل بريدك الإلكتروني مثال: example@gmail.com'**
  String get emailHint;

  /// No description provided for @passwordHint.
  ///
  /// In ar, this message translates to:
  /// **'أدخل كلمة المرور الخاصة بك'**
  String get passwordHint;

  /// No description provided for @searchAndFilter.
  ///
  /// In ar, this message translates to:
  /// **'البحث والتصفية'**
  String get searchAndFilter;

  /// No description provided for @logout.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get logout;

  /// No description provided for @fieldRequired.
  ///
  /// In ar, this message translates to:
  /// **'هذا الحقل مطلوب'**
  String get fieldRequired;

  /// No description provided for @invalidName.
  ///
  /// In ar, this message translates to:
  /// **'أدخل اسمًا صحيحًا من 3 أحرف على الأقل'**
  String get invalidName;

  /// No description provided for @invalidEmail.
  ///
  /// In ar, this message translates to:
  /// **'أدخل بريدًا إلكترونيًا صحيحًا'**
  String get invalidEmail;

  /// No description provided for @invalidPhone.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رقم جوال صحيحًا حسب الدولة المختارة'**
  String get invalidPhone;

  /// No description provided for @weakPassword.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور يجب أن تكون 6 أحرف على الأقل'**
  String get weakPassword;

  /// No description provided for @passwordMismatch.
  ///
  /// In ar, this message translates to:
  /// **'كلمتا المرور غير متطابقتين'**
  String get passwordMismatch;

  /// No description provided for @selectCountryAndCity.
  ///
  /// In ar, this message translates to:
  /// **'اختر الدولة والمدينة'**
  String get selectCountryAndCity;

  /// No description provided for @invalidCommercialRegistration.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رقم سجل تجاري صحيحًا'**
  String get invalidCommercialRegistration;

  /// No description provided for @accountCreated.
  ///
  /// In ar, this message translates to:
  /// **'تم إنشاء الحساب بنجاح'**
  String get accountCreated;

  /// No description provided for @confirmEmailMessage.
  ///
  /// In ar, this message translates to:
  /// **'تم إنشاء الحساب. تحقق من بريدك الإلكتروني ثم سجل الدخول'**
  String get confirmEmailMessage;

  /// No description provided for @loginFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تسجيل الدخول. تحقق من البيانات وحاول مرة أخرى'**
  String get loginFailed;

  /// No description provided for @registrationFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر إنشاء الحساب. حاول مرة أخرى'**
  String get registrationFailed;

  /// No description provided for @officePending.
  ///
  /// In ar, this message translates to:
  /// **'حساب المكتب بانتظار التفعيل'**
  String get officePending;

  /// No description provided for @chooseCountry.
  ///
  /// In ar, this message translates to:
  /// **'اختر الدولة'**
  String get chooseCountry;

  /// No description provided for @chooseCity.
  ///
  /// In ar, this message translates to:
  /// **'اختر المدينة'**
  String get chooseCity;

  /// No description provided for @passwordResetSent.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال رابط استعادة كلمة المرور إلى بريدك'**
  String get passwordResetSent;

  /// No description provided for @invalidCredentials.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني أو كلمة المرور غير صحيحة'**
  String get invalidCredentials;

  /// No description provided for @emailNotConfirmed.
  ///
  /// In ar, this message translates to:
  /// **'يرجى تأكيد بريدك الإلكتروني قبل تسجيل الدخول'**
  String get emailNotConfirmed;

  /// No description provided for @emailAlreadyRegistered.
  ///
  /// In ar, this message translates to:
  /// **'هذا البريد الإلكتروني مسجل مسبقًا'**
  String get emailAlreadyRegistered;

  /// No description provided for @serviceConfigurationError.
  ///
  /// In ar, this message translates to:
  /// **'تعذر الاتصال بالخدمة. تحقق من إعدادات التطبيق'**
  String get serviceConfigurationError;

  /// No description provided for @networkError.
  ///
  /// In ar, this message translates to:
  /// **'تعذر الاتصال بالإنترنت. تحقق من الشبكة وحاول مرة أخرى'**
  String get networkError;

  /// No description provided for @tooManyAttempts.
  ///
  /// In ar, this message translates to:
  /// **'محاولات كثيرة. انتظر قليلًا ثم حاول مرة أخرى'**
  String get tooManyAttempts;

  /// No description provided for @unexpectedError.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ غير متوقع. حاول مرة أخرى'**
  String get unexpectedError;

  /// No description provided for @guest.
  ///
  /// In ar, this message translates to:
  /// **'زائر'**
  String get guest;

  /// No description provided for @contactUs.
  ///
  /// In ar, this message translates to:
  /// **'تواصل معنا'**
  String get contactUs;

  /// No description provided for @aboutAjrni.
  ///
  /// In ar, this message translates to:
  /// **'عن أجرني بلس'**
  String get aboutAjrni;

  /// No description provided for @privacyPolicy.
  ///
  /// In ar, this message translates to:
  /// **'سياسة الخصوصية'**
  String get privacyPolicy;

  /// No description provided for @termsAndConditions.
  ///
  /// In ar, this message translates to:
  /// **'الشروط والأحكام'**
  String get termsAndConditions;

  /// No description provided for @confirmLogoutTitle.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get confirmLogoutTitle;

  /// No description provided for @confirmLogoutMessage.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد أنك تريد تسجيل الخروج؟'**
  String get confirmLogoutMessage;

  /// No description provided for @confirmDeleteTitle.
  ///
  /// In ar, this message translates to:
  /// **'حذف الحساب'**
  String get confirmDeleteTitle;

  /// No description provided for @confirmDeleteMessage.
  ///
  /// In ar, this message translates to:
  /// **'سيتم حذف حسابك وبياناتك نهائيًا ولا يمكن التراجع عن هذا الإجراء.'**
  String get confirmDeleteMessage;

  /// No description provided for @cancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد'**
  String get confirm;

  /// No description provided for @saveChanges.
  ///
  /// In ar, this message translates to:
  /// **'حفظ التعديلات'**
  String get saveChanges;

  /// No description provided for @profileUpdated.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث بياناتك بنجاح'**
  String get profileUpdated;

  /// No description provided for @loginToContinue.
  ///
  /// In ar, this message translates to:
  /// **'سجل الدخول للاستفادة من جميع مزايا التطبيق'**
  String get loginToContinue;

  /// No description provided for @selectLanguage.
  ///
  /// In ar, this message translates to:
  /// **'اختر اللغة'**
  String get selectLanguage;

  /// No description provided for @myRequestsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد طلبات حجز مسجلة حتى الآن.'**
  String get myRequestsEmpty;

  /// No description provided for @notifications.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات'**
  String get notifications;

  /// No description provided for @noNotifications.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد إشعارات حاليًا'**
  String get noNotifications;

  /// No description provided for @accountDeletionFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر حذف الحساب الآن. أعد المحاولة بعد تحديث الخدمة.'**
  String get accountDeletionFailed;

  /// No description provided for @contactAdministrationToDelete.
  ///
  /// In ar, this message translates to:
  /// **'يرجى مراجعة إدارة أجرني بلس لحذف حسابك.'**
  String get contactAdministrationToDelete;

  /// No description provided for @understood.
  ///
  /// In ar, this message translates to:
  /// **'حسنًا'**
  String get understood;

  /// No description provided for @registrationServiceError.
  ///
  /// In ar, this message translates to:
  /// **'تم الاتصال بخدمة التسجيل، لكن تعذر إنشاء ملف الحساب. يرجى تحديث إعدادات قاعدة البيانات والمحاولة مجددًا.'**
  String get registrationServiceError;

  /// No description provided for @registrationDisabled.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء الحسابات متوقف مؤقتًا.'**
  String get registrationDisabled;

  /// No description provided for @officeHasNoCars.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد سيارات لهذا المكتب.'**
  String get officeHasNoCars;

  /// No description provided for @noInternetTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد اتصال بالإنترنت'**
  String get noInternetTitle;

  /// No description provided for @noInternetMessage.
  ///
  /// In ar, this message translates to:
  /// **'يرجى التحقق من اتصال الإنترنت للمتابعة في استخدام التطبيق.'**
  String get noInternetMessage;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
