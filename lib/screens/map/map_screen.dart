import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../../app_colors.dart';
import '../../data/campus_data.dart';
import '../../models/campus_location.dart';
import '../../widgets/campus_hotspot.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final _searchController = TextEditingController();
  final _mapController = TransformationController();
  String _searchQuery = '';
  CampusLocation? _activeLocation;

  @override
  void initState() {
    super.initState();
    _mapController.value = Matrix4.diagonal3Values(2.25, 2.25, 1);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _searchQuery = '');
  }

  void _openLocation(CampusLocation location) {
    setState(() {
      _activeLocation = location;
      _searchQuery = '';
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeLocation = _activeLocation;
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          _MapHeader(
            subtitle: activeLocation == null
                ? 'Online Campus Map'
                : '${activeLocation.name} — Interior',
            showBack: activeLocation != null,
            onBack: () => setState(() => _activeLocation = null),
          ),
          if (activeLocation == null) _buildSearchField(),
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: const Color(0xFF95BE86),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: .08),
                      blurRadius: 8,
                      offset: const Offset(0, 2))
                ],
              ),
              child: activeLocation == null
                  ? _buildCampusMap()
                  : _buildInterior(activeLocation),
            ),
          ),
          _GuidanceCard(location: activeLocation),
          const SizedBox(height: 92),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
          color: const Color(0xFFE3E3E8),
          borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppColors.iosGray, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              style: const TextStyle(fontSize: 14, color: Color(0xFF1C1C1E)),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Search building or facility...',
                hintStyle: TextStyle(color: AppColors.iosGray),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            IconButton(
              onPressed: _clearSearch,
              icon:
                  const Icon(Icons.cancel, color: AppColors.iosGray, size: 16),
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
              tooltip: 'Clear search',
            ),
        ],
      ),
    );
  }

  Widget _buildCampusMap() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availW = constraints.maxWidth;
        final availH = constraints.maxHeight;
        const imgAspect = 1037.0 / 1024.0;

        double mapWidth = availW;
        double mapHeight = mapWidth / imgAspect;
        if (mapHeight > availH) {
          mapHeight = availH;
          mapWidth = mapHeight * imgAspect;
        }

        final normalizedQuery = _searchQuery.toLowerCase().trim();

        return InteractiveViewer(
          transformationController: _mapController,
          alignment: Alignment.center,
          minScale: 1,
          maxScale: 4,
          panEnabled: true,
          scaleEnabled: true,
          boundaryMargin: const EdgeInsets.all(120),
          child: AnimatedBuilder(
            animation: _mapController,
            child: Positioned.fill(
              child: Image.asset(
                'assets/campus_map.png',
                fit: BoxFit.fill,
              ),
            ),
            builder: (context, mapImage) {
              final mapScale = _mapController.value.getMaxScaleOnAxis();
              final hotspotScale =
                  math.pow(1.25 / mapScale, 0.8).clamp(0.1, 1.0).toDouble();

              return Center(
                child: SizedBox(
                  width: mapWidth,
                  height: mapHeight,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      mapImage!,
                      for (final location in campusLocations)
                        Positioned(
                          left: location.left * mapWidth,
                          top: location.top * mapHeight - 8 * hotspotScale,
                          child: FractionalTranslation(
                            translation: const Offset(-0.5, 0),
                            child: CampusHotspot(
                              location: location,
                              scale: hotspotScale,
                              highlighted: normalizedQuery.isNotEmpty &&
                                  (location.label
                                          .toLowerCase()
                                          .contains(normalizedQuery) ||
                                      location.name
                                          .toLowerCase()
                                          .contains(normalizedQuery)),
                              onTap: () => _openLocation(location),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildInterior(CampusLocation location) {
    final cs = Theme.of(context).colorScheme;
    final cardColor = Theme.of(context).cardColor;
    return InteractiveViewer(
      minScale: 1,
      maxScale: 4,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(40),
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: .10),
                  blurRadius: 10,
                  offset: const Offset(0, 4))
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.business_outlined,
                  size: 48, color: AppColors.primaryGreen),
              const SizedBox(height: 12),
              Text('Indoor Blueprint for ${location.name}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 17,
                      color: cs.onSurface,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text(location.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 13,
                      height: 1.38,
                      color: cs.onSurface.withValues(alpha: .55))),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapHeader extends StatelessWidget {
  const _MapHeader(
      {required this.subtitle, required this.showBack, required this.onBack});

  final String subtitle;
  final bool showBack;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
      color: isDark
          ? AppColors.surfaceDark.withValues(alpha: .97)
          : Colors.white.withValues(alpha: .92),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('LAGUNA UNIVERSITY',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: .3,
                        color: AppColors.primaryGreen)),
                const SizedBox(height: 1),
                Text(subtitle,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: cs.onSurface.withValues(alpha: .55))),
              ],
            ),
          ),
          if (showBack)
            FilledButton.tonalIcon(
              onPressed: onBack,
              icon: const Icon(Icons.chevron_left, size: 16),
              label: const Text('Back'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                textStyle:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                shape: const StadiumBorder(),
              ),
            ),
        ],
      ),
    );
  }
}

class _GuidanceCard extends StatelessWidget {
  const _GuidanceCard({required this.location});

  final CampusLocation? location;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = location != null;
    final iconBg = isDark
        ? AppColors.primaryGreen.withValues(alpha: .2)
        : AppColors.lightGreen;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? .30 : .10),
              blurRadius: 12,
              offset: const Offset(0, -4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                    color: iconBg, borderRadius: BorderRadius.circular(12)),
                child: Icon(isSelected ? Icons.map : Icons.business,
                    color: AppColors.primaryGreen, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(location?.name ?? 'Campus Exploration',
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface)),
                    const SizedBox(height: 1),
                    Text(
                        location?.floorsCount ??
                            'Tap any building pin on the map to view details',
                        style: TextStyle(
                            fontSize: 13,
                            color: cs.onSurface.withValues(alpha: .55))),
                  ],
                ),
              ),
            ],
          ),
          if (isSelected) ...[
            const SizedBox(height: 12),
            Text(location?.description ?? '',
                style: TextStyle(
                    fontSize: 13,
                    height: 1.38,
                    color: cs.onSurface.withValues(alpha: .70))),
          ],
        ],
      ),
    );
  }
}
