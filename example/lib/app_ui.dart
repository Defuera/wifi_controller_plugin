import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wifi_controller_plugin_example/app_bloc.dart';
import 'package:wifi_controller_plugin_example/app_model.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _bloc = MyAppBloc();

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
              if (state.isLoading)
                return CircularProgressIndicator();
              else
                return Container(
                  width: double.infinity,
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text('Is wifi enabled: ${state.isWifiEbabled}'),
                        Text('SSID: ${state.ssid}'),
                        RaisedButton(
                          child: Text('Reload'),
                          onPressed: () => _bloc.add(OnReloadState()),
                        ),
                        RaisedButton(
                          child: Text('Test socket connection'),
                          onPressed: () => _bloc.add(TestSocketConnection()),
                        ),
                      ],
                    ),
                  ),
                );
            },
          ),
        ),
      ),
    );
  }

}