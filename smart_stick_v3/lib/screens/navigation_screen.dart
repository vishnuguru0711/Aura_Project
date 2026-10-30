import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';
import '../services/tts_service.dart';
import '../widgets/common_widgets.dart';

class NavigationScreen extends StatefulWidget {
  final String initialDestination;

  const NavigationScreen({
    super.key,
    this.initialDestination = '',
  });

  @override
  State<NavigationScreen> createState() =>
      _NavigationScreenState();
}

class _NavigationScreenState
    extends State<NavigationScreen> {

  final TextEditingController _destCtrl =
      TextEditingController();

  bool _loading = false;

  Position? _currentPos;

  @override
  void initState() {
    super.initState();

    _getLocation();

    if (widget.initialDestination.isNotEmpty) {

      _destCtrl.text =
          widget.initialDestination;

      WidgetsBinding.instance
          .addPostFrameCallback((_) {

        _navigate();
      });
    }
  }

  Future<void> _getLocation() async {

    try {

      LocationPermission perm =
          await Geolocator.checkPermission();

      if (perm ==
          LocationPermission.denied) {

        perm =
            await Geolocator.requestPermission();
      }

      if (perm ==
              LocationPermission.whileInUse ||
          perm ==
              LocationPermission.always) {

        final pos =
            await Geolocator.getCurrentPosition(
          desiredAccuracy:
              LocationAccuracy.high,
        ).timeout(
          const Duration(seconds: 8),
        );

        if (mounted) {
          setState(() => _currentPos = pos);
        }
      }

    } catch (_) {}
  }

  // =========================
  // AUTO START NAVIGATION
  // =========================

  Future<void> _navigate() async {

    final dest =
        _destCtrl.text.trim();

    if (dest.isEmpty) {

      TtsService.instance.speak(
        'Please enter a destination.',
      );

      return;
    }

    setState(() => _loading = true);

    TtsService.instance.speak(
      'Starting navigation to $dest',
    );

    final encoded =
        Uri.encodeComponent(dest);

    try {

      // DIRECT GOOGLE MAPS NAVIGATION
      final Uri navigationUri =
          Uri.parse(
        'google.navigation:q=$encoded&mode=w',
      );

      // WEB FALLBACK
      final Uri webUri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1'
        '&destination=$encoded'
        '&travelmode=walking',
      );

      if (await canLaunchUrl(
        navigationUri,
      )) {

        await launchUrl(
          navigationUri,
          mode:
              LaunchMode.externalApplication,
        );

      } else if (await canLaunchUrl(
        webUri,
      )) {

        await launchUrl(
          webUri,
          mode:
              LaunchMode.externalApplication,
        );

      } else {

        TtsService.instance.speak(
          'Could not open Google Maps.',
        );
      }

    } catch (e) {

      debugPrint(
        'Navigation launch error: $e',
      );

      TtsService.instance.speak(
        'Navigation failed.',
      );
    }

    if (mounted) {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {

    _destCtrl.dispose();

    super.dispose();
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
                  'Navigation',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.w700,
                    color:
                        AppTheme.textPri,
                  ),
                ),

                const Spacer(),

                if (_currentPos != null)

                  StatusBadge(
                    label: 'GPS READY',
                    color:
                        AppTheme.accent,
                  )

                else

                  StatusBadge(
                    label: 'LOCATING...',
                    color:
                        AppTheme.textMuted,
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
              'Voice-controlled walking navigation',
              style: TextStyle(
                fontSize: 11,
                color:
                    AppTheme.textMuted,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // =========================
          // SEARCH BAR
          // =========================

          Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Row(
              children: [

                Expanded(
                  child: Container(
                    decoration:
                        BoxDecoration(
                      color:
                          AppTheme.card,
                      borderRadius:
                          BorderRadius
                              .circular(
                        14,
                      ),
                      border: Border.all(
                        color:
                            AppTheme
                                .border,
                      ),
                    ),
                    child: TextField(
                      controller:
                          _destCtrl,

                      style:
                          const TextStyle(
                        color:
                            AppTheme
                                .textPri,
                        fontSize: 14,
                      ),

                      decoration:
                          const InputDecoration(
                        hintText:
                            'Where do you want to go?',
                        hintStyle:
                            TextStyle(
                          color:
                              AppTheme
                                  .textMuted,
                        ),
                        prefixIcon:
                            Icon(
                          Icons.search,
                          color:
                              AppTheme
                                  .textMuted,
                          size: 20,
                        ),
                        border:
                            InputBorder
                                .none,
                        contentPadding:
                            EdgeInsets.symmetric(
                          horizontal:
                              12,
                          vertical:
                              14,
                        ),
                      ),

                      onSubmitted:
                          (_) =>
                              _navigate(),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                GestureDetector(
                  onTap:
                      _loading
                          ? null
                          : _navigate,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration:
                        BoxDecoration(
                      color:
                          AppTheme
                              .accent,
                      borderRadius:
                          BorderRadius
                              .circular(
                        14,
                      ),
                    ),

                    child: _loading

                        ? const Center(
                            child:
                                SizedBox(
                              width: 20,
                              height: 20,
                              child:
                                  CircularProgressIndicator(
                                color:
                                    Colors
                                        .black,
                                strokeWidth:
                                    2.5,
                              ),
                            ),
                          )

                        : const Icon(
                            Icons
                                .navigation_rounded,
                            color:
                                Colors
                                    .black,
                            size: 24,
                          ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // =========================
          // QUICK DESTINATIONS
          // =========================

          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection:
                  Axis.horizontal,
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 16,
              ),

              children: [

                'Hospital',
                'Bus Stop',
                'Police Station',
                'Pharmacy',
                'Railway Station',
                'Market',
                'School',

              ].map((p) {

                return GestureDetector(

                  onTap: () {

                    _destCtrl.text = p;

                    _navigate();
                  },

                  child: Container(
                    margin:
                        const EdgeInsets.only(
                      right: 8,
                    ),

                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),

                    decoration:
                        BoxDecoration(
                      color:
                          AppTheme.card,
                      borderRadius:
                          BorderRadius
                              .circular(
                        20,
                      ),
                      border: Border.all(
                        color:
                            AppTheme
                                .border,
                      ),
                    ),

                    child: Text(
                      p,
                      style:
                          const TextStyle(
                        fontSize: 12,
                        color:
                            AppTheme
                                .textPri,
                      ),
                    ),
                  ),
                );

              }).toList(),
            ),
          ),

          const Spacer(),

          // =========================
          // NAV BUTTON
          // =========================

          Padding(
            padding:
                const EdgeInsets.fromLTRB(
              16,
              0,
              16,
              16,
            ),

            child: GestureDetector(

              onTap:
                  _loading
                      ? null
                      : _navigate,

              child: Container(
                width: double.infinity,

                padding:
                    const EdgeInsets.symmetric(
                  vertical: 16,
                ),

                decoration:
                    BoxDecoration(
                  gradient:
                      LinearGradient(
                    colors: [
                      AppTheme.blue,
                      AppTheme.blue
                          .withOpacity(
                        0.7,
                      ),
                    ],
                  ),

                  borderRadius:
                      BorderRadius.circular(
                    16,
                  ),
                ),

                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .center,

                  children: [

                    const Icon(
                      Icons
                          .navigation_rounded,
                      color:
                          Colors.white,
                      size: 22,
                    ),

                    const SizedBox(
                      width: 10,
                    ),

                    Text(
                      _loading
                          ? 'Opening Navigation...'
                          : 'Start Navigation',

                      style:
                          const TextStyle(
                        fontSize: 15,
                        fontWeight:
                            FontWeight
                                .w700,
                        color:
                            Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}