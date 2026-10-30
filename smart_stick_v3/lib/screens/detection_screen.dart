import 'package:flutter/material.dart';

import '../main.dart';
import '../services/scan_service.dart';
import '../widgets/common_widgets.dart';

class DetectionScreen extends StatefulWidget {
  const DetectionScreen({super.key});

  @override
  State<DetectionScreen> createState() =>
      _DetectionScreenState();
}

class _DetectionScreenState
    extends State<DetectionScreen> {

  final List<DetectedObject> _objects = [];

  bool _scanning = false;

  @override
  void initState() {

    super.initState();

    ScanService.instance.onDetection =
        (detections) {

      if (!mounted) return;

      setState(() {

        _objects
          ..clear()
          ..addAll(detections);
      });
    };
  }

  @override
  void dispose() {

    ScanService.instance.stop();

    super.dispose();
  }

  void _toggleScan() {

    if (_scanning) {

      ScanService.instance.stop();

    } else {

      ScanService.instance.start();
    }

    setState(() {

      _scanning = !_scanning;
    });
  }

  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [

          // =========================
          // HEADER
          // =========================

          Padding(
            padding:
                const EdgeInsets.fromLTRB(
              20,
              16,
              20,
              0,
            ),

            child: Row(
              children: [

                const Text(
                  'Live Detection',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.w700,
                    color:
                        AppTheme.textPri,
                  ),
                ),

                const Spacer(),

                StatusBadge(
                  label: _scanning
                      ? 'SCANNING'
                      : 'IDLE',

                  color: _scanning
                      ? AppTheme.accent
                      : AppTheme.textMuted,
                ),
              ],
            ),
          ),

          const SizedBox(height: 4),

          const Padding(
            padding:
                EdgeInsets.symmetric(
              horizontal: 20,
            ),

            child: Text(
              'ESP32-CAM person detection',
              style: TextStyle(
                fontSize: 11,
                color:
                    AppTheme.textMuted,
              ),
            ),
          ),

          const SizedBox(height: 18),

          // =========================
          // LIVE ESP32 STREAM
          // =========================

          Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 16,
            ),

            child: Container(
              height: 260,
              width: double.infinity,

              decoration: BoxDecoration(
                color: AppTheme.bg3,

                borderRadius:
                    BorderRadius.circular(
                  20,
                ),

                border: Border.all(
                  color:
                      AppTheme.border,
                ),
              ),

              clipBehavior:
                  Clip.hardEdge,

              child: Stack(
                children: [

                  // LIVE STREAM
                  Positioned.fill(
                    child: Image.network(

                      // CHANGE IP IF NEEDED
                      'http://10.213.229.30:81/stream',

                      fit: BoxFit.cover,

                      gaplessPlayback:
                          true,

                      errorBuilder:
                          (_, __, ___) {

                        return const Center(
                          child: Text(
                            'ESP32 Stream Offline',
                            style: TextStyle(
                              color:
                                  AppTheme
                                      .textMuted,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // LIVE LABEL
                  Positioned(
                    top: 12,
                    left: 12,

                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),

                      decoration:
                          BoxDecoration(
                        color: Colors.black
                            .withOpacity(
                          0.6,
                        ),

                        borderRadius:
                            BorderRadius
                                .circular(
                          12,
                        ),
                      ),

                      child: const Row(
                        children: [

                          Icon(
                            Icons.circle,
                            color: Colors.red,
                            size: 10,
                          ),

                          SizedBox(
                            width: 6,
                          ),

                          Text(
                            'LIVE',
                            style: TextStyle(
                              color:
                                  Colors
                                      .white,
                              fontSize:
                                  11,
                              fontWeight:
                                  FontWeight
                                      .w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // STREAM LABEL
                  Positioned(
                    bottom: 12,
                    left: 12,

                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),

                      decoration:
                          BoxDecoration(
                        color: Colors.black
                            .withOpacity(
                          0.6,
                        ),

                        borderRadius:
                            BorderRadius
                                .circular(
                          12,
                        ),
                      ),

                      child: const Text(
                        'ESP32-CAM STREAM',
                        style: TextStyle(
                          color:
                              Colors.white,
                          fontSize: 11,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 18),

          // =========================
          // SCAN BUTTON
          // =========================

          Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 16,
            ),

            child: GestureDetector(
              onTap: _toggleScan,

              child: Container(
                width: double.infinity,

                padding:
                    const EdgeInsets.symmetric(
                  vertical: 16,
                ),

                decoration: BoxDecoration(

                  gradient: LinearGradient(
                    colors: _scanning

                        ? [
                            Colors.red,
                            Colors.redAccent,
                          ]

                        : [
                            AppTheme.accent,
                            AppTheme.accent
                                .withOpacity(
                              0.7,
                            ),
                          ],
                  ),

                  borderRadius:
                      BorderRadius.circular(
                    18,
                  ),
                ),

                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .center,

                  children: [

                    Icon(
                      _scanning
                          ? Icons.stop
                          : Icons
                              .play_arrow_rounded,

                      color: Colors.black,
                    ),

                    const SizedBox(
                      width: 10,
                    ),

                    Text(
                      _scanning
                          ? 'STOP SCANNING'
                          : 'START SCANNING',

                      style:
                          const TextStyle(
                        color:
                            Colors.black,
                        fontSize: 14,
                        fontWeight:
                            FontWeight
                                .w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 18),

          // =========================
          // DETECTIONS
          // =========================

          Expanded(
            child: _objects.isEmpty

                ? const Center(
                    child: Text(
                      'No person detected',
                      style: TextStyle(
                        color:
                            AppTheme
                                .textMuted,
                      ),
                    ),
                  )

                : ListView.builder(

                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 16,
                    ),

                    itemCount:
                        _objects.length,

                    itemBuilder:
                        (_, i) {

                      final obj =
                          _objects[i];

                      return Container(

                        margin:
                            const EdgeInsets
                                .only(
                          bottom: 12,
                        ),

                        padding:
                            const EdgeInsets
                                .all(
                          14,
                        ),

                        decoration:
                            BoxDecoration(
                          color:
                              AppTheme.card,

                          borderRadius:
                              BorderRadius
                                  .circular(
                            18,
                          ),

                          border: Border.all(
                            color:
                                AppTheme
                                    .border,
                          ),
                        ),

                        child: Row(
                          children: [

                            Container(
                              width: 46,
                              height: 46,

                              decoration:
                                  BoxDecoration(
                                color:
                                    AppTheme
                                        .accent
                                        .withOpacity(
                                  0.15,
                                ),

                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  14,
                                ),
                              ),

                              child: const Icon(
                                Icons.person,
                                color:
                                    AppTheme
                                        .accent,
                              ),
                            ),

                            const SizedBox(
                              width: 14,
                            ),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,

                                children: [

                                  const Text(
                                    'PERSON',
                                    style:
                                        TextStyle(
                                      color:
                                          AppTheme
                                              .textPri,

                                      fontSize:
                                          14,

                                      fontWeight:
                                          FontWeight
                                              .w700,
                                    ),
                                  ),

                                  const SizedBox(
                                    height: 4,
                                  ),

                                  Text(
                                    '${obj.direction.toUpperCase()} • ${obj.meters} meters',

                                    style:
                                        const TextStyle(
                                      color:
                                          AppTheme
                                              .textMuted,

                                      fontSize:
                                          12,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const Icon(
                              Icons.warning_amber_rounded,
                              color:
                                  Colors.orange,
                            ),
                          ],
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