import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/common/spFile.dart';
import 'package:flutter_app/generated/l10n.dart';
import 'package:flutter_app/routes/homePage/home.dart';
import 'package:flutter_app/routes/kb.dart';
import 'package:flutter_app/routes/myPage/me.dart';
import 'package:flutter_app/widgets/iconFont.dart';

import 'curriculum.dart';

class Tabs extends StatefulWidget {
  @override
  _TabsState createState() => _TabsState();
}

class _TabsState extends State<Tabs> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TabController controller;
  List<Widget> kbs=[SchedulePage(),Curriculum()];
  int kbIndex=0;
  List<Widget> _pageList;

  Map kbIndexMap={
    "韩氏风格":0,
    "邓氏风格":1
  };

  @override
  void initState() {
    super.initState();
    _pageList= [kbPage(), HomePage(), MyPage()];
    controller = new TabController(length: 3, vsync: this);
  }

  Widget kbPage()
  {
    return IndexedStack(
      index:  kbIndexMap[SpUtil.getString(LocalShare.KB_STYLE)],
      children: <Widget>[
        SchedulePage(),
        Curriculum()
      ],
    );
  }

  // void onTabTapped(int index) {
  //   setState(() {
  //     kbIndex = index;
  //   });
  // }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      body: new TabBarView(controller: controller, children: _pageList),
      bottomNavigationBar: new Material(
        color: Colors.white,
        child: new TabBar(
          controller: controller,
          labelColor: Colors.blueAccent,
          unselectedLabelColor: Colors.black26,
          tabs: <Widget>[
            new Tab(
              text: S.of(context).schedule,
              icon: new Icon(Icons.map),
            ),
            new Tab(
              text: S.of(context).discover,
              icon: new Icon(IconFont.icon_LC_icon_light_line),
            ),
            new Tab(
              text: S.of(context).me,
              icon: new Icon(Icons.directions_run),
            ),
          ],
        ),
      ),
    );
  }
}
