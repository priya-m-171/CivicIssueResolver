import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../models/issue_model.dart';
import '../../providers/issue_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../services/location_service.dart';
import '../../config/app_constants.dart';
import '../dashboard/map_view.dart';
import '../../utils/translations.dart';
import '../../widgets/responsive_wrapper.dart';
import '../../services/ai_service.dart';

class ReportIssueScreen extends StatefulWidget {
  const ReportIssueScreen({super.key});

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  final PageController _pageController = PageController();
  int _step = 0;
  final int _totalSteps = 5;

  // Step 1: Photos
  final List<XFile> _pickedImages = [];
  bool _isAnalyzing = false;
  String?
  _aiResultMessage; // Shows "AI detected: Pothole" or "Could not identify" etc.
  bool _aiFailed = false; // true when fallback was triggered

  // Step 2: Description
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = AppConstants.basicCategories.first;
  String _selectedPriority = 'medium';

  // Step 3: Location
  String _currentAddress = 'Tap to fetch location';
  LatLng? _selectedLatLng;
  bool _gettingLocation = false;
  List<String> _currentDropdownCategories = AppConstants.basicCategories;

  // Step 4: Contact
  final _contactNameController = TextEditingController();
  final _contactPhoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    _contactNameController.text = user?.name ?? '';
    _contactPhoneController.text = user?.phone ?? '';
    _getLocation();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _contactNameController.dispose();
    _contactPhoneController.dispose();
    super.dispose();
  }

  Future<void> _getLocation() async {
    setState(() => _gettingLocation = true);
    try {
      final pos = await LocationService().getCurrentLocation();
      final addr = await LocationService().getAddressFromCoordinates(
        pos.latitude,
        pos.longitude,
      );
      setState(() {
        _currentAddress = addr;
        _selectedLatLng = LatLng(pos.latitude, pos.longitude);
      });
    } catch (e) {
      setState(() {
        _currentAddress = 'Location unavailable - tap map to set';
        _selectedLatLng = const LatLng(10.9372, 76.9556);
      });
    } finally {
      setState(() => _gettingLocation = false);
    }
  }

  Future<void> _pickImage() async {
    if (_pickedImages.length >= 3) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Maximum 3 photos allowed')),
        );
      }
      return;
    }

    final picker = ImagePicker();
    XFile? file;
    try {
      file = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        imageQuality: 75,
      );
    } catch (e) {
      debugPrint('Image picker error: $e');
      return;
    }

    if (file == null) return;

    final isFirstPhoto = _pickedImages.isEmpty;

    setState(() {
      _pickedImages.add(file!);
      _aiResultMessage = null;
      _aiFailed = false;
      if (isFirstPhoto) {
        _isAnalyzing = true;
      }
    });

    if (isFirstPhoto) {
      try {
        debugPrint('[Report] Calling AIService.analyzeImage...');
        final result = await AIService.analyzeImage(file);
        debugPrint('[Report] AI result: $result');

        if (!mounted) return;

        setState(() {
          _isAnalyzing = false;

          if (result != null) {
            final detectedCategory = result['category'] ?? 'Unknown';
            final priority = result['priority'] ?? 'medium';
            final title = result['title'] ?? '';
            final description = result['description'] ?? '';

            debugPrint(
              '[Report] category="$detectedCategory" priority="$priority"',
            );
            debugPrint('[Report] title="$title"');

            // Always set title and description first
            if (title.isNotEmpty) {
              _titleController.text = title;
            }
            if (description.isNotEmpty) {
              _descriptionController.text = description;
            }
            if (AppConstants.priorities.contains(priority)) {
              _selectedPriority = priority;
            }

            // Category matching: exact -> case-insensitive -> partial
            String? matchedCategory;

            // 1. Exact match
            if (detectedCategory != 'Unknown' &&
                AppConstants.categories.contains(detectedCategory)) {
              matchedCategory = detectedCategory;
              debugPrint('[Report] Exact match: $matchedCategory');
            }

            // 2. Case-insensitive match
            if (matchedCategory == null && detectedCategory != 'Unknown') {
              for (final cat in AppConstants.categories) {
                if (cat.toLowerCase().trim() ==
                    detectedCategory.toLowerCase().trim()) {
                  matchedCategory = cat;
                  debugPrint(
                    '[Report] Case-insensitive match: $matchedCategory',
                  );
                  break;
                }
              }
            }

            // 3. Partial / substring match
            if (matchedCategory == null && detectedCategory != 'Unknown') {
              for (final cat in AppConstants.categories) {
                if (cat.toLowerCase().contains(
                      detectedCategory.toLowerCase(),
                    ) ||
                    detectedCategory.toLowerCase().contains(
                      cat.toLowerCase(),
                    )) {
                  matchedCategory = cat;
                  debugPrint('[Report] Partial match: $matchedCategory');
                  break;
                }
              }
            }

            if (matchedCategory != null) {
              _currentDropdownCategories = AppConstants.categories;
              _selectedCategory = matchedCategory;
              _aiFailed = false;
              _aiResultMessage = matchedCategory;
            } else {
              debugPrint(
                '[Report] No match for "$detectedCategory" - using basic categories',
              );
              _currentDropdownCategories = AppConstants.basicCategories;
              _selectedCategory = AppConstants.basicCategories.first;
              _aiFailed = true;
              _aiResultMessage = null;
            }
          } else {
            debugPrint('[Report] AI returned null');
            _currentDropdownCategories = AppConstants.basicCategories;
            _selectedCategory = AppConstants.basicCategories.first;
            _aiFailed = true;
            _selectedPriority = 'medium';
          }
        });
      } catch (e, stack) {
        debugPrint('[Report] AI Error: $e');
        debugPrint('[Report] Stack: $stack');
        if (mounted) {
          setState(() {
            _isAnalyzing = false;
            _currentDropdownCategories = AppConstants.basicCategories;
            _selectedCategory = AppConstants.basicCategories.first;
            _aiFailed = true;
          });
        }
      }
    }
  }

  bool _canProceed() {
    if (_isAnalyzing) return false; // Block Next Step during AI analysis
    switch (_step) {
      case 0: // Photos
        return _pickedImages.isNotEmpty;
      case 1: // Description
        return _titleController.text.trim().isNotEmpty &&
            _descriptionController.text.trim().isNotEmpty;
      case 2: // Location
        return _selectedLatLng != null;
      case 3: // Contact
        return _contactNameController.text.trim().isNotEmpty &&
            _contactPhoneController.text.trim().isNotEmpty;
      default:
        return true;
    }
  }

  void _nextStep() {
    if (_isAnalyzing) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please wait for AI analysis to complete...'),
          backgroundColor: AppColors.info,
        ),
      );
      return;
    }
    if (!_canProceed()) {
      String message;
      if (_step == 0) {
        message = 'Please add at least one photo';
      } else if (_step == 1) {
        message = 'Please fill in both title and description';
      } else if (_step == 3) {
        message = 'Name and phone number are required';
      } else {
        message = 'Please complete this step';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppColors.danger),
      );
      return;
    }
    if (_step < _totalSteps - 1) {
      setState(() => _step++);
      _pageController.animateToPage(
        _step,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _submitIssue();
    }
  }

  void _prevStep() {
    if (_step > 0) {
      setState(() => _step--);
      _pageController.animateToPage(
        _step,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _submitIssue() async {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user == null) return;

    final ticketNum =
        'CMP-${DateTime.now().year}-${(DateTime.now().millisecondsSinceEpoch % 10000).toString().padLeft(4, '0')}';
    const uuid = Uuid();

    final newIssue = Issue(
      id: uuid.v4(),
      ticketNumber: ticketNum,
      userId: user.id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _selectedCategory,
      priority: _selectedPriority,
      imageUrl: '',
      imageUrls: [],
      latitude: _selectedLatLng?.latitude ?? 10.9372,
      longitude: _selectedLatLng?.longitude ?? 76.9556,
      address: _currentAddress,
      status: 'pending',
      createdAt: DateTime.now(),
      submittedBy: _contactNameController.text.trim(),
    );

    final issueProvider = Provider.of<IssueProvider>(context, listen: false);
    final notifProvider = Provider.of<NotificationProvider>(
      context,
      listen: false,
    );

    try {
      await issueProvider.addIssue(
        newIssue,
        imageFiles: _pickedImages,
        onNotify: notifProvider.addNotification,
      );

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => _SuccessDialog(
            ticketNumber: ticketNum,
            onClose: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit issue: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Submit New Issue'.tr(context)),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ResponsiveWrapper(
        child: Column(
          children: [
            // Step indicator
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Column(
                children: [
                  Row(
                    children: List.generate(_totalSteps, (i) {
                      final labels = [
                        'Photos'.tr(context),
                        'Description'.tr(context),
                        'Location'.tr(context),
                        'Contact'.tr(context),
                        'Review'.tr(context),
                      ];
                      final isCompleted = i < _step;
                      final isCurrent = i == _step;
                      return Expanded(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                if (i > 0)
                                  Expanded(
                                    child: Container(
                                      height: 2,
                                      color: isCompleted
                                          ? AppColors.primary
                                          : AppColors.divider,
                                    ),
                                  ),
                                Container(
                                  width: 28,
                                  height: 28,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: isCompleted || isCurrent
                                        ? AppColors.primary
                                        : AppColors.divider,
                                    shape: BoxShape.circle,
                                  ),
                                  child: isCompleted
                                      ? const Icon(
                                          Icons.check,
                                          size: 14,
                                          color: Colors.white,
                                        )
                                      : Text(
                                          '${i + 1}',
                                          style: TextStyle(
                                            color: isCurrent
                                                ? Colors.white
                                                : AppColors.textSecondary,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                                if (i < _totalSteps - 1)
                                  Expanded(
                                    child: Container(
                                      height: 2,
                                      color: isCompleted
                                          ? AppColors.primary
                                          : AppColors.divider,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              labels[i],
                              style: TextStyle(
                                fontSize: 9,
                                color: isCurrent
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                                fontWeight: isCurrent
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),

            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _Step1Photos(
                    images: _pickedImages,
                    isAnalyzing: _isAnalyzing,
                    aiResultMessage: _aiResultMessage,
                    aiFailed: _aiFailed,
                    onPickImage: _pickImage,
                    onRemoveImage: (i) =>
                        setState(() => _pickedImages.removeAt(i)),
                  ),
                  _Step2Description(
                    titleController: _titleController,
                    descController: _descriptionController,
                    selectedCategory: _selectedCategory,
                    selectedPriority: _selectedPriority,
                    availableCategories: _currentDropdownCategories,
                    aiFailed: _aiFailed,
                    onCategoryChanged: (v) =>
                        setState(() => _selectedCategory = v!),
                    onPriorityChanged: (v) =>
                        setState(() => _selectedPriority = v!),
                  ),
                  _Step3Location(
                    address: _currentAddress,
                    gettingLocation: _gettingLocation,
                    selectedLatLng: _selectedLatLng,
                    onRefresh: _getLocation,
                    onLocationSelected: (ll) async {
                      setState(() {
                        _selectedLatLng = ll;
                        _gettingLocation = true;
                      });
                      final addr = await LocationService()
                          .getAddressFromCoordinates(ll.latitude, ll.longitude);
                      setState(() {
                        _currentAddress = addr;
                        _gettingLocation = false;
                      });
                    },
                  ),
                  _Step4Contact(
                    nameController: _contactNameController,
                    phoneController: _contactPhoneController,
                  ),
                  _Step5Review(
                    title: _titleController.text,
                    description: _descriptionController.text,
                    category: _selectedCategory,
                    priority: _selectedPriority,
                    address: _currentAddress,
                    photos: _pickedImages,
                    name: _contactNameController.text,
                    phone: _contactPhoneController.text,
                  ),
                ],
              ),
            ),

            // Navigation buttons
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: _prevStep,
                        icon: const Icon(Icons.arrow_back, size: 16),
                        label: Text(
                          _step == 0 ? 'Cancel' : 'Back',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: 52,
                      child: Consumer<IssueProvider>(
                        builder: (ctx, issueProvider, _) => ElevatedButton.icon(
                          onPressed: (issueProvider.isLoading || _isAnalyzing)
                              ? null
                              : _nextStep,
                          icon: issueProvider.isLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : _isAnalyzing
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Icon(
                                  _step == _totalSteps - 1
                                      ? Icons.check
                                      : Icons.arrow_forward,
                                  size: 16,
                                ),
                          label: Text(
                            _isAnalyzing
                                ? 'Analyzing...'
                                : _step == _totalSteps - 1
                                ? 'Submit Report'.tr(context)
                                : 'Next Step'.tr(context),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
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
}

// ---- Success Dialog ----
class _SuccessDialog extends StatelessWidget {
  final String ticketNumber;
  final VoidCallback onClose;

  const _SuccessDialog({required this.ticketNumber, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 20),
          Text(
            'Report Submitted!'.tr(context),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Your issue has been successfully submitted. You will receive updates on its status.'
                .tr(context),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text('Ticket Number'.tr(context), style: AppTextStyles.caption),
                const SizedBox(height: 4),
                Text(
                  ticketNumber,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onClose,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                'Done'.tr(context),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---- Step 1: Photos ----
class _Step1Photos extends StatefulWidget {
  final List<XFile> images;
  final bool isAnalyzing;
  final String? aiResultMessage; // Non-null = AI successfully identified
  final bool aiFailed; // true = AI failed, showing basic categories
  final VoidCallback onPickImage;
  final Function(int) onRemoveImage;

  const _Step1Photos({
    required this.images,
    required this.isAnalyzing,
    required this.onPickImage,
    required this.onRemoveImage,
    this.aiResultMessage,
    this.aiFailed = false,
  });

  @override
  State<_Step1Photos> createState() => _Step1PhotosState();
}

class _Step1PhotosState extends State<_Step1Photos>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Add Photos'.tr(context), style: AppTextStyles.heading2),
          const SizedBox(height: 4),
          Text(
            'Capture a photo and AI will automatically identify the issue type for you.'
                .tr(context),
            style: AppTextStyles.bodySecondary,
          ),
          const SizedBox(height: 20),

          // === AI Status Banner ===
          if (widget.isAnalyzing)
            _AIScanningBanner(pulseController: _pulseController)
          else if (widget.aiResultMessage != null)
            _AISuccessBanner(category: widget.aiResultMessage!)
          else if (widget.aiFailed)
            const _AIFallbackBanner(),

          const SizedBox(height: 20),

          // === Camera Capture Button ===
          if (widget.images.length < 3)
            GestureDetector(
              onTap: widget.isAnalyzing ? null : widget.onPickImage,
              child: Container(
                height: 130,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: widget.isAnalyzing
                      ? Colors.grey.withValues(alpha: 0.05)
                      : AppColors.primary.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: widget.isAnalyzing
                        ? Colors.grey.withValues(alpha: 0.3)
                        : AppColors.primary.withValues(alpha: 0.3),
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_a_photo_outlined,
                      size: 40,
                      color: widget.isAnalyzing
                          ? Colors.grey
                          : AppColors.primary.withValues(alpha: 0.7),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.isAnalyzing
                          ? 'Please wait...'.tr(context)
                          : widget.images.isEmpty
                          ? 'Tap to Capture Photo'.tr(context)
                          : 'Add Another Photo'.tr(context),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: widget.isAnalyzing
                            ? Colors.grey
                            : AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Camera only · Max 3 photos'.tr(context),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // === Photo Grid ===
          if (widget.images.isNotEmpty) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(
                  Icons.photo_library_outlined,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  '${widget.images.length} / 3 ${'photos captured'.tr(context)}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: widget.images.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: kIsWeb
                          ? Image.network(
                              widget.images[index].path,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            )
                          : Image.file(
                              File(widget.images[index].path),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => widget.onRemoveImage(index),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

// AI Scanning Banner
class _AIScanningBanner extends StatelessWidget {
  final AnimationController pulseController;
  const _AIScanningBanner({required this.pulseController});

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: pulseController,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.document_scanner,
              color: AppColors.primary,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI is analyzing your photo...'.tr(context),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'This will auto-detect the issue type and priority.'.tr(
                      context,
                    ),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// AI Success Banner
class _AISuccessBanner extends StatelessWidget {
  final String category;
  const _AISuccessBanner({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: AppColors.success, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Identified the Issue ✓'.tr(context),
                  style: const TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  category.tr(context),
                  style: const TextStyle(
                    color: AppColors.success,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// AI Fallback Banner
class _AIFallbackBanner extends StatelessWidget {
  const _AIFallbackBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.help_outline, color: AppColors.warning, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Could not identify the issue from photo'.tr(context),
                  style: const TextStyle(
                    color: AppColors.warning,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'You can select the category manually in the next step.'.tr(
                    context,
                  ),
                  style: const TextStyle(
                    color: AppColors.warning,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---- Step 2: Description ----
class _Step2Description extends StatefulWidget {
  final TextEditingController titleController, descController;
  final String selectedCategory, selectedPriority;
  final List<String> availableCategories;
  final bool aiFailed;
  final Function(String?) onCategoryChanged, onPriorityChanged;

  const _Step2Description({
    required this.titleController,
    required this.descController,
    required this.selectedCategory,
    required this.selectedPriority,
    required this.availableCategories,
    required this.onCategoryChanged,
    required this.onPriorityChanged,
    this.aiFailed = false,
  });

  @override
  State<_Step2Description> createState() => _Step2DescriptionState();
}

class _Step2DescriptionState extends State<_Step2Description> {
  int _descLen = 0;

  @override
  void initState() {
    super.initState();
    _descLen = widget.descController.text.length;
    widget.descController.addListener(_updateDescLen);
  }

  @override
  void dispose() {
    widget.descController.removeListener(_updateDescLen);
    super.dispose();
  }

  void _updateDescLen() {
    if (mounted) {
      setState(() {
        _descLen = widget.descController.text.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Issue Details'.tr(context), style: AppTextStyles.heading2),
          const SizedBox(height: 4),
          Text(
            widget.aiFailed
                ? 'Please fill in the details to describe the issue.'.tr(
                    context,
                  )
                : 'AI has auto-filled some fields based on your photo. Please verify.'
                      .tr(context),
            style: AppTextStyles.bodySecondary,
          ),
          const SizedBox(height: 24),
          Text('Title *'.tr(context), style: AppTextStyles.label),
          const SizedBox(height: 8),
          TextField(
            controller: widget.titleController,
            decoration: InputDecoration(
              hintText: 'e.g., Deep pothole on residential road'.tr(context),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Category *'.tr(context), style: AppTextStyles.label),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            key: ValueKey(
              'cat-${widget.selectedCategory}-${widget.availableCategories.length}',
            ),
            initialValue:
                widget.availableCategories.contains(widget.selectedCategory)
                ? widget.selectedCategory
                : widget.availableCategories.first,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            isExpanded: true,
            items: widget.availableCategories
                .map(
                  (c) => DropdownMenuItem(
                    value: c,
                    child: Text(c.tr(context), overflow: TextOverflow.ellipsis),
                  ),
                )
                .toList(),
            onChanged: widget.onCategoryChanged,
          ),
          const SizedBox(height: 16),
          Text('Description *'.tr(context), style: AppTextStyles.label),
          const SizedBox(height: 8),
          TextField(
            controller: widget.descController,
            maxLines: 4,
            maxLength: 500,
            decoration: InputDecoration(
              hintText: 'Provide more details'.tr(context),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              helperText: '$_descLen/500',
            ),
          ),
          const SizedBox(height: 16),
          Text('Priority Level *'.tr(context), style: AppTextStyles.label),
          const SizedBox(height: 8),
          Row(
            children: AppConstants.priorities.map((p) {
              final isSelected = widget.selectedPriority == p;
              final color = AppConstants.priorityColor(p);
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => widget.onPriorityChanged(p),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color.withValues(alpha: 0.1)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? color : AppColors.divider,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected ? color : Colors.grey.shade300,
                              border: Border.all(
                                color: isSelected
                                    ? color
                                    : Colors.grey.shade400,
                                width: 2,
                              ),
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check,
                                    size: 12,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            p.tr(context),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected ? color : Colors.grey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ---- Step 3: Location ----
class _Step3Location extends StatelessWidget {
  final String address;
  final bool gettingLocation;
  final LatLng? selectedLatLng;
  final VoidCallback onRefresh;
  final Function(LatLng) onLocationSelected;

  const _Step3Location({
    required this.address,
    required this.gettingLocation,
    required this.selectedLatLng,
    required this.onRefresh,
    required this.onLocationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Issue Location'.tr(context), style: AppTextStyles.heading2),
              const SizedBox(height: 4),
              Text(
                'Auto-detected location. Tap map to adjust.'.tr(context),
                style: AppTextStyles.bodySecondary,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: AppColors.danger),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        gettingLocation
                            ? 'Finding address...'.tr(context)
                            : address,
                        style: const TextStyle(fontSize: 13),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.my_location, size: 20),
                      onPressed: onRefresh,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: LocationPickerMap(
            initialLocation: selectedLatLng,
            onLocationSelected: onLocationSelected,
          ),
        ),
      ],
    );
  }
}

// ---- Step 4: Contact ----
class _Step4Contact extends StatelessWidget {
  final TextEditingController nameController, phoneController;
  const _Step4Contact({
    required this.nameController,
    required this.phoneController,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Contact Info'.tr(context), style: AppTextStyles.heading2),
          const SizedBox(height: 4),
          Text(
            'Used only for status updates and verification'.tr(context),
            style: AppTextStyles.bodySecondary,
          ),
          const SizedBox(height: 24),
          Text('Full Name *'.tr(context), style: AppTextStyles.label),
          const SizedBox(height: 8),
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Phone Number *'.tr(context), style: AppTextStyles.label),
          const SizedBox(height: 8),
          TextField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              prefixText: '+91 ',
              prefixIcon: const Icon(Icons.phone_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---- Step 5: Review ----
class _Step5Review extends StatelessWidget {
  final String title, description, category, priority, address, name, phone;
  final List<XFile> photos;

  const _Step5Review({
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.address,
    required this.photos,
    required this.name,
    required this.phone,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Review Submission'.tr(context), style: AppTextStyles.heading2),
          const SizedBox(height: 20),
          _ReviewSection('Details'.tr(context), [
            _ReviewRow('Title'.tr(context), title),
            _ReviewRow('Category'.tr(context), category.tr(context)),
            _ReviewRow('Priority'.tr(context), priority.tr(context)),
            _ReviewRow('Description'.tr(context), description),
          ]),
          const SizedBox(height: 16),
          _ReviewSection('Location'.tr(context), [
            _ReviewRow('Address'.tr(context), address),
          ]),
          const SizedBox(height: 16),
          _ReviewSection('Contact'.tr(context), [
            _ReviewRow('Name'.tr(context), name),
            _ReviewRow('Phone'.tr(context), phone),
          ]),
        ],
      ),
    );
  }
}

class _ReviewSection extends StatelessWidget {
  final String title;
  final List<Widget> rows;
  const _ReviewSection(this.title, this.rows);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              fontSize: 14,
            ),
          ),
          const Divider(height: 20),
          ...rows,
        ],
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final String label, value;
  const _ReviewRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
