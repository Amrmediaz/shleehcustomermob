import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shleehcustomer/features/booking/presentation/pages/booking_detail_page.dart';
import 'package:shleehcustomer/features/booking/presentation/widgets/booking_detail_page/data_widget/price_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shleehcustomer/core/network/urls.dart';
import 'package:shleehcustomer/core/styles/text/text_style.dart';
import 'package:shleehcustomer/core/util/Constants.dart';
import 'package:shleehcustomer/core/util/share_links.dart';
import 'package:shleehcustomer/core/util/characteristics_translator.dart';
import '../../../../../core/widgets/today_offer_widgets.dart';
import '../../../../../core/strings/language.dart';
import '../../../../../core/styles/app_theme.dart';
import '../../../../booking/presentation/pages/chalet_booking_date_page.dart';
import '../../../domain/entities/chalet_details_model.dart';

class ChaletDetailWidget extends StatefulWidget {
  final ChaletDetails chalet;
  const ChaletDetailWidget({Key? key, required this.chalet}) : super(key: key);

  @override
  State<ChaletDetailWidget> createState() => _ChaletDetailWidgetState();
}

class _ChaletDetailWidgetState extends State<ChaletDetailWidget>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _animationController;
  int _currentPage = 0;
  late Timer _autoSliderTimer;
  GoogleMapController? _mapController;
  bool _isFavorite = false;
  bool _expandedDescription = false;

  static const Color primaryColor = Color(0xFF6366F1);
  static const Color accentColor = Color(0xFFF97316);
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color softPriceColor = Color(0xFF8B5CF6);

  // Maps the English value the API stores for chaletType back to the
  // Arabic label used in the UI (same mapping used on the owner side).
  static const Map<String, String> _typeArabicLabels = {
    'Chalet': 'شاليه',
    'Resort': 'استراحة',
    'Hut': 'كوخ',
  };

  @override
  void initState() {
    super.initState();
    widget.chalet.buldingService = removeDuplicates(widget.chalet.buldingService);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    )..forward();

    _autoSliderTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients) {
        int nextPage = (_currentPage + 1) % widget.chalet.buldingImages.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _autoSliderTimer.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _openGoogleMaps() async {
    final lat = double.tryParse(widget.chalet.lat.toString()) ?? 0.0;
    final lng = double.tryParse(widget.chalet.lng.toString()) ?? 0.0;
    final mapsUrl = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';

    try {
      if (await canLaunchUrl(Uri.parse(mapsUrl))) {
        await launchUrl(Uri.parse(mapsUrl), mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  // ✅ Show Images Gallery with Grid & Horizontal Views
  void _showImageGalleryBottomSheet() {
    int viewMode = 0; // 0: Horizontal, 1: Grid

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Directionality(
                textDirection: TextDirection.rtl,
                child: SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: Column(
                    children: [
                      SizedBox(height: 90,),
                      SafeArea(
                        bottom: false,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'معرض الصور (${widget.chalet.buldingImages.length})',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.close_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // View Mode Buttons
                      Container(
                        padding: const EdgeInsets.all(12),
                        color: Colors.black87,
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => viewMode = 0),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: viewMode == 0
                                        ? primaryColor
                                        : Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: viewMode == 0
                                          ? primaryColor
                                          : Colors.white.withOpacity(0.2),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.view_carousel_rounded,
                                        color: viewMode == 0
                                            ? Colors.white
                                            : Colors.grey[400],
                                        size: 18,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'أفقي',
                                        style: TextStyle(
                                          color: viewMode == 0
                                              ? Colors.white
                                              : Colors.grey[400],
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => viewMode = 1),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: viewMode == 1
                                        ? primaryColor
                                        : Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: viewMode == 1
                                          ? primaryColor
                                          : Colors.white.withOpacity(0.2),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.grid_3x3_rounded,
                                        color: viewMode == 1
                                            ? Colors.white
                                            : Colors.grey[400],
                                        size: 18,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'شبكة',
                                        style: TextStyle(
                                          color: viewMode == 1
                                              ? Colors.white
                                              : Colors.grey[400],
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Content Area
                      Expanded(
                        child: Container(
                          color: Colors.black,
                          child: viewMode == 0
                              ? _buildHorizontalGallery()
                              : _buildGridGallery(),
                        ),
                      ),
                    ],
                  ),

                ));
          },
        );
      },
    );
  }

  // ✅ Horizontal Gallery View
  Widget _buildHorizontalGallery() {
    return PageView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: widget.chalet.buldingImages.length,
      itemBuilder: (context, index) {
        return _buildHighQualityImageItem(index);
      },
    );
  }

  // ✅ Grid Gallery View
  Widget _buildGridGallery() {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: widget.chalet.buldingImages.length,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
              ),
            ],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: BASE_URL + widget.chalet.buldingImages[index]["path"],
                  fit: BoxFit.cover,
                  memCacheHeight: 1200,
                  memCacheWidth: 1000,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[800],
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor:
                        AlwaysStoppedAnimation<Color>(primaryColor),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[800],
                    child: const Icon(
                      Icons.image_not_supported,
                      size: 40,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              // Image counter overlay
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ✅ High Quality Image Item
  Widget _buildHighQualityImageItem(int index) {
    return RepaintBoundary(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(color: Colors.black),
          Center(
            child: CachedNetworkImage(
              imageUrl: BASE_URL + widget.chalet.buldingImages[index]["path"],
              fit: BoxFit.cover,
              fadeInDuration: Duration.zero,
              memCacheWidth: (MediaQuery.of(context).size.width *
                  MediaQuery.of(context).devicePixelRatio)
                  .round(),
              maxWidthDiskCache: 1600,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(),
              ),
              errorWidget: (context, url, error) => const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('خطأ في تحميل الصورة', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${index + 1}/${widget.chalet.buldingImages.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  void _showPoliciesBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryColor, primaryColor.withOpacity(0.8)],
                    ),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.verified_user_rounded, color: Colors.white, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'السياسات والضمانات',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'نسعد بخدمتكم',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPolicySection(
                          icon: Icons.info_rounded,
                          title: 'من نحن',
                          content: 'نحن منصة موثوقة تربط الضيوف برموز السكن المتميزة. دورنا هو ضمان تجربة آمنة وسلسة لجميع أطرافنا.',
                          color: primaryColor,
                        ),
                        const SizedBox(height: 16),

                        _buildPolicySection(
                          icon: Icons.verified_rounded,
                          title: 'ضماناتنا لك',
                          content: '✓ نضمن أن المكان حقيقي وموجود بالفعل\n✓ نتحقق من بيانات المالك والعقار\n✓ المالك يتحمل مسؤولية الصور والتجهيز\n✓ دعم 24/7 في حالة أي مشكلة',
                          color: Colors.green.shade600,
                        ),
                        const SizedBox(height: 16),

                        _buildPolicySection(
                          icon: Icons.home_rounded,
                          title: 'التزام المالك',
                          content: 'المالك يتحمل:\n✓ صحة جميع الصور والمعلومات\n✓ توفر الخدمات المذكورة\n✓ نظافة وتجهيز المكان\n✓ الالتزام بشروط الحجز',
                          color: accentColor,
                        ),
                        const SizedBox(height: 16),

                        _buildPolicySection(
                          icon: Icons.person_rounded,
                          title: 'التزامك كضيف',
                          content: 'نتوقع منك:\n✓ احترام ممتلكات المالك\n✓ الالتزام بشروط الإقامة\n✓ التواصل المهذب والاحترافي\n✓ الإبلاغ الفوري عن أي مشكلة',
                          color: primaryColor,
                        ),
                        const SizedBox(height: 16),

                        _buildPolicySection(
                          icon: Icons.support_agent_rounded,
                          title: 'سياسة الشكاوى',
                          content: 'إذا اكتشفت عدم مطابقة الصور للواقع:\n\n1️⃣ التقط صور توثيقية\n2️⃣ تواصل معنا فوراً\n3️⃣ نحقق في المشكلة\n4️⃣ نتخذ الإجراء المناسب\n\nحقوقك محمية معنا',
                          color: Colors.red.shade600,
                        ),
                        const SizedBox(height: 16),

                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: primaryColor.withOpacity(0.2)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.mail_rounded, color: primaryColor, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'هل لديك سؤال أو شكوى؟',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1A1F2E),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'تواصل معنا عبر البريد أو التطبيق\nنحن هنا لمساعدتك 24/7',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[600],
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.red.shade400, width: 1.5),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'لا أوافق',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.red.shade400,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _navigateToBooking();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'أوافق',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPolicySection({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToBooking() {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => ChaletBookingPage(chalet: widget.chalet,isChalet: true,),
    ));

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        // Navigate to booking page
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          SizedBox(
            height: 360,
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemCount: widget.chalet.buldingImages.length,
                  itemBuilder: (context, i) => _buildHighQualityImage(i),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.15),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          DraggableScrollableSheet(
            initialChildSize: 0.62,
            minChildSize: 0.62,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return _buildAnimatedContentSheet(scrollController);
            },
          ),

          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            right: 16,
            child: _buildAnimatedHeader(),
          ),
        ],
      ),
      bottomNavigationBar: _buildBookingSection(),
    );
  }

  Widget _buildHighQualityImage(int index) {
    return CachedNetworkImage(
      imageUrl: BASE_URL + widget.chalet.buldingImages[index]["path"],
      fit: BoxFit.cover,
      memCacheHeight: 1400,
      memCacheWidth: 900,
      placeholder: (context, url) => Container(
        color: Colors.grey[300],
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey[300],
        child: const Icon(Icons.image_not_supported, size: 48),
      ),
    );
  }

  Widget _buildAnimatedHeader() {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
          .animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildHeaderButton(Icons.arrow_back_rounded, () => Navigator.pop(context)),
          Row(
            children: [
              _buildHeaderButton(
                Icons.share_rounded,
                () => ShareLinks.shareChalet(widget.chalet.id, widget.chalet.name),
              ),
              const SizedBox(width: 8),
              _buildImageCounter(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
        ),
        child: Icon(icon, color: Colors.black87, size: 20),
      ),
    );
  }

  Widget _buildImageCounter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
      ),
      child: Text(
        '${_currentPage + 1}/${widget.chalet.buldingImages.length}',
        style: TextStyle(
          color: primaryColor,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildAnimatedContentSheet(ScrollController scrollController) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 30, offset: Offset(0, -8)),
        ],
      ),
      child: ListView(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),

          _buildTitleSection(),
          const SizedBox(height: 20),
          Divider(color: Colors.grey[200], thickness: 1),

          _buildPolicyCard(),
          const SizedBox(height: 24),
          Divider(color: Colors.grey[200], thickness: 1),

          _buildDescriptionSection(),
          const SizedBox(height: 24),
          Divider(color: Colors.grey[200], thickness: 1),

          // ✅ NEW: Image Gallery Section

          const SizedBox(height: 24),
          _buildPricesSection(),
          const SizedBox(height: 24),

          Divider(color: Colors.grey[200], thickness: 1),
          _buildImageGallerySection(),
          const SizedBox(height: 24),

          Divider(color: Colors.grey[200], thickness: 1),
          const SizedBox(height: 24),
          _buildMapSection(),

          Divider(color: Colors.grey[200], thickness: 1),
          const SizedBox(height: 24),
          _buildServicesSection(),
          const SizedBox(height: 24),

          Divider(color: Colors.grey[200], thickness: 1),
          const SizedBox(height: 24),
          _buildTermsAndConditionsSection(),
        ],
      ),
    );
  }

  // ✅ Image Gallery Section - Professional Design
  Widget _buildImageGallerySection() {
    return Column(
      children: [
        // Main Button - Professional Design
        GestureDetector(
          onTap: _showImageGalleryBottomSheet,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor.withOpacity(0.15),
                  primaryColor.withOpacity(0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: primaryColor.withOpacity(0.35),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left Side - Logo + Text
                Row(
                  children: [
                    // Logo Container
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.image_rounded,
                        color: primaryColor,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Text
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Text(
                          'معرض الصور',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${widget.chalet.buldingImages.length} صورة',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: primaryColor.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Right Side - Arrow Icon
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: primaryColor,
                    size: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Preview Images - 2 Images with Borders
        Row(
          children: [
            // Image 1
            Expanded(
              child: GestureDetector(
                onTap: _showImageGalleryBottomSheet,
                child: Container(
                  height: 140,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: primaryColor.withOpacity(0.25),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: widget.chalet.buldingImages.length > 0 ? ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: CachedNetworkImage(
                      imageUrl: BASE_URL + widget.chalet.buldingImages[0]["path"],
                      fit: BoxFit.cover,
                      memCacheHeight: 500,
                      memCacheWidth: 500,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[200],
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.image_not_supported, size: 32),
                      ),
                    ),
                  ) : Container(),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Image 2
            Expanded(
              child: GestureDetector(
                onTap: _showImageGalleryBottomSheet,
                child: Container(
                  height: 140,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: primaryColor.withOpacity(0.25),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      widget.chalet.buldingImages.length > 1 ?    ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: CachedNetworkImage(
                          imageUrl: BASE_URL + widget.chalet.buldingImages[1]["path"],
                          fit: BoxFit.cover,
                          memCacheHeight: 500,
                          memCacheWidth: 500,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[200],
                            child: Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.image_not_supported, size: 32),
                          ),
                        ),
                      ) : Container(),
                      // Show more overlay if more than 2 images
                      if (widget.chalet.buldingImages.length > 2)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.25),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.add_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '+${widget.chalet.buldingImages.length - 2}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.chalet.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1F2E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${governoratesEnglishToArabic[widget.chalet.gouvernate] ?? ""} • ${statesEnglishToArabic[widget.chalet.state] ?? ""}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            if (widget.chalet.minDays != null && widget.chalet.minDays != 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: accentColor.withOpacity(0.3), width: 1.5),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'أقل أيام للحجز',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: accentColor,
                      ),
                    ),
                    Text(
                      '${widget.chalet.minDays} أيام',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: accentColor,
                      ),
                    ),
                  ],
                ),
              )
            else if (widget.chalet.stopBook == true)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withOpacity(0.3), width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.block_rounded, size: 12, color: Colors.red),
                    const SizedBox(width: 4),
                    Text(
                      'غير متاح',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildPolicyCard() {
    return GestureDetector(
      onTap: _showPoliciesBottomSheet,
      child: Container(
        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              primaryColor.withOpacity(0.08),
              primaryColor.withOpacity(0.02),
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: primaryColor.withOpacity(0.15), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.verified_user_rounded,
                    color: primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'آمن وموثوق',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1F2E),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'نضمن أن المكان حقيقي وموجود بالفعل',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: primaryColor,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shield_rounded, size: 14, color: Colors.green.shade600),
                  const SizedBox(width: 6),
                  Text(
                    'اضغط لمزيد من المعلومات',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'الأسعار',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1F2E),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 40,
              height: 3,
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (widget.chalet.todayOfferActive) ...[
          TodayOfferBanner(percent: widget.chalet.todayOfferPercent),
          const SizedBox(height: 12),
        ],

        _buildSoftPriceRow(
          label: 'اليوم الكامل',
          price: widget.chalet.rentFullday,
          icon: Icons.sunny,
        ),
        const SizedBox(height: 10),

        if (widget.chalet.rentHalfday.isNotEmpty && widget.chalet.rentHalfday != "0")
          Column(
            children: [
              _buildSoftPriceRow(
                label: 'نصف اليوم',
                price: widget.chalet.rentHalfday,
                icon: Icons.wb_twilight,
              ),
              const SizedBox(height: 10),
            ],
          ),

        if (widget.chalet.offDayPriceFullday.isNotEmpty &&
            widget.chalet.offDayPriceFullday != "0" &&
            widget.chalet.offDayPriceFullday != widget.chalet.rentFullday)
          Column(
            children: [
              _buildSoftPriceRow(
                label: 'نهاية الأسبوع - كامل',
                price: widget.chalet.offDayPriceFullday,
                icon: Icons.weekend,
                isWeekend: true,
              ),
              const SizedBox(height: 10),
            ],
          ),

        if (widget.chalet.offDayPriceHalfday.isNotEmpty &&
            widget.chalet.offDayPriceHalfday != "0" &&
            widget.chalet.offDayPriceHalfday != widget.chalet.rentHalfday)
          _buildSoftPriceRow(
            label: 'نهاية الأسبوع - نصف',
            price: widget.chalet.offDayPriceHalfday,
            icon: Icons.weekend,
            isWeekend: true,
          ),

        widget.chalet.insuranceamount.isEmpty ? SizedBox() :  _buildSoftPriceRow(
          label: 'التأمين',
          price: widget.chalet.insuranceamount,
          icon: Icons.money,
        ),
      ],
    );
  }

  Widget _buildSoftPriceRow({
    required String label,
    required String price,
    required IconData icon,
    bool isWeekend = false,
  }) {
    final softColor = isWeekend ? Color(0xFFE5D5FF) : Color(0xFFF3EDFF);
    final textColor = isWeekend ? Color(0xFF9D4EDD) : Color(0xFF8B5CF6);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: softColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: textColor.withOpacity(0.15),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: textColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 16,
              color: textColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                price,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'ر.ع',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'الموقع الجغرافي',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1A1F2E),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 40,
              height: 3,
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 260,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: GoogleMap(
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      double.tryParse(widget.chalet.lat.toString()) ?? 0.0,
                      double.tryParse(widget.chalet.lng.toString()) ?? 0.0,
                    ),
                    zoom: 15,
                  ),
                  mapType: MapType.hybrid,
                  zoomControlsEnabled: false,
                  myLocationEnabled: false,
                  markers: {
                    Marker(
                      markerId: const MarkerId('chalet'),
                      position: LatLng(
                        double.tryParse(widget.chalet.lat.toString()) ?? 0.0,
                        double.tryParse(widget.chalet.lng.toString()) ?? 0.0,
                      ),
                      infoWindow: InfoWindow(title: widget.chalet.name),
                    ),
                  },
                ),
              ),
              Positioned(
                bottom: 10,
                left: 10,
                child: GestureDetector(
                  onTap: _openGoogleMaps,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Icon(Icons.open_in_new_rounded, size: 13, color: primaryColor),
                        const SizedBox(width: 4),
                        Text(
                          'فتح الخريطة',
                          style: TextStyle(
                            fontSize: 11,
                            color: primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }


  String _cleanAndTranslateValue(String value) {
    String text = value;
    // ترجمة الكلمات الإنجليزية التي قد تأتي داخل القيم
    text = text.replaceAll(RegExp(r'\bGuests\b', caseSensitive: false), 'ضيوف');
    text = text.replaceAll(RegExp(r'\bGuest\b', caseSensitive: false), 'ضيف');
    return text;
  }

  dynamic _parseDescriptionData(String text) {
    if (text.isEmpty) return "";
    if (text.contains('|') && text.contains(':')) {
      final pairs = text.split('|');
      final List<FeatureItem> items = [];
      for (var pair in pairs) {
        final parts = pair.split(':');
        if (parts.length >= 2) {
          final key = parts[0].trim();
          final rawValue = parts.sublist(1).join(':').trim();

          items.add(FeatureItem(
            englishKey: key,
            title: _translateKey(key),
            value: _cleanAndTranslateValue(rawValue), // تنظيف وترجمة القيمة هنا
          ));
        }
      }
      return items;
    }
    return text;
  }

  // ── New structured fields (new API body) ─────────────────────────────
  // Builds the same List<FeatureItem> the legacy "|"-separated
  // buldingDescrption parser used to produce, but reads straight from
  // the dedicated API fields (chaletType, capacity, bedrooms, ...)
  // instead of splitting text. Returns null when none of those fields
  // are populated — the caller then falls back to _parseDescriptionData
  // on the legacy description text, so older chalets keep working.
  List<FeatureItem>? _buildStructuredFeatureItems() {
    final c = widget.chalet;
    final hasAny = (c.chaletType?.isNotEmpty ?? false) ||
        (c.capacity?.isNotEmpty ?? false) ||
        (c.bedrooms?.isNotEmpty ?? false) ||
        (c.bathrooms?.isNotEmpty ?? false) ||
        (c.livingRooms?.isNotEmpty ?? false) ||
        (c.suitableFor?.isNotEmpty ?? false) ||
        (c.landscape?.isNotEmpty ?? false) ||
        (c.outdoorSpace?.isNotEmpty ?? false) ||
        (c.safety?.isNotEmpty ?? false) ||
        (c.atmosphere?.isNotEmpty ?? false) ||
        (c.bestSeason?.isNotEmpty ?? false);

    if (!hasAny) return null;

    final items = <FeatureItem>[];

    if (c.chaletType != null && c.chaletType!.isNotEmpty) {
      items.add(FeatureItem(
        englishKey: 'type',
        title: _translateKey('type'),
        value: _typeArabicLabels[c.chaletType!] ?? c.chaletType!,
      ));
    }
    if (c.capacity != null && c.capacity!.isNotEmpty) {
      items.add(FeatureItem(
        englishKey: 'capacity',
        title: _translateKey('capacity'),
        value: _cleanAndTranslateValue('${c.capacity} Guests'),
      ));
    }
    if (c.bedrooms != null && c.bedrooms!.isNotEmpty) {
      items.add(FeatureItem(
          englishKey: 'bedrooms', title: _translateKey('bedrooms'), value: c.bedrooms!));
    }
    if (c.bathrooms != null && c.bathrooms!.isNotEmpty) {
      items.add(FeatureItem(
          englishKey: 'bathrooms', title: _translateKey('bathrooms'), value: c.bathrooms!));
    }
    if (c.livingRooms != null && c.livingRooms!.isNotEmpty) {
      items.add(FeatureItem(
          englishKey: 'living rooms',
          title: _translateKey('living rooms'),
          value: c.livingRooms!));
    }
    if (c.suitableFor != null && c.suitableFor!.isNotEmpty) {
      items.add(FeatureItem(
          englishKey: 'suitable for',
          title: _translateKey('suitable for'),
          value: translateCharacteristicList(c.suitableFor!)));
    }
    if (c.landscape != null && c.landscape!.isNotEmpty) {
      items.add(FeatureItem(
          englishKey: 'landscape',
          title: _translateKey('landscape'),
          value: translateCharacteristicList(c.landscape!)));
    }
    if (c.outdoorSpace != null && c.outdoorSpace!.isNotEmpty) {
      items.add(FeatureItem(
          englishKey: 'outdoor space',
          title: _translateKey('outdoor space'),
          value: translateCharacteristicList(c.outdoorSpace!)));
    }
    if (c.safety != null && c.safety!.isNotEmpty) {
      items.add(FeatureItem(
          englishKey: 'safety',
          title: _translateKey('safety'),
          value: translateCharacteristicList(c.safety!)));
    }
    if (c.atmosphere != null && c.atmosphere!.isNotEmpty) {
      items.add(FeatureItem(
          englishKey: 'atmosphere',
          title: _translateKey('atmosphere'),
          value: translateCharacteristicList(c.atmosphere!)));
    }
    if (c.bestSeason != null && c.bestSeason!.isNotEmpty) {
      items.add(FeatureItem(
          englishKey: 'best season',
          title: _translateKey('best season'),
          value: translateCharacteristicList(c.bestSeason!)));
    }

    // Free-form owner notes never got a dedicated API field — still only
    // available inside the legacy description text, so pull it out and
    // append it even when everything else came from the new structured
    // fields.
    final notesMatch =
    RegExp(r'Notes:\s*([^|]+)').firstMatch(c.buldingDescrption ?? '');
    final noteValue = notesMatch?.group(1)?.trim() ?? '';
    if (noteValue.isNotEmpty) {
      items.add(FeatureItem(
          englishKey: 'notes', title: _translateKey('notes'), value: noteValue));
    }

    return items;
  }

  IconData _getFeatureIcon(String key) {
    switch (key.toLowerCase()) {
      case 'type': return Icons.holiday_village_outlined;
      case 'capacity': return Icons.people_outline_rounded;
      case 'bedrooms': return Icons.king_bed_outlined;
      case 'bathrooms': return Icons.bathtub_outlined;
      case 'living rooms': return Icons.chair_alt_outlined;
      case 'suitable for': return Icons.family_restroom_rounded;
      case 'landscape': return Icons.landscape_outlined;
      case 'outdoor space': return Icons.yard_outlined;
      case 'safety': return Icons.shield_outlined;
      case 'atmosphere': return Icons.mode_night;
      case 'best season': return Icons.wb_twighlight;
    // مفاتيح الـ Note
      case 'cancellation': return Icons.info_outline;
      case 'check-in': return Icons.login_rounded;
      case 'check-out': return Icons.logout_rounded;
      case 'rules': return Icons.gavel_outlined;
      default: return Icons.label_important_outline;
    }
  }

  String _translateKey(String key) {
    switch (key.toLowerCase()) {
      case 'type': return 'النوع';
      case 'capacity': return 'السعة';
      case 'bedrooms': return 'غرف النوم';
      case 'bathrooms': return 'دورات المياه';
      case 'living rooms': return 'الصـالات';
      case 'suitable for': return 'مناسب لـ';
      case 'landscape': return 'الإطلالة';
      case 'outdoor space': return 'المساحة الخارجية';
      case 'safety': return 'الأمان';
      case 'atmosphere': return 'الأجواء';
      case 'best season': return 'أفضل موسم';
      case 'notes': return 'وصف إضافي';

      default: return key;
    }
  }

  Widget _buildDescriptionSection() {
    // Prefer the new structured API fields (chaletType, capacity,
    // bedrooms, bathrooms, livingRooms, suitableFor, landscape,
    // outdoorSpace, safety, atmosphere, bestSeason). Only fall back to
    // parsing the legacy "Type: ... | Capacity: ..." description text
    // for chalets saved before those fields existed.
    final structuredItems = _buildStructuredFeatureItems();
    final rawDescription = widget.chalet.buldingDescrption ?? "";

    if (structuredItems == null && rawDescription.isEmpty) {
      return const SizedBox.shrink();
    }

    final dynamic parsedData =
        structuredItems ?? _parseDescriptionData(rawDescription);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // عنوان رئيسي فخم ومميز مع خط سفلي صغير ملون
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'المواصفات والتفاصيل',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1A1F2E),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 40,
              height: 3,
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // الحالة الأولى: البيانات الجديدة بالشكل السلس عالي الوضوح
        if (parsedData is List<FeatureItem>)
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFECEFF3), width: 1),
            ),
            clipBehavior: Clip.antiAlias, // لضمان انحناء الحواف بداخل الجدول
            child: ListView.builder(
              padding: EdgeInsets.all(2),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: parsedData.length,
              itemBuilder: (context, index) {
                final item = parsedData[index];
                // إعطاء أسطر زوجية خلفية خفيفة جداً وأسطر فردية بيضاء (Zebra Effect) لراحة العين
                final isEven = index % 2 == 0;

                return Container(
                  color: isEven ? const Color(0xFFF9FBFC) : Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      // الأيقونة بشكل ناعم ودائري خفيف
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isEven ? Colors.white : const Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getFeatureIcon(item.englishKey),
                          size: 18,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(width: 14),

                      // اسم الميزة (محاذاة ثابتة)
                      SizedBox(
                        width: 100,
                        child: Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      // القيمة (مترجمة وجاهزة وباقي المساحة لها)
                      Expanded(
                        child: Text(
                          item.value,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF1A1F2E),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          )

        // الحالة الثانية: النص القديم
        else ...[
          Text(
            _expandedDescription
                ? parsedData
                : (parsedData.length > 120 ? parsedData.substring(0, 120) + '...' : parsedData),
            style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.7),
          ),
          if (!_expandedDescription && parsedData.length > 120)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: GestureDetector(
                onTap: () => setState(() => _expandedDescription = true),
                child: const Text(
                  'اقرأ المزيد',
                  style: TextStyle(fontSize: 12, color: primaryColor, fontWeight: FontWeight.w700),
                ),
              ),
            ),
        ],
      ],
    );
  }
  Widget _buildServicesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'الخدمات المتاحة',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1A1F2E),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 40,
              height: 3,
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),


        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: widget.chalet.buldingService.map((service) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primaryColor.withOpacity(0.2)),
              ),
              child: Text(
                serviceKeyToValue[service["serviceName"]] ?? "",
                style: TextStyle(
                  color: Colors.grey[800],
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _cleanAndTranslatePolicyValue(String value) {
    String text = value;

    // ترجمة مصطلحات الإلغاء الشائعة
    text = text.replaceAll(RegExp(r'\bNot Allowed\b', caseSensitive: false), 'غير مسترد / غير مسموح');
    text = text.replaceAll(RegExp(r'\bAllowed\b', caseSensitive: false), 'مسموح');
    text = text.replaceAll(RegExp(r'\bFree\b', caseSensitive: false), 'مجاني');

    // ترجمة التوقيت الصباحي والمسائي بشكل احترافي
    text = text.replaceAll(RegExp(r'\bAM\b', caseSensitive: false), 'صباحاً');
    text = text.replaceAll(RegExp(r'\bPM\b', caseSensitive: false), 'مساءً');

    return text;
  }

// دالة تفكيك نص الشروط والسياسات
  dynamic _parsePolicyData(String text) {
    if (text.isEmpty) return "";

    if (text.contains('|') && text.contains(':')) {
      final pairs = text.split('|');
      final List<FeatureItem> items = [];

      for (var pair in pairs) {
        final parts = pair.split(':');
        if (parts.length >= 2) {
          final key = parts[0].trim();
          // تجميع القيمة حتى لو تحتوي على ":" إضافية مثل أوقات الساعات (2:00 AM)
          final rawValue = parts.sublist(1).join(':').trim();

          items.add(FeatureItem(
            englishKey: key,
            title: _translatePolicyKey(key),
            value: _cleanAndTranslatePolicyValue(rawValue),
          ));
        }
      }
      return items;
    }
    return text;
  }

// ترجمة مفاتيح السياسات والشروط
  String _translatePolicyKey(String key) {
    switch (key.toLowerCase()) {
      case 'cancellation': return 'سياسة الإلغاء';
      case 'check-in': return 'وقت الدخول';
      case 'check-out': return 'وقت الخروج';
      case 'rules': return 'قواعد الإقامة';
      case 'additional' : return "أخرى";
      default: return key; // لو جالنا مفتاح جديد مثل Additional هيعرضه زي ما هو أو تترجمه هنا
    }
  }

// الأيقونات الخاصة بكل شرط من شروط الإقامة
  IconData _getPolicyIcon(String key) {
    switch (key.toLowerCase()) {
      case 'cancellation': return Icons.gavel_rounded; // أو Icons.assignment_late_outlined
      case 'check-in': return Icons.login_rounded;
      case 'check-out': return Icons.logout_rounded;
      case 'rules': return Icons.rule_rounded;
      case 'additional' : return Icons.info_outline_rounded;

      default: return Icons.info_outline_rounded;
    }
  }

// الـ Widget المطورة لشروط الحجز والسياسات
  Widget _buildTermsAndConditionsSection() {
    final rawNote = widget.chalet.note ?? "";
    if (rawNote.isEmpty) return const SizedBox.shrink();

    final parsedData = _parsePolicyData(rawNote);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // عنوان القسم بنفس الـ Concept الاحترافي
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'شروط وقوانين الحجز',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1A1F2E),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 40,
              height: 3,
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // الحالة الأولى: لو الداتا مفصلة وجديدة (عرض منسق ونظيف جداً)
        if (parsedData is List<FeatureItem>)
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFECEFF3), width: 1),
            ),
            clipBehavior: Clip.antiAlias,
            child: ListView.builder(
              padding: EdgeInsets.all(2),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: parsedData.length,
              itemBuilder: (context, index) {
                final item = parsedData[index];
                final isEven = index % 2 == 0;

                return Container(
                  color: isEven ? const Color(0xFFF9FBFC) : Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start, // عشان لو القواعد سطرين تنزل الأيقونة متناسقة
                    children: [
                      // أيقونة الشرط داخل دائرة خفيفة وعميقة
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isEven ? Colors.white : const Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getPolicyIcon(item.englishKey),
                          size: 18,
                          color: primaryColor, // لون براند تطبيقك
                        ),
                      ),
                      const SizedBox(width: 14),

                      // اسم الشرط / السياسة (عناوين بمحاذاة تامة وثابتة)
                      SizedBox(
                        width: 100,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 2), // محاذاة النص مع الأيقونة تماماً
                          child: Text(
                            item.title,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      // تفاصيل الشرط (مرنة وتدعم السطور المتعددة)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            item.value,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF1A1F2E),
                              fontWeight: FontWeight.w700,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          )

        // الحالة الثانية: لو الداتا قديمة أو نصية (تعرض بداخل الكارت القديم الأنيق)
        else
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFECEFF3)),
            ),
            child: Text(
              parsedData,
              style: TextStyle(
                color: Colors.grey[700],
                height: 1.8,
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
      ],
    );}

  Widget _buildBookingSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: widget.chalet.stopBook == true
                ? null
                : _showPoliciesBottomSheet,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey[300],
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.chalet.stopBook != true) ...[
                  Icon(Icons.calendar_today_rounded, size: 18, color: Colors.white),
                  const SizedBox(width: 10),
                ],
                Text(
                  widget.chalet.stopBook == true ? 'غير متاح للحجز' : 'احجز الآن',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

List<Map<String, dynamic>> removeDuplicates(List<Map<String, dynamic>> services) {
  Set<String> seen = {};
  return services
      .where((s) => (seen.add(s['serviceName'] ?? '') && s['serviceName'] != ""))
      .toList();
}
class FeatureItem {
  final String englishKey; // نحتاجها لتحديد الأيقونة بدقة
  final String title;
  final String value;
  FeatureItem({required this.englishKey, required this.title, required this.value});
}