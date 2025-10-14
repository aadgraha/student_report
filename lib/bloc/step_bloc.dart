import 'package:flutter_bloc/flutter_bloc.dart';

class StepBloc extends Cubit<StepState> {
  StepBloc() : super((message: null, now: null, total: null));
  void setValue(StepState data) =>
      emit((message: data.message, now: data.now, total: data.total));
}

typedef StepState = ({String? message, int? now, int? total});
