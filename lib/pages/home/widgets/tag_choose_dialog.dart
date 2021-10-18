import 'package:feh_rebuilder/utils.dart';
import 'package:flutter/material.dart';

class TagChooseDialog extends StatefulWidget {
  final List<String> allTags;
  final List<String> tags;
  const TagChooseDialog({
    Key? key,
    required this.allTags,
    required this.tags,
  }) : super(key: key);

  @override
  _TagChooseDialogState createState() => _TagChooseDialogState();
}

class _TagChooseDialogState extends State<TagChooseDialog> {
  Set<String> selectedTags = {};

  @override
  void initState() {
    for (var element in widget.tags) {
      if (widget.allTags.contains(element)) {
        selectedTags.add(element);
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: MediaQuery.of(context).size.width / 2,
        height: MediaQuery.of(context).size.height / 2,
        child: Column(
          children: [
            TextField(
              maxLines: 1,
              decoration: InputDecoration(
                  labelText: "输入新标签",
                  prefixIcon: const Icon(Icons.tag),
                  suffixIcon: IconButton(
                      onPressed: () {}, icon: const Icon(Icons.add_circle))),
            ),
            Expanded(
                child: SingleChildScrollView(
              child: Wrap(
                children: [
                  for (String tag in widget.allTags)
                    ChoiceChip(
                      label: Text(tag),
                      selected: selectedTags.contains(tag),
                      onSelected: (bool state) {
                        setState(() {
                          Utils.debug(state);
                          state
                              ? selectedTags.add(tag)
                              : selectedTags.remove(tag);
                        });
                      },
                    )
                ],
              ),
            )),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(onPressed: () {}, child: const Text("取消")),
                TextButton(
                    onPressed: () {
                      setState(() {
                        selectedTags.clear();
                      });
                    },
                    child: const Text("清空")),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(selectedTags);
                    },
                    child: const Text("确定")),
              ],
            )
          ],
        ),
      ),
    );
  }
}
