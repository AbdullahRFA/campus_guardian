import 'package:campus_guardian/services/database_service.dart';
import 'package:campus_guardian/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GiveFeedbackScreen extends StatefulWidget {
  final String sessionId;
  final bool isUserTheMentor;

  const GiveFeedbackScreen({super.key, required this.sessionId, required this.isUserTheMentor});

  @override
  State<GiveFeedbackScreen> createState() => _GiveFeedbackScreenState();
}

class _GiveFeedbackScreenState extends State<GiveFeedbackScreen> {
  int _rating = 0;
  final _feedbackController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submitFeedback() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a rating.'), backgroundColor: Colors.orange),
      );
      return;
    }
    setState(() => _isSubmitting = true);

    try {
      await DatabaseService().submitFeedback(
        sessionId: widget.sessionId,
        rating: _rating,
        feedback: _feedbackController.text.trim(),
        isUserTheMentor: widget.isUserTheMentor,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thank you for your feedback!'), backgroundColor: Colors.green),
        );
        // MODIFICATION: Redirect to the sessions page instead of just popping.
        context.go('/app/sessions');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Give Feedback')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text('How was your session?', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          Text('Please rate your experience (1-5 stars):', style: Theme.of(context).textTheme.titleMedium),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                icon: Icon(
                  index < _rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 40,
                ),
                onPressed: () => setState(() => _rating = index + 1),
              );
            }),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _feedbackController,
            decoration: const InputDecoration(
              labelText: 'Additional Comments (Optional)',
              border: OutlineInputBorder(),
            ),
            maxLines: 5,
          ),
          const SizedBox(height: 32),
          AppButton(
            text: _isSubmitting ? 'Submitting...' : 'Submit Feedback',
            onPressed: _isSubmitting ? null : _submitFeedback,
          ),
        ],
      ),
    );
  }
}