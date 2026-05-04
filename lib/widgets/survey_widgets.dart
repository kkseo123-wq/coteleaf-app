import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String number;
  final String title;
  final IconData icon;

  const SectionHeader({
    super.key,
    required this.number,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.teal.shade600,
              shape: BoxShape.circle,
            ),
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Icon(icon, color: Colors.teal.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ScaleSlider extends StatelessWidget {
  final String label;
  final int value;
  final String minLabel;
  final String maxLabel;
  final ValueChanged<int> onChanged;

  const ScaleSlider({
    super.key,
    required this.label,
    required this.value,
    required this.minLabel,
    required this.maxLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(minLabel, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
            Expanded(
              child: Slider(
                value: value.toDouble(),
                min: 1,
                max: 5,
                divisions: 4,
                activeColor: Colors.teal,
                label: value.toString(),
                onChanged: (v) => onChanged(v.round()),
              ),
            ),
            Text(maxLabel, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
          ],
        ),
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.teal.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$value점',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal.shade700),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class RadioButtonGroup extends StatelessWidget {
  final String label;
  final List<String> options;
  final String? selectedValue;
  final ValueChanged<String?> onChanged;
  final bool isRequired;

  const RadioButtonGroup({
    super.key,
    required this.label,
    required this.options,
    required this.selectedValue,
    required this.onChanged,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            if (isRequired) Text(' *', style: TextStyle(color: Colors.red.shade400)),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: options.map((option) {
            final isSelected = selectedValue == option;
            return ChoiceChip(
              label: Text(option),
              selected: isSelected,
              selectedColor: Colors.teal.shade200,
              onSelected: (selected) => onChanged(selected ? option : null),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class ScaleCheckboxList extends StatelessWidget {
  final String title;
  final Map<String, int> items;
  final ValueChanged<Map<String, int>> onChanged;

  const ScaleCheckboxList({
    super.key,
    required this.title,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text('(1=전혀 없음, 5=매우 심함)', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        const SizedBox(height: 12),
        ...items.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(flex: 2, child: Text(entry.key, style: const TextStyle(fontSize: 13))),
                Expanded(
                  flex: 3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(5, (index) {
                      final score = index + 1;
                      return GestureDetector(
                        onTap: () {
                          final newItems = Map<String, int>.from(items);
                          newItems[entry.key] = score;
                          onChanged(newItems);
                        },
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: entry.value == score ? Colors.teal.shade400 : Colors.grey.shade200,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '$score',
                              style: TextStyle(
                                fontSize: 12,
                                color: entry.value == score ? Colors.white : Colors.grey.shade700,
                                fontWeight: entry.value == score ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 16),
      ],
    );
  }
}

class ProgressIndicatorBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const ProgressIndicatorBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LinearProgressIndicator(
          value: currentStep / totalSteps,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.teal.shade400),
          minHeight: 8,
        ),
        const SizedBox(height: 8),
        Text('$currentStep / $totalSteps', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
      ],
    );
  }
}
