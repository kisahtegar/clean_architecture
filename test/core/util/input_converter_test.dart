import 'package:clean_architecture/core/util/input_converter.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late InputConverter inputConverter;

  setUp(() {
    inputConverter = InputConverter();
  });

  group('stringToUnsignedInt', () {
    test(
      'should return an integer when the string represents an unsigned integer',
      () async {
        // arrange
        const string = '123';
        // act
        final result = inputConverter.stringToUnsignedInteger(string);
        // assert
        expect(result, const Right(123));
      },
    );

    test(
      'should return a Failure when the string is not an integer',
      () async {
        // arrange
        const string = 'abc';
        // act
        final result = inputConverter.stringToUnsignedInteger(string);
        // assert
        expect(result, Left(InvalidInputFailure()));
      },
    );

    test(
      'should return a Failure when the string is negative integer',
      () async {
        // arrange
        const string = '-123';
        // act
        final result = inputConverter.stringToUnsignedInteger(string);
        // assert
        expect(result, Left(InvalidInputFailure()));
      },
    );
  });
}
