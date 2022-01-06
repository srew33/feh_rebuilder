import 'package:flutter/material.dart';

class TagChoose extends StatefulWidget {
  const TagChoose({
    Key? key,
    required this.data,
  }) : super(key: key);
  final Map<String, String> data;
  @override
  TagChooseState createState() => TagChooseState();
}

class TagChooseState extends State<TagChoose> {
  List<String> selected = [];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 5,
      runSpacing: 5,
      children: [
        for (var entry in widget.data.entries)
          ChoiceChip(
            label: Text(entry.value),
            selected: selected.contains(entry.key),
            onSelected: (value) {
              setState(() {
                selected.contains(entry.key)
                    ? selected.remove(entry.key)
                    : selected.add(entry.key);
              });
            },
          )
      ],
    );
  }
}
