import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forsatech/dash_board/business_logic/cubit/dash_board_cubit.dart';
import 'package:forsatech/dash_board/business_logic/cubit/dash_board_state.dart';
import 'package:forsatech/dash_board/data/model/policy_model.dart';
import 'package:forsatech/dash_board/data/repository/policy_repository.dart';
import 'package:forsatech/dash_board/data/web_services/policy_web_services.dart';

class PoliciesScreen extends StatefulWidget {
  const PoliciesScreen({super.key});

  @override
  State<PoliciesScreen> createState() => _PoliciesScreenState();
}

class _PoliciesScreenState extends State<PoliciesScreen> {
  int? selectedPlanId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PoliciesCubit(PoliciesRepository(PoliciesWebService()))
        ..loadPolicies(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
          title: ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF3B82F6), Color(0xFF9333EA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: const Text(
              "Policies",
              style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
        ),
        body: BlocConsumer<PoliciesCubit, PoliciesState>(
          listener: (context, state) {},
          builder: (context, state) {
            if (state is PoliciesLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is PoliciesLoaded) {
              final policies = state.policies;

              for (var p in policies) {
                print(
                    'Policy: ${p.name}, isActiveForCompany: ${p.isActiveForCompany}');
              }

              final unsubscribedPlans =
                  policies.where((p) => !p.isActiveForCompany).toList();

              print(
                  'Unsubscribed plans: ${unsubscribedPlans.map((e) => e.name).toList()}');

              if (selectedPlanId != null &&
                  !unsubscribedPlans.any((plan) => plan.id == selectedPlanId)) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  setState(() {
                    selectedPlanId = null;
                  });
                });
              }

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Change Subscription Plan:",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButton<int>(
                        value: selectedPlanId,
                        hint: const Text("Select a plan"),
                        isExpanded: true,
                        underline: const SizedBox(),
                        items: unsubscribedPlans
                            .map((p) => DropdownMenuItem<int>(
                                  value: p.id,
                                  child: Text(p.name),
                                ))
                            .toList(),
                        onChanged: (value) async {
                          if (value != null) {
                            setState(() {
                              selectedPlanId = value;
                            });

                            await context
                                .read<PoliciesCubit>()
                                .subscribe(value);

                            await context.read<PoliciesCubit>().loadPolicies();

                            await Future.delayed(
                                const Duration(milliseconds: 100));

                            setState(() {
                              selectedPlanId = null;
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    "📩 Subscription request has been sent"),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          double screenWidth = constraints.maxWidth;
                          int columns = screenWidth >= 1200 ? 2 : 1;
                          double aspectRatio =
                              screenWidth >= 1200 ? 16 / 9 : 18 / 10;

                          return GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: columns,
                              crossAxisSpacing: 20,
                              mainAxisSpacing: 20,
                              childAspectRatio: aspectRatio,
                            ),
                            itemCount: policies.length,
                            itemBuilder: (context, index) {
                              final policy = policies[index];
                              final bool isSubscribed =
                                  policy.isActiveForCompany;

                              // ✅ علامة الصح تظهر فقط إذا كانت الخطة مفعّلة من السيرفر
                              bool showSubscribedBadge = isSubscribed;

                              return _buildPolicyCard(
                                context,
                                title: policy.name,
                                icon: policy.name.toLowerCase() == 'free'
                                    ? Icons.free_breakfast
                                    : Icons.workspace_premium,
                                policy: policy,
                                showSubscribeButton: false,
                                showSubscribedBadge: showSubscribedBadge,
                                onSubscribe: () {},
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            }

            if (state is PoliciesLoadError) {
              return Center(
                child: Text(
                  "⚠️ Error: ${state.message}",
                  style: const TextStyle(fontSize: 18, color: Colors.red),
                ),
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildPolicyCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required PolicyDetail policy,
    required VoidCallback onSubscribe,
    bool showSubscribeButton = true,
    bool showSubscribedBadge = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 28, color: const Color(0xFF6366F1)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF6366F1),
                      ),
                ),
              ),
              if (showSubscribedBadge)
                const Icon(Icons.check_circle, color: Colors.green, size: 28),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _infoRow(Icons.person, "Name", policy.name),
                _infoRow(Icons.post_add, "Job Post Limit",
                    policy.jobPostLimit?.toString() ?? 'Unlimited'),
                _infoRow(Icons.article, "Generate Tests",
                    policy.canGenerateTests ? '✅ Yes' : '❌ No'),
                _infoRow(Icons.schedule, "Schedule Interviews",
                    policy.canScheduleInterviews ? '✅ Yes' : '❌ No'),
                _infoRow(Icons.group, "Candidate Suggestions",
                    policy.candidateSuggestions),
                _infoRow(Icons.attach_money, "Price",
                    policy.price != null ? '\$${policy.price}' : 'Free'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
