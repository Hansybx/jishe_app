import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/common/apis.dart';
import 'package:flutter_app/common/spFile.dart';
import 'package:flutter_app/generated/l10n.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:flutter_xupdate/flutter_xupdate.dart';


//课表界面
class Curriculum extends StatefulWidget {
  @override
  _CurriculumState createState() => _CurriculumState();
}


class _CurriculumState extends State<Curriculum> {
  //学生教务系统的用户名和密码
  String _uid,_password;
  //存放学年
  List<String> _schoolYears;
  //当前学年
  String yearNow;
  //当前周次
  String weekNow;
  //当前月份
  String monthNow;
  //负责网络请求
  Dio _dio=new Dio();
  //存放课程信息
  List<List<Subject>> subjectList;

  //课程颜色候选表
  List colorArrays = [
    0xE5ccabd8,
    0xE597d1c0,
    0xE5d76350,
    0xE57fdb93,
    0xE592b6c7,
    0xE5eee8aa,
    0xE5b46a7f,
    0xE533CC33, // 绿
    0xE53399ff, // 蓝
    0xE5ff6666, // 红-粉
    0xE5CC9933, // 褐
    0xE599CCFF, // 青
    0xE586e3ce,//浅青色
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
  List<String> dayOfWeek=[
    "一","二","三","四","五","六","日"
  ];

  //长山课程时间
  List classTimeOfChangShan = [
    '''第一大节 
    8:30
    ~
    10:05''',
    '''第二大节
    10:25
    ~
    12:00''',
    '''第三大节
    13:30
    ~
    15:05''',
    '''第四大节
    15:25
    ~
    17:00''',
    '''第五大节
    18:30
    ~
    20:05''',
  ];

  //梦溪课程时间
  List classTimeOfMengXi = [
    '''第一大节 8:00 
     9:40''',
    '''第二大节10:00
    11:40''',
    '''第三大节14:00
    15:40''',
    '''第四大节15:50
    17:30''',
    '''第五大节19:00
    20:40''',
  ];

  //星期英文
  Map<String,int> day7 = {
    'monday':1,
    'tuesday':2,
    'wednesday':3,
    'thursday':4,
    'friday':5,
    'saturday':6,
    'sunday':7
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
    _schoolYears=SpUtil.getStringList(LocalShare.ALL_YEAR);
    //获得当前学年
    yearNow=_schoolYears[0];
    //获得当前周次
    weekNow = _zcArray[SpUtil.getInt(LocalShare.SERVER_WEEK)+SpUtil.getInt(LocalShare.WEEK_ADVANCE,defValue: 0)];
    monthNow=DateTime.now().month.toString()+"月";
    //获得课表信息
    _getCurriculum();
  }


  //课表主体
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
              onChanged: (value){
                setState(() {
                  yearNow=value;
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
                  weekNow=newValue;
                });
              },
              items: _zcArray.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
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
                flex: 1,
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
                flex: 10,
                child: //内容
                GridView(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    childAspectRatio: 0.5,
                    //每行子元素个数
                    crossAxisCount: 8,
                  ),
                  children: classinfo(),
                ),
              ),

            ],
          ),
        ),
        onRefresh: refresh,
      ),

    );
  }

  //下拉刷新函数
  Future<void> refresh()
  {
    return null;
  }

  //获得第一行
  List<Card> classHeader()
  {
    List<Card> classesHeader=[];
    for(int a=0;a<8;a++)
      {
        classesHeader.add(getHeader(a));
      }
    return classesHeader;
  }

  //存放所有课表的卡片组件
  List<Card> classinfo()
  {
    List<Card> classes=[];
    for(int a=8;a<48;a++)
    {
      classes.add(getClass(a));
    }
    return classes;
  }

  //对课表内容列表进行绘画
  Card getClass(int index)
  {
    //绘制第一行
    // if(index<8)
    //   {
    //     return getHeader(index);
    //   }
    //绘制第一列
    if(index%8==0)
      {
        return getColumnHead(index%8);
      }
    //绘制课程
    else
      {
        return getClassinfo((index/8).floor(), index%8,weekNow);
      }

  }

  //绘制第一行的表头,该方法用于classHeader方法中
  Card getHeader(int index)
  {
    if(index==0)
      {
        return Card(
          color: Colors.white,
          child: Center(child:Text(monthNow),)
        );
      }
    else
      {
        return Card(
          color: Colors.white,
          child: Center(child: Text(dayOfWeek[index-1]),),
        );
      }
  }

  //返回第一列的列头,里面是每节课的时间,该方法用于getClass方法中
  Card getColumnHead(int index)
  {
    return Card(
      color: Colors.white,
      child: Container(
        child: Center(
          child: Text(classTimeOfChangShan[index],textAlign: TextAlign.center,),
        ),
      )

    );
  }

  //获得课程的信息,该方法用于getClass方法中
  Card getClassinfo(int classNum,int weekDay,String weekNow)
  {
    //课程信息，用来显示
    String info;
    //该课程的颜色
    Color color;
    //课程信息已经或得到了
    if(subjectList!=null)
      {
        //遍历课程
        subjectList[classNum-1].forEach((element) {
          //如果该课程在这个周次且在这个星期
          if(element.hasThisClass(weekNow.substring(1,weekNow.length-1))&&element.weekNum==weekDay)
          {
            //设置信息和颜色
            info=element.subjectName+" "+element.place;
            color=Color(colorArrays[element.color]);
          }
        });
      }
    //生成卡片
    if(info!=null)
      {
        return Card(
          color: color,
          child: Center(child:Text(info),)
          // elevation: 10,
        );
      }
    else
      {
        return Card(
          color: Colors.transparent,
          shadowColor: Colors.transparent,
        );
      }

  }

  //发送请求,获得课表数据，异步方法
  Future<void> _getCurriculum() async
  {
    //请求的传给后台的数据
    FormData formData = FormData.fromMap({
      "username": _uid,
      "password": _password,
      "semester": _schoolYears[0],
    });

    //获得返回结果
    await _dio.post(Constant.KB, data: formData).then((res){
      //如果返回成功了
      if(res.statusCode==200)
      {
        if(res.data["code"]==200)
        {
          List curriculumList=res.data["info"];
          //添加更多信息到本地
          SpUtil.putString(LocalShare.CLASS_MORE, curriculumList[curriculumList.length-1]["more"]);
          //创建一个列表,存放的是按第几节来分的科目,比如第一大节的全部放在列表的第一个里
          subjectList=new List(curriculumList.length-1);
          //记录课程数量，也给课程设置颜色
          int classNum=0;
          for(int a=0;a<subjectList.length;a++)
          {
            //初始化每个最里面的List
            subjectList[a]=new List();
            var m=curriculumList[a];
            Map<String,String> m1=Map.from(m);
            //key是星期,value是课程的详细信息
            m1.forEach((key, value) {
              //分割,如果这个位置有不止一节课
              List subjectInfo=value.split("@---------------------");
              //利用信息创建类,element是单节详细信息,key是星期的英文
              subjectInfo.forEach((element) {
                subjectList[a].add(Subject(element, key));
              });
            });
          }
          setColor();
          //保存课表到本地
          //SpUtil.putObjectList(LocalShare.HANDLED_KB, subjectList);
        }
      }
      setState(() {
        classinfo();
      });
    });

  }

  //为课程设置唯一颜色
  void setColor()
  {
    //一个用来存储课程号的Set,同时利用map的key唯一性可以为一门课设置一个颜色
    Map<String,int> classNum=new Map();
    //记录不同的课程数量
    int a=0;
    //已经获得课程数据
    if(subjectList!=null)
      {
        subjectList.forEach((element) {
          element.forEach((element) {
            //如果该课程已设置颜色
            if(classNum.containsKey(element.subjectNum))
              {
                element.color=classNum[element.subjectNum];
              }
            //该课程没有设置颜色
            else
              {
                element.color=a;
                classNum.putIfAbsent(element.subjectNum, () => a);
                a++;
              }
          });
        });
      }
  }
}

