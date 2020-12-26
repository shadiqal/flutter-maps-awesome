import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'models/market.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MapsScreen(),
    );
  }
}

class MapsScreen extends StatefulWidget {
  @override
  _MapsScreenState createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController mapController;
  LatLng center;
  BitmapDescriptor markerIcon;
  BitmapDescriptor warungIcon;
  String _mapStyle;
  PageController _pageController;
  ScrollController _scrollController;
  AutoCompleteTextField searchTextField;
  int pageIndex = 0;
  Set<Marker> _markers = {};
  void initState() {
    super.initState();
    getIcons();
    getMarketIcons();
    getCurrentLocation();
    _addMarketMarkers();
    rootBundle.loadString('assets/json_assets/map_style.txt').then((string) {
      _mapStyle = string;
    });
    _pageController = PageController(initialPage: 0, viewportFraction: 0.8);
  }

  void getCurrentLocation() async {
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((res) {
      setState(() {
        _markers.add(
          Marker(
            markerId: MarkerId(LatLng(res.latitude, res.longitude).toString()),
            position: LatLng(res.latitude, res.longitude),
            icon: markerIcon,
          ),
        );
        center = new LatLng(res.latitude, res.longitude);
      });
    });
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))
        .buffer
        .asUint8List();
  }

  GlobalKey key = new GlobalKey<AutoCompleteTextFieldState<Market>>();

  AutoCompleteTextField<Market> textField;

  Market selected;
  getIcons() async {
    var icon = await getBytesFromAsset("assets/images/user_marker.png", 85);

    setState(() {
      this.markerIcon = BitmapDescriptor.fromBytes(icon);
    });
  }

  getMarketIcons() async {
    var icon = await getBytesFromAsset("assets/images/laundry.png", 85);

    setState(() {
      this.warungIcon = BitmapDescriptor.fromBytes(icon);
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    mapController.setMapStyle(_mapStyle);
    setState(() {
      _controller.complete(controller);
    });
  }

  void _markersOnTap(int page, MarkerId markerId) {
    _pageController.animateToPage(page,
        duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
    mapController.showMarkerInfoWindow(markerId);
  }

  void _addMarketMarkers() async {
    setState(() {
      for (var i = 0; i < listMarket.length; i++) {
        _markers.add(
          Marker(
            markerId: MarkerId(i.toString()),
            position: listMarket[i].position,
            icon: warungIcon,
            consumeTapEvents: true,
            infoWindow: InfoWindow(title: listMarket[i].nama),
            onTap: () => _markersOnTap(i, MarkerId(i.toString())),
          ),
        );
      }
    });
  }

  moveCamera(int index, MarkerId markerId) {
    mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: listMarket[index].position,
      zoom: 18.0,
      bearing: 45.0,
      tilt: 45.0,
    )));
    mapController.showMarkerInfoWindow(markerId);
  }

  _centerCamera(LatLng position) {
    mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: position,
      zoom: 18.0,
      bearing: 45.0,
      tilt: 45.0,
    )));
  }

  _bouncingMarker(MarkerId markerId) {}

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: MediaQuery.of(context).size.width,
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          GoogleMap(
                            zoomControlsEnabled: false,
                            onMapCreated: _onMapCreated,
                            initialCameraPosition: CameraPosition(
                              target: center,
                              zoom: 18.0,
                            ),
                            markers: _markers,
                          ),
                          Positioned(
                            right: 10,
                            bottom: 300,
                            child: FloatingActionButton(
                              onPressed: () {
                                _centerCamera(center);
                              },
                              mini: true,
                              backgroundColor: Colors.white,
                              child: Icon(
                                Icons.my_location,
                                size: 25,
                                color: Color(0xFFFF7463),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 20,
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal: (10),
                                ),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.15),
                                        spreadRadius: 1,
                                        blurRadius: 1,
                                        offset: Offset(
                                          0,
                                          1,
                                        ), // changes position of shadow
                                      ),
                                    ]),
                                child: Container(
                                  child: AutoCompleteTextField<Market>(
                                    decoration: InputDecoration(
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        hintText: "Search market . . .",
                                        prefixIcon: Icon(
                                          Icons.search,
                                          color: Colors.grey,
                                        ),
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: (20), vertical: (16))),
                                    itemSubmitted: (item) =>
                                        setState(() => selected = item),
                                    key: key,
                                    suggestions: listMarket,
                                    itemBuilder: (context, suggestion) =>
                                        buildList(suggestion),
                                    itemFilter: (suggestion, input) =>
                                        suggestion.nama
                                            .toLowerCase()
                                            .startsWith(input.toLowerCase()),
                                    itemSorter: (a, b) {
                                      return a.nama.compareTo(b.nama);
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: (80),
                            width: MediaQuery.of(context).size.width,
                            child: Container(
                              width: double.infinity,
                              alignment: Alignment.center,
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                height: 130,
                                child: Flexible(
                                  child: PageView.builder(
                                      controller: _pageController,
                                      onPageChanged: (index) {
                                        moveCamera(
                                            index, MarkerId(index.toString()));
                                      },
                                      scrollDirection: Axis.horizontal,
                                      itemCount: listMarket.length,
                                      physics: BouncingScrollPhysics(),
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return _marketListCard(
                                          index,
                                          listMarket[index],
                                        );
                                      }),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Padding buildList(Market suggestion) {
    return new Padding(
        child: InkWell(
          onTap: () {},
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Image.asset(
                  suggestion.gambar,
                  width: 50,
                  height: 50,
                  fit: BoxFit.fill,
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(suggestion.nama),
                    Text(suggestion.alamat),
                  ],
                ),
              )
            ],
          ),
        ),
        padding: EdgeInsets.all(8.0));
  }

  _marketListCard(index, Market market) {
    return InkWell(
      child: Expanded(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: (15),
            vertical: (15),
          ),
          margin: EdgeInsets.only(
            right: (5),
            left: (5),
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.15),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Image.asset(
                  market.gambar,
                  height: 120,
                  width: 100,
                  fit: BoxFit.fill,
                ),
              ),
              SizedBox(
                width: 20,
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      market.nama,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: (1),
                    ),
                    Text(
                      market.alamat,
                      maxLines: 2,
                      style: TextStyle(
                        fontFamily: 'Muli',
                        fontSize: 12,
                        letterSpacing: 1.0,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(
                      height: (8),
                    ),
                    Row(
                      children: [
                        SvgPicture.asset("assets/images/Star_Icon.svg"),
                        const SizedBox(
                          width: 5,
                        ),
                        SvgPicture.asset("assets/images/Star_Icon.svg"),
                        const SizedBox(
                          width: 5,
                        ),
                        SvgPicture.asset("assets/images/Star_Icon.svg"),
                        const SizedBox(
                          width: 5,
                        ),
                        SvgPicture.asset("assets/images/Star_Icon.svg"),
                        const SizedBox(
                          width: 5,
                        ),
                        SvgPicture.asset("assets/images/Star_Icon.svg"),
                        const SizedBox(
                          width: 5,
                        ),
                        Text("12 Review",
                            style: TextStyle(
                              fontFamily: 'Muli',
                              fontSize: 12,
                              height: 1.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF7463),
                            ))
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
