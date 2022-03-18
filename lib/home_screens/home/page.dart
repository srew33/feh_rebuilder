import 'package:feh_rebuilder/core/enum/sort_key.dart';
import 'package:feh_rebuilder/models/person/person.dart';
import 'package:feh_rebuilder/widgets/jumpable_listview.dart';
import 'package:feh_rebuilder/widgets/person_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/home_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool showVersion = context.select<HomeBloc, bool>(
      (bloc) => bloc.state.sortKey == SortKey.versionNum,
    );
    return JumpableListView<Person>(
      groupData: const {},
      itemBuilder: (context, person) => PersonTile(
        showVersion: showVersion,
        person: person,
        sum: person.bst.toString(),
      ),
      scrollController: context.read<HomeBloc>().controller,
      itemExtent: 80,
    );
  }
}
