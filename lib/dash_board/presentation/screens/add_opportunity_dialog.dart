import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forsatech/dash_board/data/model/opportunity_model.dart';
import 'package:forsatech/dash_board/data/web_services/opportunity_web_services.dart';

class AddOpportunityDialog extends StatefulWidget {
  final void Function(Opportunity) onSubmit;
  final Opportunity? opportunity;

  const AddOpportunityDialog(
      {super.key, required this.onSubmit, this.opportunity});

  @override
  State<AddOpportunityDialog> createState() => _AddOpportunityDialogState();
}

class _AddOpportunityDialogState extends State<AddOpportunityDialog> {
  List<String> jobTitles = [];
  String? selectedJobTitle;
  TextEditingController? fieldTextController; // ✅ مضاف

  final List<String> jobLevels = [
    'Entry Level',
    'Mid Level',
    'Senior Level',
    'Manager',
    'Director',
    'Executive',
  ];
  String? selectedJobLevel;

  final List<String> qualifications = [
    'High School Diploma',
    'Associate Degree',
    'Bachelor\'s Degree',
    'Master\'s Degree',
    'PhD',
    'Other',
  ];
  String? selectedQualification;

  final List<String> yearsOfExperienceOptions = [
    '0-1',
    '1-3',
    '3-5',
    '5-7',
    '7-10',
    '10+',
  ];
  String? selectedYearsOfExperience;

  final _skillsController = TextEditingController();

  static const List<Map<String, String>> employmentTypes = [
    {'value': 'remote', 'label': 'Remote'},
    {'value': 'on-site', 'label': 'On-site'},
    {'value': 'hybrid', 'label': 'Hybrid'},
    {'value': 'freelance', 'label': 'Freelance'},
    {'value': 'internship', 'label': 'Internship'},
    {'value': 'part-time', 'label': 'Part-time'},
    {'value': 'full-time', 'label': 'Full-time'},
  ];
  String? selectedEmploymentType;

  final _descController = TextEditingController();
  final _locationController = TextEditingController();
  final _salaryRangeController = TextEditingController();
  DateTime? _date;
  DateTime? _applicationDeadline;

  @override
  void initState() {
    super.initState();
    _loadJobTitles();
  }

  Future<void> _loadJobTitles() async {
    try {
      final webService = OpportunityWebService();
      final titles = await webService.getJobTitles();

      setState(() {
        jobTitles = titles;

        if (widget.opportunity != null &&
            titles.contains(widget.opportunity!.title)) {
          selectedJobTitle = widget.opportunity!.title;
          fieldTextController?.text = selectedJobTitle ?? '';
        } else {
          selectedJobTitle ??= null;
        }
        //  fieldTextController?.text = selectedJobTitle ?? '';

        selectedEmploymentType ??= widget.opportunity?.employmentType;
        selectedJobLevel ??= widget.opportunity?.experienceLevel;
        selectedQualification ??= widget.opportunity?.educationLevel;
        selectedYearsOfExperience ??= widget.opportunity?.yearsOfExperience;

        _descController.text =
            widget.opportunity?.description ?? _descController.text;
        _locationController.text =
            widget.opportunity?.location ?? _locationController.text;
        _salaryRangeController.text =
            widget.opportunity?.salaryRange ?? _salaryRangeController.text;
        _skillsController.text =
            widget.opportunity?.requiredSkills ?? _skillsController.text;
        _date = widget.opportunity?.postingDate ?? _date;
        _applicationDeadline =
            widget.opportunity?.applicationDeadline ?? _applicationDeadline;
      });
    } catch (e) {
      debugPrint('Failed to load job titles: $e');
    }
  }

