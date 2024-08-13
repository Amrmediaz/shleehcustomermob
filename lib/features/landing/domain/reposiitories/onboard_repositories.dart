import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

import '../entities/onboard.dart';

abstract class OnboardRepositories {
  Future<Either<Failure, List<Onboard>>> getBoardItems(
      );}