import 'package:flutter/material.dart';
import 'package:money_manager/features/add_expense/models/expense_category/expense_category.dart';
import 'package:money_manager/share/share.dart';

/// Categories per [PageView] page (4×4 grid).
const int kQuickAddCategoriesPerPage = 16;

class QuickAddCategoryPager extends StatefulWidget {
  const QuickAddCategoryPager({
    super.key,
    required this.categories,
    required this.selectedId,
    required this.onSelect,
  });

  final List<ExpenseCategory> categories;
  final String? selectedId;
  final ValueChanged<String> onSelect;

  @override
  State<QuickAddCategoryPager> createState() => _QuickAddCategoryPagerState();
}

class _QuickAddCategoryPagerState extends State<QuickAddCategoryPager> {
  static const int _crossAxisCount = 4;
  static const int _rowCount = 4;

  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goToPage(int page, int pageCount) {
    if (page < 0 || page >= pageCount) return;
    _controller.animateToPage(
      page,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = _chunk(widget.categories, kQuickAddCategoriesPerPage);
    if (pages.isEmpty) return const SizedBox.shrink();

    final multiPage = pages.length > 1;

    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _controller,
            itemCount: pages.length,
            physics: multiPage
                ? const PageScrollPhysics(parent: BouncingScrollPhysics())
                : const NeverScrollableScrollPhysics(),
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (context, pageIndex) {
              return _CategoryPageGrid(
                items: pages[pageIndex],
                selectedId: widget.selectedId,
                onSelect: widget.onSelect,
                crossAxisCount: _crossAxisCount,
                rowCount: _rowCount,
              );
            },
          ),
        ),
        if (multiPage) ...[
          const SizedBox(height: AppSpacing.s12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: _page > 0 ? () => _goToPage(_page - 1, pages.length) : null,
                icon: const Icon(Icons.chevron_left),
                tooltip: MaterialLocalizations.of(context).previousPageTooltip,
              ),
              ...List.generate(
                pages.length,
                (i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: i == _page
                          ? AppColors.primary
                          : AppColors.surfaceContainerHigh,
                      shape: BoxShape.circle,
                    ),
                    child: const SizedBox(width: 6, height: 6),
                  ),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed:
                    _page < pages.length - 1 ? () => _goToPage(_page + 1, pages.length) : null,
                icon: const Icon(Icons.chevron_right),
                tooltip: MaterialLocalizations.of(context).nextPageTooltip,
              ),
            ],
          ),
        ],
      ],
    );
  }

  List<List<T>> _chunk<T>(List<T> list, int size) {
    if (list.isEmpty) return const [];
    final out = <List<T>>[];
    for (var i = 0; i < list.length; i += size) {
      out.add(list.sublist(i, (i + size).clamp(0, list.length)));
    }
    return out;
  }
}

/// Non-scrollable 4×4 grid so it does not compete with [PageView] gestures.
class _CategoryPageGrid extends StatelessWidget {
  const _CategoryPageGrid({
    required this.items,
    required this.selectedId,
    required this.onSelect,
    required this.crossAxisCount,
    required this.rowCount,
  });

  final List<ExpenseCategory> items;
  final String? selectedId;
  final ValueChanged<String> onSelect;
  final int crossAxisCount;
  final int rowCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var row = 0; row < rowCount; row++) ...[
          if (row > 0) const SizedBox(height: AppSpacing.s12),
          Expanded(
            child: Row(
              children: [
                for (var col = 0; col < crossAxisCount; col++) ...[
                  if (col > 0) const SizedBox(width: AppSpacing.s8),
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        final index = row * crossAxisCount + col;
                        if (index >= items.length) {
                          return const SizedBox.shrink();
                        }
                        final c = items[index];
                        return QuickAddCategoryTile(
                          category: c,
                          selected: c.id == selectedId,
                          onTap: () => onSelect(c.id),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class QuickAddCategoryTile extends StatelessWidget {
  const QuickAddCategoryTile({
    super.key,
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final ExpenseCategory category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return InkResponse(
      onTap: onTap,
      radius: AppSpacing.s48,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.s12),
                color: category.backgroundColor,
                borderRadius: AppRadius.xl,
                child: Icon(
                  category.icon,
                  color: category.foregroundColor,
                  size: AppSpacing.s24,
                ),
              ),
              if (selected)
                Positioned(
                  top: 0,
                  right: -3,
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(3),
                      child: Icon(
                        Icons.check,
                        size: 12,
                        color: AppColors.onPrimary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.s4),
          Text(
            category.label,
            style: textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
