import 'package:flutter_test/flutter_test.dart';

import 'package:agents_app/main.dart';
import 'package:agents_app/features/jobs/widgets/job_card.dart';
import 'package:agents_app/data/mock/mock_data.dart';

import 'helpers/pump_app.dart';

void main() {
  testWidgets('VerifiX app launches login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const VerifiXApp());
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets('JobCard renders without layout overflow', (tester) async {
    final job = MockData.jobs.first;

    await pumpTestApp(
      tester,
      JobCard(job: job, onTap: () {}),
      scrollable: true,
    );

    expect(find.text('Address Verification'), findsOneWidget);
    expect(find.text(job.applicant.name), findsOneWidget);
  });

  testWidgets('JobCard compact mode renders verification type', (tester) async {
    final job = MockData.jobs.first;

    await pumpTestApp(
      tester,
      JobCard(job: job, onTap: () {}, compact: true),
      scrollable: true,
    );

    expect(find.text('Address Verification'), findsOneWidget);
  });
}
