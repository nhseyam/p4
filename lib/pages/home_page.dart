import 'package:ai_radio/model/radio.dart';
import 'package:ai_radio/utils/ai_util.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:velocity_x/velocity_x.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<MyRadio> radios;
  MyRadio _selectRadio;
  Color _selectColor;
  bool _isPlaing = false;

  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    fetchradios();
    _audioPlayer.onPlayerStateChanged.listen((event) {
      if (event == AudioPlayerState.PLAYING) {
        _isPlaing = true;
      } else {
        _isPlaing = false;
      }
      setState(() {});
    });
  }

  fetchradios() async {
    final radioJson = await rootBundle.loadString("assets/radio.json");
    radios = MyRadioList.fromJson(radioJson).radios;
    setState(() {});
  }

  _playMusic(String url) {
    _audioPlayer.play(url);
    _selectRadio = radios.firstWhere((element) => element.url == url);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(),
      body: Stack(
        children: [
          VxAnimatedBox()
              .size(context.screenWidth, context.screenHeight)
              .withGradient(LinearGradient(colors: [
                AIColors.primaryColor2,
                _selectColor ?? AIColors.primaryColor1,
              ], begin: Alignment.topLeft, end: Alignment.bottomRight))
              .make(),
          AppBar(
            title: "AI Radio".text.xl4.bold.white.make().shimmer(
                primaryColor: Vx.purple300, secondaryColor: Colors.white),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
          ).h(80).p16(),
          radios != null
              ? VxSwiper.builder(
                  aspectRatio: 1.0,
                  enlargeCenterPage: true,
                  itemCount: radios.length,
                  onPageChanged: (index) {
                    final colorHex = radios[index].color;
                    _selectColor = Color(int.parse(colorHex));
                    setState(() {});
                  },
                  itemBuilder: (context, index) {
                    final red = radios[index];
                    return VxBox(
                            child: ZStack([
                      Positioned(
                          top: 0,
                          right: 0,
                          child: VxBox(
                            child:
                                red.category.text.uppercase.white.make().px16(),
                          )
                              .height(40)
                              .black
                              .alignCenter
                              .withRounded(value: 10)
                              .make()),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: VStack(
                          [
                            red.name.text.xl3.white.bold.make(),
                            5.heightBox,
                            red.tagline.text.sm.white.semiBold.make()
                          ],
                          crossAlignment: CrossAxisAlignment.center,
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: [
                          Icon(
                            Icons.play_circle_outline_outlined,
                            color: Colors.white,
                          ),
                          10.heightBox,
                          "Double tap to Play".text.gray300.make()
                        ].vStack(),
                      )
                    ]))
                        .clip(Clip.antiAlias)
                        .bgImage(DecorationImage(
                            image: NetworkImage(red.image),
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(
                                Colors.black.withOpacity(0.3),
                                BlendMode.darken)))
                        .border(color: Colors.black45, width: 3)
                        .withRounded(value: 60)
                        .make()
                        .onInkDoubleTap(() {
                      _playMusic(red.url);
                    }).p12();
                  }).centered()
              : Center(
                  child: CircularProgressIndicator(),
                ),
          Align(
            alignment: Alignment.bottomCenter,
            child: [
              if (_isPlaing)
                "Playing - ${_selectRadio.name} FM".text.white.makeCentered(),
              Icon(
                _isPlaing
                    ? Icons.stop_circle_outlined
                    : Icons.play_arrow_outlined,
                color: Colors.white,
                size: 50,
              ).onInkTap(() {
                if (_isPlaing) {
                  _audioPlayer.stop();
                } else {
                  _playMusic(_selectRadio.url);
                }
              })
            ].vStack(),
          ).pOnly(bottom: context.percentHeight * 12)
        ],
        fit: StackFit.expand,
        clipBehavior: Clip.antiAlias,
      ),
    );
  }
}
