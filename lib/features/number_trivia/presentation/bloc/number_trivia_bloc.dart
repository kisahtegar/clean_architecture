import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/util/input_converter.dart';
import '../../domain/entities/number_trivia.dart';
import '../../domain/usecases/get_concrete_number_trivia.dart';
import '../../domain/usecases/get_random_number_trivia.dart';

part 'number_trivia_event.dart';
part 'number_trivia_state.dart';

const String SERVER_FAILURE_MESSAGE = 'Server Failure';
const String CACHE_FAILURE_MESSAGE = 'Cache Failure';
const String INVALID_INPUT_FAILURE_MESSAGE =
    'Invalid Input - The number must be a positive integer or zero.';

class NumberTriviaBloc extends Bloc<NumberTriviaEvent, NumberTriviaState> {
  final GetConcreteNumberTrivia getConcreteNumberTrivia;
  final GetRandomNumberTrivia getRandomNumberTrivia;
  final InputConverter inputConverter;

  NumberTriviaState get initialState => Empty();

  NumberTriviaBloc({
    required this.getConcreteNumberTrivia,
    required this.getRandomNumberTrivia,
    required this.inputConverter,
  }) : super(Empty()) {
    on<GetTriviaForConcreteNumber>((event, emit) async {
      debugPrint('[on<GetTriviaForConcreteNumber>]: im inside Concrete');
      final inputEither =
          inputConverter.stringToUnsignedInteger(event.numberString);
      debugPrint('[on<GetTriviaForConcreteNumber>]: test');
      await inputEither.fold(
        (failure) async {
          debugPrint('[on<GetTriviaForConcreteNumber>]: test');
          emit(Error(message: INVALID_INPUT_FAILURE_MESSAGE));
        },
        (integer) async {
          debugPrint(
              '[on<GetTriviaForConcreteNumber>]: Inside inputEither.fold(integer)');
          emit(Loading());
          final failureOrTrivia =
              await getConcreteNumberTrivia(Params(number: integer));
          failureOrTrivia!.fold(
            (failure) {
              debugPrint(
                  '[on<GetTriviaForConcreteNumber>]: Inside failureOrTrivia.fold(failure)');
              emit(Error(message: _mapFailureToMessage(failure)));
            },
            (trivia) {
              debugPrint(
                  '[on<GetTriviaForConcreteNumber>]: Inside failureOrTrivia.fold(trivia)');
              debugPrint(trivia.toString());
              // await emit.forEach();
              emit(Loaded(trivia: trivia));
            },
          );
        },
      );
    });
    on<GetTriviaForRandomNumber>((event, emit) async {
      debugPrint('[on<GetTriviaForRandomNumber>]: im inside');
      emit(Loading());
      final failureOrTrivia = await getRandomNumberTrivia(NoParams());
      failureOrTrivia!.fold((failure) {
        debugPrint('[on<GetTriviaForRandomNumber>]: Im passing in failure');
        emit(Error(message: _mapFailureToMessage(failure)));
      }, (trivia) {
        debugPrint('[on<GetTriviaForRandomNumber>]: Im passing Loaded');
        debugPrint(trivia.toString());
        emit(Loaded(trivia: trivia));
      });
    });
  }

  // Stream<NumberTriviaState> _eitherLoadedOrErrorState(
  //     Either<Failure, NumberTrivia> failureOrTrivia) async* {
  //   failureOrTrivia.fold((failure) {
  //     emit(Error(message: _mapFailureToMessage(failure)));
  //   }, (trivia) {
  //     emit(Loaded(trivia: trivia));
  //   });
}

String _mapFailureToMessage(Failure failure) {
  switch (failure.runtimeType) {
    case ServerFailure:
      return SERVER_FAILURE_MESSAGE;
    case CacheFailure:
      return CACHE_FAILURE_MESSAGE;
    default:
      return 'Unexpected error';
  }
}
