import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lu_navigate/app_colors.dart';
import 'package:lu_navigate/screens/map/map_screen.dart';
import 'package:lu_navigate/widgets/campus_hotspot.dart';

// Mirrors the production MaterialApp theme so layout is identical in tests.
Widget _buildApp() => MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryGreen,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: AppColors.background,
        cardColor: Colors.white,
      ),
      home: const Scaffold(body: MapScreen()),
    );

void main() {
  testWidgets(
      'Campus map pins remain at the same relative position across screen sizes',
      (tester) async {
    const testSizes = [
      Size(360, 640), // Compact mobile
      Size(412, 915), // Modern tall mobile
      Size(800, 1000), // Tablet portrait
      Size(1440, 900), // Desktop / landscape
    ];

    double? referenceRelX;
    double? referenceRelY;

    for (final size in testSizes) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      final mapViewer = tester.widget<InteractiveViewer>(
        find.byType(InteractiveViewer).first,
      );
      final zoomController = mapViewer.transformationController!;
      final initialMapScale = zoomController.value.getMaxScaleOnAxis();
      expect(initialMapScale, greaterThan(1));
      expect(mapViewer.boundaryMargin.horizontal, greaterThan(0));

      final imageBox = tester.renderObject<RenderBox>(find.byType(Image));
      final pinIconBox = tester.renderObject<RenderBox>(
        find.descendant(
          of: find.widgetWithText(CampusHotspot, 'Engr. Bldg.'),
          matching: find.byIcon(Icons.location_on),
        ),
      );

      final imageTopLeft = imageBox.localToGlobal(Offset.zero);
      final imageBottomRight = imageBox.localToGlobal(
        Offset(imageBox.size.width, imageBox.size.height),
      );
      final pinCenter = pinIconBox.localToGlobal(
        pinIconBox.size.center(Offset.zero),
      );

      final relX = (pinCenter.dx - imageTopLeft.dx) /
          (imageBottomRight.dx - imageTopLeft.dx);
      final relY = (pinCenter.dy - imageTopLeft.dy) /
          (imageBottomRight.dy - imageTopLeft.dy);

      if (referenceRelX == null) {
        // First size is the reference baseline
        referenceRelX = relX;
        referenceRelY = relY;

        // Sanity-check: pin should be roughly in the engineering building area
        expect(relX, inInclusiveRange(0.30, 0.50),
            reason: 'Engr. Bldg. pin X out of expected region at $size');
        expect(relY, inInclusiveRange(0.35, 0.55),
            reason: 'Engr. Bldg. pin Y out of expected region at $size');
      } else {
        // All subsequent sizes must match the reference (pins are locked)
        expect(
          relX,
          closeTo(referenceRelX, 0.002),
          reason:
              'Pin X shifted across screen sizes (expected ${referenceRelX.toStringAsFixed(4)}, got ${relX.toStringAsFixed(4)}) at $size',
        );
        expect(
          relY,
          closeTo(referenceRelY!, 0.002),
          reason:
              'Pin Y shifted across screen sizes (expected ${referenceRelY.toStringAsFixed(4)}, got ${relY.toStringAsFixed(4)}) at $size',
        );
      }

      if (size == testSizes.first) {
        final hotspot = tester.widget<CampusHotspot>(
          find.widgetWithText(CampusHotspot, 'Engr. Bldg.'),
        );
        expect(hotspot.scale, lessThanOrEqualTo(1));
        final labelFinder = find.text('Engr. Bldg.');
        final labelBox = tester.renderObject<RenderBox>(labelFinder);
        final initialLabelTopLeft = labelBox.localToGlobal(Offset.zero);
        final initialLabelBottomRight = labelBox.localToGlobal(
          Offset(labelBox.size.width, labelBox.size.height),
        );
        final initialLabelWidth =
            initialLabelBottomRight.dx - initialLabelTopLeft.dx;
        zoomController.value = Matrix4.diagonal3Values(4, 4, 1);
        await tester.pump();

        final zoomedHotspot = tester.widget<CampusHotspot>(
          find.widgetWithText(CampusHotspot, 'Engr. Bldg.'),
        );
        expect(zoomedHotspot.scale, lessThan(hotspot.scale));
        final zoomedLabelBox = tester.renderObject<RenderBox>(labelFinder);
        final zoomedLabelTopLeft = zoomedLabelBox.localToGlobal(Offset.zero);
        final zoomedLabelBottomRight = zoomedLabelBox.localToGlobal(
          Offset(zoomedLabelBox.size.width, zoomedLabelBox.size.height),
        );
        expect(
          zoomedLabelBottomRight.dx - zoomedLabelTopLeft.dx,
          lessThan(initialLabelWidth * 4 / initialMapScale),
          reason: 'Hotspot labels should counter-scale as the map zooms in',
        );

        final zoomedImage = tester.renderObject<RenderBox>(find.byType(Image));
        final zoomedPinIconBox = tester.renderObject<RenderBox>(
          find.descendant(
            of: find.widgetWithText(CampusHotspot, 'Engr. Bldg.'),
            matching: find.byIcon(Icons.location_on),
          ),
        );
        final zoomedImageTopLeft = zoomedImage.localToGlobal(Offset.zero);
        final zoomedImageBottomRight = zoomedImage.localToGlobal(
          Offset(zoomedImage.size.width, zoomedImage.size.height),
        );
        final zoomedPinCenter = zoomedPinIconBox.localToGlobal(
          zoomedPinIconBox.size.center(Offset.zero),
        );
        expect(
          (zoomedPinCenter.dx - zoomedImageTopLeft.dx) /
              (zoomedImageBottomRight.dx - zoomedImageTopLeft.dx),
          closeTo(relX, 0.002),
        );
        expect(
          (zoomedPinCenter.dy - zoomedImageTopLeft.dy) /
              (zoomedImageBottomRight.dy - zoomedImageTopLeft.dy),
          closeTo(relY, 0.002),
        );
        zoomController.value = Matrix4.diagonal3Values(
          initialMapScale,
          initialMapScale,
          1,
        );
        await tester.pump();
      }
    }
  });
}
