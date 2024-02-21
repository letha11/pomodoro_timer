import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:file_picker/file_picker.dart';

import 'package:pomodoro_timer/core/constants.dart';
import 'package:pomodoro_timer/core/utils/audio_player.dart';
import 'package:pomodoro_timer/core/utils/service_locator.dart';
import 'package:pomodoro_timer/timer/presentation/blocs/setting/setting_bloc.dart';
import 'package:pomodoro_timer/timer/presentation/views/settings/widgets/title_switch.dart';

class SoundsSetting extends StatefulWidget {
  const SoundsSetting({super.key});

  @override
  State<SoundsSetting> createState() => _SoundsSettingState();
}

// TODO:
// 1. Store the imported sound into local storage
// 2. Store the soundType so we know what the user picked before
class _SoundsSettingState extends State<SoundsSetting> {
  SoundType soundType = SoundType.defaults;
  String customAudioLabel = '';
  Uint8List? importedAudioBytes;

  _showBottomSheet(BuildContext context) async => await showModalBottomSheet(
        context: context,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        builder: (_) {
          return StatefulBuilder(builder: (_, setStateSB) {
            Color testColor = Colors.black;
            if (importedAudioBytes == null) {
              testColor = Colors.grey;
            } else {
              if (soundType.isImported) {
                testColor = Colors.white;
              } else {
                testColor = Colors.black;
              }
            }

            return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 25.0, vertical: 26),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 50,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SoundSettingTile(
                    selected: soundType.isDefault,
                    onTap: () {
                      if (soundType.isDefault) return;

                      setStateSB(() {
                        soundType = SoundType.defaults;
                      });
                      context
                          .read<SettingBloc>()
                          .add(SettingSet(type: soundType));
                    },
                    onPlayTapped: playDefaultAudio,
                  ),
                  const SizedBox(height: 16),
                  SoundSettingTile(
                    label: customAudioLabel,
                    selected: soundType.isImported,
                    onTap: !soundType.isImported && importedAudioBytes != null
                        ? () {
                            setStateSB(() {
                              soundType = SoundType.imported;
                            });
                            context
                                .read<SettingBloc>()
                                .add(SettingSet(type: soundType));
                          }
                        : null,
                    actions: [
                      GestureDetector(
                        onTap: importedAudioBytes != null
                            ? playImportedAudio
                            : null,
                        child: SvgPicture.asset(
                          'assets/images/play.svg',
                          colorFilter:
                              ColorFilter.mode(testColor, BlendMode.srcIn),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () async {
                          FilePickerResult? result =
                              await FilePicker.platform.pickFiles(
                            withData: true,
                            type: FileType.audio,
                          );

                          if (result != null) {
                            PlatformFile platformFile = result.files.first;
                            debugPrint(platformFile.name);
                            // setStateSB(() {});
                            setStateSB(() {
                              customAudioLabel = platformFile.name;
                              importedAudioBytes = platformFile.bytes;
                            });
                            if (context.mounted) {
                              context.read<SettingBloc>().add(SettingSet(
                                    bytesData: platformFile.bytes,
                                    importedFileName: platformFile.name,
                                  ));
                            }
                          } else {
                            // User canceled the picker
                          }
                        },
                        child: SvgPicture.asset(
                          'assets/images/import.svg',
                          colorFilter: ColorFilter.mode(
                              soundType.isImported
                                  ? Colors.white
                                  : Colors.black,
                              BlendMode.srcIn),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          });
        },
      ).whenComplete(() {
        pickAudioDismissed();
        setState(() {});
      });

  void playDefaultAudio() =>
      sl<AudioPlayerL>().playSound('assets/audio/alarm.wav');

  void playImportedAudio() =>
      sl<AudioPlayerL>().playSoundFromUint8List(importedAudioBytes!);

  void pickAudioDismissed() {
    sl<AudioPlayerL>().stopSound();
  }

  @override
  void initState() {
    final soundSetting =
        (context.read<SettingBloc>().state as SettingLoaded).soundSetting;
    importedAudioBytes = soundSetting.bytesData;
    customAudioLabel = soundSetting.importedFileName ?? '';
    soundType = soundSetting.type;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 12.0),
        child: Column(
          children: [
            TitleSwitch(
              title: "Play Sound",
              initialState: (context.read<SettingBloc>().state as SettingLoaded)
                  .soundSetting
                  .playSound,
              onToggle: (val) =>
                  context.read<SettingBloc>().add(SettingSet(playSound: val)),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(soundType.isDefault ? "Default" : customAudioLabel,
                    style: Theme.of(context).textTheme.bodySmall),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (soundType.isDefault) {
                          playDefaultAudio();
                        } else {
                          playImportedAudio();
                        }
                      },
                      child: SvgPicture.asset(
                        'assets/images/play.svg',
                        width: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () async {
                        _showBottomSheet(context);
                      },
                      child: SvgPicture.asset(
                        'assets/images/setting.svg',
                        width: 24,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SoundSettingTile extends StatelessWidget {
  final String label;
  final bool selected;
  final void Function()? onTap;

  /// will handle onTap of an default action button
  final void Function()? onPlayTapped;
  final List<Widget>? actions;

  SoundSettingTile({
    super.key,
    this.label = 'Default',
    required this.selected,
    this.onTap,
    this.onPlayTapped,
    this.actions,
  }) {
    backgroundColor = selected ? Colors.black : Colors.white;
    itemColor = selected ? Colors.white : Colors.black;
  }

  late final Color backgroundColor;
  late final Color itemColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 17, horizontal: 10),
        color: backgroundColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.timer,
                  size: 24,
                  color: itemColor,
                ),
                const SizedBox(width: 8),
                Column(
                  children: [
                    Text(
                      label,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: itemColor),
                    ),
                  ],
                ),
              ],
            ),
            if (actions == null)
              GestureDetector(
                onTap: onPlayTapped,
                child: SvgPicture.asset(
                  'assets/images/play.svg',
                  colorFilter: ColorFilter.mode(itemColor, BlendMode.srcIn),
                ),
              )
            else
              Row(
                children: actions!,
              ),
            // ...actions!
          ],
        ),
      ),
    );
  }
}
