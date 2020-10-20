import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wifi_controller_plugin_example/model.dart';
import 'package:wifi_controller_plugin_example/my_app_bloc.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _bloc = MyAppBloc();

  // Platform messages are asynchronous, so we initialize in an async method.
  // Future<void> initPlatformState() async {
  //   String platformVersion;
  //   // Platform messages may fail, so we use a try/catch PlatformException.
  //   try {
  //     platformVersion = await WifiControllerPlugin.platformVersion;
  //   } on PlatformException {
  //     platformVersion = 'Failed to get platform version.';
  //   }
  //
  //   // If the widget was removed from the tree while the asynchronous platform
  //   // message was in flight, we want to discard the reply rather than calling
  //   // setState to update our non-existent appearance.
  //   if (!mounted) return;
  //
  //   setState(() {
  //     _platformVersion = platformVersion;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: BlocProvider(
          create: (context) => _bloc,
          child: BlocBuilder<MyAppBloc, MyAppState>(
            cubit: _bloc,
            builder: (context, state) {
              if (state.showEnableWifiPage) {
                return EnableWifiPage(state.requestManualEnabling);
              } else if (state.connectToHomeNetwork) {
                return ConnectToHomeNetworkPage();
              } else if (state.provideWifiPassword) {
                return EnterWifiPasswordPage(state.ssid);
              } else if (state.setupHubWifi) {
                return SetupHubPage();
              }

              // if (state.error != null) {
              //   return getErrorWidget(state.error);
              // }
              //
              // return Center(
              //   child: Column(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     crossAxisAlignment: CrossAxisAlignment.center,
              //     children: [
              //       Text("Please connect your phone to your home wifi"),
              //       RaisedButton(
              //         onPressed: () => _bloc.add(SetupHubWifi()),
              //         child: Text("I'm connected to my home wifi"),
              //       ),
              //       RaisedButton(
              //         onPressed: () {},
              //         child: Text("Switch Wifi"), //todo
              //       ),
              //     ],
              //   ),
              // );
            },
          ),
        ),
      ),
    );
  }

  Widget getErrorWidget(String error) {
    switch (error) {
      case ERROR_WIFI_NOT_ENABLED:
        return Column(
          children: [
            Text("App was not able to enable WiFi, pls enable manually and then press proceed button"),
            FlatButton(onPressed: () => _bloc.add(Init()), child: Text("Proceed"))
          ],
        );
      default:
        return Text("Unknowon error. Kapoot");
    }
  }
}

abstract class OnboardingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          gradient: LinearGradient(
              stops: [0.1, 0.2, 0.8, 0.9],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Color(0xff73EE8C), Color(0xff292929), Color(0xff292929), Color(0xff4696EC)])),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: buildContent(context, BlocProvider.of<MyAppBloc>(context)),
      ),
    );
  }

  buildContent(BuildContext OnboardingPage, MyAppBloc bloc);
}

class EnableWifiPage extends OnboardingPage {
  final bool manualInputRequired;

  EnableWifiPage(this.manualInputRequired);

  @override
  Widget buildContent(BuildContext context, bloc) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Please enable Wifi",
          style: TextStyle(color: Colors.white),
        ),
        !manualInputRequired
            ? RaisedButton(
                onPressed: () => bloc.add(EnableWifi()),
                child: Text("Enable Wifi"),
              )
            : RaisedButton(
                onPressed: () => bloc.add(Init()),
                child: Text("I did enable Wifi in settings"),
              )
      ],
    );
  }
}

class ConnectToHomeNetworkPage extends OnboardingPage {
  @override
  Widget buildContent(BuildContext context, bloc) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Please connect to home network, same network we will connect LiveLeds hub to",
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
        RaisedButton(
          onPressed: () => bloc.add(RetrieveHomeNetworkSsid()),
          child: Text("I'm on my home network"),
        )
      ],
    );
  }
}

class EnterWifiPasswordPage extends OnboardingPage {
  final String ssid;
  final _passwordInputController = TextEditingController();
  EnterWifiPasswordPage(this.ssid);

  @override
  Widget buildContent(BuildContext context, bloc) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Please enter password for $ssid, it will be shared with LiveLeds hub",
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
        TextField(
          controller: _passwordInputController,
          cursorColor: Colors.white,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Password",
            hintStyle: TextStyle(color: Colors.white),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          ),
        ),
        RaisedButton(
          onPressed: () => bloc.add(ConnectToHub(ssid, _passwordInputController.text)),
          child: Text("Proceed"),
        )
      ],
    );
  }
}

class SetupHubPage extends OnboardingPage {
  @override
  Widget buildContent(BuildContext context, bloc) {
    return Column(
      children: [
        Text("SetupHubPage"),
        RaisedButton(
          // onPressed: () => bloc.add(EnableWifi()),
          child: Text("Enable Wifi"),
        )
      ],
    );
  }
}
