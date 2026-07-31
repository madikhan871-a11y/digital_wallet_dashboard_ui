import 'package:flutter/material.dart';

class CitySearchBar extends StatefulWidget {
  const CitySearchBar({
    super.key,
    required this.controller,
    required this.onSearch,
    this.onSubmitted,
    this.hintText = 'Search city…',
  });

  final TextEditingController controller;
  final VoidCallback onSearch;
  final ValueChanged<String>? onSubmitted;
  final String hintText;

  @override
  State<CitySearchBar> createState() => _CitySearchBarState();
}

class _CitySearchBarState extends State<CitySearchBar> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
  }

  @override
  void didUpdateWidget(covariant CitySearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onChanged);
      widget.controller.addListener(_onChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: widget.controller,
            textInputAction: TextInputAction.search,
            onSubmitted: widget.onSubmitted ?? (_) => widget.onSearch(),
            decoration: InputDecoration(
              hintText: widget.hintText,
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: widget.controller.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () => widget.controller.clear(),
                    ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        FilledButton(
          onPressed: widget.onSearch,
          style: FilledButton.styleFrom(
            minimumSize: const Size(52, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Icon(Icons.arrow_forward_rounded),
        ),
      ],
    );
  }
}
