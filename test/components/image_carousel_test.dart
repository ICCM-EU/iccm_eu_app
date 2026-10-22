import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iccm_eu_app/components/image_carousel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ImageCarousel Tests', () {
    testWidgets('renders CarouselSlider and DotsIndicator when imageUrls is non-empty', (WidgetTester tester) async {
      final images = [
        'https://example.com/img1.png',
        'https://example.com/img2.png',
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ImageCarousel(imageUrls: images),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CarouselSlider), findsOneWidget);
      expect(find.byType(DotsIndicator), findsOneWidget);
    });

    testWidgets('renders SizedBox.shrink when imageUrls is empty', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ImageCarousel(imageUrls: []),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CarouselSlider), findsNothing);
    });
  });
}
