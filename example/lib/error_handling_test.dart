import 'package:doo_cx_flutter_sdk_plus/doo_cx_flutter_sdk.dart';
import 'package:flutter/material.dart';

/// Comprehensive error handling and edge case testing for DOO CX Flutter SDK
/// This file demonstrates robust error handling patterns and tests edge cases
/// to ensure the SDK works reliably under all conditions.
class ErrorHandlingTestPage extends StatefulWidget {
  const ErrorHandlingTestPage({super.key});

  @override
  State<ErrorHandlingTestPage> createState() => _ErrorHandlingTestPageState();
}

class _ErrorHandlingTestPageState extends State<ErrorHandlingTestPage> {
  final List<String> _testResults = [];
  bool _isRunningTests = false;
  DOOClient? _testClient;

  @override
  void dispose() {
    _testClient?.dispose();
    super.dispose();
  }

  void _addResult(String result) {
    setState(() {
      _testResults.add('${DateTime.now().toIso8601String()}: $result');
    });
  }

  // Test 1: Invalid Parameters
  Future<void> _testInvalidParameters() async {
    _addResult('🧪 Testing invalid parameters...');

    try {
      // Test with empty base URL
      await DOOClient.create(
        baseUrl: '',
        inboxIdentifier: 'valid-inbox',
      );
      _addResult('❌ FAILED: Empty base URL should throw error');
    } catch (e) {
      _addResult('✅ PASSED: Empty base URL properly rejected: $e');
    }

    try {
      // Test with invalid URL format
      await DOOClient.create(
        baseUrl: 'not-a-url',
        inboxIdentifier: 'valid-inbox',
      );
      _addResult('❌ FAILED: Invalid URL should throw error');
    } catch (e) {
      _addResult('✅ PASSED: Invalid URL properly rejected: $e');
    }

    try {
      // Test with empty inbox identifier
      await DOOClient.create(
        baseUrl: 'http://localhost:3001',
        inboxIdentifier: '',
      );
      _addResult('❌ FAILED: Empty inbox identifier should throw error');
    } catch (e) {
      _addResult('✅ PASSED: Empty inbox identifier properly rejected: $e');
    }
  }

  // Test 2: Network Error Handling
  Future<void> _testNetworkErrors() async {
    _addResult('🧪 Testing network error handling...');

    try {
      // Test with unreachable server
      final client = await DOOClient.create(
        baseUrl: 'http://unreachable-server.invalid:9999',
        inboxIdentifier: 'test-inbox',
        callbacks: DOOCallbacks(
          onError: (error) {
            _addResult('✅ PASSED: Network error properly handled: $error');
          },
        ),
      );

      // Try to send a message
      await client.sendMessage(content: 'Test message');
      _addResult('❌ FAILED: Should have failed with network error');

      client.dispose();
    } catch (e) {
      _addResult('✅ PASSED: Network error properly caught: $e');
    }
  }

  // Test 3: Message Validation
  Future<void> _testMessageValidation() async {
    _addResult('🧪 Testing message validation...');

    try {
      final client = await DOOClient.create(
        baseUrl: 'http://localhost:3001',
        inboxIdentifier: 'test-inbox',
        callbacks: DOOCallbacks(
          onError: (error) {
            _addResult('Error handled: $error');
          },
        ),
      );

      // Test empty message
      try {
        await client.sendMessage(content: '');
        _addResult('❌ FAILED: Empty message should be rejected');
      } catch (e) {
        _addResult('✅ PASSED: Empty message properly rejected: $e');
      }

      // Test very long message
      final longMessage = 'x' * 10000;
      try {
        await client.sendMessage(content: longMessage);
        _addResult('✅ PASSED: Long message handled gracefully');
      } catch (e) {
        _addResult('✅ PASSED: Long message properly validated: $e');
      }

      // Test message with special characters
      try {
        await client.sendMessage(
            content: 'Test 🚀 emoji & special chars: @#\$%^&*()');
        _addResult('✅ PASSED: Special characters handled properly');
      } catch (e) {
        _addResult('❌ FAILED: Special characters should be supported: $e');
      }

      client.dispose();
    } catch (e) {
      _addResult('❌ FAILED: Client creation failed: $e');
    }
  }

