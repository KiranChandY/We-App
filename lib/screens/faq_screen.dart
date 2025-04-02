import 'package:flutter/material.dart';

class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FAQ', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              color: Colors.deepPurple,
              child: const Column(
                children: [
                  Icon(
                    Icons.question_answer,
                    size: 48,
                    color: Colors.white,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Frequently Asked Questions',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Find answers to common questions about WE',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const ExpansionTileGroup(
              title: 'Getting Started',
              faqs: [
                FAQ(
                  question: 'What is WE?',
                  answer: 'WE is a collaborative event planning platform that helps communities organize and manage events together. It combines social networking features with powerful event management tools.',
                ),
                FAQ(
                  question: 'How do I create an account?',
                  answer: 'You can create an account using your email address or sign up with your Google or Apple account. Just tap the "Sign Up" button on the welcome screen and follow the instructions.',
                ),
                FAQ(
                  question: 'Is WE free to use?',
                  answer: 'Yes, WE is free to use for basic features. We also offer premium features for users who need advanced event planning capabilities.',
                ),
              ],
            ),
            const ExpansionTileGroup(
              title: 'Events',
              faqs: [
                FAQ(
                  question: 'How do I create an event?',
                  answer: 'Tap the "+" button on the home screen, select "Create Event," and fill in the event details. You can add a title, date, location, description, and invite members.',
                ),
                FAQ(
                  question: 'Can I edit an event after creating it?',
                  answer: 'Yes, as an event organizer, you can edit any event details at any time. Just open the event and tap the edit icon in the top right corner.',
                ),
                FAQ(
                  question: 'How do I invite people to my event?',
                  answer: 'Open your event, tap "Manage Members," and use the invite button to add new members. You can invite them via email or by sharing a unique event link.',
                ),
              ],
            ),
            const ExpansionTileGroup(
              title: 'Photos & Media',
              faqs: [
                FAQ(
                  question: 'How do I share photos in an event?',
                  answer: 'Open the event, go to the Photos tab, and tap the "+" button to add photos. You can choose photos from your gallery or take new ones.',
                ),
                FAQ(
                  question: 'Who can see the photos I share?',
                  answer: 'Photos are visible to all event members. You can delete your own photos at any time.',
                ),
                FAQ(
                  question: 'Can I download photos from an event?',
                  answer: 'Yes, you can download any photo from events you\'re a member of. Just tap the photo and use the download button.',
                ),
              ],
            ),
            const ExpansionTileGroup(
              title: 'Privacy & Security',
              faqs: [
                FAQ(
                  question: 'How is my data protected?',
                  answer: 'We use industry-standard encryption to protect your data. Your personal information is never shared with third parties without your consent.',
                ),
                FAQ(
                  question: 'Can I make my events private?',
                  answer: 'Yes, when creating an event, you can set it as private. Private events are only visible to invited members.',
                ),
                FAQ(
                  question: 'How do I report inappropriate content?',
                  answer: 'You can report inappropriate content by using the "Report" option in the menu of any post, photo, or comment.',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class FAQ {
  final String question;
  final String answer;

  const FAQ({
    required this.question,
    required this.answer,
  });
}

class ExpansionTileGroup extends StatelessWidget {
  final String title;
  final List<FAQ> faqs;

  const ExpansionTileGroup({
    super.key,
    required this.title,
    required this.faqs,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        ...faqs.map((faq) => ExpansionTile(
          title: Text(
            faq.question,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                faq.answer,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
            ),
          ],
        )),
        const SizedBox(height: 8),
      ],
    );
  }
} 