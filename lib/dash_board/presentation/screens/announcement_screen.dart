import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:forsatech/dash_board/data/model/announcement_model.dart';
import 'package:forsatech/dash_board/business_logic/cubit/dash_board_cubit.dart';
import 'package:forsatech/dash_board/business_logic/cubit/dash_board_state.dart';

class AnnouncementDialog extends StatefulWidget {
  const AnnouncementDialog({super.key});

  @override
  State<AnnouncementDialog> createState() => _AnnouncementDialogState();
}

class _AnnouncementDialogState extends State<AnnouncementDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _title;
  String? _description;
  File? _selectedImageFile;
  Uint8List? _selectedImageBytes;

  Shader _iconGradient(Rect rect) {
    return const LinearGradient(
      colors: [Color(0xFF3B82F6), Color(0xFF9333EA)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(rect);
  }

  Future<void> _pickImageWebOrMobile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedImageBytes = result.files.first.bytes;
        _selectedImageFile = null; 
      });
    }
  }

  Widget _buildImagePreview() {
    if (_selectedImageFile != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          _selectedImageFile!,
          height: 180,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    } else if (_selectedImageBytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.memory(
          _selectedImageBytes!,
          height: 180,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    } else {
      return OutlinedButton.icon(
        icon: const Icon(Icons.image),
        label: const Text('Upload Image'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          backgroundColor: Colors.grey.shade100,
          side: BorderSide(color: Colors.grey.shade300),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: _pickImageWebOrMobile,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // ignore: unused_local_variable
    final dialogWidth = screenWidth * 0.75;

    return Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.60,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            child: BlocConsumer<AnnouncementCubit, AnnouncementState>(
              listener: (context, state) {
                if (state is AnnouncementError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
                if (state is AnnouncementLoaded) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Announcement created successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              builder: (context, state) {
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: 60,
                            width: 60,
                            child: ShaderMask(
                              shaderCallback: _iconGradient,
                              child: const Icon(Icons.campaign,
                                  size: 60, color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Create New Announcement",
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF6366F1),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          _buildFlatTextField(
                            icon: Icons.title,
                            label: 'Announcement Title',
                            hint: 'Enter a clear and concise title',
                            onSaved: (val) => _title = val,
                            validator: (val) =>
                                val == null || val.trim().isEmpty
                                    ? 'Title is required'
                                    : null,
                          ),
                          const SizedBox(height: 18),
                          _buildFlatTextField(
                            icon: Icons.description_outlined,
                            label: 'Description',
                            hint: 'Add details about the announcement',
                            maxLines: 5,
                            onSaved: (val) => _description = val,
                            validator: (val) =>
                                val == null || val.trim().isEmpty
                                    ? 'Description is required'
                                    : null,
                          ),
                          const SizedBox(height: 18),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (_selectedImageFile != null ||
                                  _selectedImageBytes != null)
                                Stack(
                                  alignment: Alignment.topRight,
                                  children: [
                                    _buildImagePreview(),
                                    IconButton(
                                      icon: const Icon(Icons.cancel,
                                          color: Colors.red),
                                      onPressed: () {
                                        setState(() {
                                          _selectedImageFile = null;
                                          _selectedImageBytes = null;
                                        });
                                      },
                                    ),
                                  ],
                                )
                              else
                                _buildImagePreview(),
                            ],
                          ),
                          const SizedBox(height: 26),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  icon: ShaderMask(
                                    shaderCallback: _iconGradient,
                                    child: const Icon(Icons.cancel,
                                        color: Colors.white),
                                  ),
                                  label: Text(
                                    "Cancel",
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      color: const Color(0xFF6366F1),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  onPressed: () => Navigator.of(context).pop(),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    side:
                                        BorderSide(color: Colors.grey.shade300),
                                    backgroundColor: Colors.grey.shade100,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton.icon(
                                  icon: state is AnnouncementLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : ShaderMask(
                                          shaderCallback: (bounds) =>
                                              const LinearGradient(
                                            colors: [
                                              Color(0xFF3B82F6),
                                              Color(0xFF9333EA)
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ).createShader(bounds),
                                          child: const Icon(Icons.send,
                                              color: Colors.white),
                                        ),
                                  label: Text(
                                    state is AnnouncementLoading
                                        ? 'Submitting...'
                                        : 'Submit',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  onPressed: state is AnnouncementLoading
                                      ? null
                                      : _handleSubmit,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    backgroundColor: const Color(0xFF6366F1),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ));
  }
//////////////////////////////////////////////////////////////////////////
///                         widget           
 


  Widget _buildFlatTextField({
    required IconData icon,
    required String label,
    String? hint,
    int maxLines = 1,
    FormFieldSetter<String>? onSaved,
    FormFieldValidator<String>? validator,
  }) {
    return TextFormField(
      maxLines: maxLines,
      onSaved: onSaved,
      validator: validator,
      style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
      cursorColor: const Color(0xFF3B82F6),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: ShaderMask(
          shaderCallback: (bounds) => _iconGradient(bounds),
          child: Icon(icon, color: Colors.white),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF9333EA), width: 2.5),
        ),
      ),
    );
  }
//////////////////////////////////////////////////////////////////////////
  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      print("Title: $_title");
      print("Description: $_description");
      print("Image File: $_selectedImageFile");
      print("Image Bytes: ${_selectedImageBytes?.length}");

      final newAd = Announcement(
        title: _title!.trim(),
        description: _description!.trim(),
      );

      context.read<AnnouncementCubit>().addAnnouncement(
            newAd,
            _selectedImageFile,
            _selectedImageBytes,
          );
    }
  }
}
