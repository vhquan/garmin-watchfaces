import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Time;
import Toybox.ActivityMonitor;
import Toybox.UserProfile;
import Toybox.Sensor;

class fr255_aly_watchfaceView extends WatchUi.WatchFace {
  function initialize() { WatchFace.initialize(); }

  function onLayout(dc as Dc) as Void { setLayout(Rez.Layouts.WatchFace(dc)); }

  function onUpdate(dc as Dc) as Void {
    showTime();
    showDate();
    var batteryPer = showBattery();
    var stepPer = showSteps();
    showHeartRate();
    showCalories();
    showRespirationRate();
    showDistance();
    showFloorUpDown();
    showRecovery();

    showAuthorStr();

    View.onUpdate(dc);

    // draw object from drawable-list
    var myAly = new Rez.Drawables.Aly();
    myAly.draw(dc);

    /* update progress bars */
    drawBattery(43, 135, 100, 9, 65348, batteryPer, dc);
    drawStep(43, 170, 100, 9, 58364, stepPer, dc);
  }

  function onShow() as Void {}
  function onHide() as Void {}
  function onExitSleep() as Void {}
  function onEnterSleep() as Void {}

 private
  function showDistance() as Void {
    var info = ActivityMonitor.getInfo();
    var mDistanceView = View.findDrawableById("DistanceDisplay") as Text;
    mDistanceView.setText(Lang.format(
        "$1$ km",
        [(info.distance.toFloat() / 100.0 / 1000.0).format("%.02f")]));
  }

 private
  function drawCal(x, y, w, h, color, percentage, dc as Dc) as Void {
    var mCalBar = new InverseHorizontalProgressBar({
      :locX => x,
      :locY => y,
      :width => w,
      :height => h,
      :color => color
    });

    mCalBar.setPercent(percentage);
    mCalBar.draw(dc);
  }

 private
  function showRespirationRate() as Void {
    var info = ActivityMonitor.getInfo();

    var mRespirationRateView =
        View.findDrawableById("RespirationRateDisplay") as Text;
    mRespirationRateView.setText(info.respirationRate.toString());
  }

 private
  function showRecovery() as Void {
    var info = ActivityMonitor.getInfo();

    var mRecovery = View.findDrawableById("RecoveryDisplay") as Text;
    mRecovery.setText(info.timeToRecovery.toString() + " h");
  }

 private
  function showFloorUpDown() as Void {
    var info = ActivityMonitor.getInfo();

    var climbView = View.findDrawableById("ClimbFloorDisplay") as Text;
    var descendView = View.findDrawableById("DescendFloorDisplay") as Text;
    var targetView = View.findDrawableById("TargetFloorDisplay") as Text;

    climbView.setText(info.floorsClimbed.toString());
    targetView.setText(info.floorsClimbedGoal.toString());
    descendView.setText(info.floorsDescended.toString());
  }

 private
  function showCalories() as Void {
    var info = ActivityMonitor.getInfo();
    var mCalView = View.findDrawableById("CalDisplay") as Text;

    mCalView.setText(info.calories.toString());
  }

 private
  function showHeartRate() as Void {
    var mHeartRateIter = ActivityMonitor.getHeartRateHistory(1, true);
    var mCurHeartRate = mHeartRateIter.next().heartRate;
    var mHeartRateView = View.findDrawableById("HeartRateDisplay") as Text;

    if (mCurHeartRate == ActivityMonitor.INVALID_HR_SAMPLE) {
      mHeartRateView.setText("--");
    } else {
      mHeartRateView.setText(mCurHeartRate.format("%d"));
    }
  }

 private
  function drawStep(x, y, w, h, color, percentage, dc as Dc) as Void {
    var mStepBar = new HorizontalProgressBar({
      :locX => x,
      :locY => y,
      :width => w,
      :height => h,
      :color => color
    });

    mStepBar.setPercent(percentage);
    mStepBar.draw(dc);
  }

 private
  function drawBattery(x, y, w, h, color, percentage, dc as Dc) as Void {
    var mBatteryBar = new HorizontalProgressBar({
      :locX => x,
      :locY => y,
      :width => w,
      :height => h,
      :color => color
    });

    mBatteryBar.setPercent(percentage);
    mBatteryBar.draw(dc);
  }

 private
  function showSteps() as Float {
    var info = ActivityMonitor.getInfo();

    var mStepView = View.findDrawableById("StepDisplay") as Text;
    mStepView.setText(info.steps.toString());

    var mStepGoalView = View.findDrawableById("StepGoalDisplay") as Text;
    mStepGoalView.setText(info.stepGoal.toString());

    if (info.stepGoal == 0) {
      return 0.0;
    }

    return (info.steps.toFloat() / info.stepGoal.toFloat());
  }

 private
  function showBattery() as Float {
    var mSysStat = System.getSystemStats();

    var mBatteryDisplay = View.findDrawableById("BatteryDisplay") as Text;
    mBatteryDisplay.setText(mSysStat.battery.format("%d") + "%");

    var mBatteryInDaysDisplay =
        View.findDrawableById("BatteryInDaysDisplay") as Text;
    mBatteryInDaysDisplay.setText(mSysStat.batteryInDays.format("%d") + " d");

    return (mSysStat.battery / 100);
  }

 private
  function showTime() as Void {
    var mTime = System.getClockTime();

    var mTimeView = View.findDrawableById("TimeDisplay") as Text;
    mTimeView.setText(Lang.format(
        "$1$:$2$", [ mTime.hour.format("%02d"), mTime.min.format("%02d") ]));
  }

 private
  function showDate() as Void {
    var mDate = Time.Gregorian.info(Time.now(), Time.FORMAT_LONG);

    var mDateView = View.findDrawableById("DateDisplay") as Text;
    mDateView.setText(Lang.format(
        "$1$, $2$ $3$", [ mDate.day_of_week, mDate.day, mDate.month ]));
  }

 private
  function showAuthorStr() as Void {
    var mBeginLoveDay = {
      :year => 2021,
      :month => 12,
      :day => 20,
      :hour => 0,
      :minute => 1
    };

    var mBeginMoment = Time.Gregorian.moment(mBeginLoveDay);
    var mCurrentMoment = new Time.Moment(Time.today().value());
    var mLoveDaysView = View.findDrawableById("LoveDaysDisplay") as Text;
    mLoveDaysView.setText(
        Lang.format("$1$ days", [mCurrentMoment.subtract(mBeginMoment).value() /
                                    Gregorian.SECONDS_PER_DAY]));

    var authorView = View.findDrawableById("AuthorDisplay") as Text;
    authorView.setText("Aly's Quan");
  }
}
