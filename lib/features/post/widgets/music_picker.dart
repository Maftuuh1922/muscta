import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../../core/constants/app_colors.dart';
import '../../../services/spotify/spotify_service.dart';

class MusicSelection {
  final String title;
  final String artist;
  final String albumCover;
  final int durationMs;
  final String? previewUrl;
  final String spotifyId;
  final int clipStartMs;
  final int clipDurationMs; // e.g., 15000 for 15s

  MusicSelection({
    required this.title,
    required this.artist,
    required this.albumCover,
    required this.durationMs,
    required this.previewUrl,
    required this.spotifyId,
    required this.clipStartMs,
    required this.clipDurationMs,
  });
}

Future<MusicSelection?> showMusicPicker(BuildContext context) async {
  // Open full-screen music picker
  return await Navigator.of(context).push<MusicSelection?>(
    MaterialPageRoute(builder: (_) => const _MusicPickerPage()),
  );
}

class _MusicPickerPage extends StatelessWidget {
  const _MusicPickerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(child: _MusicPickerSheet()),
    );
  }
}

class _MusicPickerSheet extends StatefulWidget {
  const _MusicPickerSheet();
  @override
  State<_MusicPickerSheet> createState() => _MusicPickerSheetState();
}

class _MusicPickerSheetState extends State<_MusicPickerSheet> {
  final _controller = TextEditingController();
  Timer? _debounce;
  bool _loading = true;
  List<Map<String, dynamic>> _tracks = [];

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    try {
      final connected = await SpotifyService.isConnected();
      if (connected) {
        final top = await SpotifyService.getTopTracks(limit: 20);
        setState(() {
          // Keep only tracks that have a preview URL
          _tracks = top.where((t) => (t['preview_url'] as String?) != null).toList();
        });
      } else {
        _tracks = [];
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  void _onSearchChanged(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      if (text.trim().isEmpty) {
        _loadInitial();
        return;
      }
      setState(() => _loading = true);
      try {
        final res = await SpotifyService.searchTracks(text.trim(), limit: 20);
        if (!mounted) return;
        setState(() {
          // Filter search results to tracks that include a preview_url
          _tracks = res.where((t) => (t['preview_url'] as String?) != null).toList();
          _loading = false;
        });
      } catch (_) {
        if (mounted) setState(() => _loading = false);
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 12,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text('Add Music', style: TextStyle(color: AppColors.primaryText, fontSize: 16, fontWeight: FontWeight.w700)),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.primaryText),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
        const SizedBox(height: 8),
            TextField(
              controller: _controller,
              onChanged: _onSearchChanged,
              style: const TextStyle(color: AppColors.primaryText),
              decoration: InputDecoration(
          hintText: 'Cari musik',
                hintStyle: const TextStyle(color: AppColors.mutedText),
                prefixIcon: const Icon(Icons.search, color: AppColors.mutedText),
                filled: true,
                fillColor: AppColors.cardBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primaryPurple),
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
              )
            else
              Flexible(
                child: _tracks.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text('No tracks', style: TextStyle(color: AppColors.mutedText)),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: _tracks.length,
                        itemBuilder: (context, index) {
                          final t = _tracks[index];
                          final album = (t['album'] as Map<String, dynamic>? ?? {});
                          final images = List<Map<String, dynamic>>.from(album['images'] ?? []);
                          final imageUrl = images.isNotEmpty ? images.last['url'] ?? images.first['url'] : null;
                          final title = t['name']?.toString() ?? 'Unknown';
                          final artists = List<Map<String, dynamic>>.from(t['artists'] ?? []);
                          final artist = artists.isNotEmpty ? artists.map((a) => a['name']).join(', ') : 'Unknown';
                          final durationMs = (t['duration_ms'] as int?) ?? 0;
                          final durationStr = _formatMs(durationMs);
                          final previewUrl = t['preview_url'] as String?;
                          final spotifyId = t['id']?.toString() ?? '';

                          return InkWell(
                            onTap: () async {
                              // Open clip selector
                              final clip = await showClipSelector(
                                context,
                                title: title,
                                artist: artist,
                                albumCover: imageUrl ?? '',
                                previewUrl: previewUrl,
                              );
                              if (clip == null) return;
                              // Return selection
                              if (context.mounted) {
                                Navigator.pop(
                                  context,
                                  MusicSelection(
                                    title: title,
                                    artist: artist,
                                    albumCover: imageUrl ?? '',
                                    durationMs: durationMs,
                                    previewUrl: previewUrl,
                                    spotifyId: spotifyId,
                                    clipStartMs: clip.startMs,
                                    clipDurationMs: clip.durationMs,
                                  ),
                                );
                              }
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.cardBackground,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.borderColor),
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: imageUrl != null
                                        ? Image.network(imageUrl, width: 44, height: 44, fit: BoxFit.cover)
                                        : Container(width: 44, height: 44, color: AppColors.borderColor,
                                            child: const Icon(Icons.music_note, color: AppColors.mutedText)),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(title, style: const TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.w600)),
                                        Text(artist, style: const TextStyle(color: AppColors.mutedText, fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                  Text(durationStr, style: const TextStyle(color: AppColors.mutedText, fontSize: 12)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

String _formatMs(int ms) {
  final d = Duration(milliseconds: ms);
  final m = d.inMinutes;
  final s = d.inSeconds % 60;
  return '$m:${s.toString().padLeft(2, '0')}';
}

class _ClipResult {
  final int startMs;
  final int durationMs;
  _ClipResult(this.startMs, this.durationMs);
}

Future<_ClipResult?> showClipSelector(
  BuildContext context, {
  required String title,
  required String artist,
  required String albumCover,
  required String? previewUrl,
}) async {
  // Open full-screen clip selector
  return Navigator.of(context).push<_ClipResult?>(
    MaterialPageRoute(builder: (_) => Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(child: _ClipSelectorSheet(title: title, artist: artist, albumCover: albumCover, previewUrl: previewUrl)),
    )),
  );
}

class _ClipSelectorSheet extends StatefulWidget {
  final String title;
  final String artist;
  final String albumCover;
  final String? previewUrl;

  const _ClipSelectorSheet({
    required this.title,
    required this.artist,
    required this.albumCover,
    required this.previewUrl,
  });

  @override
  State<_ClipSelectorSheet> createState() => _ClipSelectorSheetState();
}

class _ClipSelectorSheetState extends State<_ClipSelectorSheet> {
  final _player = AudioPlayer();
  StreamSubscription<PlayerState>? _playerSub;
  int _previewMs = 30000; // default 30s if unknown
  int _clipDurationMs = 15000; // default 15s
  double _clipStartMs = 0;
  bool _loading = true;
  bool _playing = false;

  @override
  void initState() {
    super.initState();
    _initAudio();
  }

  Future<void> _initAudio() async {
    try {
      // If there's no preview URL, nothing to load
      if (widget.previewUrl == null) {
        if (mounted) setState(() => _loading = false);
        return;
      }

      final duration = await _player.setUrl(widget.previewUrl!);
      if (duration != null) {
        _previewMs = duration.inMilliseconds;
      }

      // Ensure start is valid
      if (_clipStartMs + _clipDurationMs > _previewMs) {
        _clipStartMs = (_previewMs - _clipDurationMs).clamp(0, _previewMs).toDouble();
      }
    } catch (_) {
      // ignore
    }

    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    _playerSub?.cancel();
    _player.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    if (widget.previewUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Preview tidak tersedia untuk lagu ini")),
      );
      return;
    }

    if (_playing) {
      await _player.pause();
      setState(() => _playing = false);
      return;
    }

    final start = Duration(milliseconds: _clipStartMs.toInt());
    final end = Duration(milliseconds: (_clipStartMs + _clipDurationMs).toInt());

    await _player.setClip(start: start, end: end);
    await _player.seek(start);
    await _player.play();

    setState(() => _playing = true);

    // Cancel previous subscription if any
    await _playerSub?.cancel();
    _playerSub = _player.playerStateStream.listen((st) {
      if (st.processingState == ProcessingState.completed) {
        setState(() => _playing = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step indicator and header
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.primaryText),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 8),
                const Text('Pilih Potongan Musik', style: TextStyle(color: AppColors.primaryText, fontSize: 18, fontWeight: FontWeight.w700)),
                const Spacer(),
                Text('2/2', style: TextStyle(color: AppColors.mutedText)),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: widget.albumCover.isNotEmpty
                    ? Image.network(widget.albumCover, width: 160, height: 160, fit: BoxFit.cover)
                    : Container(width: 160, height: 160, color: AppColors.borderColor,
                        child: const Icon(Icons.music_note, color: AppColors.mutedText, size: 48)),
              ),
            ),
            const SizedBox(height: 12),
            Center(child: Text(widget.title, style: const TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.w700))),
            Center(child: Text(widget.artist, style: const TextStyle(color: AppColors.mutedText, fontSize: 12))),
            const SizedBox(height: 18),

            // Waveform placeholder
            Container(
              height: 90,
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderColor),
              ),
              child: Center(
                child: Text(widget.previewUrl == null ? 'No preview waveform' : 'Waveform preview', style: const TextStyle(color: AppColors.mutedText)),
              ),
            ),
            const SizedBox(height: 16),

            if (widget.previewUrl == null) ...[
              const Text('No preview available for this track', style: TextStyle(color: AppColors.mutedText)),
              const SizedBox(height: 12),
            ] else if (_loading)
              const Center(child: CircularProgressIndicator(color: AppColors.primary))
            else ...[
              Row(
                children: [
                  const Text('Durasi potongan', style: TextStyle(color: AppColors.primaryText)),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('5s'),
                    selected: _clipDurationMs == 5000,
                    onSelected: (_) => setState(() => _clipDurationMs = 5000),
                  ),
                  const SizedBox(width: 6),
                  ChoiceChip(
                    label: const Text('10s'),
                    selected: _clipDurationMs == 10000,
                    onSelected: (_) => setState(() => _clipDurationMs = 10000),
                  ),
                  const SizedBox(width: 6),
                  ChoiceChip(
                    label: const Text('15s'),
                    selected: _clipDurationMs == 15000,
                    onSelected: (_) => setState(() => _clipDurationMs = 15000),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Big slider
              Text('Mulai: ${_formatMs(_clipStartMs.toInt())} — Akhir: ${_formatMs((_clipStartMs + _clipDurationMs).toInt())}', style: const TextStyle(color: AppColors.mutedText)),
              Slider(
                min: 0,
                max: (_previewMs - _clipDurationMs).clamp(0, _previewMs).toDouble(),
                value: _clipStartMs.clamp(0, (_previewMs - _clipDurationMs).toDouble()),
                onChanged: (v) => setState(() => _clipStartMs = v),
                activeColor: AppColors.primary,
                inactiveColor: AppColors.borderColor,
              ),
              const SizedBox(height: 8),
              if (widget.previewUrl != null) ...[
                Row(
                  children: [
                    IconButton(
                      icon: Icon(_playing ? Icons.pause_circle_filled : Icons.play_circle_fill, color: AppColors.primary, size: 40),
                      onPressed: _togglePlay,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context, _ClipResult(_clipStartMs.toInt(), _clipDurationMs));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Selanjutnya'),
                      ),
                    )
                  ],
                ),
              ] else ...[
                Center(
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 16),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.borderColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Preview tidak tersedia untuk lagu ini',
                          style: TextStyle(color: AppColors.mutedText),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context, _ClipResult(0, _clipDurationMs));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Selanjutnya'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
            const SizedBox(height: 16),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
