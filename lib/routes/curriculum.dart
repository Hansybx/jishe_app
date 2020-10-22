import 'dart:ui';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_app/common/apis.dart';
import 'package:flutter_app/common/spFile.dart';
import 'package:flutter_app/entity/subject.dart';


//课表界面
class Curriculum extends StatefulWidget {
  @override
  _CurriculumState createState() => _CurriculumState();
}

class _CurriculumState extends State<Curriculum> {
  //学生教务系统的用户名和密码
  String _uid, _password;

  //存放学年
  List<String> _schoolYears;

  //当前学年
  String yearNow;

  //当前周次
  String weekNow;

  //当前月份
  String monthNow;

  //负责网络请求
  Dio _dio = new Dio();

  //风格选项
  int style=0;

  //存放课程信息
  List<List<Subject>> subjectList;

  //颜色风格合集
  List<List<Color>> colorStyleList=new List();

  //字体风格
  List<Color> fontColors=[
    Color(0xE52e383f),
    Colors.white
  ];

  //风格
  List<String> styles=[
    "风格1",
    "风格2"
  ];

  //课程颜色候选表
  //配色方案一
  List<Color> colorArrays=[
    Color(0xCCffcfdf),
    Color(0xCCfefdca),
    Color(0xCCe0f9b5),
    Color(0xCCa5dee5),
    Color(0xCCc8e7ed),
    Color(0xCCbfcfff),
    Color(0xCCf9a828),
    Color(0xCCececeb),
    Color(0xCCdb6400),
    Color(0xCCfa7f72),
    Color(0xCCedc988),
    Color(0xCCb83b5e),
    Color(0xCC07617d),
  ];


  //配色方案二
  List<Color> colorArrays2 = [
    Color(0xffccabd8),
    Color(0xff86e3ce),
    Color(0xff97d1c0),
    Color(0xffd76350),
    Color(0xff7fdb93),
    Color(0xff92b6c7),
    Color(0xffeee8aa),
    Color(0xff33CC33), // 绿
    Color(0xff3399ff), // 蓝
    Color(0xffff6666), // 红-粉
    Color(0xffCC9933), // 褐
    Color(0xff99CCFF), // 青
    Color(0xffb46a7f),
  ];


  //周次表
  List<String> _zcArray = [
    '第1周',
    '第2周',
    '第3周',
    '第4周',
    '第5周',
    '第6周',
    '第7周',
    '第8周',
    '第9周',
    '第10周',
    '第11周',
    '第12周',
    '第13周',
    '第14周',
    '第15周',
    '第16周',
    '第17周',
    '第18周',
    '第19周',
    '第20周'
  ];

  //周几
  List<String> dayOfWeek = ["一", "二", "三", "四", "五", "六", "日"];

  //长山课程时间
  List classTimeOfChangShan = [
    '''
    第一
    大节
    8:30
    ~
    10:05''',
    '''
    第二
    大节
    10:25
    ~
    12:00''',
    '''
    第三
    大节
    13:30
    ~
    15:05''',
    '''
    第四
    大节
    15:25
    ~
    17:00''',
    '''
    第五
    大节
    18:30
    ~
    20:05''',
  ];

  //梦溪课程时间
  List classTimeOfMengXi = [
    '''
    第一
    大节
    8:00
    ~
    9:40''',
    '''
    第二
    大节
    10:00
    ~
    11:40''',
    '''
    第三
    大节
    14:00
    ~
    15:40''',
    '''
    第四
    大节
    15:50
    ~
    17:30''',
    '''
    第五
    大节
    19:00
    ~
    20:40''',
  ];

  //星期英文
  Map<String, int> day7 = {
    'monday': 1,
    'tuesday': 2,
    'wednesday': 3,
    'thursday': 4,
    'friday': 5,
    'saturday': 6,
    'sunday': 7
  };

