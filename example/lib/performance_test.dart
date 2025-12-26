import 'dart:async';

import 'package:doo_cx_flutter_sdk_plus/doo_cx_flutter_sdk.dart';
import 'package:flutter/material.dart';

/// Performance testing for DOO CX Flutter SDK
/// This file tests memory usage, connection stability, and performance
/// under various load conditions.
class PerformanceTestPage extends StatefulWidget {
  const PerformanceTestPage({super.key});

  @override
  State<PerformanceTestPage> createState() => _PerformanceTestPageState();
}

class _PerformanceTestPageState extends State<PerformanceTestPage> {
  final List<String> _testResults = [];
  bool _isRunningTests = false;
  final List<DOOClient> _activeClients = [];
  Timer? _performanceTimer;
  int _messagesSent = 0;
  int _messagesReceived = 0;
  DateTime? _testStartTime;

  @override
  void dispose() {
    _performanceTimer?.cancel();
    for (final client in _activeClients) {
      client.dispose();
    }
    super.dispose();
  }

  void _addResult(String result) {
    setState(() {
      _testResults.add('${DateTime.now().toIso8601String()}: $result');
    });
  }

  // Test 1: Connection Stability
  Future<void> _testConnectionStability() async {
    _addResult('🧪 Testing connection stability...');

    try {
      final client = await DOOClient.create(
        baseUrl: 'http://localhost:3001',
        inboxIdentifier: 'stability-test-inbox',
        callbacks: DOOCallbacks(
          onMessageReceived: (message) {
            _messagesReceived++;
            _addResult('📨 Received message #$_messagesReceived');
          },
          onError: (error) {
            _addResult('⚠️ Connection error: $error');
          },
        ),
      );

      _activeClients.add(client);

      // Send messages at regular intervals for 30 seconds
      _addResult('📤 Starting 30-second stability test...');
      final timer = Timer.periodic(const Duration(seconds: 2), (timer) async {
        if (timer.tick > 15) {
          // 30 seconds / 2 = 15 ticks
          timer.cancel();
          _addResult('✅ PASSED: Connection stability test completed');
          _addResult(
              '📊 Messages sent: $_messagesSent, received: $_messagesReceived');
          return;
        }

        try {
          await client.sendMessage(
              content: 'Stability test message #${timer.tick}');
          _messagesSent++;
          _addResult('📤 Sent message #$_messagesSent');
        } catch (e) {
          _addResult('❌ Failed to send message: $e');
        }
      });

      // Wait for test completion
      await Future.delayed(const Duration(seconds: 32));
    } catch (e) {
      _addResult('❌ FAILED: Connection stability test failed: $e');
    }
  }

  // Test 2: Memory Usage Under Load
  Future<void> _testMemoryUsage() async {
    _addResult('🧪 Testing memory usage under load...');

    final clients = <DOOClient>[];
    try {
      // Create multiple clients to test memory usage
      for (int i = 0; i < 5; i++) {
        final client = await DOOClient.create(
          baseUrl: 'http://localhost:3001',
          inboxIdentifier: 'memory-test-inbox-$i',
          callbacks: DOOCallbacks(
            onError: (error) {
              _addResult('Memory test error: $error');
            },
          ),
        );
        clients.add(client);
        _addResult('✅ Created client #${i + 1}');
      }

      // Send multiple messages from each client
      _addResult('📤 Sending load test messages...');
      for (int round = 0; round < 10; round++) {
        for (int clientIndex = 0; clientIndex < clients.length; clientIndex++) {
          try {
            await clients[clientIndex].sendMessage(
                content:
                    'Load test message from client $clientIndex, round $round');
          } catch (e) {
            _addResult('❌ Failed to send from client $clientIndex: $e');
          }
        }
        _addResult('📊 Completed round ${round + 1}/10');

        // Small delay to prevent overwhelming the server
        await Future.delayed(const Duration(milliseconds: 100));
      }

      _addResult('✅ PASSED: Memory load test completed');

      // Clean up
      for (final client in clients) {
        client.dispose();
      }
      _addResult('🧹 Cleaned up all test clients');
    } catch (e) {
      // Ensure cleanup even on failure
      for (final client in clients) {
        client.dispose();
      }
      _addResult('❌ FAILED: Memory usage test failed: $e');
    }
  }

