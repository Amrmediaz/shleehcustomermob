import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/strings/language.dart';
import '../../../../core/styles/app_theme.dart';
import '../../../../core/styles/text/text_style.dart';
import '../../../../core/util/Constants.dart';
import '../../../../core/widgets/action_btn.dart';
import '../../../../core/widgets/app_bar_back.dart';
import '../../../../injection_container.dart';
import '../../../home_page/presentation/pages/home_page.dart';
import '../../domain/usecases/payment_book_qpay.dart';
import '../../domain/usecases/send_qpay_otp.dart';
import '../../domain/usecases/get_qpay_cards.dart';
import '../../domain/usecases/confirm_qpay.dart';

// QPay (installments) checkout — mirrors shleeh_com_customer's
// QpayCheckoutPage.jsx step-by-step, restyled with this app's own theme
// tokens (primaryColor/secondaryColor, DEFAULT_CORNER, TextStyles).
//
// Every step here hits a real, confirmed (24 Aug 2026) backend endpoint:
// phone (bookPaymentQpay), OTP send/resend (sendQpayOtp), OTP verify +
// card list (BookingQpayCards), and the final confirm/charge
// (BookingQpayConfirm) — exactly like the website version.
const List<String> _kQpaySteps = ['plan', 'verify', 'card', 'confirm'];

// TEMP — flow-preview mode. While true, the phone step skips
// bookPaymentQpay (using local dummy plan data instead) and the OTP step
// skips sendQpayOtp entirely, so the whole ticket flow — phone, plan,
// verify, card, confirm, success — can be clicked through end-to-end
// without touching the backend at all. A banner on screen makes this
// obvious.
//
// OFF now that the real endpoints are confirmed and hit the same shleeh.com
// base URL as every other API call in this app (see BASE_URL in
// core/network/urls.dart) — backend test deploy expected 24 Aug 2026. Flip
// back to true only if you need a UI-only walkthrough again.
const bool _kQpayBypassApi = false;

// Oman's country code, as a literal prefix on the number sent to the API —
// matches the confirmed real payload shape ("0096891412923" in Ahmed's
// test), which is "00" + "968" + the 8-digit local number. The user only
// ever types the 8 digits; this gets stitched on right before either QPay
// call goes out, so they never have to type/see the prefix themselves.
const String _kQpayPhonePrefix = '00968';

class QpayCheckoutScreen extends StatefulWidget {
  final int bookingId;
  final bool isChalet;
  final double totalPrice;

  const QpayCheckoutScreen({
    super.key,
    required this.bookingId,
    required this.isChalet,
    required this.totalPrice,
  });

  @override
  State<QpayCheckoutScreen> createState() => _QpayCheckoutScreenState();
}

class _QpayCheckoutScreenState extends State<QpayCheckoutScreen> {
  // 'phone' -> real bookPaymentQpay call. 'plan' -> real plansList from
  // that response. 'verify'|'card'|'confirm' -> still UI-only mockups.
  // 'success' -> final confirmation screen.
  String _stage = 'phone';

  final TextEditingController _phoneController = TextEditingController();
  String? _phoneError;
  bool _submitting = false;
  String? _submitError;

  List<Map<String, dynamic>> _plans = [];
  dynamic _principalId;
  String? _paymentNumber;
  int? _selectedPlanId;