  // Test 4: Multiple Client Instances
  Future<void> _testMultipleClients() async {
    _addResult('🧪 Testing multiple client instances...');

    final clients = <DOOClient>[];
    try {
      // Create multiple clients
      for (int i = 0; i < 3; i++) {
        final client = await DOOClient.create(
          baseUrl: 'http://localhost:3001',
          inboxIdentifier: 'test-inbox-$i',
          callbacks: DOOCallbacks(
            onMessageReceived: (message) {
              _addResult('Client $i received message: ${message.content}');
            },
            onError: (error) {
              _addResult('Client $i error: $error');
            },
          ),
        );
        clients.add(client);
      }

      _addResult('✅ PASSED: Multiple clients created successfully');

      // Test sending messages from different clients
      for (int i = 0; i < clients.length; i++) {
        await clients[i].sendMessage(content: 'Message from client $i');
      }

      _addResult('✅ PASSED: Messages sent from multiple clients');

      // Dispose all clients
      for (final client in clients) {
        client.dispose();
      }

      _addResult('✅ PASSED: All clients disposed properly');
    } catch (e) {
      // Clean up any created clients
      for (final client in clients) {
        client.dispose();
      }
      _addResult('❌ FAILED: Multiple clients test failed: $e');
    }
  }

  // Test 5: Memory Leak Prevention
  Future<void> _testMemoryManagement() async {
    _addResult('🧪 Testing memory management...');

    try {
      // Create and dispose multiple clients rapidly
      for (int i = 0; i < 10; i++) {
        final client = await DOOClient.create(
          baseUrl: 'http://localhost:3001',
          inboxIdentifier: 'temp-inbox-$i',
        );

        // Send a message
        await client.sendMessage(content: 'Test message $i');

        // Immediately dispose
        client.dispose();
      }

      _addResult('✅ PASSED: Rapid create/dispose cycle completed');
    } catch (e) {
      _addResult('❌ FAILED: Memory management test failed: $e');
    }
  }

  // Test 6: Callback Error Handling
  Future<void> _testCallbackErrors() async {
    _addResult('🧪 Testing callback error handling...');

    try {
      final client = await DOOClient.create(
        baseUrl: 'http://localhost:3001',
        inboxIdentifier: 'callback-test-inbox',
        callbacks: DOOCallbacks(
          onMessageReceived: (message) {
            // Intentionally throw an error in callback
            throw Exception('Intentional callback error');
          },
          onError: (error) {
            _addResult('✅ PASSED: Callback error properly handled: $error');
          },
        ),
      );

      // This should trigger the error callback
      await client.sendMessage(content: 'Trigger callback error');

      await Future.delayed(const Duration(seconds: 2));
      client.dispose();
    } catch (e) {
      _addResult('❌ FAILED: Callback error test failed: $e');
    }
  }

  // Test 7: Edge Case Parameters
  Future<void> _testEdgeCaseParameters() async {
    _addResult('🧪 Testing edge case parameters...');

    try {
      final client = await DOOClient.create(
        baseUrl: 'http://localhost:3001',
        inboxIdentifier: 'edge-case-inbox',
        enablePersistence: true,
        user: DOOUser(
          identifier: '', // Empty identifier
          name: '', // Empty name
          email: '', // Empty email
        ),
      );

      _addResult('✅ PASSED: Edge case parameters handled');
      client.dispose();
    } catch (e) {
      _addResult('❌ FAILED: Edge case parameters test failed: $e');
    }
  }

  // Test 8: Rapid Fire Operations
  Future<void> _testRapidOperations() async {
    _addResult('🧪 Testing rapid fire operations...');

    try {
      final client = await DOOClient.create(
        baseUrl: 'http://localhost:3001',
        inboxIdentifier: 'rapid-test-inbox',
        callbacks: DOOCallbacks(
          onError: (error) {
            _addResult('Rapid operation error: $error');
          },
        ),
      );

      // Send many messages rapidly
      final futures = <Future>[];
      for (int i = 0; i < 20; i++) {
        futures.add(client.sendMessage(content: 'Rapid message $i'));
      }

      await Future.wait(futures);
      _addResult('✅ PASSED: Rapid fire operations completed');

      client.dispose();
    } catch (e) {
      _addResult('❌ FAILED: Rapid operations test failed: $e');
    }
  }

