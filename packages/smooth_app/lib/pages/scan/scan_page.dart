import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/continuous_scan_model.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/helpers/permission_helper.dart';
import 'package:smooth_app/pages/scan/camera_scan_page.dart';
import 'package:smooth_app/pages/scan/smooth_barcode_scanner_type.dart';
import 'package:smooth_app/widgets/smooth_product_carousel.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

class ScanPage extends StatefulWidget {
  const ScanPage();

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  ContinuousScanModel? _model;

  /// Percentage of the bottom part of the screen that hosts the carousel.
  static const int _carouselHeightPct = 55;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateModel();
  }

  Future<void> _updateModel() async {
    if (_model == null) {
      _model = context.read<ContinuousScanModel>();
    } else {
      await _model!.refresh();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_model == null) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    final UserPreferences prefs = context.watch<UserPreferences>();

    // TODO(m123): Scanning engine
    /*final SmoothBarcodeScannerType scannerType =
        context.read<SmoothBarcodeScannerType>();*/
    return SmoothScaffold(
      brightness: Brightness.light,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 100 - _carouselHeightPct,
              child: Consumer<PermissionListener>(
                builder: (
                  BuildContext context,
                  PermissionListener listener,
                  _,
                ) {
                  switch (listener.value.status) {
                    case DevicePermissionStatus.checking:
                      return EMPTY_WIDGET;
                    case DevicePermissionStatus.granted:
                      // TODO(m123): change
                      return const CameraScannerPage(
                          SmoothBarcodeScannerType.mockup);
                    default:
                      return const _PermissionDeniedCard();
                  }
                },
              ),
            ),
            if (prefs.scanningEngine() != SmoothBarcodeScannerType.awesome)
              const Expanded(
                flex: _carouselHeightPct,
                child: Padding(
                  padding: EdgeInsetsDirectional.only(bottom: 10),
                  child: SmoothProductCarousel(containSearchCard: true),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PermissionDeniedCard extends StatelessWidget {
  const _PermissionDeniedCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context);

    return SafeArea(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Container(
            alignment: Alignment.topCenter,
            constraints: BoxConstraints.tightForFinite(
              width: constraints.maxWidth *
                  SmoothProductCarousel.carouselViewPortFraction,
              height: math.min(constraints.maxHeight * 0.9, 200),
            ),
            padding: SmoothProductCarousel.carouselItemInternalPadding,
            child: SmoothCard(
              padding: const EdgeInsetsDirectional.only(
                top: 10.0,
                start: SMALL_SPACE,
                end: SMALL_SPACE,
                bottom: 5.0,
              ),
              child: Align(
                alignment: Alignment.topCenter,
                child: Column(
                  children: <Widget>[
                    Text(
                      localizations.permission_photo_denied_title,
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10.0,
                            vertical: 10.0,
                          ),
                          child: Text(
                            localizations.permission_photo_denied_message(
                              APP_NAME,
                            ),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              height: 1.4,
                              fontSize: 15.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SmoothActionButtonsBar.single(
                      action: SmoothActionButton(
                        text: localizations.permission_photo_denied_button,
                        onPressed: () => _askPermission(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _askPermission(BuildContext context) {
    return Provider.of<PermissionListener>(
      context,
      listen: false,
    ).askPermission(onRationaleNotAvailable: () async {
      return showDialog(
          context: context,
          builder: (BuildContext context) {
            final AppLocalizations localizations = AppLocalizations.of(context);

            return SmoothAlertDialog(
              title:
                  localizations.permission_photo_denied_dialog_settings_title,
              body: Text(
                localizations.permission_photo_denied_dialog_settings_message,
                style: const TextStyle(
                  height: 1.6,
                ),
              ),
              negativeAction: SmoothActionButton(
                text: localizations
                    .permission_photo_denied_dialog_settings_button_cancel,
                onPressed: () => Navigator.of(context).pop(false),
                lines: 2,
              ),
              positiveAction: SmoothActionButton(
                text: localizations
                    .permission_photo_denied_dialog_settings_button_open,
                onPressed: () => Navigator.of(context).pop(true),
                lines: 2,
              ),
              actionsAxis: Axis.vertical,
            );
          });
    });
  }
}
