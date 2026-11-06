import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/incident_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import 'report_list_slivers.dart';

// The Search tab: search text, status filters and a category filter.
// The filtering itself happens in IncidentProvider.filtered.
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<IncidentProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _CategoryFilterButton(p: p),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _filters(p)),
          ...reportListSlivers(
            context,
            provider: p,
            items: p.filtered,
            emptyIcon: p.isFiltering ? Icons.search_off : Icons.inbox_outlined,
            emptyMessage: p.isFiltering
                ? 'No reports match your search or filters'
                : 'No reports yet.',
          ),
        ],
      ),
    );
  }

  Widget _filters(IncidentProvider p) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            onChanged: p.setSearch,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search title, description or location',
              prefixIcon: const Icon(Icons.search),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(color: AppColors.line),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterPill(
                  label: 'All',
                  selected: p.statusFilter == null,
                  onTap: () => p.setStatusFilter(null),
                ),
                for (final e in statusLabels.entries)
                  _FilterPill(
                    label: e.value,
                    selected: p.statusFilter == e.key,
                    onTap: () => p.setStatusFilter(e.key),
                  ),
              ],
            ),
          ),
          if (p.categoryFilter != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: InputChip(
                label: Text('Category: ${categoryLabels[p.categoryFilter]}'),
                onDeleted: () => p.setCategoryFilter(null), // the x clears it
              ),
            ),
          if (!p.isLoading && p.loadError == null) ...[
            const SizedBox(height: 14),
            Text(
              '${p.filtered.length} '
              '${p.filtered.length == 1 ? 'result' : 'results'}',
              style: const TextStyle(color: AppColors.muted, fontSize: 12.5),
            ),
          ],
        ],
      ),
    );
  }
}

// A rounded status filter: blue when selected, white when not
class _FilterPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: selected ? AppColors.primary : AppColors.surface,
        shape: StadiumBorder(
          side: BorderSide(
            color: selected ? AppColors.primary : AppColors.line,
          ),
        ),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.ink,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// The round button in the top bar that opens the category menu
class _CategoryFilterButton extends StatelessWidget {
  final IncidentProvider p;
  const _CategoryFilterButton({required this.p});

  @override
  Widget build(BuildContext context) {
    final active = p.categoryFilter != null;
    return PopupMenuButton<String>(
      tooltip: 'Filter by category',
      onSelected: (value) => p.setCategoryFilter(value == 'all' ? null : value),
      itemBuilder: (_) => [
        const PopupMenuItem(value: 'all', child: Text('All categories')),
        for (final e in categoryLabels.entries)
          PopupMenuItem(
            value: e.key,
            child: Row(
              children: [
                Icon(categoryIcons[e.key], size: 20, color: AppColors.primary),
                const SizedBox(width: 10),
                Text(e.value),
              ],
            ),
          ),
      ],
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.tint,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.tune,
          size: 20,
          color: active ? Colors.white : AppColors.primary,
        ),
      ),
    );
  }
}
