import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/features/simulation/domain/models/simulation_models.dart';
import 'package:just_audio/just_audio.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ClinicalMediaViewer extends StatefulWidget {
  final ClinicalMedia media;
  const ClinicalMediaViewer({super.key, required this.media});

  @override
  State<ClinicalMediaViewer> createState() => _ClinicalMediaViewerState();
}

class _ClinicalMediaViewerState extends State<ClinicalMediaViewer> {
  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initAudio();
  }

  @override
  void didUpdateWidget(ClinicalMediaViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.media.url != widget.media.url) {
      _initAudio();
    }
  }

  Future<void> _initAudio() async {
    if (widget.media.type == MediaType.audio) {
      try {
        await _audioPlayer.setUrl(widget.media.url);
      } catch (e) {
        debugPrint("Error loading audio: $e");
      }
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                widget.media.type == MediaType.audio
                    ? Iconsax.volume_high
                    : widget.media.type == MediaType.ecg
                    ? Iconsax.activity
                    : Iconsax.image,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                widget.media.title ?? l10n.simInterpretation,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (widget.media.type == MediaType.audio)
          _buildAudioPlayer()
        else
          _buildImageViewer(),
        const SizedBox(height: 24),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildAudioPlayer() {
    return Column(
      children: [
        StreamBuilder<PlayerState>(
          stream: _audioPlayer.playerStateStream,
          builder: (context, snapshot) {
            final playerState = snapshot.data;
            final processingState = playerState?.processingState;
            final playing = playerState?.playing ?? false;

            return Column(
              children: [
                Container(
                  height: 80,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (processingState == ProcessingState.buffering ||
                            processingState == ProcessingState.loading)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.green,
                            ),
                          )
                        else
                          Icon(
                            Iconsax.flash,
                            color: playing ? Colors.green : Colors.grey,
                            size: 16,
                          ),
                        const SizedBox(width: 12),
                        Builder(builder: (context) {
                          final l10n = AppLocalizations.of(context)!;
                          return Text(
                            processingState == ProcessingState.loading
                                ? l10n.simLoadingAudio
                                : playing
                                ? l10n.simPlayingAuscultation
                                : l10n.simReadyToListen,
                            style: TextStyle(
                              color: playing ? Colors.green : Colors.grey,
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                IconButton(
                  iconSize: 80,
                  color: AppColors.primary,
                  icon: Icon(
                    playing ? Iconsax.pause_circle : Iconsax.play_circle,
                  ),
                  onPressed: () {
                    if (playing) {
                      _audioPlayer.pause();
                    } else {
                      _audioPlayer.play();
                    }
                  },
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildImageViewer() {
    return Container(
      height: 350, // Fixed height ensures visibility in a Column
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: InteractiveViewer(
          maxScale: 4.0,
          child: CachedNetworkImage(
            imageUrl: widget.media.url,
            progressIndicatorBuilder: (context, url, downloadProgress) =>
                const Center(child: CircularProgressIndicator(color: Colors.white)),
            errorWidget: (context, url, error) => const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, color: Colors.white, size: 40),
                SizedBox(height: 8),
                Text("Error loading image", style: TextStyle(color: Colors.white)),
              ],
            ),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