//科目类,就是一门课程
class Subject{
  //原始信息,返回的结果
  String message;
  //课程号
  String subjectNum;
  //课程名
  String subjectName;
  //任课老师名字
  String teacherName;
  //上课时间,比如说是第几周
  Set time=Set();
  //上课地点
  String place;
  //星期几上的课
  int weekNum;
  //科目颜色,这里是颜色数组里的index
  int color;
  //星期英文
  Map<String,int> day7 = {
    'monday':1,
    'tuesday':2,
    'wednesday':3,
    'thursday':4,
    'friday':5,
    'saturday':6,
    'sunday':7
  };



  //构造方法
  Subject(String msg,String day)
  {
    //如果给的信息不是空
    if(msg!=null&&msg.isNotEmpty)
    message=msg;
    //分割信息19020193a-3@离散数学@王丽娟@1-4,6-14(周)@东区教学楼3-308,第1个是课程号,第2个是科目名,第3个是任课老师名,第4个是周次,第5个是地点
    List<String> msgList=message.split("@");
    //赋值
    subjectNum=msgList[0];
    subjectName=msgList[1];
    teacherName=msgList[2];
    setTime(time, msgList[3]);
    place=msgList[4];
    weekNum=day7[day];
  }

  //设置该科目在哪些周上课
  void setTime(Set time,String msg)
  {
    //把 1-4,6-14(周) 这样的拆成1-4  6-14
    List<String> times=msg.substring(0,msg.length-3).split(",");
    //每个s是类似"1-4",也可能就一个数字
    for(String s in times)
      {
        //获得起始周次
        int a=int.parse(s.split("-")[0]);
        //获得最后的周次
        int b=a;
        if(s.split("-").length>1)
          {
            b=int.parse(s.split("-")[1]);
          }
        //把要上课的周次添加进去
        for(a;a<=b;a++)
          {
            time.add(a.toString());
          }
      }
  }

  //判断这个周次有没有这节课
  bool hasThisClass(String weekNum)
  {
    return time.contains(weekNum);
  }
}
