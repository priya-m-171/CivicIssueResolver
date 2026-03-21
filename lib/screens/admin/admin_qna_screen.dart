import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/qna_provider.dart';
import '../../config/app_constants.dart';

class AdminQnaScreen extends StatefulWidget {
  const AdminQnaScreen({super.key});

  @override
  State<AdminQnaScreen> createState() => _AdminQnaScreenState();
}

class _AdminQnaScreenState extends State<AdminQnaScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<QnaProvider>(context, listen: false).fetchQna();
    });
  }

  void _showReplyDialog(BuildContext context, QnaItem item) {
    final TextEditingController replyCtrl = TextEditingController(
      text: item.reply ?? '',
    );
    bool submitting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Reply to User'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'User: ${item.userEmail}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Question: ${item.question}',
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: replyCtrl,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Type your reply...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: submitting ? null : () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: submitting
                    ? null
                    : () async {
                        if (replyCtrl.text.trim().isEmpty) return;
                        final messenger = ScaffoldMessenger.of(this.context);
                        final navigator = Navigator.of(context);
                        setState(() => submitting = true);
                        try {
                          await Provider.of<QnaProvider>(
                            this.context,
                            listen: false,
                          ).replyToQuestion(item.id, replyCtrl.text.trim());
                          navigator.pop();
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text('Reply saved!'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        } catch (e) {
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text('Failed: $e'),
                              backgroundColor: AppColors.danger,
                            ),
                          );
                        } finally {
                          if (mounted) {
                            setState(() => submitting = false);
                          }
                        }
                      },
                child: submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Send Reply'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inbox & Q&A')),
      body: Consumer<QnaProvider>(
        builder: (context, qnaProvider, _) {
          if (qnaProvider.isLoading && qnaProvider.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (qnaProvider.items.isEmpty) {
            return const Center(
              child: Text('No messages or Q&A submissions yet.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: qnaProvider.items.length,
            itemBuilder: (ctx, i) {
              final item = qnaProvider.items[i];
              final isAnswered = item.status == 'answered';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.userEmail,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isAnswered
                              ? AppColors.success.withValues(alpha: 0.1)
                              : AppColors.warning.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isAnswered ? 'Answered' : 'Pending',
                          style: TextStyle(
                            color: isAnswered
                                ? AppColors.success
                                : AppColors.warning,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        item.question,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (isAnswered && item.reply != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Reply: ${item.reply}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.reply),
                    color: AppColors.primary,
                    onPressed: () => _showReplyDialog(context, item),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
