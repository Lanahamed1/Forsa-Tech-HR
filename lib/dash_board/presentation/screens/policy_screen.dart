import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forsatech/dash_board/business_logic/cubit/dash_board_cubit.dart';
import 'package:forsatech/dash_board/business_logic/cubit/dash_board_state.dart';
import 'package:forsatech/dash_board/data/model/policy_model.dart';
import 'package:forsatech/dash_board/data/repository/policy_repository.dart';
import 'package:forsatech/dash_board/data/web_services/policy_web_services.dart';

class PoliciesScreen extends StatelessWidget {
  const PoliciesScreen({super.key});

  void showSnackBar(BuildContext context, String message,
      {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

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
                color: Colors.white,
              ),
            ),
          ),
        ),
        body: BlocConsumer<PoliciesCubit, PoliciesState>(
          listener: (context, state) {
            if (state is PoliciesSubscribed) {
              showSnackBar(context, '✅ Subscription successful');
            } else if (state is PoliciesPending) {
              showSnackBar(context, '⏳ Your request is pending approval');
            } else if (state is PoliciesError) {
              showSnackBar(context, '❌ ${state.message}', isError: true);
            }
          },
          builder: (context, state) {
            if (state is PoliciesLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is PoliciesLoaded) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  double screenWidth = constraints.maxWidth;
                  int columns = 1;
                  double aspectRatio = 18 / 10;

                  if (screenWidth >= 1200) {
                    columns = 2;
                    aspectRatio = 16 / 9;
                  }
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio: aspectRatio,
                      ),
                      itemCount: 2,
                      itemBuilder: (context, index) {
                        final isFree = index == 0;
                        final policy = isFree
                            ? state.policy.freePolicy
                            : state.policy.premiumPolicy;

                        return _buildPolicyCard(
                          context,
                          title: isFree ? "Free Plan" : "Premium Plan",
                          icon: isFree
                              ? Icons.free_breakfast
                              : Icons.workspace_premium,
                          policy: policy,
                          onSubscribe: () {
                            context.read<PoliciesCubit>().subscribe(policy.id);
                          },
                        );
                      },
                    ),
                  );
                },
              );
            } else if (state is PoliciesPending) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.hourglass_top, size: 64, color: Colors.orange),
                    SizedBox(height: 12),
                    Text(
                      "⏳ Your request is pending approval.",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            } else if (state is PoliciesSubscribed) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, size: 64, color: Colors.green),
                    SizedBox(height: 12),
                    Text(
                      "🎉 Subscription successful!",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            } else if (state is PoliciesError) {
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
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
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
          const SizedBox(height: 20),
          Center(
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(18),
              child: InkWell(
                onTap: onSubscribe,
                borderRadius: BorderRadius.circular(18),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3B82F6), Color(0xFF9333EA)],
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.subscriptions_outlined, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        "Subscribe Now",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF6366F1)),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: Colors.black87,
                ),
                children: [
                  TextSpan(
                    text: "$label: ",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
