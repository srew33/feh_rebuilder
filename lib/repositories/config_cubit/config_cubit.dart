// ignore_for_file: use_build_context_synchronously

import 'package:equatable/equatable.dart';
import 'package:feh_rebuilder/core/enum/languages.dart';
import 'package:feh_rebuilder/my_18n/widget.dart';
import 'package:feh_rebuilder/repositories/repository.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'config_state.dart';

class ConfigCubit extends Cubit<Config> {
  ConfigCubit({
    required this.repo,
    required Config initial,
  }) : super(initial);

  final Repository repo;

  Future switchLang(BuildContext context, AppLanguages newLang) async {
    await repo.config.putIfAbsent(
      "dataLang",
      newLang.index,
    );
    MyI18nWidget.of(context).locale = newLang.localeWithoutCountry;

    emit(state.copyWith(dataLanguage: newLang));
  }

  Future setAllowInvalidUpdate(bool allowInvalidUpdate) async {
    await repo.config.putIfAbsent("allowInvalidUpdate", allowInvalidUpdate);
    emit(state.copyWith(ignoreSignature: allowInvalidUpdate));
  }

  Future setAllowGetSysId(bool allowGetSysId) async {
    await repo.config.putIfAbsent("allowGetSysId", allowGetSysId);

    emit(state.copyWith(allowGetSysId: allowGetSysId));
  }
}
