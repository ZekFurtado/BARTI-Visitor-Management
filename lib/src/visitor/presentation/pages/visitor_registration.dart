import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:iconly/iconly.dart';
import 'package:visitor_management/src/authentication/domain/entities/user.dart';
import 'package:visitor_management/src/employee/presentation/widgets/employee_search_dialog.dart';
import 'package:visitor_management/src/employee/presentation/bloc/employee_bloc.dart';
import 'package:visitor_management/core/services/injection_container.dart' as di;
import 'package:visitor_management/src/visitor/presentation/bloc/visitor_bloc.dart';
import 'package:visitor_management/src/visitor/presentation/bloc/visitor_profile_bloc.dart';
import 'package:visitor_management/src/visitor/presentation/widgets/visitor_search_dialog.dart';
import 'package:visitor_management/src/visitor/domain/entities/visitor_profile.dart';
import 'package:visitor_management/core/widgets/loader_dialog.dart';
import 'dart:async';

class VisitorRegistrationScreen extends StatelessWidget {
  const VisitorRegistrationScreen({super.key, required this.gatekeeper});

  final LocalUser gatekeeper;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(
          value: context.read<VisitorBloc>(),
        ),
        BlocProvider<VisitorProfileBloc>(
          create: (context) => di.sl<VisitorProfileBloc>(),
        ),
      ],
      child: _VisitorRegistrationView(gatekeeper: gatekeeper),
    );
  }
}

class _VisitorRegistrationView extends StatefulWidget {
  const _VisitorRegistrationView({required this.gatekeeper});

  final LocalUser gatekeeper;

  @override
  State<_VisitorRegistrationView> createState() => _VisitorRegistrationViewState();
}

