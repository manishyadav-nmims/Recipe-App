import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipeapp/features/theme/app_theme.dart';
import '../bloc/recipe_bloc.dart';
import '../bloc/recipe_event.dart';

class SortButton extends StatelessWidget {
  final SortOption currentSort;
  const SortButton({super.key, required this.currentSort});

  @override
  Widget build(BuildContext context) {
    final isDefault = currentSort == SortOption.rating;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => _showSortSheet(context, currentSort),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isDefault
              ? (isDark ? Colors.white.withOpacity(0.06) : Colors.white)
              : AppTheme.primaryColor.withOpacity(0.1),
          border: Border.all(
            color: isDefault
                ? Colors.grey.withOpacity(0.3)
                : AppTheme.primaryColor.withOpacity(0.4),
            width: 0.5,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.tune_rounded,
              size: 15,
              color: isDefault ? Colors.grey[600] : AppTheme.primaryColor,
            ),
            const SizedBox(width: 5),
            Text(
              isDefault ? 'Sort' : _label(currentSort),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDefault ? Colors.grey[700] : AppTheme.primaryColor,
              ),
            ),
            if (!isDefault) ...[
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '1',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _label(SortOption opt) => switch (opt) {
    SortOption.rating => 'Highest rating',
    SortOption.name => 'Name A–Z',
    SortOption.cookTime => 'Cook time',
    SortOption.calories => 'Calories',
  };

  void _showSortSheet(BuildContext context, SortOption current) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _SortSheet(
        current: current,
        onSelected: (option) {
          context.read<RecipeBloc>().add(SortRecipesEvent(option));
        },
      ),
    );
  }
}

class _SortSheet extends StatefulWidget {
  final SortOption current;
  final ValueChanged<SortOption> onSelected;

  const _SortSheet({required this.current, required this.onSelected});

  @override
  State<_SortSheet> createState() => _SortSheetState();
}

class _SortSheetState extends State<_SortSheet> {
  late SortOption _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.current;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppTheme.darkSurfaceColor : Colors.white;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 16, 12),
            child: Row(
              children: [
                Text(
                  'Sort by',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() => _selected = SortOption.rating);
                    widget.onSelected(SortOption.rating);
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Reset',
                      style: TextStyle(fontSize: 13)),
                ),
              ],
            ),
          ),

          Divider(
            height: 1,
            thickness: 0.5,
            color: Colors.grey.withOpacity(0.2),
          ),

          // Options
          ..._options.map((opt) => _OptionTile(
            option: opt,
            isSelected: _selected == opt.value,
            isDark: isDark,
            onTap: () {
              setState(() => _selected = opt.value);
              widget.onSelected(opt.value);
              Future.delayed(
                const Duration(milliseconds: 150),
                    () => Navigator.pop(context),
              );
            },
          )),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final _SortOptionMeta option;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _OptionTile({
    required this.option,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        color: isSelected
            ? AppTheme.primaryColor.withOpacity(0.06)
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
        child: Row(
          children: [
            // Icon pill
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: option.iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(option.icon, color: option.iconColor, size: 18),
            ),
            const SizedBox(width: 14),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    option.subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),

            // Check
            AnimatedOpacity(
              opacity: isSelected ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 150),
              child: Icon(
                Icons.check_circle_rounded,
                color: AppTheme.primaryColor,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SortOptionMeta {
  final SortOption value;
  final String label;
  final String subtitle;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;

  const _SortOptionMeta({
    required this.value,
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
  });
}

const _options = [
  _SortOptionMeta(
    value: SortOption.rating,
    label: 'Highest rating',
    subtitle: 'Top-rated recipes first',
    icon: Icons.star_rounded,
    iconBg: Color(0xFFFFF0E8),
    iconColor: Color(0xFFD85A30),
  ),
  _SortOptionMeta(
    value: SortOption.name,
    label: 'Name A–Z',
    subtitle: 'Alphabetical order',
    icon: Icons.sort_by_alpha_rounded,
    iconBg: Color(0xFFE8F0FE),
    iconColor: Color(0xFF185FA5),
  ),
  _SortOptionMeta(
    value: SortOption.cookTime,
    label: 'Cook time',
    subtitle: 'Quickest to make first',
    icon: Icons.timer_rounded,
    iconBg: Color(0xFFE1F5EE),
    iconColor: Color(0xFF0F6E56),
  ),
  _SortOptionMeta(
    value: SortOption.calories,
    label: 'Calories',
    subtitle: 'Lowest calories first',
    icon: Icons.local_fire_department_rounded,
    iconBg: Color(0xFFFAEEDA),
    iconColor: Color(0xFF854F0B),
  ),
];