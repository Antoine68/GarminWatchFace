import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

const SCREEN_MULTIPLIER = (System.getDeviceSettings().screenWidth < 360) ? 1 : 2;
//const BATTERY_LINE_WIDTH = 2;
const BATTERY_HEAD_HEIGHT = 4 * SCREEN_MULTIPLIER;
const BATTERY_MARGIN = SCREEN_MULTIPLIER;
const LINE_HEIGHT = 65;

class wf_fr55View extends WatchUi.WatchFace {
    
    private var mDayOfWeek;
    private var mDayString;
    private var mMonth;
    private var mMonthString;
    private var mCenterX = System.getDeviceSettings().screenWidth / 2;
    private var mCenterY = System.getDeviceSettings().screenHeight / 2;

    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {        
        process(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
        WatchUi.requestUpdate();
    }
    
    function onPartialUpdate(dc as Dc) as Void {
        process(dc);
    }
    
    function process(dc as Dc) as Void {
        drawTime(dc);
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
        dc.clear();
        dc.setPenWidth(2);
        drawSecondHandArc(dc);
        drawDate(dc);
        drawLines(dc);
        drawBattery(dc);
        drawData(dc);
    }
    
    function drawTime(dc as Dc) as Void {
        // Get the current time and format it correctly
        var timeFormat = "$1$:$2$:$3$";
        var clockTime = System.getClockTime();
        var hours = clockTime.hour;
        if (!System.getDeviceSettings().is24Hour) {
            if (hours > 12) {
                hours = hours - 12;
            }
        } else {
            if (getApp().getProperty("UseMilitaryFormat")) {
                timeFormat = "$1$$2$";
                hours = hours.format("%02d");
            }
        }
        var timeString = Lang.format(timeFormat, [hours, clockTime.min.format("%02d"), clockTime.sec.format("%02d")]);
        // Update the view
        var view = View.findDrawableById("TimeLabel") as Text;
        view.setColor(getApp().getProperty("ForegroundColor") as Number);
        view.setFont(WatchUi.loadResource(Rez.Fonts.TimeFont));
        view.setColor(Graphics.COLOR_YELLOW);
        view.setLocation(mCenterX, mCenterY - 23);
        view.setText(timeString);
    }
    
    private function drawSecondHandArc(dc as Dc) as Void {
        var sec = System.getClockTime().sec;
        if (sec > 0) {
            dc.drawArc(mCenterX, mCenterY, mCenterX - 2, Graphics.ARC_CLOCKWISE, 90, 90 - (sec * 360 / 60));
        }
    }
    
    private function drawLines(dc as Dc) as Void {
        dc.drawLine(mCenterX - 1, 10, mCenterX - 1, LINE_HEIGHT);
        dc.drawLine(mCenterX - 1, System.getDeviceSettings().screenHeight - LINE_HEIGHT, mCenterX - 1, System.getDeviceSettings().screenHeight - 10);

    }
    
    private function drawDate(dc as Dc) as Void {
        var rezStrings = Rez.Strings;
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        
        var dateFormat = "$1$ $2$ $3$ $4$";
        var now = Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT);

        var dayOfWeek = now.day_of_week;
        if (mDayOfWeek == null || mDayOfWeek != dayOfWeek) {
            mDayOfWeek = dayOfWeek;
            mDayString = WatchUi.loadResource([
                rezStrings.Sun,rezStrings.Mon,rezStrings.Tue,rezStrings.Wed,rezStrings.Thu,rezStrings.Fri,rezStrings.Sat
		    ][mDayOfWeek - 1]);
        }
        
        var monthNow = now.month;
        if (mMonth == null || mMonth != monthNow) {
            mMonth = monthNow;
            mMonthString = WatchUi.loadResource([
                rezStrings.Jan,rezStrings.Feb,rezStrings.Mar,rezStrings.Apr,rezStrings.May,rezStrings.Jun,rezStrings.Jul,rezStrings.Aug,rezStrings.Sep,rezStrings.Oct,rezStrings.Nov,rezStrings.Dec
		    ][mMonth - 1]);
        }
        dc.drawText(mCenterX, LINE_HEIGHT, Graphics.FONT_XTINY, Lang.format(dateFormat, [mDayString, now.day.format("%02d"), mMonthString, now.year]), Graphics.TEXT_JUSTIFY_CENTER);
    }
    
