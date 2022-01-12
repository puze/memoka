import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class LicenseRoute extends StatelessWidget {
  const LicenseRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: loadFile(),
        builder: (context, snapshot) {
          if (snapshot.hasData == false) {
            return const CircularProgressIndicator();
          } else {
            return SafeArea(
                child: SingleChildScrollView(
                    child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Text(snapshot.data.toString()))));
          }
        },
      ),
    );
  }

  Future<String> loadFile() async {
    return await rootBundle.loadString("assets/license.txt");
  }
}
