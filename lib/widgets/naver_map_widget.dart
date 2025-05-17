import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:something_app/services/naver_cafe_service.dart';
import 'error_dialog.dart';

class NaverMapWidget extends StatefulWidget {
  const NaverMapWidget({super.key});

  @override
  State<NaverMapWidget> createState() => _NaverMapWidgetState();
}

class _NaverMapWidgetState extends State<NaverMapWidget> {
  NaverMapController? mapController;
  Position? currentPosition;
  bool isLoading = true;
  String? errorMessage;
  bool isMapInitialized = false;
  double _zoom = 15;

  // 네이버 클라우드 콘솔에서 발급받은 값으로 입력
  final cafeService = NaverCafeService(
    clientId: dotenv.env['NAVER_CLIENT_ID'] ?? '',
    clientSecret: dotenv.env['NAVER_CLIENT_SECRET'] ?? '',
  );

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    try {
      await FlutterNaverMap().init(
        onAuthFailed: (error) {
          setState(() {
            errorMessage = '네이버 지도 인증에 실패했습니다: $error';
            isLoading = false;
          });
          showErrorDialog(context, '네이버 지도 인증에 실패했습니다: $error');
        },
      );
      setState(() {
        isMapInitialized = true;
      });
      _getCurrentLocation();
    } catch (e) {
      setState(() {
        errorMessage = '네이버 지도 초기화 중 오류가 발생했습니다: $e';
        isLoading = false;
      });
      if (!mounted) return;
      showErrorDialog(context, '네이버 지도 초기화 중 오류가 발생했습니다: $e');
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      // 위치 권한 확인
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        setState(() {
          errorMessage = '위치 권한이 거부되었습니다.';
          isLoading = false;
        });
        if (!mounted) return;
        showErrorDialog(context, '위치 권한이 거부되었습니다.');
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          errorMessage = '위치 권한이 영구적으로 거부되었습니다. 설정에서 권한을 허용해주세요.';
          isLoading = false;
        });
        if (!mounted) return;
        showErrorDialog(context, '위치 권한이 영구적으로 거부되었습니다. 설정에서 권한을 허용해주세요.');
        return;
      }

      // 현재 위치 가져오기
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        currentPosition = position;
        isLoading = false;
      });
      cafeService.fetchCafes(
          lat: currentPosition!.latitude, lng: currentPosition!.longitude);
    } catch (e) {
      setState(() {
        errorMessage = '위치를 가져오는 중 오류가 발생했습니다: $e';
        isLoading = false;
      });
      if (!mounted) return;
      showErrorDialog(context, '위치를 가져오는 중 오류가 발생했습니다: $e');
    }
  }

  void _zoomIn() {
    setState(() {
      _zoom += 1;
    });
    mapController?.updateCamera(
      NCameraUpdate.withParams(
        zoom: _zoom,
      ),
    );
  }

  void _zoomOut() {
    setState(() {
      _zoom -= 1;
    });
    mapController?.updateCamera(
      NCameraUpdate.withParams(
        zoom: _zoom,
      ),
    );
  }

  Future<void> requestLocationPermissionAgain(BuildContext context) async {
    LocationPermission permission = await Geolocator.requestPermission();

    if (!mounted) return;

    if (permission == LocationPermission.denied) {
      showErrorDialog(context, '위치 권한이 거부되었습니다.');
    } else if (permission == LocationPermission.deniedForever) {
      showErrorDialog(
        context,
        '위치 권한이 영구적으로 거부되었습니다. 설정에서 권한을 허용해주세요.',
      );
      await Geolocator.openLocationSettings();
    } else {
      // 권한 허용됨
      await Geolocator.openLocationSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _initializeMap,
                child: const Text('다시 시도'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                ),
              ),
              ElevatedButton(
                onPressed: () => requestLocationPermissionAgain(context),
                child: const Text('위치 권한 다시 요청'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (!isMapInitialized) {
      return const Center(
        child: Text('네이버 지도를 초기화하는 중입니다...'),
      );
    }

    if (currentPosition == null) {
      return const Center(
        child: Text('위치 정보를 가져올 수 없습니다.'),
      );
    }

    return Stack(
      children: [
        NaverMap(
          options: const NaverMapViewOptions(
            indoorEnable: true,
            locationButtonEnable: true,
            consumeSymbolTapEvents: false,
          ),
          onMapReady: (controller) {
            mapController = controller;
            controller.addOverlay(
              NMarker(
                id: 'current_location',
                position: NLatLng(
                  currentPosition!.latitude,
                  currentPosition!.longitude,
                ),
              ),
            );
            controller.updateCamera(
              NCameraUpdate.withParams(
                target: NLatLng(
                  currentPosition!.latitude,
                  currentPosition!.longitude,
                ),
                zoom: 15,
              ),
            );
          },
        ),
        Positioned(
          right: 16,
          bottom: 80,
          child: Column(
            children: [
              FloatingActionButton(
                backgroundColor: Colors.white,
                heroTag: 'zoomIn',
                onPressed: _zoomIn,
                mini: true,
                child: const Icon(
                  Icons.add,
                ),
              ),
              const SizedBox(height: 8),
              FloatingActionButton(
                backgroundColor: Colors.white,
                heroTag: 'zoomOut',
                onPressed: _zoomOut,
                mini: true,
                child: const Icon(
                  Icons.remove,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