    private function drawBattery(dc as Dc) as Void {
        var batteryX = mCenterX;
        var batteryY = System.getDeviceSettings().screenHeight - LINE_HEIGHT - 10;
        var batteryWd = 22;
        var batteryHt = 10;
        //dc.drawText(mCenterX, System.getDeviceSettings().screenHeight - LINE_HEIGHT - 25, Graphics.FONT_XTINY, Lang.format(dateFormat, [dayOfWeekString, day, monthString, year]), Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawRoundedRectangle(batteryX - (batteryWd/2) + 1, batteryY - (batteryHt/2) + 1, batteryWd - 1, batteryHt - 1, 2 * SCREEN_MULTIPLIER);
        dc.fillRectangle(batteryX + (batteryWd/2) + BATTERY_MARGIN, batteryY - (BATTERY_HEAD_HEIGHT / 2),/* BATTERY_HEAD_WIDTH */ 2, BATTERY_HEAD_HEIGHT);
        var batteryLevel = Math.floor(System.getSystemStats().battery);
        var batteryColor = Graphics.COLOR_BLUE;
        if (!System.getSystemStats().charging) {
            if (batteryLevel <= 20.0) {
            batteryColor = Graphics.COLOR_RED;
            } else if (batteryLevel <= 50.0) {
                batteryColor = Graphics.COLOR_YELLOW;
            } else {
                batteryColor = Graphics.COLOR_GREEN;
            }
        } else if (batteryLevel == 100) {
            batteryColor = Graphics.COLOR_LT_GRAY;
        }
        dc.setColor(batteryColor, Graphics.COLOR_TRANSPARENT);
        var lineWidthPlusMargin = (/* BATTERY_LINE_WIDTH */ 2 + BATTERY_MARGIN);
	    var fillWidth = batteryWd - (2 * lineWidthPlusMargin);
	    dc.fillRectangle(batteryX - (batteryWd / 2) + lineWidthPlusMargin, batteryY - (batteryHt / 2) + lineWidthPlusMargin, Math.ceil(fillWidth * (batteryLevel / 100)), batteryHt - (2 * lineWidthPlusMargin));

    }
    
    private function drawData(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        
        dc.drawText(65, 37, Graphics.FONT_XTINY, ActivityMonitor.getInfo().steps, Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(System.getDeviceSettings().screenWidth - 65, 37, Graphics.FONT_XTINY, (ActivityMonitor.getInfo().distance/100000.0).format("%.2f"), Graphics.TEXT_JUSTIFY_CENTER);
        var heartRate = Activity.getActivityInfo().currentHeartRate;
        dc.drawText(65, System.getDeviceSettings().screenHeight - 45, Graphics.FONT_XTINY, heartRate ? heartRate : "--", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(System.getDeviceSettings().screenWidth - 65, System.getDeviceSettings().screenHeight - 45, Graphics.FONT_XTINY, ActivityMonitor.getInfo().calories, Graphics.TEXT_JUSTIFY_CENTER);

        dc.drawText(65, 12, WatchUi.loadResource(Rez.Fonts.IconsFont), 0, Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(System.getDeviceSettings().screenWidth - 65, 12, WatchUi.loadResource(Rez.Fonts.IconsFont), 7, Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(65, System.getDeviceSettings().screenHeight - 70, WatchUi.loadResource(Rez.Fonts.IconsFont), 3, Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(System.getDeviceSettings().screenWidth - 65, System.getDeviceSettings().screenHeight - 70, WatchUi.loadResource(Rez.Fonts.IconsFont), 6, Graphics.TEXT_JUSTIFY_CENTER);

    }

}