class _VisitorRegistrationViewState extends State<_VisitorRegistrationView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _originController = TextEditingController();
  final _purposeController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _notesController = TextEditingController();
  final _expectedDurationController = TextEditingController();

  LocalUser? _selectedEmployee;
  File? _capturedPhoto;
  final ImagePicker _picker = ImagePicker();
  VisitorProfile? _selectedVisitorProfile;
  Timer? _debounceTimer;

  final List<String> _durationOptions = [
    '30 minutes',
    '1 hour',
    '2 hours',
    '3 hours',
    'Half day',
    'Full day',
    'Other',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _originController.dispose();
    _purposeController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _notesController.dispose();
    _expectedDurationController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<VisitorBloc, VisitorState>(
      listener: (context, state) {
        if (state is VisitorLoading) {
          LoaderDialog.show(context);
        } else if (state is VisitorRegistered) {
          LoaderDialog.hide(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Visitor registered successfully! Employee has been notified.'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        } else if (state is VisitorProfileRegistered) {
          LoaderDialog.hide(context);
          final message = _selectedVisitorProfile != null 
              ? 'New visit added to ${state.visitorProfile.name}\'s history! Employee has been notified.'
              : 'Visitor profile created successfully! Employee has been notified.';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        } else if (state is VisitorError) {
          LoaderDialog.hide(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
        ),
        BlocListener<VisitorProfileBloc, VisitorProfileState>(
          listener: (context, state) {
            if (state is VisitorProfileLoaded && state.profile != null) {
              // Auto-fill form when visitor profile is found
              _fillFormWithVisitorData(state.profile!);
              
              // Show feedback that profile was found
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Found returning visitor: ${state.profile!.name}'),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                ),
              );
            } else if (state is VisitorProfileLoaded && state.profile == null) {
              // No profile found for this phone number
              if (_phoneController.text.length >= 10) {
                log('No existing profile found for phone: ${_phoneController.text}');
              }
            }
          },
        ),
      ],
      child: Scaffold(
      appBar: AppBar(
        title: Text('Register Visitor'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          TextButton(
            onPressed: () => _resetForm(),
            child: Text(
              'Reset',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.person_add,
                        size: 32,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'New Visitor Registration',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Fill in the visitor details below',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Photo Section
              Text(
                'Visitor Photo',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              
              _buildPhotoSection(),

              const SizedBox(height: 24),

              // Personal Information
              Text(
                'Personal Information',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name *',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter visitor\'s full name';
                  }
                  return null;
                },
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),

              // Phone Number with Search Option
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: Icon(Icons.phone),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value != null && value.isNotEmpty && value.length < 10) {
                          return 'Please enter a valid phone number';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        // Clear selected visitor profile when phone changes
                        if (_selectedVisitorProfile != null && 
                            value.trim() != _selectedVisitorProfile!.phoneNumber) {
                          setState(() {
                            _selectedVisitorProfile = null;
                          });
                        }
                        
                        // Debounced lookup for visitor profile
                        _searchVisitorByPhone(value.trim());
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(IconlyLight.search, size: 18),
                        label: const Text('Search'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onPressed: _showVisitorSearchDialog,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Selected Visitor Info Card
              if (_selectedVisitorProfile != null) ...[
                Card(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          IconlyBold.user_3,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Existing Visitor Selected',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${_selectedVisitorProfile!.visitCount} previous visit${_selectedVisitorProfile!.visitCount != 1 ? 's' : ''}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            IconlyLight.close_square,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                          onPressed: () {
                            setState(() {
                              _selectedVisitorProfile = null;
                              _nameController.clear();
                              _phoneController.clear();
                              _emailController.clear();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Email
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Visit Information
              Text(
                'Visit Information',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Origin/Company
              TextFormField(
                controller: _originController,
                decoration: InputDecoration(
                  labelText: 'Coming From (Company/Organization) *',
                  prefixIcon: Icon(Icons.business),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter where the visitor is coming from';
                  }
                  return null;
                },
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),

              // Employee to Meet
              _buildEmployeeSelection(),
              const SizedBox(height: 16),

              // Purpose
              TextFormField(
                controller: _purposeController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Purpose of Visit *',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the purpose of visit';
                  }
                  return null;
                },
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),

              // Expected Duration
              DropdownButtonFormField<String>(
                value: _expectedDurationController.text.isEmpty 
                    ? null 
                    : _expectedDurationController.text,
                decoration: InputDecoration(
                  labelText: 'Expected Duration',
                  prefixIcon: Icon(Icons.access_time),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _durationOptions.map((duration) {
                  return DropdownMenuItem<String>(
                    value: duration,
                    child: Text(duration),
                  );
                }).toList(),
                onChanged: (value) {
                  _expectedDurationController.text = value ?? '';
                },
              ),
              const SizedBox(height: 16),

              // Additional Notes
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Additional Notes',
                  prefixIcon: Icon(Icons.note),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignLabelWithHint: true,
                ),
                textCapitalization: TextCapitalization.sentences,
              ),

              const SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _registerVisitor,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        'Register & Notify Employee',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: _capturedPhoto != null
          ? Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    _capturedPhoto!,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: IconButton(
                      icon: Icon(Icons.close, color: Colors.white, size: 20),
                      onPressed: () {
                        setState(() {
                          _capturedPhoto = null;
                        });
                      },
                    ),
                  ),
                ),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.camera_alt,
                  size: 48,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  'Capture Visitor Photo',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Take a photo for identification',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _capturePhoto(ImageSource.camera),
                      icon: Icon(Icons.camera_alt),
                      label: Text('Camera'),
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton.icon(
                      onPressed: () => _capturePhoto(ImageSource.gallery),
                      icon: Icon(Icons.photo_library),
                      label: Text('Gallery'),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildEmployeeSelection() {
    return GestureDetector(
      onTap: _selectEmployee,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.person_search,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedEmployee != null
                        ? _selectedEmployee!.name ?? 'Unknown'
                        : 'Select Employee to Meet *',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: _selectedEmployee != null
                          ? Theme.of(context).colorScheme.onSurface
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (_selectedEmployee != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${_selectedEmployee!.jobRole} • ${_selectedEmployee!.department}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _capturePhoto(ImageSource source) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (photo != null) {
        setState(() {
          _capturedPhoto = File(photo.path);
        });
      }
    } catch (e) {
      log('Error capturing photo: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error capturing photo. Please try again.')),
        );
      }
    }
  }

  void _selectEmployee() async {
    final selectedEmployee = await showDialog<LocalUser>(
      context: context,
      builder: (context) => BlocProvider<EmployeeBloc>(
        create: (context) => di.sl<EmployeeBloc>(),
        child: const EmployeeSearchDialog(),
      ),
    );

    if (selectedEmployee != null) {
      setState(() {
        _selectedEmployee = selectedEmployee;
      });
    }
  }

  void _registerVisitor() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedEmployee == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an employee to meet')),
      );
      return;
    }

    // Trigger smart visitor registration via BLoC
    context.read<VisitorBloc>().add(
      SmartRegisterVisitorEvent(
        name: _nameController.text.trim(),
        origin: _originController.text.trim(),
        purpose: _purposeController.text.trim(),
        employeeToMeetId: _selectedEmployee!.uid ?? '',
        employeeToMeetName: _selectedEmployee!.name ?? 'Unknown',
        gatekeeperId: widget.gatekeeper.uid ?? '',
        gatekeeperName: widget.gatekeeper.name ?? 'Unknown',
        phoneNumber: _phoneController.text.trim().isNotEmpty 
          ? _phoneController.text.trim() : null,
        email: _emailController.text.trim().isNotEmpty 
          ? _emailController.text.trim() : null,
        expectedDuration: _expectedDurationController.text.trim().isNotEmpty 
          ? _expectedDurationController.text.trim() : null,
        notes: _notesController.text.trim().isNotEmpty 
          ? _notesController.text.trim() : null,
        photoFile: _capturedPhoto,
      ),
    );
  }

  void _showVisitorSearchDialog() async {
    final selectedVisitor = await showDialog<VisitorProfile>(
      context: context,
      builder: (context) => const VisitorSearchDialog(),
    );

    if (selectedVisitor != null) {
      _fillFormWithVisitorData(selectedVisitor);
    }
  }

  void _fillFormWithVisitorData(VisitorProfile visitor) {
    setState(() {
      _selectedVisitorProfile = visitor;
      _nameController.text = visitor.name;
      _phoneController.text = visitor.phoneNumber;
      _emailController.text = visitor.email ?? '';
      
      // Auto-fill company/origin from latest visit if available
      if (visitor.visits.isNotEmpty) {
        final latestVisit = visitor.latestVisit;
        if (latestVisit != null && _originController.text.isEmpty) {
          _originController.text = latestVisit.origin;
        }
      }
      
      // Don't fill visit-specific fields like purpose, etc.
      // as this is a new visit for the same visitor
    });
  }

  void _searchVisitorByPhone(String phoneNumber) {
    // Cancel previous timer
    _debounceTimer?.cancel();
    
    // Only search if phone number is valid length
    if (phoneNumber.length < 10) {
      return;
    }
    
    // Set up new timer with 1 second delay
    _debounceTimer = Timer(const Duration(seconds: 1), () {
      // Only search if not already showing this profile
      if (_selectedVisitorProfile?.phoneNumber != phoneNumber) {
        context.read<VisitorProfileBloc>().add(
          GetVisitorProfileEvent(phoneNumber: phoneNumber),
        );
      }
    });
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _nameController.clear();
    _originController.clear();
    _purposeController.clear();
    _phoneController.clear();
    _emailController.clear();
    _notesController.clear();
    _expectedDurationController.clear();
    setState(() {
      _selectedEmployee = null;
      _capturedPhoto = null;
      _selectedVisitorProfile = null;
    });
  }
}