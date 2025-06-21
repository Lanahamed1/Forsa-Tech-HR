import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forsatech/dash_board/business_logic/cubit/dash_board_cubit.dart';
import 'package:forsatech/dash_board/business_logic/cubit/dash_board_state.dart';
import 'package:forsatech/dash_board/data/model/model.dart';
import 'package:forsatech/dash_board/data/web_services/dash_board_web_services.dart';
import 'package:forsatech/dash_board/presentation/screens/job_opportunity_details_secreen.dart';

class OpportunityScreen extends StatefulWidget {
  const OpportunityScreen({super.key});

  @override
  State<OpportunityScreen> createState() => _OpportunityScreenState();
}

class _OpportunityScreenState extends State<OpportunityScreen> {
    final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<OpportunityCubit>().loadOpportunities();
  }

  void _addOpportunity(Opportunity opportunity) {
    context.read<OpportunityCubit>().addOpportunity(opportunity);
  }

  void _editOpportunity(
      Opportunity oldOpportunity, Opportunity newOpportunity) {
    context.read<OpportunityCubit>().updateOpportunity(newOpportunity);
  }

  void _deleteOpportunity(Opportunity opportunity) {
    if (opportunity.id != null) {
      context.read<OpportunityCubit>().deleteOpportunity(opportunity.id!);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid opportunity ID')),
      );
    }
  }

  // ignore: unused_field

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      onChanged: (query) {
        context.read<OpportunityCubit>().filterOpportunities(query);
      },
      decoration: InputDecoration(
        hintText: 'Search for an opportunity...',
        prefixIcon: const Icon(Icons.search, size: 20, color: Colors.blueGrey),
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
  Widget _buildCreateButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        showDialog(
          context: context,
          builder: (ctx) => AddOpportunityDialog(onSubmit: _addOpportunity),
        );
      },
      icon: const Icon(Icons.add, color: Color(0xFF6366F1)),
      label: const Text('CREATE'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 800;

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF9333EA)],
                  ).createShader(
                      Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                  child: const Text(
                    'Opportunities',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              isWide
                  ? Row(
                      children: [
                        Expanded(child: _buildSearchField()),
                        const SizedBox(width: 16),
                        _buildCreateButton(context),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildSearchField(),
                        const SizedBox(height: 16),
                        _buildCreateButton(context),
                      ],
                    ),
              const SizedBox(height: 30),
              Expanded(
                child: BlocConsumer<OpportunityCubit, OpportunityState>(
                  listener: (context, state) {
                    if (state is OpportunityError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.message)),
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state is OpportunityLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is OpportunityLoaded) {
                      return OpportunityList(
                        opportunities: state.opportunities,
                        onEdit: _editOpportunity,
                        onDelete: _deleteOpportunity,
                      );
                    } else {
                      return const Center(child: Text('Something went wrong'));
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

//////////////////////////////////////////////////////////////////////////////////////////////////////

class OpportunityList extends StatelessWidget {
  final List<Opportunity> opportunities;
  final void Function(Opportunity oldOpportunity, Opportunity newOpportunity)
      onEdit;
  final void Function(Opportunity opportunity) onDelete;

  const OpportunityList({
    super.key,
    required this.opportunities,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (opportunities.isEmpty) {
      return const Center(child: Text('No opportunities found.'));
    }

    return ListView.builder(
      itemCount: opportunities.length,
      itemBuilder: (ctx, i) => OpportunityCard(
        opportunity: opportunities[i],
        onEdit: onEdit,
        onDelete: onDelete,
      ),
    );
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////
class OpportunityCard extends StatelessWidget {
  final Opportunity opportunity;
  final void Function(Opportunity oldOpportunity, Opportunity newOpportunity)
      onEdit;
  final void Function(Opportunity opportunity) onDelete;

  const OpportunityCard({
    super.key,
    required this.opportunity,
    required this.onEdit,
    required this.onDelete,
  });

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Opportunity'),
        content:
            const Text('Are you sure you want to delete this opportunity?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              onDelete(opportunity);
              Navigator.of(ctx).pop();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        // ignore: unused_local_variable
        final isWide = constraints.maxWidth > 600;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 20),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFF3B82F6), Color(0xFF9333EA)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    child: const Icon(Icons.work_outline,
                        size: 32, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Color(0xFF3B82F6), Color(0xFF9333EA)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(bounds),
                            child: Text(
                              opportunity.title ?? 'Untitled Opportunity',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors
                                    .white, // Required when using ShaderMask
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        if (opportunity.status != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: _StatusChip(status: opportunity.status!),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit,
                        color: Color(0xFF6366F1), size: 24),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AddOpportunityDialog(
                          opportunity: opportunity,
                          onSubmit: (updatedOpportunity) {
                            onEdit(opportunity, updatedOpportunity);
                          },
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red, size: 24),
                    onPressed: () => _showDeleteDialog(context),
                  ),
                ],
              ),

              const SizedBox(height: 17),

              // Description
              if (opportunity.description != null)
                Text(
                  opportunity.description!,
                  style: const TextStyle(fontSize: 17, color: Colors.black87),
                ),

              const SizedBox(height: 22),

              // Information Chips
// Information Chips
              Wrap(
                spacing: 14,
                runSpacing: 10,
                children: [
                  if (opportunity.salaryRange != null)
                    _InfoChip(
                      icon: Icons.monetization_on_outlined,
                      text: opportunity.salaryRange!,
                    ),
                  if (opportunity.location != null)
                    _InfoChip(
                      icon: Icons.location_city_outlined,
                      text: opportunity.location!,
                    ),
                  if (opportunity.postingDate != null)
                    _InfoChip(
                      icon: Icons.calendar_today_outlined,
                      text:
                          'Posted: ${opportunity.postingDate!.toLocal().toString().split(' ')[0]}',
                    ),
                  if (opportunity.applicationDeadline != null)
                    _InfoChip(
                      icon: Icons.hourglass_empty_outlined,
                      text:
                          'Deadline: ${opportunity.applicationDeadline!.toLocal().toString().split(' ')[0]}',
                    ),
                  if (opportunity.employmentType != null)
                    _InfoChip(
                      icon: Icons.work_outline,
                      text: opportunity.employmentType!,
                    ),
                  if (opportunity.experienceLevel != null)
                    _InfoChip(
                      icon: Icons.trending_up,
                      text: opportunity.experienceLevel!,
                    ),
                  if (opportunity.yearsOfExperience != null)
                    _InfoChip(
                      icon: Icons.schedule_outlined,
                      text: '${opportunity.yearsOfExperience!} years',
                    ),
                  if (opportunity.educationLevel != null)
                    _InfoChip(
                      icon: Icons.school_outlined,
                      text: opportunity.educationLevel!,
                    ),
                ],
              ),

              // Skills Section
              if (opportunity.requiredSkills != null) ...[
                const SizedBox(height: 20),
                const Text(
                  'Required Skills:',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: Color(0xFF6366F1)),
                ),
                const SizedBox(height: 9),
                Wrap(
                  spacing: 10,
                  children: opportunity.requiredSkills!
                      .split(',')
                      .map((skill) => Chip(
                            avatar: const Icon(Icons.bolt,
                                size: 16, color: Color(0xFF6366F1)),
                            backgroundColor: Colors.grey.shade100,
                            label: Text(skill.trim()),
                          ))
                      .toList(),
                ),
              ],

              const SizedBox(height: 24),

              // Show Applicants Button
              // داخل build في OpportunityCard

              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () {
                    if (opportunity.id != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => JobOpportunityDetailsScreen(
                              opportunityId: opportunity.id!),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Invalid opportunity ID')),
                      );
                    }
                  },
                  icon:
                      const Icon(Icons.arrow_forward, color: Color(0xFF6366F1)),
                  label: const Text('Show details',
                      style: TextStyle(color: Color(0xFF6366F1))),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

//////////////////////////////////////////////////////////////////////////////////////////////
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Chip(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      avatar: Icon(icon, size: 24, color: Color(0xFF6366F1)),
      label: Text(text, style: const TextStyle(fontSize: 15)),
      backgroundColor: Colors.grey.shade100,
    );
  }
}

//////////////////////////////////////////////////////////////////////////////////////////////

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final normalizedStatus = status.toLowerCase();
    final isOpen = normalizedStatus == 'open';

    return Chip(
      label: Text(
        status,
        style: TextStyle(
          color: isOpen ? Colors.green.shade800 : Colors.grey.shade800,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
      backgroundColor: isOpen ? Colors.green.shade100 : Colors.grey.shade200,
      avatar: Icon(
        isOpen ? Icons.check_circle : Icons.info_outline,
        color: isOpen ? Colors.green : Colors.grey,
        size: 18,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    );
  }
}

///
///
///
///
///
///
///
///
///
///
///
///
///
///

/////////////////////////////////////////////////////////////////////////////////////////////////
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
        } else {
          selectedJobTitle = null;
        }

        // تعيين باقي الحقول من الopportunity بعد تحميل العناوين
        _descController.text = widget.opportunity?.description ?? '';
        selectedEmploymentType = widget.opportunity?.employmentType;
        _locationController.text = widget.opportunity?.location ?? '';
        _salaryRangeController.text = widget.opportunity?.salaryRange ?? '';
        selectedJobLevel = widget.opportunity?.experienceLevel;
        _skillsController.text = widget.opportunity?.requiredSkills ?? '';
        selectedQualification = widget.opportunity?.educationLevel;
        selectedYearsOfExperience = widget.opportunity?.yearsOfExperience;
        _date = widget.opportunity?.postingDate;
        _applicationDeadline = widget.opportunity?.applicationDeadline;
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
      TextEditingController controller, String label, IconData icon,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
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

                    // Dropdown لعناوين الفرص الوظيفية
                    _buildDropdown<String>(
                      label: 'Opportunity Title',
                      value: selectedJobTitle,
                      items: jobTitles
                          .map((title) => DropdownMenuItem(
                                value: title,
                                child: Text(title),
                              ))
                          .toList(),
                      onChanged: (val) {
                        setState(() => selectedJobTitle = val);
                      },
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
                    _buildTextField(_salaryRangeController, 'Salary Range',
                        Icons.monetization_on),
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

                    Row(
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