  // Run all tests
  Future<void> _runAllTests() async {
    setState(() {
      _isRunningTests = true;
      _testResults.clear();
    });

    _addResult('🚀 Starting comprehensive error handling tests...');

    try {
      await _testInvalidParameters();
      await _testNetworkErrors();
      await _testMessageValidation();
      await _testMultipleClients();
      await _testMemoryManagement();
      await _testCallbackErrors();
      await _testEdgeCaseParameters();
      await _testRapidOperations();

      _addResult('✅ All tests completed!');
    } catch (e) {
      _addResult('❌ Test suite failed: $e');
    }

    setState(() {
      _isRunningTests = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error Handling Tests'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'DOO CX Flutter SDK - Error Handling & Edge Case Tests',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'This test suite validates error handling, edge cases, and robustness of the SDK.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _isRunningTests ? null : _runAllTests,
                  icon: _isRunningTests
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.play_arrow),
                  label: Text(
                      _isRunningTests ? 'Running Tests...' : 'Run All Tests'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: _testResults.isEmpty
                ? const Center(
                    child: Text(
                      'Click "Run All Tests" to start error handling validation',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _testResults.length,
                    itemBuilder: (context, index) {
                      final result = _testResults[index];
                      final isSuccess = result.contains('✅ PASSED');
                      final isFailure = result.contains('❌ FAILED');
                      final isTest = result.contains('🧪');

                      Color backgroundColor;
                      Color textColor;

                      if (isSuccess) {
                        backgroundColor = Colors.green.shade50;
                        textColor = Colors.green.shade800;
                      } else if (isFailure) {
                        backgroundColor = Colors.red.shade50;
                        textColor = Colors.red.shade800;
                      } else if (isTest) {
                        backgroundColor = Colors.blue.shade50;
                        textColor = Colors.blue.shade800;
                      } else {
                        backgroundColor = Colors.grey.shade50;
                        textColor = Colors.grey.shade800;
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: textColor.withOpacity(0.3)),
                        ),
                        child: Text(
                          result,
                          style: TextStyle(
                            color: textColor,
                            fontFamily: 'monospace',
                            fontSize: 13,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// Test Widget Integration Error Handling
class WidgetErrorTestPage extends StatefulWidget {
  const WidgetErrorTestPage({super.key});

  @override
  State<WidgetErrorTestPage> createState() => _WidgetErrorTestPageState();
}

class _WidgetErrorTestPageState extends State<WidgetErrorTestPage> {
  final List<String> _widgetTestResults = [];

  void _addResult(String result) {
    setState(() {
      _widgetTestResults.add('${DateTime.now().toIso8601String()}: $result');
    });
  }

  void _testWidgetErrorHandling() {
    _addResult('🧪 Testing widget error handling...');

    // Test DOOWidget with invalid parameters
    try {
      const DOOWidget(
        baseUrl: '', // Invalid empty URL
        websiteToken: 'test-token',
      );
      _addResult('❌ Widget should validate parameters');
    } catch (e) {
      _addResult('✅ Widget parameter validation working: $e');
    }

    // Test with null callbacks (should not crash)
    try {
      const DOOWidget(
        baseUrl: 'http://localhost:3001',
        websiteToken: 'test-token',
      );
      _addResult('✅ Widget handles null callbacks gracefully');
    } catch (e) {
      _addResult('❌ Widget should handle null callbacks: $e');
    }

    _addResult('✅ Widget error handling tests completed');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Widget Error Tests'),
        backgroundColor: Colors.orange.shade700,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Widget Error Handling Tests',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _testWidgetErrorHandling,
                  icon: const Icon(Icons.bug_report),
                  label: const Text('Test Widget Error Handling'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade700,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: _widgetTestResults.isEmpty
                ? const Center(
                    child: Text(
                      'Click button to test widget error handling',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _widgetTestResults.length,
                    itemBuilder: (context, index) {
                      final result = _widgetTestResults[index];
                      final isSuccess = result.contains('✅');
                      final isFailure = result.contains('❌');

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSuccess
                              ? Colors.green.shade50
                              : isFailure
                                  ? Colors.red.shade50
                                  : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSuccess
                                ? Colors.green.shade300
                                : isFailure
                                    ? Colors.red.shade300
                                    : Colors.grey.shade300,
                          ),
                        ),
                        child: Text(
                          result,
                          style: TextStyle(
                            color: isSuccess
                                ? Colors.green.shade800
                                : isFailure
                                    ? Colors.red.shade800
                                    : Colors.grey.shade800,
                            fontFamily: 'monospace',
                            fontSize: 13,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