  //初始化
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //获得学生用户和密码
    _uid = SpUtil.getString(LocalShare.STU_ID);
    _password = SpUtil.getString(LocalShare.STU_PASSWD);
    //该方法用于获得放在顶部学期选择框里的学期,获得从大一到本学期的学年[2020-2021-1, 2019-2020-2, 2019-2020-1, 2018-2019-2, 2018-2019-1]
    _schoolYears = SpUtil.getStringList(LocalShare.ALL_YEAR);
    //获得当前学年
    yearNow = _schoolYears[0];
    //获得当前周次
    weekNow = _zcArray[SpUtil.getInt(LocalShare.SERVER_WEEK) +
        SpUtil.getInt(LocalShare.WEEK_ADVANCE, defValue: 0)];
    monthNow = DateTime.now().month.toString() + "月";
    //加载风格
    colorStyleList.add(colorArrays);
    colorStyleList.add(colorArrays2);
    //获得课表信息
    _getCurriculum();
  }

  //课表主体控件
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //课表界面顶部
      appBar: AppBar(
        backgroundColor: Colors.white,
        //放两个下拉选择,分别是学年和周次
        title: Row(
          //水平垂直都居中
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          //放两个下拉选择
          children: <Widget>[
            //学年下拉
            DropdownButton(
              value: yearNow,
              //选中的改变了
              onChanged: (value) {
                setState(() {
                  yearNow = value;
                  refresh();
                });
              },
              items: _schoolYears.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(
              width: 10,
            ),
            Text('|'),
            SizedBox(
              width: 20,
            ),
            //周次
            DropdownButton(
              isDense: true,
              value: weekNow,
              onChanged: (newValue) {
                setState(() {
                  weekNow = newValue;
                });
              },
              items: _zcArray.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(
              width: 10,
            ),
            Text('|'),
            SizedBox(
              width: 20,
            ),
            //风格
            DropdownButton(
              isDense: true,
              value: styles[style],
              onChanged: (newValue) {
                setState(() {
                  style = styles.indexOf(newValue);
                });
              },
              items: styles.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            )
          ],
        ),
      ),
      //课表界面身体
      //下拉刷新组件
      body: RefreshIndicator(
        child: Container(
          //背景图片
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage('https://patchwiki.biligame.com/images/blhx/1/16/3qfj1l3mnvn4urn78jln4875cmsclu9.png'),
              fit: BoxFit.cover,
            )
          ),
          //使用GridView来布置课表网格
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: //第一行表头
                    GridView(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    childAspectRatio: 1,
                    //每行子元素个数
                    crossAxisCount: 8,
                  ),
                  children: classHeader(),
                ),
              ),
              Expanded(
                flex: 20,
                child: //内容
                Column(
                  children: <Widget>[
                    Expanded(
                      flex: 20,
                      child: GridView(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            childAspectRatio: 0.45,
                            //每行子元素个数
                            crossAxisCount: 8,
                          ),
                          children: classInfo()
                      ),
                    ),
                    getOtherInfo()
                  ],
                )
              ),
            ],
          ),
        ),
        onRefresh: refresh,
      ),
    );
  }

  //下拉刷新函数
  Future<void> refresh() async{
    //把课表设置为没有加载
    SpUtil.putBool(LocalShare.IS_OPEN_KB, false);
    //从头获取数据
    _getCurriculum();
  }

  //卡片组装区*******************************************************************
  //获得第一行
  List<Card> classHeader() {
    List<Card> classesHeader = [];
    for (int a = 0; a < 8; a++) {
      classesHeader.add(getHeader(a));
    }
    return classesHeader;
  }

  //存放所有课表的卡片组件
  List<Widget> classInfo() {
    List<Widget> classes = [];
    for (int a = 8; a < 48; a++) {
      classes.add(getClass(a));
    }
    return classes;
  }

  //对课表内容列表进行组装
  Card getClass(int index) {
    //绘制第一行
    // if(index<8)
    //   {
    //     return getHeader(index);
    //   }
    //绘制第一列
    if (index % 8 == 0) {
      return getColumnHead((index/8).floor()-1);
    }
    //绘制课程
    else {
      return getClassInfo((index / 8).floor(), index % 8, weekNow);
    }
  }

  //卡片绘画区*******************************************************************
  //绘制第一行的表头,该方法用于classHeader方法中
  Card getHeader(int index) {
    if (index == 0) {
      return Card(
          color: Colors.white,
          margin: EdgeInsets.all(0),
          child: Center(
            child: Text(monthNow),
          ));
    } else {
      //把今天对应的星期表头设置为红色
      if (DateTime.now().weekday == index) {
        return Card(
          color: Color(0xe5d54062),
          margin: EdgeInsets.all(0),
          child: Center(
            child: Text(dayOfWeek[index - 1]+"\n"+DateTime.now().day.toString()+"日",textAlign: TextAlign.center,),
          ),
        );
      } else {
        return Card(
          color: Colors.white,
          margin: EdgeInsets.all(0),
          child: Center(
            child: Text(
              dayOfWeek[index - 1]+"\n"+
                  DateTime.now().add(new Duration(days: (index-DateTime.now().weekday))).day.toString()+"日",
              textAlign: TextAlign.center,
            ),
          ),
        );
      }
    }
  }

  //返回第一列的列头,里面是每节课的时间,该方法用于getClass方法中
  Card getColumnHead(int index) {
    if(SpUtil.getString(LocalShare.SCHOOLAREA)=="长山")
      {
        return Card(
            color: Colors.white,//卡片颜色
            margin: EdgeInsets.all(0),//卡片边框
            //我调了贼久才把文字调成在卡片中间显示,如果你将来看到了这个,希望你可以不需要重新调,太费时间了
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                classTimeOfChangShan[index],//显示的内容
                textAlign: TextAlign.center,
              ),
            )
        );
      }
    else
      {
        return Card(
            color: Colors.white,//卡片颜色
            margin: EdgeInsets.all(0),//卡片边框
            //我调了贼久才把文字调成在卡片中间显示,如果你将来看到了这个,希望你可以不需要重新调,太费时间了
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                classTimeOfMengXi[index],//显示的内容
                textAlign: TextAlign.center,
              ),
            )
        );
      }

  }

  //获得课程的信息,该方法用于getClass方法中
  Card getClassInfo(int classNum, int weekDay, String weekNow) {
    //课程信息，用来显示
    String info;
    //该课程的颜色
    Color color;
    //课程信息已经或得到了
    if (subjectList != null) {
      //遍历课程
      subjectList[classNum - 1].forEach((element) {
        //如果该课程在这个周次且在这个星期
        if (element.hasThisClass(weekNow.substring(1, weekNow.length - 1)) &&
            element.weekNum == weekDay) {
          //设置信息和颜色
          info = element.subjectName + "\n" + element.place;
          color = colorStyleList[style][element.color];
        }
      });
    }
    //生成卡片
    if (info != null) {
      return Card(
        color: color,
        margin: EdgeInsets.all(2),
        child: Center(
          child: Text(
            info,
            strutStyle: StrutStyle(leading: 0.3), //文字行间距
            style: TextStyle(
              color: fontColors[style], //课程信息字体颜色
            ),
          ),
        ),
        // elevation: 10,
      );
    } else {
      return Card(
        color: Colors.transparent,
        shadowColor: Colors.transparent,
      );
    }
  }

  //获得其他课程信息,放在最下面
  Container getOtherInfo()
  {
    return Container(
      color: Color(0xCCFFFFFF),
      child: Text("其他课程信息:"+SpUtil.getString(LocalShare.CLASS_MORE)),
    );

  }

  //发送请求,获得课表数据，异步方法
  Future<void> _getCurriculum() async {
    //请求的传给后台的数据
    FormData formData = FormData.fromMap({
      "username": _uid,
      "password": _password,
      "semester": yearNow,
    });

    if(SpUtil.getBool(LocalShare.IS_OPEN_KB))
      {
        //获得存储在本地的课表数据
        var res=jsonDecode(SpUtil.getString(LocalShare.CLASS_SAVE).toString());
        //传给解析方法
        dealInfo(res["info"]);
      }
    else
      {
        //获得返回结果
        await _dio.post(Constant.KB, data: formData).then((res) {
          //如果返回成功了
          if (res.statusCode == 200) {
            if (res.data["code"] == 200) {
              //处理数据
              dealInfo(res.data["info"]);
              //保存课表到本地
              SpUtil.putString(LocalShare.CLASS_SAVE, res.toString());
              SpUtil.putBool(LocalShare.IS_OPEN_KB, true);
            }
          }
        });
      }
    //刷新课表状态
    setState(() {
      classInfo();
    });

  }

  //对返回数据中的info里的课表信息进行解析并赋值给subjectList
  void dealInfo(var info)
  {
    List curriculumList = info;
    //添加更多信息到本地
    SpUtil.putString(LocalShare.CLASS_MORE,
        curriculumList[curriculumList.length - 1]["more"]);
    //创建一个列表,存放的是按第几节来分的科目,比如第一大节的全部放在列表的第一个里
    subjectList = new List(curriculumList.length - 1);
    //取出课程信息并放入subjectList
    for (int a = 0; a < subjectList.length; a++) {
      //初始化每个最里面的List
      subjectList[a] = new List();
      var m = curriculumList[a];
      Map<String, String> m1 = Map.from(m);
      //key是星期,value是课程的详细信息
      m1.forEach((key, value) {
        //分割,如果这个位置有不止一节课
        List subjectInfo = value.split("@---------------------");
        //利用信息创建类,element是单节详细信息,key是星期的英文
        subjectInfo.forEach((element) {
          subjectList[a].add(Subject.byInfo(element, key));
        });
      });
    }
    //为课程设置颜色
    setColor();
  }

  //为课程设置唯一颜色
  void setColor() {
    //一个用来存储课程号的Set,同时利用map的key唯一性可以为一门课设置一个颜色
    Map<String, int> classNum = new Map();
    //记录不同的课程数量
    int a = 0;
    //已经获得课程数据
    if (subjectList != null) {
      subjectList.forEach((element) {
        element.forEach((element) {
          //如果该课程已设置颜色
          if (classNum.containsKey(element.subjectNum)) {
            element.color = classNum[element.subjectNum];
          }
          //该课程没有设置颜色
          else {
            element.color = a;
            classNum.putIfAbsent(element.subjectNum, () => a);
            a++;
          }
        });
      });
    }
  }
}


