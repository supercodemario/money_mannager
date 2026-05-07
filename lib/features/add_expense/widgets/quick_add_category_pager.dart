import 'package:flutter/material.dart';
import 'package:money_manager/features/add_expense/models/expense_category/expense_category.dart';
import 'package:money_manager/share/share.dart';

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
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = _chunk(widget.categories, 8);
    return Column(
      children: [
        SizedBox(
          height: 2 * 78,
          child: PageView.builder(
            controller: _controller,
            itemCount: pages.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (context, pageIndex) {
              final items = pages[pageIndex];
              return GridView.builder(
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: AppSpacing.s12,
                  crossAxisSpacing: AppSpacing.s8,
                  childAspectRatio: 0.92,
                ),
                itemCount: items.length,
                itemBuilder: (context, i) {
                  final c = items[i];
                  final selected = c.id == widget.selectedId;
                  return QuickAddCategoryTile(
                    category: c,
                    selected: selected,
                    onTap: () => widget.onSelect(c.id),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.s12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            pages.length,
            (i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: i == _page ? AppColors.primary : AppColors.surfaceContainerHigh,
                  shape: BoxShape.circle,
                ),
                child: const SizedBox(width: 6, height: 6),
              ),
            ),
          ),
        ),
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
      radius: AppSpacing.s32,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.s12),
                color: category.backgroundColor,
                borderRadius: AppRadius.xl,
                child: Icon(category.icon, color: category.foregroundColor, size: AppSpacing.s24),
              ),
              if (selected)
                Positioned(
                  top: -6,
                  right: -6,
                  child: DecoratedBox(
                    decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    child: const Padding(
                      padding: EdgeInsets.all(3),
                      child: Icon(Icons.check, size: 12, color: AppColors.onPrimary),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.s4),
          Text(
            category.label,
            style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

