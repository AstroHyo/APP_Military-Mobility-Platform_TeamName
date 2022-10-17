import 'package:flutter/material.dart';
import 'dart:async';
import 'package:military_mobility_platform_frontend/model/mobility.dart';
import 'package:military_mobility_platform_frontend/provider/auth.dart';
import 'package:military_mobility_platform_frontend/provider/accident.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_pin_picker/map_pin_picker.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:military_mobility_platform_frontend/service/toast.dart';
import 'package:military_mobility_platform_frontend/service/snackbar.dart';


class RecoveryTeamRequest extends StatelessWidget {
  const RecoveryTeamRequest({super.key});

  @override
  Widget build(BuildContext context) {
    const subtitle = '구난차량 요청';
    return Material( child:
    GestureDetector(
      child: 
        Container(
          width: 168,
          height: 149,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(1.0),
                spreadRadius: 0,
                blurRadius: 7,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.fromLTRB(0,25,0,20),
                child: Icon(Icons.accessibility_outlined, size: 60),
              ),
              Text(subtitle, style: TextStyle(fontSize: 16)),
            ]
          )
        ),
        onTap: () {
          Navigator.push(
            //context, MaterialPageRoute(builder: (childContext) => VehicleLocationCheck(mobility: mobility, context: context))
            context, MaterialPageRoute(builder: (childContext) => VehicleLocationCheck(context: context))
          );
        },
    )
    );
  }
}

class VehicleLocationCheck extends StatefulWidget {
  //const VehicleLocationCheck(this.mobility, {super.key, required this.context});

  const VehicleLocationCheck({super.key, required this.context});
  final BuildContext context;
  //final MobilityDTO mobility;

  @override
  State<VehicleLocationCheck> createState() => _VehicleLocationCheckState();
}

class _VehicleLocationCheckState extends State<VehicleLocationCheck> {
  final _controller = Completer<GoogleMapController>();
  MapPickerController mapPickerController = MapPickerController(); 
  //현재 위치 가져오는 함수 var gps = await getCurrentLocation(); //gps.latitude gps.longitude

  //첫 화면 시작 위치 설정
  CameraPosition cameraPosition = CameraPosition(
    target: LatLng(37.531918, 127.018598),
    zoom: 14.4746,
  );