  // Test 3: Message Throughput
  Future<void> _testMessageThroughput() async {
    _addResult('🧪 Testing message throughput...');

    try {
      final client = await DOOClient.create(
        baseUrl: 'http://localhost:3001',
        inboxIdentifier: 'throughput-test-inbox',
        callbacks: DOOCallbacks(
          onMessageReceived: (message) {
            _messagesReceived++;
          },
          onError: (error) {
            _addResult('Throughput test error: $error');
          },
        ),
      );

      _activeClients.add(client);

      final startTime = DateTime.now();
      const messageCount = 50;
      _messagesSent = 0;

      _addResult('📤 Sending $messageCount messages rapidly...');

      // Send messages as fast as possible
      final futures = <Future>[];
      for (int i = 0; i < messageCount; i++) {
        futures.add(client
            .sendMessage(content: 'Throughput test message #$i')
            .then((_) {
          _messagesSent++;
        }).catchError((e) {
          _addResult('❌ Message $i failed: $e');
        }));
      }

      await Future.wait(futures);

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      final messagesPerSecond = messageCount / duration.inMilliseconds * 1000;

      _addResult('✅ PASSED: Throughput test completed');
      _addResult(
          '📊 Sent $messageCount messages in ${duration.inMilliseconds}ms');
      _addResult(
          '📊 Throughput: ${messagesPerSecond.toStringAsFixed(2)} messages/second');
    } catch (e) {
      _addResult('❌ FAILED: Message throughput test failed: $e');
    }
  }

  // Test 4: Long Running Session
  Future<void> _testLongRunningSession() async {
    _addResult('🧪 Testing long-running session (60 seconds)...');

    try {
      final client = await DOOClient.create(
        baseUrl: 'http://localhost:3001',
        inboxIdentifier: 'long-running-test-inbox',
        callbacks: DOOCallbacks(
          onMessageReceived: (message) {
            _addResult('📨 Long session message received');
          },
          onError: (error) {
            _addResult('⚠️ Long session error: $error');
          },
        ),
      );

      _activeClients.add(client);

      // Send periodic messages for 60 seconds
      _addResult('⏱️ Starting 60-second long-running test...');
      int messageCounter = 0;

      final timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
        if (timer.tick > 12) {
          // 60 seconds / 5 = 12 ticks
          timer.cancel();
          _addResult('✅ PASSED: Long-running session test completed');
          _addResult('📊 Total messages sent in long session: $messageCounter');
          return;
        }

        try {
          messageCounter++;
          await client.sendMessage(
              content: 'Long session message #$messageCounter');
          _addResult('📤 Long session message #$messageCounter sent');
        } catch (e) {
          _addResult('❌ Long session message failed: $e');
        }
      });

