import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forsatech/dash_board/business_logic/cubit/dash_board_cubit.dart';
import 'package:forsatech/dash_board/business_logic/cubit/dash_board_state.dart';
import 'package:forsatech/dash_board/data/model/opportunity_model.dart';
import 'package:forsatech/dash_board/presentation/screens/add_opportunity_dialog.dart';
import 'package:forsatech/dash_board/presentation/screens/job_opportunity_details_secreen.dart';

class OpportunityScreen extends StatefulWidget {
  const OpportunityScreen({super.key});

  @override
  State<OpportunityScreen> createState() => _OpportunityScreenState();
}

class _OpportunityScreenState extends State<OpportunityScreen> {
  @override
  void initState() {
    super.initState();
    context.read<OpportunityCubit>().loadOpportunities();
    _filteredOpportunities = List.from(_allOpportunities);
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

  void _filterOpportunities(String query) {
    setState(() {});
  }

  final TextEditingController _searchController = TextEditingController();
  final List<String> _allOpportunities = [
    "Software Tester",
    "Backend developer",
    "Frontend developer",
    "UI/UX Engineer",
    "React.js Developer",
    "Vue.js Developer",
    "Vue.js Developer",
    "Web Designer",
    "JavaScript Developer",
    "Database Engineer",
    "Fullstack Developer (Django + React)",
    "Fullstack Developer (Django + React)",
    "AWS/GCP Engineer",
    "Network Security Engineer",
    "Flutter Developer",
    "ML Engineer",
    "NLP Engineer",
    "System Administrator"
  ];
  // ignore: unused_field
  List<String> _filteredOpportunities = [];

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      onChanged: _filterOpportunities,
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
                      fontSize: 28,
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
                    final filteredOpportunities = state.opportunities
                        .where((opportunity) {
                          return opportunity.title!
                              .toLowerCase()
                              .contains(_searchController.text.toLowerCase());
                        })
                        .toList()
                        .reversed
                        .toList();

                    return OpportunityList(
                      opportunities: filteredOpportunities,
                      onEdit: _editOpportunity,
                      onDelete: _deleteOpportunity,
                    );
                  } else {
                    return const Center(child: Text('Something went wrong'));
                  }
                },
              )),
            ],
          ),
        );
      },
    );
  }
}

//////////////////////////////////////////////////////////////////////////////////////////////////////
///                 Opportunity List
///
///


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
///
///            Opportunity Card
/// 
/// 

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

  String getStatus() {
    final now = DateTime.now();

    if (opportunity.postingDate != null &&
        now.isBefore(opportunity.postingDate!)) {
      return 'Pending';
    } else if (opportunity.applicationDeadline != null &&
        now.isAfter(opportunity.applicationDeadline!)) {
      return 'Closed';
    } else {
      return 'Open';
    }
  }

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
                // ignore: deprecated_member_use
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
                        // if (opportunity.status != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: _StatusChip(status: getStatus()),
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

//////////////////////////////////////////////////////////
///
///           widget
/// 



class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Chip(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      avatar: Icon(icon, size: 24, color: const Color(0xFF6366F1)),
      label: Text(text, style: const TextStyle(fontSize: 15)),
      backgroundColor: Colors.grey.shade100,
    );
  }
}


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