  bool _otpSending = false;
  String? _otpSendError;
  bool _otpResent = false;
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());

  // Populated from BookingQpayCards, called once the OTP is entered. Each
  // entry is normalized to {'id': ..., 'label': ...} — see _normalizeCard.
  List<Map<String, String>> _cards = [];
  Map<String, String>? _selectedCard;
  bool _otpVerifying = false;
  String? _otpVerifyError;

  bool _confirming = false;
  String? _confirmError;

  @override
  void dispose() {
    _phoneController.dispose();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _otpFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  Map<String, dynamic>? get _activePlan {
    if (_plans.isEmpty) return null;
    return _plans.firstWhere(
      (p) => p['id'] == _selectedPlanId,
      orElse: () => _plans.first,
    );
  }

  double _planTotal(Map<String, dynamic> plan) {
    final installments = plan['installments'] as List? ?? [];
    return installments.fold<double>(
        0, (sum, i) => sum + (double.tryParse('${i['amount']}') ?? 0));
  }

  // CONFIRMED response shape (Ahmed Younes, 24 Aug 2026): a cardsList of
  // { account, cardNumber, expiryDate, cardHolderName }. cardNumber comes
  // pre-masked from the backend ("464156****3343") but can also be null
  // (his BNPL001 sample), so fall back to the account id itself as the
  // label rather than a generic placeholder. "account" doubles as the id:
  // it's exactly the field BookingQpayConfirm expects back to identify
  // which card was picked.
  Map<String, String> _normalizeCard(dynamic raw, int idx) {
    if (raw is String) return {'id': raw, 'label': raw};
    if (raw is Map) {
      final label = (raw['cardNumber'] ?? raw['account'] ?? 'Card ${idx + 1}').toString();
      final id = (raw['account'] ?? raw['id'] ?? raw['cardId'] ?? label).toString();
      return {'id': id, 'label': label};
    }
    final label = 'Card ${idx + 1}';
    return {'id': label, 'label': label};
  }

  String _formatDate(String? iso) {
    if (iso == null) return '';
    final d = DateTime.tryParse(iso);
    if (d == null) return iso;
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  // Local-only installment plan for flow-preview mode — same shape as the
  // real plansList (name/id/installments[dueDate,amount,period]) so every
  // downstream widget (plan cards, summary, totals) renders exactly as it
  // would with real data.
  List<Map<String, dynamic>> _buildDummyPlans() {
    final total = widget.totalPrice > 0 ? widget.totalPrice : 20.0;
    final per = double.parse((total / 4).toStringAsFixed(3));
    final now = DateTime.now();
    return [
      {
        'name': 'QPAY BNPL',
        'id': 1,
        'installments': List.generate(4, (i) {
          final due = DateTime(now.year, now.month + i, now.day);
          return {
            'dueDate':
                '${due.year.toString().padLeft(4, '0')}-${due.month.toString().padLeft(2, '0')}-${due.day.toString().padLeft(2, '0')}',
            'amount': per,
            'period': i + 1,
          };
        }),
      },
    ];
  }

  Future<void> _submitPhone() async {
    final trimmed = _phoneController.text.trim();
    if (trimmed.length != 8) {
      setState(() => _phoneError = getTextByKey(key: TranslationKey.keyQpayPhoneInvalid));
      return;
    }
    final fullPhone = _kQpayPhonePrefix + trimmed;
    setState(() {
      _phoneError = null;
      _submitError = null;
      _submitting = true;
    });

    if (_kQpayBypassApi) {
      final dummyPlans = _buildDummyPlans();
      setState(() {
        _submitting = false;
        _plans = dummyPlans;
        _principalId = 'TEST-PRINCIPAL';
        _paymentNumber = 'TESTFLOW';
        _selectedPlanId = dummyPlans.first['id'] as int?;
        _stage = 'plan';
      });
      return;
    }

    final result = await sl<BookingPaymentQpayUsecase>().call(
      paymentData: {
        "bookingId": widget.bookingId,
        "paymentType": 3,
        "phoneNumber": fullPhone,
      },
      isChalet: widget.isChalet,
    );

    if (!mounted) return;
    result.fold(
      (failure) {
        setState(() {
          _submitting = false;
          _submitError = getTextByKey(key: TranslationKey.keyError);
        });
      },
      (data) {
        final plansList = (data['plansList'] as List? ?? [])
            .cast<Map<String, dynamic>>();
        setState(() {
          _submitting = false;
          _plans = plansList;
          _principalId = data['principalId'];
          _paymentNumber = data['paymentNumber']?.toString();
          _selectedPlanId = plansList.isNotEmpty ? plansList.first['id'] as int? : null;
          _stage = 'plan';
        });
      },
    );
  }

  // Sends (or resends) the OTP via BookingQpayOTP, keyed by the
  // paymentNumber from the phone step. `advance` moves the user into the
  // verify step (first send, from the plan step) vs. just re-triggering
  // the code while already there (resend).
  Future<void> _sendOtp(bool advance) async {
    setState(() {
      _otpSendError = null;
      _otpResent = false;
      _otpSending = true;
    });

    if (_kQpayBypassApi) {
      setState(() {
        _otpSending = false;
        if (advance) {
          _stage = 'verify';
        } else {
          _otpResent = true;
        }
      });
      return;
    }

    final result = await sl<SendQpayOtpUsecase>().call(
      otpData: {
        "PaymentNumber": _paymentNumber,
        "phoneNumber": _kQpayPhonePrefix + _phoneController.text.trim(),
      },
      isChalet: widget.isChalet,
    );

    if (!mounted) return;
    result.fold(
      (failure) {
        setState(() {
          _otpSending = false;
          _otpSendError = getTextByKey(key: TranslationKey.keyError);
        });
      },
      (message) {
        setState(() {
          _otpSending = false;
          if (advance) {
            _stage = 'verify';
          } else {
            _otpResent = true;
          }
        });
      },
    );
  }

  // Verifies the entered OTP via BookingQpayCards and, on success, loads
  // the customer's real QPay cards to pick from on the next step.
  Future<void> _verifyOtp() async {
    setState(() {
      _otpVerifyError = null;
      _otpVerifying = true;
    });

    final code = _otpControllers.map((c) => c.text).join();

    if (_kQpayBypassApi) {
      setState(() {
        _otpVerifying = false;
        _stage = 'card';
      });
      return;
    }

    final result = await sl<GetQpayCardsUsecase>().call(
      cardsData: {
        "paymentNumber": _paymentNumber,
        "phoneNumber": _kQpayPhonePrefix + _phoneController.text.trim(),
        "otp": code,
      },
      isChalet: widget.isChalet,
    );

    if (!mounted) return;
    result.fold(
      (failure) {
        setState(() {
          _otpVerifying = false;
          _otpVerifyError = getTextByKey(key: TranslationKey.keyError);
        });
      },
      (data) {
        final rawList = data is List ? data : (data?['cards'] ?? data?['cardsList'] ?? []);
        final normalized = <Map<String, String>>[
          for (var i = 0; i < (rawList as List).length; i++) _normalizeCard(rawList[i], i),
        ];
        setState(() {
          _otpVerifying = false;
          _cards = normalized;
          _selectedCard = normalized.isNotEmpty ? normalized.first : null;
          _stage = 'card';
        });
      },
    );
  }

  // Final step — actually charges the selected card via BookingQpayConfirm.
  Future<void> _confirmPurchase() async {
    setState(() {
      _confirmError = null;
      _confirming = true;
    });

    if (_kQpayBypassApi) {
      setState(() {
        _confirming = false;
        _stage = 'success';
      });
      return;
    }

    final code = _otpControllers.map((c) => c.text).join();
    final result = await sl<ConfirmQpayUsecase>().call(
      confirmData: {
        "paymentNumber": _paymentNumber,
        "phoneNumber": _kQpayPhonePrefix + _phoneController.text.trim(),
        "otp": code,
        // PascalCase — CONFIRMED (Ahmed Younes, 24 Aug 2026): this endpoint
        // expects PrincipalId/PlanId capitalized while every other field
        // stays lowercase, same mixed-casing pattern QPAY_SEND_OTP_URL
        // already has (PaymentNumber vs phoneNumber).
        "PrincipalId": _principalId,
        "PlanId": _selectedPlanId,
        "account": _selectedCard?['id'],
      },
      isChalet: widget.isChalet,
    );

    if (!mounted) return;
    result.fold(
      (failure) {
        setState(() {
          _confirming = false;
          _confirmError = getTextByKey(key: TranslationKey.keyError);
        });
      },
      (data) {
        setState(() {
          _confirming = false;
          _stage = 'success';
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: PADDING_PAGE,
          children: [
            AppBarBack(leadingWidgetAction: () => Navigator.pop(context)),
            const SizedBox(height: 10),
            if (_kQpayBypassApi) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF6DC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: yellowAppColor),
                ),
                child: Text(
                  '🧪 Test mode — flow only, no server calls yet. Set _kQpayBypassApi to false in qpay_checkout_screen.dart when ready.',
                  style: TextStyles.textStyleHelper(context, scaleFactor: 0.38)
                      .copyWith(color: const Color(0xFF6b5300)),
                ),
              ),
              const SizedBox(height: 12),
            ],
            _buildHeader(context),
            const SizedBox(height: 18),
            if (_kQpaySteps.contains(_stage)) _buildStepRail(context),
            if (_kQpaySteps.contains(_stage)) const SizedBox(height: 20),
            _buildStageContent(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(DEFAULT_CORNER),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Shleeh · QPay',
                style: TextStyles.textStyleButton(context, scaleFactor: 0.62),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(999),
                ),
                // principalId isn't shown to the user (it's QPay's own
                // internal application reference, kept in state for the
                // verify/card/confirm steps once their real endpoints are
                // shared) — surfaced as a semantics label so it's still
                // inspectable while those steps are mockups.
                child: Semantics(
                  label: _principalId != null ? 'principalId:$_principalId' : null,
                  child: Text(
                    '#${widget.bookingId}${_paymentNumber != null ? ' · $_paymentNumber' : ''}',
                    style: TextStyles.textStyleHelper(context, scaleFactor: 0.4)
                        .copyWith(color: Colors.white70),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            getTextByKey(key: TranslationKey.keyQpayDueToday),
            style: TextStyles.textStyleHelper(context, scaleFactor: 0.42)
                .copyWith(color: Colors.white70),
          ),
          Text(
            '${widget.totalPrice.toStringAsFixed(3)} ${getTextByKey(key: TranslationKey.keyOMR)}',
            style: TextStyles.textStyleHeadline(context, titleSizeFactor: 1.1)
                .copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildStepRail(BuildContext context) {
    final stepIndex = _kQpaySteps.indexOf(_stage);
    final labels = {
      'plan': TranslationKey.keyQpayStepPlan,
      'verify': TranslationKey.keyQpayStepVerify,
      'card': TranslationKey.keyQpayStepCard,
      'confirm': TranslationKey.keyQpayStepConfirm,
    };
    return Row(
      children: List.generate(_kQpaySteps.length, (i) {
        final isActive = i == stepIndex;
        final isDone = i < stepIndex;
        return Expanded(
          child: Column(
            children: [
              CircleAvatar(
                radius: 15,
                backgroundColor: isActive || isDone ? primaryColor : Colors.grey.shade200,
                child: isDone
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : Text(
                        '${i + 1}',
                        style: TextStyle(
                          color: isActive ? Colors.white : Colors.grey.shade600,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
              ),
              const SizedBox(height: 4),
              Text(
                getTextByKey(key: labels[_kQpaySteps[i]]!),
                style: TextStyles.textStyleHelper(context, scaleFactor: 0.36).copyWith(
                  color: isActive ? secondaryColor : Colors.grey.shade500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStageContent(BuildContext context) {
    switch (_stage) {
      case 'phone':
        return _buildPhoneStage(context);
      case 'plan':
        return _buildPlanStage(context);
      case 'verify':
        return _buildVerifyStage(context);
      case 'card':
        return _buildCardStage(context);
      case 'confirm':
        return _buildConfirmStage(context);
      case 'success':
        return _buildSuccessStage(context);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPhoneStage(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(getTextByKey(key: TranslationKey.keyQpayPhoneTitle),
            style: TextStyles.textStyleHeadline(context).copyWith(color: primaryColor)),
        const SizedBox(height: 8),
        Text(getTextByKey(key: TranslationKey.keyQpayPhoneSub),
            style: TextStyles.textStyleBody(context)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: formGreyColor,
            borderRadius: BorderRadius.circular(DEFAULT_CORNER),
          ),
          child: Row(
            children: [
              // Fixed, non-editable prefix — the user only types their own
              // 8-digit local number; "00968" is stitched on before the
              // value ever reaches the API (see _submitPhone/_sendOtp).
              Text(
                _kQpayPhonePrefix,
                style: TextStyles.textStyleForm(context).copyWith(color: Colors.grey.shade500),
              ),
              const SizedBox(width: 6),
              Container(width: 1, height: 20, color: Colors.grey.shade300),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textDirection: TextDirection.ltr,
                  maxLength: 8,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(8),
                  ],
                  style: TextStyles.textStyleForm(context),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    counterText: '',
                    hintText: getTextByKey(key: TranslationKey.keyQpayPhonePlaceholder),
                    hintStyle: TextStyles.textStyleHint(context),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Persistent note (not an error) — this number is checked against
        // QPay's own registry server-side, so it has to be the number the
        // user actually registered with QPay, not just any phone number.
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline_rounded, size: 14, color: Colors.grey.shade500),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                getTextByKey(key: TranslationKey.keyQpayPhoneHelper),
                style: TextStyles.textStyleHelper(context).copyWith(color: Colors.grey.shade600),
              ),
            ),
          ],
        ),
        if (_phoneError != null) ...[
          const SizedBox(height: 8),
          Text(_phoneError!, style: TextStyles.textStyleHelper(context).copyWith(color: Colors.red)),
        ],
        if (_submitError != null) ...[
          const SizedBox(height: 8),
          Text(_submitError!, style: TextStyles.textStyleHelper(context).copyWith(color: Colors.red)),
        ],
        const SizedBox(height: 20),
        ActionBtn(
          isLoading: _submitting,
          onPressed: _submitPhone,
          btnTitle: TranslationKey.keyQpayContinue,
          btnColor: primaryColor,
        ),
        const SizedBox(height: 10),
        ActionBtn(
          onPressed: () => Navigator.pop(context),
          btnTitle: TranslationKey.keyQpayBackToPaymentChoice,
          btnColor: Colors.white,
          btnTxtColor: primaryColor,
          borderColor: primaryColor,
        ),
      ],
    );
  }

  Widget _buildPlanStage(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(getTextByKey(key: TranslationKey.keyQpayChoosePlanTitle),
            style: TextStyles.textStyleHeadline(context).copyWith(color: primaryColor)),
        const SizedBox(height: 8),
        Text(getTextByKey(key: TranslationKey.keyQpayChoosePlanSub),
            style: TextStyles.textStyleBody(context)),
        const SizedBox(height: 16),
        ..._plans.asMap().entries.map((entry) {
          final idx = entry.key;
          final plan = entry.value;
          final installments = (plan['installments'] as List? ?? []);
          final first = installments.isNotEmpty ? installments.first as Map : null;
          final total = _planTotal(plan);
          final isSelected = _selectedPlanId == plan['id'];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () => setState(() => _selectedPlanId = plan['id'] as int?),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(DEFAULT_CORNER),
                      border: Border.all(
                        color: isSelected ? primaryColor : Colors.grey.shade300,
                        width: isSelected ? 1.6 : 1,
                      ),
                      color: isSelected ? primaryColor.withOpacity(0.05) : Colors.white,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected ? Icons.check_circle : Icons.circle_outlined,
                          color: isSelected ? primaryColor : Colors.grey.shade400,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${plan['name'] ?? getTextByKey(key: TranslationKey.keyQpayStepPlan)}',
                                  style: TextStyles.textStyleTitle(context).copyWith(color: secondaryColor)),
                              const SizedBox(height: 2),
                              Text(
                                getTextByKey(
                                        key: TranslationKey.keyQpayPlanInstallments,
                                        namedArgs: {'n': '${installments.length}'}) +
                                    (first != null
                                        ? ' · ${getTextByKey(key: TranslationKey.keyQpayPlanFirstDue, namedArgs: {'date': _formatDate(first['dueDate']?.toString())})}'
                                        : ''),
                                style: TextStyles.textStyleHelper(context, scaleFactor: 0.45)
                                    .copyWith(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              first != null ? '${double.tryParse('${first['amount']}')?.toStringAsFixed(3) ?? '—'}' : '—',
                              style: TextStyles.textStyleTitle(context).copyWith(color: secondaryColor),
                            ),
                            Text(
                              getTextByKey(key: TranslationKey.keyQpayInstallmentUnit),
                              style: TextStyles.textStyleHelper(context, scaleFactor: 0.32)
                                  .copyWith(color: Colors.grey.shade500),
                            ),
                            if (total > 0)
                              Text(
                                getTextByKey(key: TranslationKey.keyQpayPlanTotal, namedArgs: {'total': total.toStringAsFixed(3)}),
                                style: TextStyles.textStyleHelper(context, scaleFactor: 0.35)
                                    .copyWith(color: Colors.grey.shade500),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (idx == 0 && _plans.length > 1)
                    Positioned(
                      top: -8,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: yellowAppColor,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          getTextByKey(key: TranslationKey.keyQpayMostPopular),
                          style: TextStyles.textStyleHelper(context, scaleFactor: 0.32)
                              .copyWith(color: secondaryColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
        if (_otpSendError != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(_otpSendError!, style: TextStyles.textStyleHelper(context).copyWith(color: Colors.red)),
          ),
        const SizedBox(height: 8),
        ActionBtn(
          isLoading: _otpSending,
          onPressed: _selectedPlanId == null ? () {} : () => _sendOtp(true),
          btnTitle: TranslationKey.keyQpayContinue,
          btnColor: primaryColor,
        ),
      ],
    );
  }

  Widget _buildVerifyStage(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(getTextByKey(key: TranslationKey.keyQpayVerifyTitle),
            style: TextStyles.textStyleHeadline(context).copyWith(color: primaryColor)),
        const SizedBox(height: 8),
        Text(getTextByKey(key: TranslationKey.keyQpayVerifySub), style: TextStyles.textStyleBody(context)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: formGreyColor,
            borderRadius: BorderRadius.circular(DEFAULT_CORNER),
          ),
          child: Text(
            getTextByKey(key: TranslationKey.keyQpayCodeSentTo, namedArgs: {'phone': _kQpayPhonePrefix + _phoneController.text}),
            style: TextStyles.textStyleHelper(context),
          ),
        ),
        const SizedBox(height: 16),
        Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (i) {
              return SizedBox(
                width: 42,
                height: 52,
                child: TextField(
                  controller: _otpControllers[i],
                  focusNode: _otpFocusNodes[i],
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  maxLength: 1,
                  style: TextStyles.textStyleTitle(context).copyWith(color: secondaryColor),
                  decoration: InputDecoration(
                    counterText: '',
                    filled: true,
                    fillColor: formGreyColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (val) {
                    if (val.isNotEmpty && i < 5) {
                      _otpFocusNodes[i + 1].requestFocus();
                    }
                    setState(() {});
                  },
                ),
              );
            }),
          ),
        ),
        if (_otpResent && _otpSendError == null)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              getTextByKey(key: TranslationKey.keyQpayCodeSentTo, namedArgs: {'phone': _kQpayPhonePrefix + _phoneController.text}),
              style: TextStyles.textStyleHelper(context).copyWith(color: primaryColor),
            ),
          ),
        if (_otpSendError != null)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(_otpSendError!, style: TextStyles.textStyleHelper(context).copyWith(color: Colors.red)),
          ),
        if (_otpVerifyError != null)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(_otpVerifyError!, style: TextStyles.textStyleHelper(context).copyWith(color: Colors.red)),
          ),
        const SizedBox(height: 20),
        ActionBtn(
          isLoading: _otpVerifying,
          onPressed: _otpControllers.any((c) => c.text.isEmpty) || _otpVerifying
              ? () {}
              : _verifyOtp,
          btnTitle: TranslationKey.keyQpayVerifyContinue,
          btnColor: primaryColor,
        ),
        const SizedBox(height: 10),
        ActionBtn(
          isLoading: _otpSending,
          onPressed: () => _sendOtp(false),
          btnTitle: TranslationKey.keyQpayResendCode,
          btnColor: Colors.white,
          btnTxtColor: primaryColor,
          borderColor: primaryColor,
        ),
      ],
    );
  }

  Widget _buildCardStage(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(getTextByKey(key: TranslationKey.keyQpayPayWithTitle),
            style: TextStyles.textStyleHeadline(context).copyWith(color: primaryColor)),
        const SizedBox(height: 8),
        Text(getTextByKey(key: TranslationKey.keyQpayPayWithSub), style: TextStyles.textStyleBody(context)),
        const SizedBox(height: 16),
        if (_cards.isEmpty)
          Text(getTextByKey(key: TranslationKey.keyError),
              style: TextStyles.textStyleHelper(context).copyWith(color: Colors.red)),
        ..._cards.map((card) {
          final isSelected = _selectedCard?['id'] == card['id'];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () => setState(() => _selectedCard = card),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(DEFAULT_CORNER),
                  border: Border.all(color: isSelected ? primaryColor : Colors.grey.shade300, width: isSelected ? 1.6 : 1),
                  color: isSelected ? primaryColor.withOpacity(0.05) : Colors.white,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 24,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [secondaryColor, primaryColor]),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(card['label'] ?? '',
                          textDirection: TextDirection.ltr,
                          style: TextStyles.textStyleTitle(context).copyWith(color: secondaryColor)),
                    ),
                    Icon(isSelected ? Icons.check_circle : Icons.circle_outlined,
                        color: isSelected ? primaryColor : Colors.grey.shade400),
                  ],
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 8),
        ActionBtn(
          onPressed: _selectedCard == null ? () {} : () => setState(() => _stage = 'confirm'),
          btnTitle: TranslationKey.keyQpayUseThisCard,
          btnColor: primaryColor,
        ),
      ],
    );
  }

  Widget _buildConfirmStage(BuildContext context) {
    final plan = _activePlan;
    final installments = (plan?['installments'] as List? ?? []);
    final first = installments.isNotEmpty ? installments.first as Map : null;
    final total = plan != null ? _planTotal(plan) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(getTextByKey(key: TranslationKey.keyQpayReviewTitle),
            style: TextStyles.textStyleHeadline(context).copyWith(color: primaryColor)),
        const SizedBox(height: 8),
        Text(getTextByKey(key: TranslationKey.keyQpayReviewSub), style: TextStyles.textStyleBody(context)),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: formGreyColor,
            borderRadius: BorderRadius.circular(DEFAULT_CORNER),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              _summaryRow(context, TranslationKey.keyQpaySummaryPlan, '${plan?['name'] ?? '—'}'),
              _summaryRow(context, TranslationKey.keyQpaySummaryMonthly,
                  first != null ? '${double.tryParse('${first['amount']}')?.toStringAsFixed(3) ?? '—'}' : '—'),
              _summaryRow(context, TranslationKey.keyQpaySummaryCard, _selectedCard?['label'] ?? '—'),
              _summaryRow(context, TranslationKey.keyQpaySummaryTotal, total.toStringAsFixed(3), isLast: true),
            ],
          ),
        ),
        if (_confirmError != null)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(_confirmError!, style: TextStyles.textStyleHelper(context).copyWith(color: Colors.red)),
          ),
        const SizedBox(height: 20),
        ActionBtn(
          isLoading: _confirming,
          onPressed: _confirming ? () {} : _confirmPurchase,
          btnTitle: TranslationKey.keyQpayConfirmPurchase,
          btnColor: primaryColor,
        ),
      ],
    );
  }

  Widget _summaryRow(BuildContext context, String labelKey, String value, {bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: Colors.grey.shade300, width: 0.6)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(getTextByKey(key: labelKey), style: TextStyles.textStyleBody(context)),
          Text(value, style: TextStyles.textStyleTitle(context).copyWith(color: secondaryColor)),
        ],
      ),
    );
  }

  Widget _buildSuccessStage(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Icon(Icons.check_circle, color: primaryColor, size: MediaQuery.of(context).size.width / 3.2),
        const SizedBox(height: 16),
        Text(getTextByKey(key: TranslationKey.keyQpaySuccessTitle),
            style: TextStyles.textStyleTitle(context), textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(getTextByKey(key: TranslationKey.keyQpaySuccessSub),
            style: TextStyles.textStyleHelper(context), textAlign: TextAlign.center),
        const SizedBox(height: 20),
        ActionBtn(
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
              (Route<dynamic> route) => false,
            );
          },
          btnTitle: TranslationKey.keyBack,
          btnColor: primaryColor,
        ),
      ],
    );
  }
}
