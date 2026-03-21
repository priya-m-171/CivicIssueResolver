import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/qna_provider.dart';
import '../../config/app_constants.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final TextEditingController _questionCtrl = TextEditingController();
  bool _submitting = false;

  Future<void> _submitQuestion() async {
    final email = Provider.of<AuthProvider>(context, listen: false).user?.email;
    if (email == null) return;

    if (_questionCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a question or feedback.')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      await Provider.of<QnaProvider>(
        context,
        listen: false,
      ).submitQuestion(email, _questionCtrl.text.trim());
      if (mounted) {
        _questionCtrl.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Message sent successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<QnaProvider>(context, listen: false).fetchQna();
    });
  }

  @override
  void dispose() {
    _questionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final myEmail = Provider.of<AuthProvider>(context).user?.email;
    return Scaffold(
      appBar: AppBar(title: const Text('Help Center & Feedback')),
      body: Consumer<QnaProvider>(
        builder: (context, qnaProvider, _) {
          final myInitialQuestions = qnaProvider.items
              .where((item) => item.userEmail == myEmail)
              .toList();

          return Column(
            children: [
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'How can we help you?',
                      style: AppTextStyles.heading2,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Ask a question or send us your feedback. The support team will reply to you here shortly.',
                      style: AppTextStyles.bodySecondary,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _questionCtrl,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _submitting ? null : _submitQuestion,
                        child: _submitting
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text('Send Message'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              if (qnaProvider.isLoading && myInitialQuestions.isEmpty)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                ),
              if (!qnaProvider.isLoading && myInitialQuestions.isEmpty)
                const Expanded(
                  child: Center(child: Text('No previous messages.')),
                ),
              if (myInitialQuestions.isNotEmpty)
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: myInitialQuestions.length,
                    itemBuilder: (ctx, i) {
                      final item = myInitialQuestions[i];
                      final isAnswered = item.status == 'answered';
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isAnswered
                                          ? AppColors.success.withValues(
                                              alpha: 0.1,
                                            )
                                          : AppColors.warning.withValues(
                                              alpha: 0.1,
                                            ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      isAnswered ? 'Answered' : 'Pending Reply',
                                      style: TextStyle(
                                        color: isAnswered
                                            ? AppColors.success
                                            : AppColors.warning,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${item.createdAt.day}/${item.createdAt.month}/${item.createdAt.year}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                item.question,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              if (isAnswered && item.reply != null) ...[
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Row(
                                        children: [
                                          Icon(
                                            Icons.admin_panel_settings,
                                            size: 16,
                                            color: AppColors.adminColor,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Admin Support',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        item.reply!,
                                        style: AppTextStyles.bodySecondary,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