  void pickDate({required bool isDeadline}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isDeadline
          ? (_applicationDeadline ?? DateTime.now())
          : (_date ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isDeadline) {
          _applicationDeadline = picked;
        } else {
          _date = picked;
        }
      });
    }
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _submit() {
    if (selectedJobTitle == null ||
        _descController.text.isEmpty ||
        _date == null ||
        _applicationDeadline == null ||
        selectedEmploymentType == null ||
        _locationController.text.isEmpty ||
        _salaryRangeController.text.isEmpty ||
        selectedJobLevel == null ||
        selectedQualification == null ||
        selectedYearsOfExperience == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    widget.onSubmit(
      Opportunity(
        id: widget.opportunity?.id,
        title: selectedJobTitle!,
        description: _descController.text.trim(),
        postingDate: _date!,
        applicationDeadline: _applicationDeadline!,
        employmentType: selectedEmploymentType!,
        location: _locationController.text.trim(),
        salaryRange: _salaryRangeController.text.trim(),
        experienceLevel: selectedJobLevel!,
        requiredSkills: _skillsController.text.trim(),
        educationLevel: selectedQualification!,
        yearsOfExperience: selectedYearsOfExperience!,
      ),
    );
    Navigator.of(context).pop();
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF1F2937)),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: items.any((item) => item.value == value) ? value : null,
            isExpanded: true,
            items: items,
            onChanged: onChanged,
            icon: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF3B82F6), Color(0xFF9333EA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: const Icon(Icons.arrow_drop_down, color: Colors.white),
            ),
            style: const TextStyle(color: Color(0xFF1F2937)),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Color(0xFF6366F1)),
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF6366F1)),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        width: MediaQuery.of(context).size.width * 0.6,
        decoration: BoxDecoration(
          color: Colors.white, // خلفية بيضاء
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: jobTitles.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFF3B82F6), Color(0xFF9333EA)],
                      ).createShader(
                        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                      ),
                      child: Text(
                        widget.opportunity == null
                            ? 'Create New Opportunity'
                            : 'Edit Opportunity',
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Autocomplete<String>(
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text == '') {
                            return const Iterable<String>.empty();
                          }
                          return jobTitles.where((String option) {
                            return option
                                .toLowerCase()
                                .contains(textEditingValue.text.toLowerCase());
                          });
                        },
                        initialValue:
                            TextEditingValue(text: selectedJobTitle ?? ''),
                        onSelected: (String selection) {
                          setState(() {
                            selectedJobTitle = selection;
                          });
                        },
                        fieldViewBuilder: (BuildContext context,
                            TextEditingController controller,
                            FocusNode fieldFocusNode,
                            VoidCallback onFieldSubmitted) {
                          fieldTextController = controller;
                          return TextField(
                            controller: controller,
                            focusNode: fieldFocusNode,
                            onChanged: (val) {
                              selectedJobTitle = val;
                            },
                            decoration: InputDecoration(
                              labelText: 'Opportunity Title',
                              prefixIcon: const Icon(Icons.title,
                                  color: Color(0xFF6366F1)),
                              labelStyle:
                                  const TextStyle(color: Color(0xFF6366F1)),
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          );
                        },
                        optionsViewBuilder: (BuildContext context,
                            AutocompleteOnSelected<String> onSelected,
                            Iterable<String> options) {
                          return Align(
                            alignment: Alignment.topLeft,
                            child: Material(
                              elevation: 4,
                              borderRadius: BorderRadius.circular(12),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxHeight: 200,
                                  maxWidth: 850, // ✅ نفس عرض الـ Dialog تقريبا
                                ),
                                child: ListView.builder(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  itemCount: options.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final String option =
                                        options.elementAt(index);
                                    return ListTile(
                                      title: Text(option),
                                      onTap: () {
                                        onSelected(option);
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    _buildTextField(
                        _descController, 'Description', Icons.description,
                        maxLines: 3),
                    _buildDropdown<String>(
                      label: 'Employment Type',
                      value: selectedEmploymentType,
                      items: employmentTypes
                          .map((e) => DropdownMenuItem(
                                value: e['value'],
                                child: Text(e['label']!),
                              ))
                          .toList(),
                      onChanged: (val) {
                        setState(() => selectedEmploymentType = val);
                      },
                    ),
                    _buildDropdown<String>(
                      label: 'Job Level',
                      value: selectedJobLevel,
                      items: jobLevels
                          .map((level) => DropdownMenuItem(
                                value: level,
                                child: Text(level),
                              ))
                          .toList(),
                      onChanged: (val) {
                        setState(() => selectedJobLevel = val);
                      },
                    ),
                    _buildTextField(
                      _skillsController,
                      'Required Skills',
                      Icons.list_alt,
                      maxLines: 4,
                    ),
                    _buildDropdown<String>(
                      label: 'Qualifications',
                      value: selectedQualification,
                      items: qualifications
                          .map((q) => DropdownMenuItem(
                                value: q,
                                child: Text(q),
                              ))
                          .toList(),
                      onChanged: (val) {
                        setState(() => selectedQualification = val);
                      },
                    ),
                    _buildDropdown<String>(
                      label: 'Years of Experience',
                      value: selectedYearsOfExperience,
                      items: yearsOfExperienceOptions
                          .map((y) => DropdownMenuItem(
                                value: y,
                                child: Text(y),
                              ))
                          .toList(),
                      onChanged: (val) {
                        setState(() => selectedYearsOfExperience = val);
                      },
                    ),
                    _buildTextField(
                        _locationController, 'Location', Icons.location_on),
                    _buildTextField(
                      _salaryRangeController,
                      'Salary Range',
                      Icons.monetization_on,
                      keyboardType: TextInputType.text, 
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[\d\s\-–toTO]+')),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          _date == null
                              ? 'No date selected'
                              : 'Date: ${_date!.toLocal().toString().split(' ')[0]}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: _pickDate,
                          icon: const Icon(Icons.calendar_today,
                              color: Color(0xFF6366F1)),
                          label: const Text('Select Date',
                              style: TextStyle(color: Color(0xFF6366F1))),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[100],
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 10),
                    Flexible(
                      flex: 2,
                      child: Row(
                        children: [
                          Text(
                            _applicationDeadline == null
                                ? 'No deadline selected'
                                : 'Deadline: ${_applicationDeadline!.toLocal().toString().split(' ')[0]}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const Spacer(),
                          ElevatedButton.icon(
                            onPressed: () => pickDate(isDeadline: true),
                            icon: const Icon(Icons.event_busy,
                                color: Color(0xFF6366F1)),
                            label: const Text('Select Deadline',
                                style: TextStyle(color: Color(0xFF6366F1))),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[100],
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                              padding: EdgeInsets.zero,
                            ),
                            child: Ink(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF3B82F6),
                                    Color(0xFF9333EA)
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Container(
                                alignment: Alignment.center,
                                child: const Text(
                                  'Save',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.white),
                                ),
                              ),
                            )))
                  ],
                ),
              ),
      ),
    );
  }
}
