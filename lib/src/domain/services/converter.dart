import '../models/job_models.dart';

abstract class Converter {
  JobType get type;
  Future<void> run(JobRequest request);
}

abstract class ConverterRegistry {
  Converter? getConverter(JobType type);
}
