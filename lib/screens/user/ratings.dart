import 'package:flutter/material.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_snackbar.dart';

class RatingsScreen extends StatefulWidget {
  const RatingsScreen({super.key});

  @override
  State<RatingsScreen> createState() => _RatingsScreenState();
}

class _RatingsScreenState extends State<RatingsScreen> {
  int selectedRating = 0;
  final TextEditingController _reviewController = TextEditingController();

  void _submitRating() {
    if (selectedRating == 0) {
      AppSnackbar.show(context, "Please select a rating.");
      return;
    }

    String summary = '''
Rating: $selectedRating star${selectedRating > 1 ? 's' : ''}
Review: ${_reviewController.text}
    ''';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Review"),
        content: Text(summary),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              AppSnackbar.show(context, "Thank you for your feedback!");
              Navigator.pop(context); 
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }

  Widget _buildStars() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return IconButton(
          icon: Icon(
            index < selectedRating ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 30,
          ),
          onPressed: () => setState(() => selectedRating = index + 1),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text("Rate Your Delivery")),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFe0f7fa), Color(0xFF80deea)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    "How was your experience?",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  _buildStars(),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _reviewController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: "Write a review (optional)...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 30),
                  AppButton(text: "Submit Review", onPressed: _submitRating),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
