import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:archive/core/constants/app_colors.dart';
import 'package:archive/core/constants/app_text_styles.dart';
import 'package:archive/domain/entities/trip.dart';
import 'package:archive/presentation/providers/saved_provider.dart';

class TripTile extends ConsumerWidget {
  final Trip trip;

  const TripTile({super.key, required this.trip});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.route, color: AppColors.primary),
        ),
        title: Text(trip.name, style: AppTextStyles.title2),
        subtitle: Text(
          '${trip.stops.length} stop${trip.stops.length == 1 ? '' : 's'}',
          style: AppTextStyles.bodySmall.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: () => _showTripStops(context, ref, trip),
        onLongPress: () => _confirmDelete(context, ref),
      ),
    );
  }

  void _showTripStops(BuildContext context, WidgetRef ref, Trip trip) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TripStopsSheet(trip: trip),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Trip'),
        content: Text('Delete "${trip.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(savedRepositoryProvider).deleteTrip(trip.id);
              ref.invalidate(tripsProvider);
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _TripStopsSheet extends ConsumerStatefulWidget {
  final Trip trip;

  const _TripStopsSheet({required this.trip});

  @override
  ConsumerState<_TripStopsSheet> createState() => _TripStopsSheetState();
}

class _TripStopsSheetState extends ConsumerState<_TripStopsSheet> {
  late List<TripStop> _stops;

  @override
  void initState() {
    super.initState();
    _stops = List.from(widget.trip.stops);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade600,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(widget.trip.name, style: AppTextStyles.title1),
          const SizedBox(height: 4),
          Text(
            '${_stops.length} stop${_stops.length == 1 ? '' : 's'}',
            style: AppTextStyles.bodySmall.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 16),
          if (_stops.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('No stops yet. Add places from the detail screen.'),
              ),
            )
          else
            SizedBox(
              height: 300,
              child: ReorderableListView.builder(
                itemCount: _stops.length,
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) newIndex--;
                    final stop = _stops.removeAt(oldIndex);
                    _stops.insert(newIndex, stop);
                  });
                  ref.read(savedRepositoryProvider).reorderTripStops(
                        widget.trip.id,
                        _stops,
                      );
                },
                itemBuilder: (context, i) {
                  final stop = _stops[i];
                  return ListTile(
                    key: Key('${stop.placeId}_$i'),
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary,
                      radius: 14,
                      child: Text(
                        '${i + 1}',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                    title: Text(
                      stop.placeId,
                      style: AppTextStyles.bodyMedium,
                    ),
                    subtitle: stop.notes.isNotEmpty ? Text(stop.notes) : null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.open_in_new, size: 18),
                          onPressed: () {
                            Navigator.pop(context);
                            context.push('/place/${stop.placeId}');
                          },
                        ),
                        const Icon(Icons.drag_handle),
                      ],
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
