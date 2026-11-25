import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/models/experience.dart';

class ExperienceDetailScreen extends StatelessWidget {
  const ExperienceDetailScreen({required this.experience, super.key});

  final Experience experience;

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final thumbnail = experience.thumbnail;
    final endedAt = experience.endedAt;
    return Scaffold(
      appBar: AppBar(title: Text(experience.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (thumbnail != null && thumbnail.isNotEmpty)
            Image.network(thumbnail),
          Text(experience.description),
          Text('Category: ${experience.category.label}'),
          Text(
            'Start Date: ${localizations.formatMediumDate(experience.startedAt)}',
          ),
          Text(
            endedAt == null
                ? 'Ongoing'
                : 'End Date: ${localizations.formatMediumDate(endedAt)}',
          ),
        ],
      ),
    );
  }
}
