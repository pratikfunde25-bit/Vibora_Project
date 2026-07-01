import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../domain/entities/event_entity.dart';
import '../controllers/event_controller.dart';

class CreateEventScreen extends ConsumerStatefulWidget {
  const CreateEventScreen({super.key});
  @override
  ConsumerState<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends ConsumerState<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _venueCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _capacityCtrl = TextEditingController();

  String _selectedCatStr = AppConstants.eventCategories[1];
  DateTime _startDate = DateTime.now().add(const Duration(days: 1));
  DateTime _endDate = DateTime.now().add(const Duration(days: 1, hours: 2));
  bool _isFree = true;
  bool _isSubmitting = false;
  
  File? _selectedImage;
  final _picker = ImagePicker();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _venueCtrl.dispose();
    _priceCtrl.dispose();
    _capacityCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      final image = await _picker.pickImage(source: source, imageQuality: 70, maxWidth: 1000);
      if (image != null) {
        final cropped = await _cropImage(image.path);
        if (cropped != null) {
          setState(() => _selectedImage = File(cropped));
        }
      }
    }
  }

  Future<String?> _cropImage(String path) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Banner',
          toolbarColor: AppColors.primary,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.ratio16x9,
          lockAspectRatio: true,
        ),
        IOSUiSettings(title: 'Crop Banner'),
      ],
    );
    return croppedFile?.path;
  }

  EventCategory _mapStringToCategory(String cat) {
    return EventCategory.values.firstWhere(
      (e) => e.name.toLowerCase() == cat.toLowerCase(),
      orElse: () => EventCategory.other,
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(authControllerProvider).valueOrNull;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to create an event')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final event = EventEntity(
      id: '',
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      organizerId: user.id,
      organizerName: user.name,
      organizerAvatar: user.avatarUrl,
      category: _mapStringToCategory(_selectedCatStr),
      startDate: _startDate,
      endDate: _endDate,
      venue: _venueCtrl.text.trim(),
      maxAttendees: int.tryParse(_capacityCtrl.text) ?? 100,
      price: _isFree ? 0 : (double.tryParse(_priceCtrl.text) ?? 0),
      isFree: _isFree,
      createdAt: DateTime.now(),
      status: EventStatus.upcoming,
    );

    final success = await ref.read(eventControllerProvider.notifier).createEvent(event, _selectedImage);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white),
              SizedBox(width: 12),
              Text('Event Published Successfully!'),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.go(AppRoutes.discover);
    } else {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create event. Please try again.'), backgroundColor: AppColors.error),
      );
    }
  }

  Future<void> _pickDate(bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return;
    if (!mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(isStart ? _startDate : _endDate),
    );
    if (time == null) return;
    final finalDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    setState(() {
      if (isStart) {
        _startDate = finalDate;
        if (_endDate.isBefore(_startDate)) _endDate = _startDate.add(const Duration(hours: 1));
      } else {
        _endDate = finalDate;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Event')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 180,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.dividerLight),
                  image: _selectedImage != null
                      ? DecorationImage(image: FileImage(_selectedImage!), fit: BoxFit.cover)
                      : null,
                ),
                child: _selectedImage == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_photo_alternate_rounded, size: 48, color: AppColors.primary),
                          const SizedBox(height: 12),
                          Text(
                            'Add Event Banner',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      )
                    : Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          onPressed: () => setState(() => _selectedImage = null),
                          icon: const CircleAvatar(
                            backgroundColor: Colors.black54,
                            child: Icon(Icons.close, color: Colors.white, size: 18),
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),
            AppTextField(
              hint: 'Event Title',
              label: 'Event Title',
              controller: _titleCtrl,
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 24),
            Text('Category', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              height: 44,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: AppConstants.eventCategories.length - 1,
                itemBuilder: (_, i) {
                  final cat = AppConstants.eventCategories[i + 1];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: CategoryChip(
                      label: cat,
                      isSelected: _selectedCatStr == cat,
                      onTap: () => setState(() => _selectedCatStr = cat),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            AppTextField(
              hint: 'Description',
              label: 'Description',
              controller: _descCtrl,
              maxLines: 4,
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: AppOutlinedButton(
                    label: '${_startDate.day}/${_startDate.month} - ${_startDate.hour}:${_startDate.minute.toString().padLeft(2, '0')}',
                    icon: Icons.calendar_today_rounded,
                    onPressed: () => _pickDate(true),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AppOutlinedButton(
                    label: '${_endDate.day}/${_endDate.month} - ${_endDate.hour}:${_endDate.minute.toString().padLeft(2, '0')}',
                    icon: Icons.calendar_today_rounded,
                    onPressed: () => _pickDate(false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            AppTextField(
              hint: 'Venue',
              label: 'Venue',
              controller: _venueCtrl,
              prefixIcon: Icons.location_on_rounded,
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    hint: '100',
                    label: 'Capacity',
                    controller: _capacityCtrl,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SwitchListTile(
                    title: const Text('Free'),
                    value: _isFree,
                    onChanged: (v) => setState(() => _isFree = v),
                  ),
                ),
              ],
            ),
            if (!_isFree) ...[
              const SizedBox(height: 24),
              AppTextField(
                hint: '0.00',
                label: 'Price (₹)',
                controller: _priceCtrl,
                keyboardType: TextInputType.number,
                prefixIcon: Icons.currency_rupee_rounded,
              ),
            ],
            const SizedBox(height: 40),
            AppPrimaryButton(
              label: 'Publish Event',
              isLoading: _isSubmitting,
              onPressed: _submit,
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}