  var textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AccidentProvider>(
      create: (_) => AccidentProvider(),
      builder: (context,child){
        return Scaffold(
          body: Stack(
            alignment: Alignment.topCenter,
            children: [
              MapPicker(
                // pass icon widget
                iconWidget: SvgPicture.asset(
                  "assets/location_icon.svg",
                  height: 60,
                ),
                //add map picker controller
                mapPickerController: mapPickerController,
                child: GoogleMap(
                  myLocationEnabled: true,
                  zoomControlsEnabled: false,
                  // hide location button
                  myLocationButtonEnabled: false,
                  mapType: MapType.normal,
                  // camera position
                  initialCameraPosition: cameraPosition,
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                  onCameraMoveStarted: () {
                    // notify map is moving
                    mapPickerController.mapMoving!();
                    textController.text = "위치 좌표 ${cameraPosition.target.latitude} ${cameraPosition.target.longitude}";
                  },
                  onCameraMove: (cameraPosition) {
                    this.cameraPosition = cameraPosition;
                  },
                  onCameraIdle: () async {
                    // notify map stopped moving
                    mapPickerController.mapFinishedMoving!();
                    //get address name from camera position
                    List<Placemark> placemarks = await placemarkFromCoordinates(
                      cameraPosition.target.latitude,
                      cameraPosition.target.longitude,
                    );
                    // update the ui with the address
                    textController.text =
                    '${placemarks.first.name}, ${placemarks.first.administrativeArea}, ${placemarks.first.country}';
                  },
                ),
              ),
              Container(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back_ios),
                      color: Colors.black,
                      iconSize: 15.0,
                      onPressed: () {Navigator.of(context).pop();},
                    ),
                  ),
              ),
              Positioned(
                top: MediaQuery.of(context).viewPadding.top + 20,
                width: MediaQuery.of(context).size.width - 50,
                height: 50,
                child: TextFormField(
                  maxLines: 3,
                  textAlign: TextAlign.center,
                  readOnly: true,
                  decoration: const InputDecoration(
                      contentPadding: EdgeInsets.zero, border: InputBorder.none),
                  controller: textController,
                ),
              ),
              Positioned(
                bottom: 24,
                left: 24,
                right: 24,
                child: SizedBox(
                  height: 50,
                  child: TextButton(
                    child: const Text(
                      "다음",
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.normal,
                        color: Colors.white,
                        fontSize: 19,
                        // height: 19/19,
                      ),
                    ),
                    onPressed: () {
                      context.read<AccidentProvider>().recoveryTeamRequestLocationSet( 
                          "Location latitude : ${cameraPosition.target.latitude} , longitude : ${cameraPosition.target.longitude}");
                      print("Address: ${textController.text}");
                      Navigator.push(
                        //context, MaterialPageRoute(builder: (childContext) => RecoveryTeamRequestContent(mobility: widget.mobility, context: context, latitude: cameraPosition.target.latitude, longitude: cameraPosition.target.longitude))
                        context, MaterialPageRoute(builder: (childContext) => RecoveryTeamRequestContent(context: context, latitude: cameraPosition.target.latitude, longitude: cameraPosition.target.longitude))
                      );
                    },
                    style: ButtonStyle(
                      backgroundColor:
                      MaterialStateProperty.all<Color>(const Color(0xFF6200EE)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      }
    );
  }
}


class RecoveryTeamRequestContent extends StatefulWidget {
  //const RecoveryTeamRequestContent(this.mobility, {super.key, required this.context, required this.latitude, required this.longitude});
  const RecoveryTeamRequestContent({super.key, required this.context, required this.latitude, required this.longitude});
  final BuildContext context;
  //final MobilityDTO mobility;
  final latitude;
  final longitude;

  @override
  State<RecoveryTeamRequestContent> createState() => _RecoveryTeamRequestContentState();
}

class _RecoveryTeamRequestContentState extends State<RecoveryTeamRequestContent> {
 
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AccidentProvider>(
      create: (_) => AccidentProvider(),
      builder: (context,child){
        return Scaffold(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios),
                color: Colors.black,
                iconSize: 15.0,
                onPressed: () {Navigator.of(context).pop();},
              ),
              const Padding(
                  padding: EdgeInsets.only(bottom: 10.0)
              ),
              const Padding(
                padding: EdgeInsets.only(left: 10.0, bottom: 10.0),
                child: Text('구난 차량 요청 내용', style: TextStyle(fontSize: 22.5, fontWeight: FontWeight.bold)),
              ),
              const Padding(
                  padding: EdgeInsets.only(bottom: 10.0)
              ),
              const Padding(
                padding: EdgeInsets.only(left: 10.0, bottom: 20.0),
                child: Text('긴급출동 요청내용을 입력해주세요', style: TextStyle(fontSize: 18.0,)),
              ),
              Padding(
                padding: EdgeInsets.only(left: 30.0),
                child:Container( 
                  height: 235,
                  width: 340,
                  decoration: BoxDecoration(border: Border.all(), borderRadius: BorderRadius.circular(20),),  
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 20.0),
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 15.0, right: 30.0),
                            child: Text('차량번호', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                          ),
                          Flexible(
                            child: TextField(
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: "12하8839",
                              ),
                            )
                          ),
                        ]
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 15.0, right: 30.0),
                            child: Text('차량위치', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                          ),
                          Flexible(
                            child: TextField(
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "서울특별시 동작구 OOO",
                              ),
                            )
                          ),
                        ]
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 15.0, right: 14.0),
                            child: Text('요청서비스', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                          ),
                          Flexible(
                            child: TextField(
                              onChanged: (val) { 
                                context.read<AccidentProvider>().recoveryTeamRequestServiceSet(val);
                              },
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: "타이어 펑크로 인한 교체",
                              ),
                            )
                          ),
                        ]
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 15.0, right: 30.0),
                            child: Text('특이사항', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                          ),
                          Flexible(
                            child: TextField(
                              onChanged: (val) { 
                                context.read<AccidentProvider>().recoveryTeamRequestNoteSet(val);
                              },
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: "기타 특이사항을 입력해주세요.",
                              ),
                            )
                          ),
                        ]
                      ),
                    ]
                  )
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: ElevatedButton(
                  onPressed: () { 
                    _postRecoveryTeam(context);
                  },
                  child: const Text('확인', style: TextStyle(fontSize: 18.0)),
                ),
              ),
            ],
          )
        );
      }
    );
  }

  void _postRecoveryTeam(BuildContext context) {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final accidentProvider =
          Provider.of<AccidentProvider>(context, listen: false);
      accidentProvider.recoveryTeamRequestLocationSet("Location latitude : ${widget.latitude} , longitude : ${widget.longitude}");
      //accidentProvider.postRecoveryTeam(authProvider.authenticatedClient!, mobility);
      int count = 0;
      Navigator.popUntil(context, (route) {
        return count++ == 2;
      });
      Snackbar(context).showSuccess('구난 차량 요청이 완료되었습니다.');
    } catch (exception) {
      print(exception);
      Toast.showFailToast('구난 차량 요청에 실패했습니다.');
    }
  }
}