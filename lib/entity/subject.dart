//科目类,就是一门课程
class Subject {
  //原始信息,返回的结果
  String message;

  //课程号
  String subjectNum;

  //课程名
  String subjectName;

  //任课老师名字
  String teacherName;

  //上课时间,比如说是第几周
  Set<String> time = Set();

  //上课地点
  String place;

  //星期几上的课
  int weekNum;

  //科目颜色,这里是颜色数组里的index
  int color;

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

  //构造方法
  Subject();

  //
  Subject.byInfo(String msg, String day) {
    //如果给的信息不是空
    if (msg != null && msg.isNotEmpty) message = msg;
    //分割信息19020193a-3@离散数学@王丽娟@1-4,6-14(周)@东区教学楼3-308,第1个是课程号,第2个是科目名,第3个是任课老师名,第4个是周次,第5个是地点
    List<String> msgList = message.split("@");
    //赋值
    if(msgList.length==5)
      {
        subjectNum = msgList[0];
        subjectName = msgList[1];
        teacherName = msgList[2];
        setTime(time, msgList[3]);
        place = msgList[4];
        if(place.contains("-"))
        {
          place=place.split("-")[0]+"-"+"\n"+place.split("-")[1];
        }
      }
    else//上帝才知道这个逼的这节课缺少了什么信息,但是反正课程号和课程名不能少,上课时间应该也不能少
      {
        subjectNum = msgList[0];
        subjectName = msgList[1];
        msgList.forEach((element) {
          if(element.contains("周"))
            {
              setTime(time, element);
            }
        });
        teacherName="";
        place="";
      }

    weekNum = day7[day];
  }



  //设置该科目在哪些周上课
  void setTime(Set time, String msg) {
    //把 1-4,6-14(周) 这样的拆成1-4  6-14
    List<String> times = msg.substring(0, msg.length - 3).split(",");
    //每个s是类似"1-4",也可能就一个数字
    for (String s in times) {
      //获得起始周次
      int a = int.parse(s.split("-")[0]);
      //获得最后的周次
      int b = a;
      if (s.split("-").length > 1) {
        b = int.parse(s.split("-")[1]);
      }
      //把要上课的周次添加进去
      for (a; a <= b; a++) {
        time.add(a.toString());
      }
    }
  }

  //判断这个周次有没有这节课
  bool hasThisClass(String weekNum) {
    return time.contains(weekNum);
  }

  //获得字符串来吧类存储在本地
  String getStringSave()
  {
    return message+"@"+subjectNum+"@"+subjectName+"@"+teacherName+"@"+time.join("%")+"@"+place+"@"+weekNum.toString()+"@"+color.toString();
  }

  //从本地存储的字符串获得类
  Subject.bySave(String stringSave)
  {
    List<String> infoList=stringSave.split("@");
    if(infoList.length==8)
      {
        message=infoList[0];
        subjectNum=infoList[1];
        subjectName=infoList[2];
        teacherName=infoList[3];
        place=infoList[5];
        weekNum=int.parse(infoList[6]);
        color=int.parse(infoList[7]);
        List<String> times=infoList[4].split("%");
        times.forEach((element) {
          time.add(element);
        });
      }

  }
}