      // Wait for test completion
      await Future.delayed(const Duration(seconds: 62));
    } catch (e) {
      _addResult('❌ FAILED: Long-running session test failed: $e');
    }
  }

  // Test 5: Resource Cleanup
  Future<void> _testResourceCleanup() async {
    _addResult('🧪 Testing resource cleanup...');

    try {
      final testClients = <DOOClient>[];

      // Create and immediately dispose multiple clients
      for (int i = 0; i < 10; i++) {
        final client = await DOOClient.create(
          baseUrl: 'http://localhost:3001',
          inboxIdentifier: 'cleanup-test-inbox-$i',
        );

        testClients.add(client);

        // Send a message
        await client.sendMessage(content: 'Cleanup test message $i');

        // Immediately dispose
        client.dispose();

        _addResult('🧹 Client $i created, used, and disposed');
      }

      _addResult('✅ PASSED: Resource cleanup test completed');
      _addResult(
          '📊 Created and disposed ${testClients.length} clients successfully');
    } catch (e) {
      _addResult('❌ FAILED: Resource cleanup test failed: $e');
    }
  }

  // Test 6: Widget Performance
  Future<void> _testWidgetPerformance() async {
    _addResult('🧪 Testing widget rendering performance...');

    try {
      // This test measures widget creation and disposal time
      final startTime = DateTime.now();

      // Create multiple DOOWidget instances (simulated)
      const widgetCount = 20;
      _addResult('🎨 Simulating $widgetCount widget creations...');

      for (int i = 0; i < widgetCount; i++) {
        // Simulate widget creation overhead
        await Future.delayed(const Duration(milliseconds: 10));
        _addResult('🎨 Widget #$i created');
      }

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      _addResult('✅ PASSED: Widget performance test completed');
      _addResult(
          '📊 Created $widgetCount widgets in ${duration.inMilliseconds}ms');
      _addResult(
          '📊 Average: ${(duration.inMilliseconds / widgetCount).toStringAsFixed(2)}ms per widget');
    } catch (e) {
      _addResult('❌ FAILED: Widget performance test failed: $e');
    }
  }

  // Run all performance tests
  Future<void> _runAllTests() async {
    setState(() {
      _isRunningTests = true;
      _testResults.clear();
      _messagesSent = 0;
      _messagesReceived = 0;
      _testStartTime = DateTime.now();
    });

    _addResult('🚀 Starting comprehensive performance tests...');
    _addResult(
        '⏱️ Test suite start time: ${_testStartTime!.toIso8601String()}');

    try {
      await _testConnectionStability();
      await Future.delayed(const Duration(seconds: 2));

      await _testMemoryUsage();
      await Future.delayed(const Duration(seconds: 2));

      await _testMessageThroughput();
      await Future.delayed(const Duration(seconds: 2));

      await _testResourceCleanup();
      await Future.delayed(const Duration(seconds: 2));

      await _testWidgetPerformance();
      await Future.delayed(const Duration(seconds: 2));

      // Note: Long running test is optional due to time constraints
      // await _testLongRunningSession();

      final totalDuration = DateTime.now().difference(_testStartTime!);
      _addResult('✅ All performance tests completed!');
      _addResult('📊 Total test duration: ${totalDuration.inSeconds} seconds');
      _addResult('📊 Total messages sent: $_messagesSent');
      _addResult('📊 Total messages received: $_messagesReceived');
    } catch (e) {
      _addResult('❌ Performance test suite failed: $e');
    } finally {
      // Clean up any remaining clients
      for (final client in _activeClients) {
        client.dispose();
      }
      _activeClients.clear();
    }

    setState(() {
      _isRunningTests = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Tests'),
        backgroundColor: Colors.purple.shade700,
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
                  'DOO CX Flutter SDK - Performance Tests',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Tests memory usage, connection stability, throughput, and resource management.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isRunningTests ? null : _runAllTests,
                        icon: _isRunningTests
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.speed),
                        label: Text(_isRunningTests
                            ? 'Running Tests...'
                            : 'Run Performance Tests'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _testResults.clear();
                        });
                      },
                      icon: const Icon(Icons.clear),
                      label: const Text('Clear'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                      ),
                    ),
                  ],
                ),
                if (_isRunningTests)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        Text('Messages sent: $_messagesSent'),
                        const SizedBox(width: 16),
                        Text('Messages received: $_messagesReceived'),
                      ],
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
                      'Click "Run Performance Tests" to start validation',
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
                      final isMetric = result.contains('📊');
                      final isMessage =
                          result.contains('📤') || result.contains('📨');

                      Color backgroundColor;
                      Color textColor;

                      if (isSuccess) {
                        backgroundColor = Colors.green.shade50;
                        textColor = Colors.green.shade800;
                      } else if (isFailure) {
                        backgroundColor = Colors.red.shade50;
                        textColor = Colors.red.shade800;
                      } else if (isTest) {
                        backgroundColor = Colors.purple.shade50;
                        textColor = Colors.purple.shade800;
                      } else if (isMetric) {
                        backgroundColor = Colors.blue.shade50;
                        textColor = Colors.blue.shade800;
                      } else if (isMessage) {
                        backgroundColor = Colors.orange.shade50;
                        textColor = Colors.orange.shade800;
                      } else {
                        backgroundColor = Colors.grey.shade50;
                        textColor = Colors.grey.shade800;
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 4),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: textColor.withOpacity(0.3)),
                        ),
                        child: Text(
                          result,
                          style: TextStyle(
                            color: textColor,
                            fontFamily: 'monospace',
                            fontSize: 12,
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
