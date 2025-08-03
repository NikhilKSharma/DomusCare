// lib/features/profile/presentation/screens/edit_profile_screen.dart
// --- COMPLETE VERSION WITH DROPDOWN ---

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_app/core/models/user_model.dart';
import 'package:flutter_app/features/customer/data/customer_repository.dart';
import 'package:flutter_app/features/customer/models/service_model.dart';
import '../../data/profile_repository.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  final UserModel user;
  const EditProfileScreen({super.key, required this.user});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _bioController;
  late TextEditingController _priceController;
  String? _selectedServiceId;

  @override
  void initState() {
    super.initState();
    final user = widget.user;
    _nameController = TextEditingController(text: user.name);
    _phoneController = TextEditingController(text: user.phone);
    _addressController = TextEditingController(text: user.address);
    _bioController = TextEditingController(text: user.bio);
    _priceController =
        TextEditingController(text: user.basePrice.toStringAsFixed(0));
    _selectedServiceId = user.service?.id;
  }

  @override
  void dispose() {
    // ... dispose all controllers
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final data = {
        'name': _nameController.text,
        'phone': _phoneController.text,
        'address': _addressController.text,
        if (widget.user.role == 'provider') ...{
          'bio': _bioController.text,
          'basePrice': double.tryParse(_priceController.text) ?? 0,
          'service': _selectedServiceId, // Add selected service ID
        }
      };
      ref.read(profileControllerProvider.notifier).updateProfile(data);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final allServicesAsync = ref.watch(servicesProvider);
    ref.listen(profileControllerProvider, (previous, next) {
      if (!next.isLoading && !next.hasError) {
        context.pop();
      } else if (next.hasError) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(next.error.toString())));
      }
    });
    final updateState = ref.watch(profileControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name')),
            TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone')),
            TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address')),
            if (user.role == 'provider') ...[
              const SizedBox(height: 16),

              // --- NEW DROPDOWN WIDGET ---
              allServicesAsync.when(
                data: (services) => DropdownButtonFormField<String>(
                  value: _selectedServiceId,
                  decoration:
                      const InputDecoration(labelText: 'Select Service'),
                  items: services.map((ServiceModel service) {
                    return DropdownMenuItem<String>(
                      value: service.id,
                      child: Text(service.name),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedServiceId = newValue;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Please select a service' : null,
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => const Text('Could not load services'),
              ),
              // ---------------------------

              const SizedBox(height: 16),
              TextFormField(
                  controller: _bioController,
                  decoration: const InputDecoration(labelText: 'Bio')),
              TextFormField(
                  controller: _priceController,
                  decoration:
                      const InputDecoration(labelText: 'Base Price (₹)'),
                  keyboardType: TextInputType.number),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: updateState.isLoading ? null : _submit,
              child: updateState.isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Save Changes'),
            )
          ],
        ),
      ),
    );
  }
}
