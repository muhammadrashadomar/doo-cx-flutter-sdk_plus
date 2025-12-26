import 'package:doo_cx_flutter_sdk_plus/doo_callbacks.dart';
import 'package:doo_cx_flutter_sdk_plus/doo_parameters.dart';
import 'package:doo_cx_flutter_sdk_plus/di/modules.dart';
import 'package:equatable/equatable.dart';

/// Represents all required parameters for [dooRepositoryProvider] to successfully provide
/// an instance of [DOORepository].
///
/// This class encapsulates configuration parameters and callback handlers needed
/// for the DOO repository to function properly.
class RepositoryParameters extends Equatable {
  /// Configuration parameters for the DOO client
  final DOOParameters params;

  /// Callback handlers for DOO events
  final DOOCallbacks callbacks;

  /// Creates repository parameters with the specified configuration
  RepositoryParameters({required this.params, required this.callbacks});

  @override
  List<Object?> get props => [params, callbacks];
}
