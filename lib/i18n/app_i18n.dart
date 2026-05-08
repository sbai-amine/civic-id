import 'package:flutter/widgets.dart';

class AppI18n {
  AppI18n._();

  static const supportedLocales = <Locale>[
    Locale('en'),
    Locale('ar'),
    Locale('fr'),
    Locale('tzm'),
  ];

  static const languageOptions = <({String code, String label})>[
    (code: 'en', label: 'English'),
    (code: 'ar', label: 'Arabic'),
    (code: 'fr', label: 'Français'),
    (code: 'tzm', label: 'Tamazight (Latin)'),
  ];

  static const Map<String, Map<String, String>> _dictionary = {
    'en': {
      'common.retry': 'Retry',
      'common.refresh': 'Refresh',
      'common.cancel': 'Cancel',
      'common.delete': 'Delete',
      'common.ok': 'OK',
      'common.done': 'Done',
      'common.signOut': 'Sign out',
      'app.name': 'BridgeID',
      'nav.dashboard': 'Dashboard',
      'nav.services': 'Services',
      'nav.profile': 'Profile',
      'nav.qrHistory': 'QR history',
      'app.tagline': 'Your civic access, simplified.',
      'form.nationalId.label': 'National ID',
      'form.nationalId.hint': 'Enter your national ID',
      'form.pin.label': 'PIN',
      'form.pin.hint': 'Enter your PIN',
      'form.pin.show': 'Show PIN',
      'form.pin.hide': 'Hide PIN',
      'profile.title': 'Profile',
      'profile.lastSync': 'Last sync',
      'profile.never': 'Never',
      'profile.appVersion': 'App version',
      'profile.nationalId': 'National ID',
      'profile.unnamedAccount': 'Account',
      'profile.about': 'About',
      'profile.bioOpen.subtitle':
          'Re-authenticate every time the app is opened.',
      'profile.bioOpen': 'Lock with biometrics on open',
      'profile.bioSync': 'Require biometrics to sync',
      'profile.appLanguage': 'App language',
      'services.title': 'Services',
      'serviceQr.title': 'Service QR',
      'serviceQr.description':
          'Generate a QR code that encodes your user ID and the current time (UTC).',
      'serviceQr.generate': 'Generate QR',
      'serviceQr.payloadHint': 'Scanning decodes JSON with userID and timestamp.',
      'serviceQr.savedPending': 'Saved on this device - pending sync when online.',
      'serviceQr.missingUser': 'No saved user ID. Sign out and sign in again, then try once more.',
      'sync.nothingPending': 'Nothing pending to upload.',
      'sync.alreadySynced': 'Everything is already synced.',
      'sync.uploadedRecords': 'Uploaded {count} record(s).',
      'sync.syncedRecords': 'Synced {count} record(s).',
      'sync.failedToPending': 'Failed rows moved back to pending queue.',
      'sync.queueReset': 'Queue normalized. Retry counters reset.',
      'login.title': 'Sign in',
      'login.subtitle': 'Use your national ID and PIN to continue.',
      'login.button': 'Log in',
      'dashboard.welcome': 'Welcome back',
      'dashboard.hero.subtitle':
          'Manage your civic services and keep your offline records synced.',
      'dashboard.pending': 'Pending',
      'dashboard.syncing': 'Syncing',
      'dashboard.synced': 'Synced',
      'dashboard.failed': 'Failed',
      'dashboard.retryFailed': 'Retry failed',
      'dashboard.syncNow': 'Sync now',
      'dashboard.resetQueue': 'Reset queue',
      'dashboard.services.title': 'Services',
      'dashboard.services.subtitle':
          'Browse official services, fees, and required documents.',
      'dashboard.recent.title': 'Recent activity',
      'dashboard.recent.empty': 'No activity yet. Generate your first service QR.',
      'dashboard.recent.seeAll': 'See all',
      'dashboard.browseServices': 'View all services',
      'dashboard.offlineBanner':
          "Working offline — your QR codes will upload when you're back online.",
      'profile.accountVerified': 'Identity verified',
      'history.couldNotSave': "Couldn't save this QR to your account.",
      'history.status.submitted': 'Submitted',
      'history.status.savedOnDevice': 'Saved on this device',
      'history.status.couldNotSave': "Couldn't save",
      'serviceDetail.showAtCounter': 'Show QR at the counter',
      'serviceDetail.submitSigned': 'Submit signed request',
      'serviceDetail.actionsHint':
          'Show the QR if you are at a counter, or submit a signed request to handle it remotely.',
      'services.notSignedIn': 'No saved session. Sign in again to load services.',
      'services.loadFailed': 'Could not load services',
      'services.empty': 'No services available',
      'services.goSignIn': 'Go to sign in',
      'serviceDetail.title': 'Service details',
      'serviceDetail.description': 'Description',
      'serviceDetail.fees': 'Fees',
      'serviceDetail.requiredDocs': 'Required documents',
      'serviceDetail.generateQr': 'Generate service QR',
      'serviceDetail.requestSigned': 'Request signed',
      'serviceDetail.signing': 'Signing...',
      'serviceDetail.signNow': 'Sign request digitally',
      'serviceDetail.signedCreated': 'Signed request created ({id})',
      'serviceDetail.signHint':
          'Creates a one-time code with your user ID and timestamp. You can sync it later from the dashboard.',
      'serviceQr.secureKeyMissing':
          'Sign out and sign in again to load a secure QR key for this account.',
      'serviceQr.saveFailed':
          'QR works offline, but saving to the local database failed. You can still show this code to an agent.',
      'serviceQr.scanTitle': 'Scan to verify identity',
      'history.refreshTooltip': 'Refresh',
      'history.empty': 'No saved QR records yet.\nGenerate one from a service.',
      'history.emptyPayload': '(empty payload)',
      'history.share': 'Export / share payload',
      'history.shareSubject': 'BridgeID QR - {name}',
      'admin.title': 'Admin Console',
      'admin.missingKey': 'Missing ADMIN_API_KEY. Run with --dart-define=ADMIN_API_KEY=...',
      'admin.users': 'Users',
      'admin.serviceRecords': 'Service Records',
      'admin.agentScans': 'Agent Scans',
      'admin.activeKeys': 'Active Keys',
      'admin.agentKeys': 'Agent Keys',
      'admin.logs': 'Audit Logs',
      'admin.noLogs': 'No logs found.',
      'admin.enable': 'Enable',
      'admin.disable': 'Disable',
      'admin.keyEnabled': 'Agent key enabled',
      'admin.keyDisabled': 'Agent key disabled',
      'admin.verifyDoc': 'Verify Signed Document',
      'admin.verifyDocId': 'Signed Document ID',
      'admin.verifySignature': 'Verify Signature',
      'admin.signatureValid': 'Signature valid: {ok}\nPayload hash: {hash}',
      'profile.language.title': 'Language',
      'profile.language.subtitle': 'Choose your preferred language for the app.',
      'profile.security': 'Security',
      'profile.bio.web': 'Biometric options are not available in the web build.',
      'profile.openAdmin': 'Open Admin Console',
    },
    'ar': {
      'common.retry': 'إعادة المحاولة',
      'common.refresh': 'تحديث',
      'common.cancel': 'إلغاء',
      'common.delete': 'حذف',
      'common.ok': 'موافق',
      'common.done': 'تم',
      'common.signOut': 'تسجيل الخروج',
      'app.name': 'BridgeID',
      'app.tagline': 'وصولك المدني، مُبسَّط.',
      'nav.dashboard': 'لوحة التحكم',
      'nav.services': 'الخدمات',
      'nav.profile': 'الملف الشخصي',
      'nav.qrHistory': 'سجل QR',
      'service.birth_certificate.name': 'شهادة الازدياد',
      'service.national_id_renewal.name': 'تجديد البطاقة الوطنية',
      'service.passport_application.name': 'طلب جواز السفر',
      'service.family_record_book.name': 'كناش الحالة المدنية',
      'service.marriage_certificate.name': 'عقد الزواج',
      'service.death_certificate.name': 'شهادة الوفاة',
      'service.residence_certificate.name': 'شهادة السكنى',
      'service.certificate_of_life.name': 'شهادة الحياة',
      'service.driving_license_application.name': 'طلب رخصة السياقة',
      'service.vehicle_registration.name': 'تسجيل العربات',
      'service.social_security_enrollment.name': 'التسجيل في CNSS',
      'service.ramed_enrollment.name': 'المساعدة الطبية RAMED',
      'service.land_registry_extract.name': 'مستخرج المحافظة العقارية',
      'service.judicial_record.name': 'شهادة السوابق العدلية',
      'service.tax_clearance_certificate.name': 'شهادة الإبراء الضريبي',
      'form.nationalId.label': 'رقم الهوية الوطنية',
      'form.nationalId.hint': 'أدخل رقم هويتك الوطنية',
      'form.pin.label': 'الرمز السري',
      'form.pin.hint': 'أدخل الرمز السري',
      'form.pin.show': 'إظهار الرمز',
      'form.pin.hide': 'إخفاء الرمز',
      'profile.title': 'الملف الشخصي',
      'profile.lastSync': 'آخر مزامنة',
      'profile.never': 'أبداً',
      'profile.appVersion': 'إصدار التطبيق',
      'profile.nationalId': 'رقم الهوية الوطنية',
      'profile.unnamedAccount': 'الحساب',
      'profile.about': 'حول',
      'profile.bioOpen.subtitle': 'إعادة المصادقة عند كل فتح للتطبيق.',
      'profile.bioOpen': 'قفل بالبيومترية عند الفتح',
      'profile.bioSync': 'المزامنة تتطلب بيومترية',
      'profile.appLanguage': 'لغة التطبيق',
      'profile.language.title': 'اللغة',
      'profile.language.subtitle': 'اختر لغة التطبيق.',
      'profile.security': 'الأمان',
      'profile.bio.web': 'القياسات الحيوية غير متاحة على الويب.',
      'profile.openAdmin': 'لوحة الإدارة',
      'login.title': 'تسجيل الدخول',
      'login.subtitle': 'استخدم رقم هويتك والرمز السري للمتابعة.',
      'login.button': 'دخول',
      'dashboard.welcome': 'مرحباً بعودتك',
      'dashboard.hero.subtitle': 'أدر خدماتك المدنية وابقِ سجلاتك متزامنة.',
      'dashboard.pending': 'قيد الانتظار',
      'dashboard.syncing': 'جارٍ المزامنة',
      'dashboard.synced': 'مزامَن',
      'dashboard.failed': 'فشل',
      'dashboard.retryFailed': 'إعادة المحاولة',
      'dashboard.syncNow': 'مزامنة الآن',
      'dashboard.resetQueue': 'إعادة تعيين القائمة',
      'dashboard.services.title': 'الخدمات',
      'dashboard.services.subtitle': 'تصفح الخدمات الرسمية والرسوم والمستندات المطلوبة.',
      'dashboard.recent.title': 'النشاط الأخير',
      'dashboard.recent.empty': 'لا نشاط حتى الآن. أنشئ أول رمز QR للخدمة.',
      'dashboard.recent.seeAll': 'عرض الكل',
      'dashboard.browseServices': 'عرض كل الخدمات',
      'dashboard.offlineBanner':
          'تعمل دون اتصال — سيتم رفع رموز QR عند عودة الإنترنت.',
      'profile.accountVerified': 'الهوية مؤكَّدة',
      'history.couldNotSave': 'تعذّر حفظ رمز QR في حسابك.',
      'history.status.submitted': 'مُرسَل',
      'history.status.savedOnDevice': 'محفوظ على هذا الجهاز',
      'history.status.couldNotSave': 'تعذّر الحفظ',
      'serviceDetail.showAtCounter': 'اعرض رمز QR عند الشبّاك',
      'serviceDetail.submitSigned': 'إرسال طلب موقَّع',
      'serviceDetail.actionsHint':
          'اعرض رمز QR في الشبّاك، أو أرسل طلباً موقَّعاً عن بُعد.',
      'services.title': 'الخدمات',
      'services.notSignedIn': 'لا توجد جلسة. سجّل الدخول مجدداً.',
      'services.loadFailed': 'تعذّر تحميل الخدمات',
      'services.empty': 'لا توجد خدمات متاحة',
      'services.goSignIn': 'الذهاب لتسجيل الدخول',
      'serviceDetail.title': 'تفاصيل الخدمة',
      'serviceDetail.description': 'الوصف',
      'serviceDetail.fees': 'الرسوم',
      'serviceDetail.requiredDocs': 'المستندات المطلوبة',
      'serviceDetail.generateQr': 'إنشاء رمز QR للخدمة',
      'serviceDetail.requestSigned': 'الطلب موقَّع',
      'serviceDetail.signing': 'جارٍ التوقيع...',
      'serviceDetail.signNow': 'توقيع رقمي للطلب',
      'serviceDetail.signedCreated': 'طلب موقَّع ({id})',
      'serviceDetail.signHint': 'ينشئ رمزاً فريداً. يمكن مزامنته لاحقاً.',
      'serviceQr.title': 'رمز QR للخدمة',
      'serviceQr.description': 'أنشئ رمز QR يحتوي على رقم هويتك والوقت الحالي.',
      'serviceQr.generate': 'إنشاء رمز QR',
      'serviceQr.payloadHint': 'المسح يفك تشفير JSON برقم المستخدم والوقت.',
      'serviceQr.savedPending': 'محفوظ على هذا الجهاز - في انتظار المزامنة.',
      'serviceQr.missingUser': 'رقم المستخدم غير موجود. سجّل الخروج ثم أعد الدخول.',
      'serviceQr.secureKeyMissing': 'سجّل الخروج ثم أعد الدخول للحصول على مفتاح QR آمن.',
      'serviceQr.saveFailed': 'رمز QR يعمل بدون إنترنت، لكن الحفظ فشل. يمكنك عرض الرمز للوكيل.',
      'serviceQr.scanTitle': 'امسح للتحقق من الهوية',
      'sync.nothingPending': 'لا شيء في الانتظار.',
      'sync.alreadySynced': 'كل شيء مزامَن بالفعل.',
      'sync.uploadedRecords': 'تم رفع {count} سجل(ات).',
      'sync.syncedRecords': 'تمت مزامنة {count} سجل(ات).',
      'sync.failedToPending': 'الصفوف الفاشلة أُعيدت إلى قائمة الانتظار.',
      'sync.queueReset': 'تمت إعادة تعيين قائمة الانتظار.',
      'history.refreshTooltip': 'تحديث',
      'history.empty': 'لا توجد سجلات QR بعد.\nأنشئ سجلاً من إحدى الخدمات.',
      'history.emptyPayload': '(بيانات فارغة)',
      'history.share': 'تصدير / مشاركة',
      'history.shareSubject': 'BridgeID QR - {name}',
      'admin.title': 'لوحة الإدارة',
      'admin.missingKey': 'مفتاح ADMIN_API_KEY مفقود.',
      'admin.users': 'المستخدمون',
      'admin.serviceRecords': 'سجلات الخدمة',
      'admin.agentScans': 'مسح الوكلاء',
      'admin.activeKeys': 'المفاتيح النشطة',
      'admin.agentKeys': 'مفاتيح الوكلاء',
      'admin.logs': 'سجلات التدقيق',
      'admin.noLogs': 'لا توجد سجلات.',
      'admin.enable': 'تفعيل',
      'admin.disable': 'تعطيل',
      'admin.keyEnabled': 'مفتاح الوكيل مفعَّل',
      'admin.keyDisabled': 'مفتاح الوكيل معطَّل',
      'admin.verifyDoc': 'التحقق من المستند الموقَّع',
      'admin.verifyDocId': 'معرّف المستند الموقَّع',
      'admin.verifySignature': 'التحقق من التوقيع',
      'admin.signatureValid': 'التوقيع صحيح: {ok}\nرمز البيانات: {hash}',
      'service.birth_certificate.description':
          'طلب رسمي للحصول على نسخة مصدقة من شهادة الازدياد من سجل الحالة المدنية.',
      'service.birth_certificate.fees':
          '5,00 درهم — معالجة في نفس اليوم حسب التوفر',
      'service.birth_certificate.requiredDocs':
          'البطاقة الوطنية للوالد أو الولي\nكناش الحالة المدنية\nموافقة الوالد إذا كان قاصراً',
      'service.national_id_renewal.description':
          'تجديد أو استبدال البطاقة الوطنية الإلكترونية (CNIE).',
      'service.national_id_renewal.fees':
          'مجاني للاستبدال الأول — 40,00 درهم للاستبدالات اللاحقة',
      'service.national_id_renewal.requiredDocs':
          'البطاقة الوطنية المنتهية الصلاحية أو التالفة\nصورتان شخصيتان\nشهادة الازدياد',
      'service.passport_application.description':
          'طلب جواز سفر مغربي جديد أو تجديد جواز قائم.',
      'service.passport_application.fees':
          '500,00 درهم — معالجة قياسية (4 إلى 6 أسابيع)',
      'service.passport_application.requiredDocs':
          'البطاقة الوطنية\nشهادة الازدياد\n4 صور شخصية\nإثبات السكن\nطابع جبائي',
      'service.family_record_book.description':
          'وثيقة رسمية تسجل تكوين الأسرة، تُسلَّم عند الزواج أو الازدياد.',
      'service.family_record_book.fees': 'مجاني',
      'service.family_record_book.requiredDocs':
          'عقد الزواج\nالبطاقة الوطنية لكلا الزوجين\nشهادات ازدياد الأبناء عند الاقتضاء',
      'service.marriage_certificate.description':
          'نسخة مصدقة من عقد زواج من سجل الحالة المدنية.',
      'service.marriage_certificate.fees': '5,00 درهم',
      'service.marriage_certificate.requiredDocs':
          'البطاقة الوطنية لكلا الزوجين\nرقم مرجع عقد الزواج الأصلي',
      'service.death_certificate.description':
          'نسخة رسمية مصدقة من شهادة وفاة من سجل الحالة المدنية.',
      'service.death_certificate.fees': '5,00 درهم',
      'service.death_certificate.requiredDocs':
          'البطاقة الوطنية لأحد أفراد الأسرة\nمعلومات هوية المتوفى\nشهادة الوفاة الطبية إن وُجدت',
      'service.residence_certificate.description':
          'إثبات رسمي للسكنى تصدره المقاطعة أو الجماعة المحلية للتحقق من العنوان.',
      'service.residence_certificate.fees': '10,00 درهم',
      'service.residence_certificate.requiredDocs':
          'البطاقة الوطنية\nفاتورة (ماء/كهرباء — آخر 3 أشهر) أو عقد كراء\nعقد الكراء أو سند الملكية عند الطلب',
      'service.certificate_of_life.description':
          'شهادة الحياة المطلوبة من صناديق التقاعد والسلطات الأجنبية.',
      'service.certificate_of_life.fees': '10,00 درهم',
      'service.certificate_of_life.requiredDocs':
          'البطاقة الوطنية\nشهادة طبية حديثة أو الحضور الشخصي إلى الجماعة',
      'service.driving_license_application.description':
          'طلب رخصة سياقة مغربية (الصنف B) لأول مرة.',
      'service.driving_license_application.fees':
          '300,00 درهم — الصنف B (تختلف رسوم السيارة/الدراجة القياسية)',
      'service.driving_license_application.requiredDocs':
          'البطاقة الوطنية\nشهادة طبية للأهلية\nإثبات اجتياز الاختبار النظري والتطبيقي\n4 صور شخصية',
      'service.vehicle_registration.description':
          'تسجيل عربة جديدة أو محوَّلة لدى مصلحة النقل.',
      'service.vehicle_registration.fees':
          'يختلف حسب نوع العربة والقوة الجبائية — ابتداءً من 350,00 درهم',
      'service.vehicle_registration.requiredDocs':
          'البطاقة الوطنية\nفاتورة شراء العربة أو وثيقة التحويل\nشهادة التأمين\nشهادة الفحص التقني',
      'service.social_security_enrollment.description':
          'التسجيل في نظام الضمان الاجتماعي للتأمين الصحي والتعويضات العائلية والتقاعد.',
      'service.social_security_enrollment.fees':
          'مجاني — يتولى رب العمل التسجيل',
      'service.social_security_enrollment.requiredDocs':
          'البطاقة الوطنية\nعقد العمل أو تصريح رب العمل\nشهادة الازدياد\nالبيانات البنكية (RIB)',
      'service.ramed_enrollment.description':
          'التسجيل في برنامج المساعدة الطبية للأسر ذات الدخل المحدود.',
      'service.ramed_enrollment.fees': 'مجاني — استحقاق حسب الدخل',
      'service.ramed_enrollment.requiredDocs':
          'البطاقة الوطنية\nإثبات الدخل أو شهادة العوز\nكناش الحالة المدنية',
      'service.land_registry_extract.description':
          'مستخرج رسمي من المحافظة العقارية يؤكد ملكية العقار ووضعه القانوني.',
      'service.land_registry_extract.fees': '150,00 درهم',
      'service.land_registry_extract.requiredDocs':
          'البطاقة الوطنية\nرقم الرسم العقاري\nاستمارة طلب مكتملة',
      'service.judicial_record.description':
          'شهادة رسمية للسوابق العدلية، مطلوبة للتوظيف وتأشيرات السفر والإجراءات الإدارية.',
      'service.judicial_record.fees':
          'مجاني — تُعالَج في المحكمة المحلية أو عبر الخدمات الإلكترونية',
      'service.judicial_record.requiredDocs':
          'البطاقة الوطنية\nشهادة الازدياد',
      'service.tax_clearance_certificate.description':
          'شهادة من إدارة الضرائب تؤكد عدم وجود ديون ضريبية مستحقة.',
      'service.tax_clearance_certificate.fees': 'مجاني',
      'service.tax_clearance_certificate.requiredDocs':
          'البطاقة الوطنية أو رقم تسجيل الشركة\nالرقم الضريبي\nآخر تصريح ضريبي',
    },
    'fr': {
      'common.retry': 'Réessayer',
      'common.refresh': 'Actualiser',
      'common.cancel': 'Annuler',
      'common.delete': 'Supprimer',
      'common.ok': 'OK',
      'common.done': 'Terminer',
      'common.signOut': 'Se déconnecter',
      'app.name': 'BridgeID',
      'app.tagline': 'Votre accès civique, simplifié.',
      'nav.dashboard': 'Tableau de bord',
      'nav.services': 'Services',
      'nav.profile': 'Profil',
      'nav.qrHistory': 'Historique QR',
      'service.birth_certificate.name': 'Acte de naissance',
      'service.national_id_renewal.name': 'Renouvellement CNIE',
      'service.passport_application.name': 'Demande de passeport',
      'service.family_record_book.name': 'Livret de famille',
      'service.marriage_certificate.name': 'Acte de mariage',
      'service.death_certificate.name': 'Acte de décès',
      'service.residence_certificate.name': 'Certificat de résidence',
      'service.certificate_of_life.name': 'Certificat de vie',
      'service.driving_license_application.name': 'Demande de permis de conduire',
      'service.vehicle_registration.name': 'Immatriculation de véhicule',
      'service.social_security_enrollment.name': 'Affiliation CNSS',
      'service.ramed_enrollment.name': 'Assistance médicale RAMED',
      'service.land_registry_extract.name': 'Extrait du registre foncier',
      'service.judicial_record.name': 'Casier judiciaire',
      'service.tax_clearance_certificate.name': 'Certificat de quitus fiscal',
      'form.nationalId.label': 'Numéro CIN',
      'form.nationalId.hint': 'Entrez votre numéro CIN',
      'form.pin.label': 'Code PIN',
      'form.pin.hint': 'Entrez votre code PIN',
      'form.pin.show': 'Afficher le PIN',
      'form.pin.hide': 'Masquer le PIN',
      'profile.title': 'Profil',
      'profile.lastSync': 'Dernière sync',
      'profile.never': 'Jamais',
      'profile.appVersion': 'Version',
      'profile.nationalId': 'Numéro CIN',
      'profile.unnamedAccount': 'Compte',
      'profile.about': 'À propos',
      'profile.bioOpen.subtitle':
          'Re-authentification à chaque ouverture de l\'application.',
      'profile.bioOpen': 'Biométrie à l\'ouverture',
      'profile.bioSync': 'Biométrie pour la sync',
      'profile.appLanguage': 'Langue',
      'profile.language.title': 'Langue',
      'profile.language.subtitle': 'Choisissez la langue de l\'application.',
      'profile.security': 'Sécurité',
      'profile.bio.web': 'La biométrie n\'est pas disponible sur le web.',
      'profile.openAdmin': 'Console d\'administration',
      'login.title': 'Connexion',
      'login.subtitle': 'Utilisez votre CIN et code PIN pour continuer.',
      'login.button': 'Se connecter',
      'dashboard.welcome': 'Bon retour',
      'dashboard.hero.subtitle': 'Gérez vos services civiques et synchronisez vos enregistrements.',
      'dashboard.pending': 'En attente',
      'dashboard.syncing': 'Sync en cours',
      'dashboard.synced': 'Synchronisé',
      'dashboard.failed': 'Échoué',
      'dashboard.retryFailed': 'Réessayer',
      'dashboard.syncNow': 'Synchroniser',
      'dashboard.resetQueue': 'Réinitialiser',
      'dashboard.services.title': 'Services',
      'dashboard.services.subtitle': 'Parcourez les services officiels, les frais et les documents requis.',
      'dashboard.recent.title': 'Activité récente',
      'dashboard.recent.empty': 'Aucune activité. Générez votre premier QR de service.',
      'dashboard.recent.seeAll': 'Tout voir',
      'dashboard.browseServices': 'Voir tous les services',
      'dashboard.offlineBanner':
          'Hors ligne — vos QR seront envoyés dès le retour de la connexion.',
      'profile.accountVerified': 'Identité vérifiée',
      'history.couldNotSave': "Impossible d'enregistrer ce QR dans votre compte.",
      'history.status.submitted': 'Envoyé',
      'history.status.savedOnDevice': 'Enregistré sur cet appareil',
      'history.status.couldNotSave': 'Échec d\'enregistrement',
      'serviceDetail.showAtCounter': 'Présenter le QR au guichet',
      'serviceDetail.submitSigned': 'Envoyer une demande signée',
      'serviceDetail.actionsHint':
          'Présentez le QR au guichet, ou envoyez une demande signée à distance.',
      'services.title': 'Services',
      'services.notSignedIn': 'Pas de session. Reconnectez-vous pour charger les services.',
      'services.loadFailed': 'Impossible de charger les services',
      'services.empty': 'Aucun service disponible',
      'services.goSignIn': 'Aller à la connexion',
      'serviceDetail.title': 'Détails du service',
      'serviceDetail.description': 'Description',
      'serviceDetail.fees': 'Frais',
      'serviceDetail.requiredDocs': 'Documents requis',
      'serviceDetail.generateQr': 'Générer le QR du service',
      'serviceDetail.requestSigned': 'Demande signée',
      'serviceDetail.signing': 'Signature en cours…',
      'serviceDetail.signNow': 'Signer numériquement',
      'serviceDetail.signedCreated': 'Demande signée créée ({id})',
      'serviceDetail.signHint': 'Crée un code unique avec votre ID et l\'horodatage. Synchronisable depuis le tableau de bord.',
      'serviceQr.title': 'QR de service',
      'serviceQr.description': 'Générez un QR avec votre ID et l\'heure actuelle (UTC).',
      'serviceQr.generate': 'Générer le QR',
      'serviceQr.payloadHint': 'Scanner décode un JSON avec l\'ID et l\'horodatage.',
      'serviceQr.savedPending': 'Enregistré sur cet appareil - en attente de sync.',
      'serviceQr.missingUser': 'ID manquant. Déconnectez-vous et reconnectez-vous.',
      'serviceQr.secureKeyMissing': 'Déconnectez-vous et reconnectez-vous pour charger la clé QR sécurisée.',
      'serviceQr.saveFailed': 'Le QR fonctionne hors ligne, mais l\'enregistrement a échoué. Vous pouvez toujours le montrer à un agent.',
      'serviceQr.scanTitle': 'Scanner pour vérifier l\'identité',
      'sync.nothingPending': 'Rien en attente à envoyer.',
      'sync.alreadySynced': 'Tout est déjà synchronisé.',
      'sync.uploadedRecords': '{count} enregistrement(s) envoyé(s).',
      'sync.syncedRecords': '{count} enregistrement(s) synchronisé(s).',
      'sync.failedToPending': 'Entrées échouées remises en file d\'attente.',
      'sync.queueReset': 'File d\'attente normalisée.',
      'history.refreshTooltip': 'Actualiser',
      'history.empty': 'Aucun QR enregistré.\nGénérez-en un depuis un service.',
      'history.emptyPayload': '(charge utile vide)',
      'history.share': 'Exporter / partager',
      'history.shareSubject': 'BridgeID QR - {name}',
      'admin.title': 'Console d\'administration',
      'admin.missingKey': 'ADMIN_API_KEY manquant.',
      'admin.users': 'Utilisateurs',
      'admin.serviceRecords': 'Enregistrements de service',
      'admin.agentScans': 'Scans des agents',
      'admin.activeKeys': 'Clés actives',
      'admin.agentKeys': 'Clés d\'agent',
      'admin.logs': 'Journaux d\'audit',
      'admin.noLogs': 'Aucun journal trouvé.',
      'admin.enable': 'Activer',
      'admin.disable': 'Désactiver',
      'admin.keyEnabled': 'Clé d\'agent activée',
      'admin.keyDisabled': 'Clé d\'agent désactivée',
      'admin.verifyDoc': 'Vérifier le document signé',
      'admin.verifyDocId': 'ID du document signé',
      'admin.verifySignature': 'Vérifier la signature',
      'admin.signatureValid': 'Signature valide : {ok}\nHash du payload : {hash}',
      // Service catalog: localized description / fees / required documents
      // (newline-separated; the screen splits on \n into bullet items).
      'service.birth_certificate.description':
          "Demande officielle d'une copie certifiée d'un acte de naissance auprès du registre civil.",
      'service.birth_certificate.fees':
          '5,00 DH — traitement le jour même selon disponibilité',
      'service.birth_certificate.requiredDocs':
          "CIN du parent ou tuteur légal\nLivret de famille\nConsentement parental si mineur",
      'service.national_id_renewal.description':
          "Renouvellement ou remplacement de la carte d'identité nationale électronique (CNIE).",
      'service.national_id_renewal.fees':
          'Gratuit pour le premier remplacement — 40,00 DH ensuite',
      'service.national_id_renewal.requiredDocs':
          "CNIE périmée ou abîmée\n2 photos d'identité\nActe de naissance",
      'service.passport_application.description':
          "Demande d'un nouveau passeport marocain ou renouvellement d'un passeport existant.",
      'service.passport_application.fees':
          '500,00 DH — traitement standard (4 à 6 semaines)',
      'service.passport_application.requiredDocs':
          "CNIE\nActe de naissance\n4 photos d'identité\nJustificatif de résidence\nTimbre fiscal",
      'service.family_record_book.description':
          "Document officiel attestant la composition familiale, délivré au mariage ou à la naissance.",
      'service.family_record_book.fees': 'Gratuit',
      'service.family_record_book.requiredDocs':
          "Acte de mariage\nCNIE des deux époux\nActes de naissance des enfants le cas échéant",
      'service.marriage_certificate.description':
          "Copie certifiée d'un acte de mariage du registre civil.",
      'service.marriage_certificate.fees': '5,00 DH',
      'service.marriage_certificate.requiredDocs':
          "CNIE des deux époux\nNuméro de référence de l'acte de mariage original",
      'service.death_certificate.description':
          "Copie officielle certifiée d'un acte de décès du registre civil.",
      'service.death_certificate.fees': '5,00 DH',
      'service.death_certificate.requiredDocs':
          "CIN du membre de famille demandeur\nInformations d'identité du défunt\nCertificat médical de décès si disponible",
      'service.residence_certificate.description':
          "Justificatif officiel de résidence délivré par la commune ou l'autorité de district pour vérification d'adresse.",
      'service.residence_certificate.fees': '10,00 DH',
      'service.residence_certificate.requiredDocs':
          "CNIE\nFacture (eau/électricité — 3 derniers mois) ou bail\nContrat de location ou titre de propriété si demandé",
      'service.certificate_of_life.description':
          "Certificat de vie requis par les caisses de retraite et les autorités étrangères.",
      'service.certificate_of_life.fees': '10,00 DH',
      'service.certificate_of_life.requiredDocs':
          "CNIE\nCertificat médical récent ou présence en personne à la commune",
      'service.driving_license_application.description':
          "Demande d'un permis de conduire marocain (Catégorie B) pour la première fois.",
      'service.driving_license_application.fees':
          '300,00 DH — Catégorie B (frais voiture/moto standards variables)',
      'service.driving_license_application.requiredDocs':
          "CNIE\nCertificat médical d'aptitude\nPreuve de réussite des examens théorique et pratique\n4 photos d'identité",
      'service.vehicle_registration.description':
          "Immatriculation d'un véhicule neuf ou transféré auprès de l'autorité des transports.",
      'service.vehicle_registration.fees':
          'Variable selon le type de véhicule et la puissance fiscale — à partir de 350,00 DH',
      'service.vehicle_registration.requiredDocs':
          "CIN\nFacture d'achat ou document de transfert du véhicule\nAttestation d'assurance\nCertificat de visite technique",
      'service.social_security_enrollment.description':
          "Inscription au système de sécurité sociale pour l'assurance maladie, les allocations familiales et la retraite.",
      'service.social_security_enrollment.fees':
          "Gratuit — l'employeur prend en charge l'inscription",
      'service.social_security_enrollment.requiredDocs':
          "CNIE\nContrat de travail ou déclaration de l'employeur\nActe de naissance\nRelevé d'identité bancaire (RIB)",
      'service.ramed_enrollment.description':
          "Inscription au programme d'assistance médicale pour les ménages à faible revenu.",
      'service.ramed_enrollment.fees':
          'Gratuit — éligibilité sous conditions de ressources',
      'service.ramed_enrollment.requiredDocs':
          "CIN\nJustificatif de revenu ou certificat d'indigence\nLivret de famille",
      'service.land_registry_extract.description':
          "Extrait officiel du registre foncier confirmant la propriété et le statut juridique d'un bien.",
      'service.land_registry_extract.fees': '150,00 DH',
      'service.land_registry_extract.requiredDocs':
          "CIN\nNuméro du titre foncier\nFormulaire de demande rempli",
      'service.judicial_record.description':
          "Certificat officiel de casier judiciaire, requis pour l'emploi, les visas et les démarches administratives.",
      'service.judicial_record.fees':
          'Gratuit — traité au tribunal local ou en ligne via les e-services',
      'service.judicial_record.requiredDocs': "CNIE\nActe de naissance",
      'service.tax_clearance_certificate.description':
          "Certificat de l'administration fiscale confirmant l'absence de dettes fiscales.",
      'service.tax_clearance_certificate.fees': 'Gratuit',
      'service.tax_clearance_certificate.requiredDocs':
          "CIN ou numéro d'immatriculation de la société\nNuméro d'identification fiscale\nDernière déclaration d'impôt",
    },
    'tzm': {
      'common.retry': 'Ɛreḍ daɣen',
      'common.refresh': 'Smiren',
      'common.cancel': 'Sefsex',
      'common.delete': 'Kkes',
      'common.ok': 'Ih',
      'common.done': 'Yekfa',
      'common.signOut': 'Ffeɣ',
      'app.name': 'BridgeID',
      'app.tagline': 'Anekcum-ik amadani, yufraren.',
      'nav.dashboard': 'Tafelwit',
      'nav.services': 'Tiddukliwin',
      'nav.profile': 'Amaɣnu',
      'nav.qrHistory': 'Amazrar QR',
      'service.birth_certificate.name': 'Asuter n tlalit',
      'service.national_id_renewal.name': 'Asnefli n CNIE',
      'service.passport_application.name': 'Asuter n upaspur',
      'service.family_record_book.name': 'Adlis n twacult',
      'service.marriage_certificate.name': 'Asuter n uzwaǧ',
      'service.death_certificate.name': 'Asuter n tmettant',
      'service.residence_certificate.name': 'Asuter n usɣar',
      'service.certificate_of_life.name': 'Asuter n tudert',
      'service.driving_license_application.name': 'Asuter n tezmert n unhaṛ',
      'service.vehicle_registration.name': 'Aklasi n ttumubil',
      'service.social_security_enrollment.name': 'Akcam ɣer CNSS',
      'service.ramed_enrollment.name': 'Tallelt tasnijya RAMED',
      'service.land_registry_extract.name': 'Asuffeɣ aklasi n tmurt',
      'service.judicial_record.name': 'Asuter n umasun',
      'service.tax_clearance_certificate.name': 'Asuter n usrid n yifka',
      'form.nationalId.label': 'Asunan aɣerfan',
      'form.nationalId.hint': 'Sekcem asunan-ik aɣerfan',
      'form.pin.label': 'Tazaɣalt',
      'form.pin.hint': 'Sekcem tazaɣalt-ik',
      'form.pin.show': 'Sken tazaɣalt',
      'form.pin.hide': 'Ffer tazaɣalt',
      'profile.title': 'Amaɣnu',
      'profile.lastSync': 'Asegdel aneggaru',
      'profile.never': 'Ulac',
      'profile.appVersion': 'Lqem n usnas',
      'profile.nationalId': 'Asunan aɣerfan',
      'profile.unnamedAccount': 'Amiḍan',
      'profile.about': 'Ɣef',
      'profile.bioOpen.subtitle':
          'Asentem yal tikkelt mara teldiḍ asnas.',
      'profile.bioOpen': 'Sgel s biometric seld uftuḥ',
      'profile.bioSync': 'Biometric i usegdel',
      'profile.appLanguage': 'Tutlayt n usnas',
      'profile.language.title': 'Tutlayt',
      'profile.language.subtitle': 'Fren tutlayt i tesbedded deg usnas.',
      'profile.security': 'Taɣellist',
      'profile.bio.web': 'Biometric ur tella ara deg web.',
      'profile.openAdmin': 'Tafelwit n unedbal',
      'login.title': 'Kcem',
      'login.subtitle': 'Seqdec asunan-ik d tazaɣalt i uɣawas.',
      'login.button': 'Kcem',
      'dashboard.welcome': 'Ansuf-ik-d daɣen',
      'dashboard.hero.subtitle': 'Ɣer tiddukliwin-ik d usgdel n iseklasen.',
      'dashboard.pending': 'Yettraǧu',
      'dashboard.syncing': 'Asegdel...',
      'dashboard.synced': 'Yesegdel',
      'dashboard.failed': 'Yexṣer',
      'dashboard.retryFailed': 'Ɛreḍ daɣen',
      'dashboard.syncNow': 'Segdel tura',
      'dashboard.resetQueue': 'Smiren taslist',
      'dashboard.services.title': 'Tiddukliwin',
      'dashboard.services.subtitle': 'Wali tiddukliwin, isemli d yiseklasen imasinen.',
      'dashboard.recent.title': 'Tigawt taneggarut',
      'dashboard.recent.empty': 'Ulac tigawt. Snulfu QR-ik amezwaru.',
      'dashboard.recent.seeAll': 'Wali akk',
      'dashboard.browseServices': 'Wali akk tiddukliwin',
      'dashboard.offlineBanner':
          'Bla tuqqna — QR-inek ad ttwasrasen mi d-tuɣal tuqqna.',
      'profile.accountVerified': 'Tamagit tettwasebded',
      'history.couldNotSave': 'Ur yezmir ara ad ikles QR-a deg umiḍan-ik.',
      'history.status.submitted': 'Yettwazen',
      'history.status.savedOnDevice': 'Yettwakles ɣef uselkim',
      'history.status.couldNotSave': 'Akles yexṣer',
      'serviceDetail.showAtCounter': 'Sken QR ɣef tewwurt',
      'serviceDetail.submitSigned': 'Azen asuter yettwasign',
      'serviceDetail.actionsHint':
          'Sken QR ɣef tewwurt, neɣ azen asuter yettwasign s lebɛid.',
      'services.title': 'Tiddukliwin',
      'services.notSignedIn': 'Ulac tafrant. Kccem daɣen i usali n tiddukliwin.',
      'services.loadFailed': 'Ur yezmir ara ad yali tiddukliwin',
      'services.empty': 'Ulac tiddukliwin',
      'services.goSignIn': 'Ddu ɣer ukcem',
      'serviceDetail.title': 'Tamagit n tiddukla',
      'serviceDetail.description': 'Aglam',
      'serviceDetail.fees': 'Isemli',
      'serviceDetail.requiredDocs': 'Yiseklasen imasinen',
      'serviceDetail.generateQr': 'Snulfu QR n tiddukla',
      'serviceDetail.requestSigned': 'Asuter yettwasign',
      'serviceDetail.signing': 'Asign...',
      'serviceDetail.signNow': 'Sign s uselkim',
      'serviceDetail.signedCreated': 'Asuter yettwasign ({id})',
      'serviceDetail.signHint': 'Isnulfu asulay d asunan-ik d akud. Yezmer ad yesegdel send.',
      'serviceQr.title': 'QR n tiddukla',
      'serviceQr.description': 'Snulfu QR s usunan-ik d wakud amiran.',
      'serviceQr.generate': 'Snulfu QR',
      'serviceQr.payloadHint': 'Anadi yefk JSON s usunan d wakud.',
      'serviceQr.savedPending': 'Yettwakles ɣef uselkim - yettraǧu asegdel.',
      'serviceQr.missingUser': 'Asunan ur yuli ara. Ffeɣ syen kcem daɣen.',
      'serviceQr.secureKeyMissing': 'Ffeɣ syen kcem daɣen i tafart n QR.',
      'serviceQr.saveFailed': 'QR ixdem bla internet, maṣ akles yexṣer. Tezmer ad t-teskneḍ i wakil.',
      'serviceQr.scanTitle': 'Nadi i usenqed n usunan',
      'sync.nothingPending': 'Ulac ayen yettraǧun.',
      'sync.alreadySynced': 'Akk yesegdel.',
      'sync.uploadedRecords': 'Yeffeɣ {count} n iseklasen.',
      'sync.syncedRecords': 'Yesegdel {count} n iseklasen.',
      'sync.failedToPending': 'Izirig yettwakkes ɣer taslist.',
      'sync.queueReset': 'Taslist tettwasmir.',
      'history.refreshTooltip': 'Smiren',
      'history.empty': 'Ulac iseklasen QR.\nSnulfu yiwen seg tiddukliwin.',
      'history.emptyPayload': '(aseɣẓan d ilem)',
      'history.share': 'Siɣez / bḍu',
      'history.shareSubject': 'BridgeID QR - {name}',
      'admin.title': 'Tafelwit n unedbal',
      'admin.missingKey': 'ADMIN_API_KEY ur yelli ara.',
      'admin.users': 'Iseqdacen',
      'admin.serviceRecords': 'Iseklasen n tiddukliwin',
      'admin.agentScans': 'Inadi n wakilen',
      'admin.activeKeys': 'Tisura tineggura',
      'admin.agentKeys': 'Tisura n wakilen',
      'admin.logs': 'Amazrar n usqerdec',
      'admin.noLogs': 'Ulac amazrar.',
      'admin.enable': 'Snekcem',
      'admin.disable': 'Sens',
      'admin.keyEnabled': 'Tasart n wakil tesnekcem',
      'admin.keyDisabled': 'Tasart n wakil tesna',
      'admin.verifyDoc': 'Senqed amagrad yettwasign',
      'admin.verifyDocId': 'ID n umagrad yettwasign',
      'admin.verifySignature': 'Senqed asign',
      'admin.signatureValid': 'Asign yelha: {ok}\nHash: {hash}',
      'service.birth_certificate.description':
          'Asuter unsib n tnaslit n tnaslit n tlalit seg uregster amadan.',
      'service.birth_certificate.fees':
          '5,00 DH — taqamt deg wass-nni ma tella',
      'service.birth_certificate.requiredDocs':
          'CNIE n umaraw neɣ n win iqebbel\nAdlis n twacult\nAṣewweb n umaraw ma yella d ameẓyan',
      'service.national_id_renewal.description':
          'Asnefli neɣ asbeddi n tkarda taɣerfant tilektrunit (CNIE).',
      'service.national_id_renewal.fees':
          'Baṭel i usbeddi amezwaru — 40,00 DH i wid d-iteddun',
      'service.national_id_renewal.requiredDocs':
          'CNIE yekfan neɣ yexṣren\n2 tewlafin\nAsuter n tlalit',
      'service.passport_application.description':
          'Asuter n upaspur amaynut neɣ asnefli n win yellan.',
      'service.passport_application.fees':
          '500,00 DH — taqamt tamatut (4 ar 6 imalasen)',
      'service.passport_application.requiredDocs':
          'CNIE\nAsuter n tlalit\n4 tewlafin\nAtbu n usɣar\nTimber n tjebbawt',
      'service.family_record_book.description':
          'Adlis unsib i wesɣen n twacult, yettunefken di zwaǧ neɣ tlalit.',
      'service.family_record_book.fees': 'Baṭel',
      'service.family_record_book.requiredDocs':
          'Asuter n uzwaǧ\nCNIE n sin n yergazen\nIsuteren n tlalit n warraw ma yella',
      'service.marriage_certificate.description':
          'Tanaslit n usuter n uzwaǧ seg uregster amadan.',
      'service.marriage_certificate.fees': '5,00 DH',
      'service.marriage_certificate.requiredDocs':
          'CNIE n sin n yergazen\nUṭṭun n umaray n usuter n uzwaǧ amezwaru',
      'service.death_certificate.description':
          'Tanaslit unsibt n usuter n tmettant seg uregster amadan.',
      'service.death_certificate.fees': '5,00 DH',
      'service.death_certificate.requiredDocs':
          'CNIE n yiwen seg twacult\nIsalan n tmagit n win yemmuten\nAsuter asnijya n tmettant ma yella',
      'service.residence_certificate.description':
          'Atbu unsib n usɣar yettunefken sɣur tjmaɛt taqlilit i usenqed n tansa.',
      'service.residence_certificate.fees': '10,00 DH',
      'service.residence_certificate.requiredDocs':
          'CNIE\nTabuṣṣart (aman/tinikt — 3 wagguren ineggura) neɣ akrah\nAsuter n ukrah neɣ azamul n tlelli ma yella',
      'service.certificate_of_life.description':
          'Asuter n tudert i ttralan ifessasen n tneflit d wakuẓ ibarraniyen.',
      'service.certificate_of_life.fees': '10,00 DH',
      'service.certificate_of_life.requiredDocs':
          'CNIE\nAsuter asnijya amaynut neɣ asentem-ik s timad-ik di tjmaɛt',
      'service.driving_license_application.description':
          'Asuter n tezmert n unhaṛ tamerrukit (Aɣanib B) i tikkelt tamezwarut.',
      'service.driving_license_application.fees':
          '300,00 DH — Aɣanib B (idriben n ttumubil/dṛaja ttbeddilen)',
      'service.driving_license_application.requiredDocs':
          'CNIE\nAsuter asnijya n tudert\nAtbu n ucinan n usenqed adyalan d uknad\n4 tewlafin',
      'service.vehicle_registration.description':
          'Aklasi n ttumubil tamaynut neɣ yettmuddun ɣer tdebbart n usaḍen.',
      'service.vehicle_registration.fees':
          'Yettbeddil s wanaw n ttumubil d tezmert tjebbawit — seg 350,00 DH',
      'service.vehicle_registration.requiredDocs':
          'CNIE\nFatura n usaɣ neɣ atbu n usakid\nAsuter n usegmel\nAsuter n usenqed atiknik',
      'service.social_security_enrollment.description':
          'Akcam ɣer unagraw n tɣellist tamettit i usegmel asnijya, tikciḍin n twacult, d tneflit.',
      'service.social_security_enrollment.fees':
          'Baṭel — bab n umahil ad iqdec aklasi',
      'service.social_security_enrollment.requiredDocs':
          'CNIE\nAsuter n umahil neɣ asnubeg n bab n umahil\nAsuter n tlalit\nIsalan n ubanka (RIB)',
      'service.ramed_enrollment.description':
          'Akcam ɣer wahil n tallelt tasnijya i twaculin tilemmasin n udrim.',
      'service.ramed_enrollment.fees': 'Baṭel — s tilawin n udrim',
      'service.ramed_enrollment.requiredDocs':
          'CNIE\nAtbu n udrim neɣ asuter n tewzelt\nAdlis n twacult',
      'service.land_registry_extract.description':
          'Asuffeɣ unsib seg uregster n tmurt yesseflalin tanḍellt d wadeg azerfan.',
      'service.land_registry_extract.fees': '150,00 DH',
      'service.land_registry_extract.requiredDocs':
          'CNIE\nUṭṭun n urzem n tmurt\nAfayl n usuter yeččuren',
      'service.judicial_record.description':
          'Asuter unsib n usaras azerfan, ittraǧa i umahil, vizat, d tegnaḍin tinedbalin.',
      'service.judicial_record.fees':
          'Baṭel — yettwaqdac di tsenbeḍt taqlilit neɣ s e-services',
      'service.judicial_record.requiredDocs': 'CNIE\nAsuter n tlalit',
      'service.tax_clearance_certificate.description':
          'Asuter sɣur tnedbalt n yifka isefraran ulac iddebren n yifka.',
      'service.tax_clearance_certificate.fees': 'Baṭel',
      'service.tax_clearance_certificate.requiredDocs':
          'CNIE neɣ uṭṭun n uklasi n tkebbanit\nUṭṭun n tmagit n yifka\nAsutter n yifka aneggaru',
    },
  };

  static String t(BuildContext context, String key) {
    final code = Localizations.localeOf(context).languageCode;
    return _dictionary[code]?[key] ?? _dictionary['en']![key] ?? key;
  }

  /// Like [t] but falls back to a runtime-provided value when the key is
  /// missing from every dictionary. Used for backend-sourced strings (e.g.
  /// service names) where the canonical text comes from the database.
  static String tOr(BuildContext context, String key, String fallback) {
    final code = Localizations.localeOf(context).languageCode;
    return _dictionary[code]?[key] ?? _dictionary['en']?[key] ?? fallback;
  }

  static String tf(
    BuildContext context,
    String key, {
    Map<String, String> args = const {},
  }) {
    var value = t(context, key);
    args.forEach((k, v) {
      value = value.replaceAll('{$k}', v);
    });
    return value;
  }
}
