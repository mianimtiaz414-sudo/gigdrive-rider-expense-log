import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rider_expense_tracker/core/app_theme.dart';
import 'package:rider_expense_tracker/data/models/app_language.dart';
import 'package:rider_expense_tracker/data/models/country_currency.dart';

class PickerOption {
  const PickerOption({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.leading,
    required this.searchText,
    this.leadingIsEmoji = false,
    this.trailing,
  });

  final String id;
  final String title;
  final String subtitle;
  final String leading;
  final bool leadingIsEmoji;
  final String? trailing;

  
  final String searchText;
}


class PickerCatalog {
  PickerCatalog._();

  static final List<PickerOption> languages = AppLanguages.all
      .map((AppLanguage l) => PickerOption(
            id: l.code,
            title: l.nativeName,
            subtitle: l.englishName,
            leading: l.code.toUpperCase(),
            searchText:
                '${l.englishName} ${l.nativeName} ${l.code}'.toLowerCase(),
          ))
      .toList(growable: false);

  static final List<PickerOption> currencies = CurrencyCatalog.all
      .map((CurrencyOption c) => PickerOption(
            id: c.countryCode,
            title: c.countryName,
            subtitle: '${c.currencyCode} • ${c.currencyName}',
            leading: c.flag,
            leadingIsEmoji: true,
            trailing: c.symbol,
            searchText:
                '${c.countryName} ${c.countryCode} ${c.currencyCode} ${c.currencyName} ${c.symbol}'
                    .toLowerCase(),
          ))
      .toList(growable: false);
}







class SearchablePicker extends StatefulWidget {
  const SearchablePicker({
    super.key,
    required this.options,
    required this.selectedId,
    required this.onSelected,
    required this.hintText,
  });

  final List<PickerOption> options;
  final String selectedId;
  final void Function(String id) onSelected;
  final String hintText;

  @override
  State<SearchablePicker> createState() => _SearchablePickerState();
}

class _SearchablePickerState extends State<SearchablePicker> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<PickerOption> get _filtered {
    final String q = _query.trim().toLowerCase();
    if (q.isEmpty) {
      return widget.options;
    }
    return widget.options
        .where((PickerOption o) => o.searchText.contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final List<PickerOption> items = _filtered;
    return Column(
      children: <Widget>[
        TextField(
          controller: _controller,
          onChanged: (String v) => setState(() => _query = v),
          textInputAction: TextInputAction.search,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: widget.hintText,
            prefixIcon:
                const Icon(Icons.search_rounded, color: AppColors.primary),
            suffixIcon: _query.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () {
                      _controller.clear();
                      setState(() => _query = '');
                    },
                  ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: items.isEmpty
              ? Center(
                  child: Text(
                    'no_results'.tr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 8),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  itemCount: items.length,
                  itemBuilder: (BuildContext context, int index) {
                    final PickerOption o = items[index];
                    return _PickerTile(
                      option: o,
                      selected: o.id == widget.selectedId,
                      onTap: () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        widget.onSelected(o.id);
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _PickerTile extends StatelessWidget {
  const _PickerTile({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final PickerOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: selected ? AppColors.primarySoft : AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: selected ? AppColors.primaryBorder : AppColors.divider,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: <Widget>[
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surfaceLight,
                  ),
                  child: Text(
                    option.leading,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: option.leadingIsEmoji ? 22 : 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        option.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        option.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (option.trailing != null) ...<Widget>[
                  const SizedBox(width: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 64),
                    child: Text(
                      option.trailing!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
                if (selected) ...<Widget>[
                  const SizedBox(width: 8),
                  const Icon(Icons.check_circle_rounded,
                      color: AppColors.primary),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
