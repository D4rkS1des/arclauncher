import 'package:flauncher/flauncher_channel.dart';
import 'package:flauncher/l10n/app_localizations.dart';
import 'package:flauncher/widgets/settings/focusable_settings_tile.dart';
import 'package:flauncher/widgets/settings/settings_theme.dart';
import 'package:flauncher/widgets/side_panel_dialog.dart';
import 'package:flutter/material.dart';

/// Opens the TV's input picker: the firmware's own panel when it has one, otherwise this
/// launcher's list of physical inputs (HDMI, AV, tuner). TVs whose picker lived in the stock
/// launcher lose it once that launcher is disabled, which is what the fallback is for.
Future<void> showTvInputPicker(BuildContext context) async {
  final channel = FLauncherChannel();
  if (await channel.openSystemInputPicker()) return;
  if (!context.mounted) return;
  await showDialog(context: context, builder: (_) => TvInputsPanel(channel: channel));
}

class TvInputsPanel extends StatelessWidget {
  final FLauncherChannel channel;

  const TvInputsPanel({super.key, required this.channel});

  // android.media.tv.TvInputInfo types
  static const int _typeTuner = 0;
  static const int _typeComposite = 1001;
  static const int _typeHdmi = 1007;

  static IconData _icon(int type) {
    switch (type) {
      case _typeHdmi:
        return Icons.settings_input_hdmi;
      case _typeComposite:
        return Icons.settings_input_composite;
      case _typeTuner:
        return Icons.settings_input_antenna;
      default:
        return Icons.input;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return SidePanelDialog(
      width: SettingsStyle.panelWidth,
      child: Column(
        children: [
          SettingsPageHeader(title: l.inputsTitle),
          Expanded(
            child: FutureBuilder<List<Map<dynamic, dynamic>>>(
              future: channel.getTvInputs(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final inputs = snapshot.data!;
                if (inputs.isEmpty) {
                  return Center(child: Text(l.inputsNone, style: Theme.of(context).textTheme.bodyMedium));
                }
                return ListView(
                  children: [
                    for (var i = 0; i < inputs.length; i++)
                      FocusableSettingsTile(
                        autofocus: i == 0,
                        leading: Icon(_icon(inputs[i]['type'] as int)),
                        title: Text(
                          (inputs[i]['type'] as int) == _typeTuner ? l.inputsTv : inputs[i]['label'] as String,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        // Many firmwares report every input as connected, so only a definite
                        // "disconnected" is worth showing
                        subtitle: (inputs[i]['state'] as int) == 2
                            ? Text(l.inputsDisconnected, style: Theme.of(context).textTheme.bodySmall)
                            : null,
                        onPressed: () async {
                          Navigator.of(context).pop();
                          await channel.openTvInput(inputs[i]['id'] as String);
                        },
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
