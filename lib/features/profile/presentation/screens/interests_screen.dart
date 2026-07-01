import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/app_widgets.dart';

class InterestsScreen extends ConsumerStatefulWidget {
  const InterestsScreen({super.key});

  @override
  ConsumerState<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends ConsumerState<InterestsScreen> {
  final List<String> _selected = [];
  final _interests = ['Tech', 'Design', 'Business', 'Marketing', 'Art', 'Music', 'Sports'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Interests')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _interests.map((i) => ChoiceChip(
                label: Text(i),
                selected: _selected.contains(i),
                onSelected: (v) {
                  setState(() {
                    if (v) {
                      _selected.add(i);
                    } else {
                      _selected.remove(i);
                    }
                  });
                },
              )).toList(),
            ),
            const Spacer(),
            AppPrimaryButton(
              label: 'Continue',
              onPressed: () => context.go(AppRoutes.home),
            )
          ],
        ),
      ),
    );
  }
}
