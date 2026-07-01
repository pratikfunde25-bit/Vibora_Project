import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  bool _isLoading = false;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authControllerProvider).valueOrNull;
    _nameController = TextEditingController(text: user?.name ?? '');
    _bioController = TextEditingController(text: user?.bio ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image != null) {
      final cropped = await _cropImage(image.path);
      if (cropped != null) {
        setState(() => _selectedImage = File(cropped));
      }
    }
  }

  Future<String?> _cropImage(String path) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Photo',
          toolbarColor: AppColors.primary,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
        ),
        IOSUiSettings(title: 'Crop Photo'),
      ],
    );
    return croppedFile?.path;
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    
    String? avatarUrl;
    if (_selectedImage != null) {
      avatarUrl = await ref.read(authControllerProvider.notifier).uploadAvatar(_selectedImage!);
    }

    final error = await ref.read(authControllerProvider.notifier).updateProfile(
      name: _nameController.text.trim(),
      bio: _bioController.text.trim(),
      avatarUrl: avatarUrl,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 4),
                        ),
                        child: _selectedImage != null
                            ? CircleAvatar(radius: 60, backgroundImage: FileImage(_selectedImage!))
                            : AppAvatar(name: user.name, imageUrl: user.avatarUrl, size: 120),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: const CircleAvatar(
                            backgroundColor: AppColors.primary,
                            radius: 18,
                            child: Icon(Icons.camera_alt_rounded, color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  AppTextField(
                    controller: _nameController,
                    hint: 'Full Name',
                    label: 'Full Name',
                    prefixIcon: Icons.person_outline_rounded,
                  ),
                  const SizedBox(height: 24),
                  AppTextField(
                    controller: _bioController,
                    hint: 'Tell us about yourself...',
                    label: 'Bio',
                    maxLines: 4,
                  ),
                  const SizedBox(height: 48),
                  AppPrimaryButton(
                    label: 'Save Changes',
                    isLoading: _isLoading,
                    onPressed: _save,
                  ),
                ],
              ),
            ),
    );
  }
}
