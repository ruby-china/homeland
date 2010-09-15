// Like Rails DataHelper
var DateHelper = {
  timeAgoInWords: function(from) {
   return this.distanceOfTimeInWords(new Date().getTime(), from);
  },

  distanceOfTimeInWords: function(to, from) {
    seconds_ago = ((to  - from) / 1000);
    minutes_ago = Math.floor(seconds_ago / 60)

    if(minutes_ago == 0) { return "不到一分钟";}
    if(minutes_ago == 1) { return "一分钟";}
    if(minutes_ago < 45) { return minutes_ago + "分钟";}
    if(minutes_ago < 90) { return "大约一小时";}
    hours_ago  = Math.round(minutes_ago / 60);
    if(minutes_ago < 1440) { return hours_ago + "小时";}
    if(minutes_ago < 2880) { return "一天";}
    days_ago  = Math.round(minutes_ago / 1440);
    if(minutes_ago < 43200) { return days_ago + "天";}
    if(minutes_ago < 86400) { return "大约一月";}
    months_ago  = Math.round(minutes_ago / 43200);
    if(minutes_ago < 525960) { return months_ago + "月";}
    if(minutes_ago < 1051920) { return "大约一年";}
    years_ago  = Math.round(minutes_ago / 525960);
    return "超过" + years_ago + "年"
  }
}