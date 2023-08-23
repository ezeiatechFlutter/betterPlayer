import 'package:auto_orientation/auto_orientation.dart';
import 'package:better_player/better_player.dart';
import 'package:better_player_example/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:native_device_orientation/native_device_orientation.dart';

class AutoFullscreenOrientationPage extends StatefulWidget {
  @override
  _AutoFullscreenOrientationPageState createState() =>
      _AutoFullscreenOrientationPageState();
}

class _AutoFullscreenOrientationPageState
    extends State<AutoFullscreenOrientationPage> {
  late BetterPlayerController _betterPlayerController;
  Orientation? target;

  @override
  void initState() {
    NativeDeviceOrientationCommunicator()
        .onOrientationChanged(useSensor: true)
        .listen((event) {
      final isPortrait = event == NativeDeviceOrientation.portraitUp;
      final isLandscape = event == NativeDeviceOrientation.landscapeLeft ||
          event == NativeDeviceOrientation.landscapeRight;
      final isTargetPortrait = target == Orientation.portrait;
      final isTargetLandscape = target == Orientation.landscape;

      if (isPortrait && isTargetPortrait || isLandscape && isTargetLandscape) {
        target = null;
        SystemChrome.setPreferredOrientations(DeviceOrientation.values);
      }
    });

    BetterPlayerDataSource dataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network, Constants.forBiggerBlazesUrl);
    _betterPlayerController = BetterPlayerController(
      BetterPlayerConfiguration(
          placeholder: Icon(Icons.access_alarm_outlined),
          allowedScreenSleep: false,
          deviceOrientationsOnFullScreen: [
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight
          ],
          deviceOrientationsAfterFullScreen: [
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown
          ],
          fullScreenAspectRatio: 1,
          fit: BoxFit.fitHeight,
          autoPlay: true,
          autoDispose: false,
          autoDetectFullscreenDeviceOrientation: true,
          autoDetectFullscreenAspectRatio: true,
          controlsConfiguration: BetterPlayerControlsConfiguration(
            enableMute: true,
            enableOverflowMenu: false,
            forwardSkipTimeInMilliseconds: 30000,
            backwardSkipTimeInMilliseconds: 30000,
            skipForwardIcon: Icons.arrow_forward_ios_sharp,
            skipBackIcon: Icons.arrow_back_ios_sharp,
            //  enableProgressBarDrag: false,
            enableQualities: true,
            fullscreenHandler: ({required bool isFullScreen}) {
              print("is full screen :: ${isFullScreen}");
              var isPortrait =
                  MediaQuery.of(context).orientation == Orientation.portrait;
              target =
                  isPortrait ? Orientation.landscape : Orientation.portrait;

              if (isPortrait) {
                _betterPlayerController.isFullScreen = (true);
                AutoOrientation.landscapeRightMode();
              } else {
                _betterPlayerController.isFullScreen = (false);
                AutoOrientation.portraitUpMode();
              }
            },
            enableSkips: true,
          )),
    );
    _betterPlayerController.setupDataSource(dataSource);
    super.initState();
  }

  void setOrientation(bool isPortrait) {
    if (isPortrait) {
      _betterPlayerController.isFullScreen = (false);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: SystemUiOverlay.values);
    } else {
      _betterPlayerController.isFullScreen = (true);
      //  Wakelock.enable();
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    }
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, orientation) {
      final isPortrait = orientation == Orientation.portrait;

      setOrientation(isPortrait);
      return Scaffold(
          appBar: (isPortrait)
              ? AppBar(
                  title: Text("Auto full screen orientation"),
                )
              : null,
          body: Column(
            children: [
              if (isPortrait) const SizedBox(height: 8),
              if (isPortrait)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "Aspect ratio and device orientation on full screen will be "
                    "managed by the BetterPlayer. Click on the fullscreen option.",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              AspectRatio(
                aspectRatio: isPortrait
                    ? 16 / 9
                    : MediaQuery.of(context).size.width /
                        MediaQuery.of(context).size.height,
                child: BetterPlayer(controller: _betterPlayerController),
              ),
              if (isPortrait)
                ElevatedButton(
                  child: Text("Play horizontal video"),
                  onPressed: () {
                    BetterPlayerDataSource dataSource = BetterPlayerDataSource(
                        BetterPlayerDataSourceType.network,
                        Constants.forBiggerBlazesUrl);
                    _betterPlayerController.setupDataSource(dataSource);
                  },
                ),
              if (isPortrait)
                ElevatedButton(
                  child: Text("Play vertical video"),
                  onPressed: () async {
                    BetterPlayerDataSource dataSource = BetterPlayerDataSource(
                        BetterPlayerDataSourceType.network,
                        Constants.verticalVideoUrl);
                    _betterPlayerController.setupDataSource(dataSource);
                  },
                ),
              if (isPortrait)
                ElevatedButton(
                    onPressed: () {
                      _betterPlayerController.toggleFullScreen(true);
                    },
                    child: Text("on full screen")),
              if (isPortrait)
                SizedBox(
                  height: 10,
                ),
              if (isPortrait)
                ElevatedButton(
                    onPressed: () {
                      _betterPlayerController.toggleFullScreen(false);
                    },
                    child: Text("on exit full  screen")),
            ],
          ));
    });
  }
}
