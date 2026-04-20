import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:archive/core/constants/app_colors.dart';
import 'package:archive/core/constants/app_text_styles.dart';
import 'package:archive/presentation/providers/places_provider.dart';

class SearchBarWidget extends ConsumerStatefulWidget {
  final bool autofocus;
  final bool readOnly;

  const SearchBarWidget({
    super.key,
    this.autofocus = false,
    this.readOnly = false,
  });

  @override
  ConsumerState<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends ConsumerState<SearchBarWidget> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ref.read(searchQueryProvider),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.readOnly ? () => context.push('/map') : null,
      child: Container(
        height: 48,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade700),
        ),
        child: Row(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Icon(Icons.search, color: AppColors.primary),
            ),
            Expanded(
              child: widget.readOnly
                  ? Text(
                      'Search places, landmarks...',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.5),
                      ),
                    )
                  : TextField(
                      controller: _controller,
                      autofocus: widget.autofocus,
                      decoration: InputDecoration(
                        hintText: 'Search places, landmarks...',
                        hintStyle: AppTextStyles.bodyMedium.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.5),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (val) {
                        ref.read(searchQueryProvider.notifier).state = val;
                      },
                    ),
            ),
            if (!widget.readOnly && _controller.text.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: () {
                  _controller.clear();
                  ref.read(searchQueryProvider.notifier).state = '';
                },
              ),
          ],
        ),
      ),
    );
  }
}
