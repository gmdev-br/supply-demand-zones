//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "© GM, 2020, 2021, 2022, 2023"
#property description "Supply and Demand Zones MTF"
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0

enum enum_price_distance {
   far_from_price,
   close_to_price
};

enum enum_point_type {
   open_close,
   high_low
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
input string                                 Id = "+vpr";                                          // Identifier
input ENUM_TIMEFRAMES                        Timeframe = PERIOD_M1;                           // Timeframe
input string                                 inputAtivo = "";
input bool                                   shortMode = false;
input int                                    input_start = 0;
input int                                    input_end = 0;
input datetime                               DefaultInitialDate = "2023.8.30 10:20:00";                 // Data inicial padrão
input datetime                               DefaultFinalDate = -1;       // Data final padrão
input int                                    WaitMilliseconds = 60000;                             // Timer (milliseconds) for recalculation
input bool                                   KeepRightLineUpdated = true;                          // Automatic update of the rightmost line
input int                                    ShiftCandles = 50;                                     // Distance in candles to adjust on automatic
input bool                                   ShowSymbol = true;
input int                                    SymbolTextSize = 8;
input color                                  SymbolTextColor = clrYellow;
input bool                                   EnableEvents = false;                                  // Ativa os eventos de teclado
input bool                                   SetGlobals = false;                                   // Set terminal global variables
input ENUM_APPLIED_VOLUME                    volumeType = VOLUME_REAL;

input group "***************  Time delimiters ***************"
input color                                  TimeFromColor = clrLime;                              // Left border line color
input int                                    TimeFromWidth = 1;                                    // Left border line width
input ENUM_LINE_STYLE                        TimeFromStyle = STYLE_DASH;                           // Left border line style
input color                                  TimeToColor = clrRed;                                 // Right border line color
input int                                    TimeToWidth = 1;                                      // Right border line width
input ENUM_LINE_STYLE                        TimeToStyle = STYLE_DASH;                             // Right border line style

input group "***************  Zone settings ***************"
input bool                                   zone_show_weak = true;                                // Show Weak Zones
input bool                                   zone_show_untested = true;                            // Show Untested Zones
input bool                                   zone_show_turncoat = true;                            // Show Broken Zones
input bool                                   enableATR = false;                                     // Use ATR or Percent change mode
input double                                 inputZoneSize = 1;                                 // Zone size in percent
input double                                 enablePercentProj1 = 0;                          // Enable 1st projection from zone base
input double                                 enablePercentProj2 = 0;                          // Enable 2nd projection from zone base
input double                                 enablePercentProj3 = 0;                          // Enable 3rd projection from zone base
input double                                 zone_fuzzfactor = 1;                               // Zone ATR Factor
input bool                                   zone_merge = false;                                    // Zone Merge
input bool                                   zone_merge_identical = false;
input bool                                   zone_sum = true;
input bool                                   zone_merge_weak = false;                              // Merge strong and weak zones
input bool                                   zone_extend = false;                                   // Zone Extend
input enum_point_type                        point_type = high_low;
input int                                    rightOffset = 1;
//input bool                                   considerGaps = true;                                  // Consider gaps on zones broken
input int                                    input_bust_count = 3;
input group "***************  Fractals ***************"
input int                                    recentBars = 0;                                       // Fractal recent bars
input int                                    PeriodAtr = 20;                                       // ATR Factor
input double                                 fractal_fast_factor = 3.0;                            // Fractal Fast Factor
input double                                 fractal_slow_factor = 6.0;                            // Fractal slow Factor

input group "***************  Zone styling ***************"
input bool                                   zone_solid = false;                                    // Fill zone with color
input bool                                   zone_short_naming = true;                           // Use zone short naming
input int                                    zone_linewidth = 2;                                   // Zone border width
input ENUM_LINE_STYLE                        zone_style = STYLE_SOLID;                             // Zone border style
input bool                                   extendZoneToLeft = false;                            // Extend zone boxes to current date
input bool                                   extendZoneToRight = false;                            // Extend zone boxes to current date

input string                                 sup_name = "";                                     // Support Name
input string                                 res_name = "";                                     // Resistance Name
input string                                 test_name = "";                                // Test Name
input color                                  color_support_untested = clrRoyalBlue;                 // Color for untested support zone
input color                                  color_support_weak     = C'68,193,150';            // Color for weak support zone
input color                                  color_support_verified = clrGreen;                    // Color for verified support zone
input color                                  color_support_proven   = clrLime;                // Color for proven support zone
input color                                  color_support_super   = clrYellow;                    // Color for super support zone
input color                                  color_support_turncoat = clrDimGray;                // Color for turncoat(broken) support zone
input color                                  color_resist_untested  = clrOrange;                   // Color for untested resistance zone
input color                                  color_resist_weak      = clrLightCoral;                   // Color for weak resistance zone
input color                                  color_resist_verified  = clrCrimson;                  // Color for verified resistance zone
input color                                  color_resist_proven    = clrRed;                      // Color for proven resistance zone
input color                                  color_resist_super    = clrYellow;                    // Color for super resistance zone
input color                                  color_resist_turncoat  = clrDimGray;               // Color for broken resistance zone

input group "***************  Filters ***************"
input int                                    filterException = 1;                                  // Do not filter last N days
input int                                    ageFilter = 0;                                        // Filter by age
input int                                    amplitudeFilter = 0;                                  // Filter by amplitude
input double                                 distanceFilter = 0;
input long                                   volumeFilter = 0;                                 // Filter by power
input int                                    averageFilter = 0;                                    // Filter by average power  percent
input long                                   volumeFilterSuper = 0;                                 // Filter super (power)
input long                                   volumeFilterProven = 0;                                // Filter proven (power)
input long                                   volumeFilterVerified = 0;                              // Filter verified (power)
input long                                   volumeFilterBroken = 0;                                // Filter broken (power)
input long                                   volumeFilterUntested = 0;                              // Filter untested (power)
input long                                   volumeFilterWeak = 0;                                  // Filter weak (power)

input group "***************  Texts ***************"
input bool                                   zone_show_info = true;                                // Show labels
input bool                                   labelOnRight = false;
input enum_price_distance                    price_distance = close_to_price;
//input bool                                   showAllZones = false;
input int                                    zone_label_shift = 10;                                // Info label shift
input int                                    Text_size = 10;                                       // Text Size
input string                                 Text_font = "Courier New";                            // Text Font
input color                                  Text_color = clrWhite;                                // Text Color
input bool                                   Text_color_sync = true;                               // Sync text color with zone color
input ENUM_ANCHOR_POINT                      anchor = ANCHOR_RIGHT;
input bool                                   showAmplitude = false;                                 // Show zone amplitude
input bool                                   showAge = false;                                       // Show zone age
input bool                                   showPower = false;                                     // Show zone power
input bool                                   showLabelPowerInsideBox = false;                      // Show zone power inside boxes

input group "***************  Other ***************"
input bool                                   debug = false;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#define ZONE_SUPPORT 1
#define ZONE_RESIST  2

#define ZONE_TURNCOAT   0
#define ZONE_UNTESTED   1
#define ZONE_WEAK       2
#define ZONE_VERIFIED   3
#define ZONE_PROVEN     4
#define ZONE_SUPER      5

#define UP_POINT 1
#define DN_POINT -1

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

ENUM_TIMEFRAMES timeframe;
datetime    ZoneTime[];
int         zone_start[], zone_age[], zone_hits[], zone_type[], zone_strength[], zone_count = 0;
long        zone_volume[];
bool        zone_turn[];
double      zone_hi[], zone_lo[];
double      zone_power[], zone_amplitude[];
double      ner_lo_zone_P1[], ner_lo_zone_P2[], ner_hi_zone_P1[], ner_hi_zone_P2[], ATR[];
double      FastDnPts[], FastUpPts[];
double      SlowDnPts[], SlowUpPts[];
double      High[], Low[], Open[], Close[];
long        Volume[];
double      fHigh[], fLow[];

bool        try_again = false, compartilhaDelimitador = false, temPrioridade = true, calculating = false;
int         time_offset = 0;
int         limitCurrentTimeframe;
int         timeFrameBarFrom;
int         timeFrameBarTo;
int         P1, P2, extraBars;
int         barsToCalculate;
int         digitos;
long        totalRates, iATR_handle;
double      averageForce = 0;
double      sumForce = 0;
string      comment = "Updating Chart...", id;
string      ativo;

datetime    data_inicial, data_final, minimumDate, maximumDate;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit() {
   if(Timeframe == PERIOD_CURRENT)
      timeframe = Period();
   else
      timeframe = Timeframe;

   ativo = inputAtivo;
   StringToUpper(ativo);
   if (ativo == "")
      ativo = _Symbol;

   if (enableATR)
      iATR_handle = iATR(NULL, timeframe, PeriodAtr);

   _prefix = Id + " m1 ";
   _timeFromLine = Id + "-from";
   _timeToLine = Id + "-to";

   _timeToColor = TimeToColor;
   _timeFromColor = TimeFromColor;
   _timeToWidth = TimeToWidth;
   _timeFromWidth = TimeFromWidth;

   verifyDates();
//data_inicial = DefaultInitialDate;
//data_final = DefaultFinalDate;
//if (KeepRightLineUpdated && DefaultFinalDate == -1) {
//   data_final = iTime(ativo, PERIOD_CURRENT, 0) + PeriodSeconds(PERIOD_CURRENT) * ShiftCandles;
//} else if (DefaultFinalDate != -1) {
//   data_final = DefaultFinalDate;
//}

   totalRates = SeriesInfoInteger(ativo, PERIOD_CURRENT, SERIES_BARS_COUNT);
   _lastOK = false;
   _updateTimer = new MillisecondTimer(WaitMilliseconds, false);
   EventSetMillisecondTimer(WaitMilliseconds);

   P1 = int(timeframe * fractal_fast_factor);
   P2 = int(timeframe * fractal_slow_factor);
   int extraBars1 = int(P1 / int(timeframe) * 2 + MathCeil(P1 / timeframe / 2));
   int extraBars2 = int(P2 / int(timeframe) * 2 + MathCeil(P2 / timeframe / 2));
   extraBars = MathMax(extraBars1, extraBars2) + 10;

   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);

   ArraySetAsSeries(SlowDnPts, true);
   ArraySetAsSeries(SlowUpPts, true);
   ArraySetAsSeries(FastDnPts, true);
   ArraySetAsSeries(FastUpPts, true);

   ArraySetAsSeries(ner_hi_zone_P1, true);
   ArraySetAsSeries(ner_hi_zone_P2, true);
   ArraySetAsSeries(ner_lo_zone_P1, true);
   ArraySetAsSeries(ner_lo_zone_P2, true);

   ArraySetAsSeries(ZoneTime, true);

   digitos = _Digits;
   if (_Digits > 2)
      digitos = 2;

//verifyDates();
   UpdateSymbol();
   Update();

   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
   DeleteZones();
   DeleteGlobalVars();

   if(StringFind(ChartGetString(0, CHART_COMMENT), comment) >= 0)
      Comment("");

   if(UninitializeReason() == REASON_REMOVE) {
      ObjectDelete(0, _timeFromLine);
      ObjectDelete(0, _timeToLine);
   }

   delete(_updateTimer);
   ObjectDelete(0, "ativo");
   ChartRedraw();
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UpdateSymbol() {
   if (ShowSymbol) {
      ObjectDelete(0, "ativo");
      ObjectCreate(0, "ativo", OBJ_LABEL, 0, 0, 0);
      //ObjectCreate(0, "ativo", OBJ_TEXT, 0, GetBarTime(WindowFirstVisibleBar(),PERIOD_CURRENT), 5);
      ObjectSetInteger(0, "ativo", OBJPROP_XDISTANCE, 0);
      ObjectSetInteger(0, "ativo", OBJPROP_YDISTANCE, 0);
      ObjectSetString(0, "ativo", OBJPROP_TEXT, ativo + ":" + GetTimeFrame(Period()));
      ObjectSetInteger(0, "ativo", OBJPROP_FONTSIZE, SymbolTextSize);
      ObjectSetInteger(0, "ativo", OBJPROP_COLOR, SymbolTextColor);
      ObjectSetInteger(0, "ativo", OBJPROP_BACK, true);
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void verifyDates() {

   minimumDate = iTime(ativo, PERIOD_CURRENT, iBars(ativo, PERIOD_CURRENT) - 2);
   maximumDate = iTime(ativo, PERIOD_CURRENT, 0) + PeriodSeconds(PERIOD_CURRENT) * ShiftCandles;

   timeFrom = GetObjectTime1(_timeFromLine);
   timeTo = GetObjectTime1(_timeToLine);

   data_inicial = DefaultInitialDate;
   data_final = DefaultFinalDate;
   if (KeepRightLineUpdated && DefaultFinalDate == -1) {
      data_final = maximumDate;
   } else if (DefaultFinalDate != -1) {
      data_final = DefaultFinalDate;
   }

   if ((timeFrom == 0) || (timeTo == 0)) {
      timeFrom = data_inicial;
      timeTo = data_final;
      DrawVLine(_timeFromLine, timeFrom, _timeFromColor, _timeFromWidth, TimeFromStyle, true, true, true, 1000);
      DrawVLine(_timeToLine, timeTo, _timeToColor, _timeToWidth, TimeToStyle, true, true, true, 1000);
   }

   if (ObjectGetInteger(0, _timeFromLine, OBJPROP_SELECTED) == false) {
      timeFrom = data_inicial;
   }

   if (ObjectGetInteger(0, _timeToLine, OBJPROP_SELECTED) == false) {
      timeTo = data_final;
   }

   if ((timeFrom < minimumDate) || (timeFrom > maximumDate))
      timeFrom = minimumDate;

   if ((timeTo >= maximumDate) || (timeTo < minimumDate))
      timeTo = maximumDate;

   ObjectSetInteger(0, _timeFromLine, OBJPROP_TIME, 0, timeFrom);
   ObjectSetInteger(0, _timeToLine, OBJPROP_TIME, 0, timeTo);
}

bool Update() {

//calculating = true;
   verifyDates();
   totalRates = SeriesInfoInteger(ativo, PERIOD_CURRENT, SERIES_BARS_COUNT);

   ObjectSetInteger(0, _timeToLine, OBJPROP_TIME, 0, timeTo);
   if(timeFrom > timeTo)
      Swap(timeFrom, timeTo);

   if(!GetRangeBars(timeFrom, timeTo, barFrom, barTo))
      return(false);

   timeFrameBarFrom = miBarShift(ativo, timeframe, timeFrom);
   timeFrameBarTo = miBarShift(ativo, timeframe, timeTo);
   barsToCalculate = MathAbs(timeFrameBarTo - timeFrameBarFrom) + extraBars;
   limitCurrentTimeframe = timeFrameBarFrom;

   if (barsToCalculate < PeriodAtr || barsToCalculate < extraBars)
      return false ;

   if (enableATR)
      if (PeriodAtr > (totalRates - barsToCalculate))
         iATR_handle = iATR(NULL, timeframe, PeriodAtr);

   if ((CopyClose(ativo, timeframe, 0, limitCurrentTimeframe + extraBars, Close) == -1) ||
         (CopyHigh(ativo, timeframe, 0, limitCurrentTimeframe + extraBars, High) == -1) ||
         (CopyLow(ativo, timeframe, 0, limitCurrentTimeframe + extraBars, Low) == -1) ||
         (CopyOpen(ativo, timeframe, 0, limitCurrentTimeframe + extraBars, Open) == -1) ||
         (volumeType == VOLUME_REAL ? CopyRealVolume(ativo, timeframe, 0, limitCurrentTimeframe + extraBars, Volume) == -1 : CopyTickVolume(ativo, timeframe, 0, limitCurrentTimeframe + extraBars, Volume) == -1)) {
      try_again = true;
      CheckTimer();
      Comment(comment);
   } else {
      if(StringFind(ChartGetString(0, CHART_COMMENT), comment) >= 0)
         Comment("");
      try_again = false;
   }

   if (enableATR)
      CopyBuffer(iATR_handle, 0, 0, limitCurrentTimeframe + extraBars, ATR);

   ArrayResize(FastUpPts, limitCurrentTimeframe + extraBars);
   ArrayResize(FastDnPts, limitCurrentTimeframe + extraBars);

   ArrayResize(SlowUpPts, limitCurrentTimeframe + extraBars);
   ArrayResize(SlowDnPts, limitCurrentTimeframe + extraBars);

   ArrayResize(ner_hi_zone_P1, limitCurrentTimeframe + extraBars);
   ArrayResize(ner_hi_zone_P2, limitCurrentTimeframe + extraBars);
   ArrayResize(ner_lo_zone_P1, limitCurrentTimeframe + extraBars);
   ArrayResize(ner_lo_zone_P2, limitCurrentTimeframe + extraBars);

   ArrayResize(ZoneTime, limitCurrentTimeframe + extraBars);

   ArraySetAsSeries(Open, true);
   ArraySetAsSeries(Close, true);
   ArraySetAsSeries(High, true);
   ArraySetAsSeries(Low, true);
   ArraySetAsSeries(Volume, true);
   if (enableATR)
      ArraySetAsSeries(ATR, true);

   int old_zone_count = zone_count;

   DeleteZones();
   FindFractals();
   FindZones();
   DrawZones();

   if(zone_count < old_zone_count)
      DeleteOldGlobalVars(old_zone_count);

   if(zone_show_info == true)
      showLabels();

//calculating = false;

   ChartRedraw();

   ArrayFree(Open);
   ArrayFree(Close);
   ArrayFree(High);
   ArrayFree(Low);
   ArrayFree(Volume);
   if (enableATR)
      ArrayFree(ATR);

   ArrayFree(fHigh);
   ArrayFree(fLow);

   ArrayFree(ner_hi_zone_P1);
   ArrayFree(ner_hi_zone_P2);
   ArrayFree(ner_lo_zone_P1);
   ArrayFree(ner_lo_zone_P2);

   ArrayFree(FastDnPts);
   ArrayFree(FastUpPts);
   ArrayFree(SlowDnPts);
   ArrayFree(SlowUpPts);

   ArrayFree(FastDnPts);
   ArrayFree(FastUpPts);
   ArrayFree(SlowDnPts);
   ArrayFree(SlowUpPts);

   ArrayFree(ZoneTime);

   _lastOK = false;

   return(true);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated, const int begin, const double &price[]) {
   return(1);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteGlobalVars() {
   if(SetGlobals == false)
      return;

   GlobalVariableDel(Id + "_" + "SSSR_Count_" + ativo + TFTS(timeframe));
   GlobalVariableDel(Id + "_" + "SSSR_Updated_" + ativo + TFTS(timeframe));

   int old_count = zone_count;
   zone_count = 0;
   DeleteOldGlobalVars(old_count);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteOldGlobalVars(int old_count) {
   if(SetGlobals == false)
      return;

   for(int i = zone_count; i < old_count; i++) {
      GlobalVariableDel(Id + "_" + "SSSR_HI_" + ativo + TFTS(timeframe) + string(i));
      GlobalVariableDel(Id + "_" + "SSSR_LO_" + ativo + TFTS(timeframe) + string(i));
      GlobalVariableDel(Id + "_" + "SSSR_HITS_" + ativo + TFTS(timeframe) + string(i));
      GlobalVariableDel(Id + "_" + "SSSR_STRENGTH_" + ativo + TFTS(timeframe) + string(i));
      GlobalVariableDel(Id + "_" + "SSSR_AGE_" + ativo + TFTS(timeframe) + string(i));
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void FindZones() {
   int i, j, bustcount = 0, testcount = 0, temp_count = 0;
   long volumecount = 0;
   double hival, loval, openval, closeval;
   bool turned = false, hasturned = false, hasGap = false;
   double temp_hi[], temp_lo[];
   int    temp_start[], temp_age[], temp_hits[], temp_type[], temp_strength[];
   bool   temp_turn[], temp_merge[];
   long   temp_volume[];
   int merge1[], merge2[], merge_count = 0;

   ArrayInitialize(temp_hi, 0);
   ArrayInitialize(temp_lo, 0);
   ArrayInitialize(temp_start, 0);
   ArrayInitialize(temp_age, 0);
   ArrayInitialize(temp_hits, 0);
   ArrayInitialize(temp_type, 0);
   ArrayInitialize(temp_strength, 0);
   ArrayInitialize(temp_turn, 0);
   ArrayInitialize(temp_merge, 0);
   ArrayInitialize(temp_volume, 0);

   ArrayResize(temp_hi, 0);
   ArrayResize(temp_lo, 0);
   ArrayResize(temp_start, 0);
   ArrayResize(temp_age, 0);
   ArrayResize(temp_hits, 0);
   ArrayResize(temp_type, 0);
   ArrayResize(temp_strength, 0);
   ArrayResize(temp_turn, 0);
   ArrayResize(temp_merge, 0);
   ArrayResize(temp_volume, 0);
   ArrayResize(merge1, 0);
   ArrayResize(merge2, 0);

// iterate through zones from oldest to youngest (ignore recent X (5) bars),
// finding those that have survived through to the present___
   for(int ii = limitCurrentTimeframe; ii > timeFrameBarTo + recentBars; ii--) {
      double atr, fu;
      if (enableATR) {
         atr = ATR[ii];
         fu = atr / 2 * zone_fuzzfactor;
      } else {
         atr = High[ii] * 0.01;
         fu = atr / (1 / inputZoneSize) * zone_fuzzfactor;
      }
      bool isWeak;
      bool touchOk = false;
      bool isBust = false;

      ArrayResize(temp_hi, temp_count + 1);
      ArrayResize(temp_lo, temp_count + 1);
      ArrayResize(temp_start, temp_count + 1);
      ArrayResize(temp_age, temp_count + 1);
      ArrayResize(temp_hits, temp_count + 1);
      ArrayResize(temp_type, temp_count + 1);
      ArrayResize(temp_strength, temp_count + 1);
      ArrayResize(temp_turn, temp_count + 1);
      ArrayResize(temp_merge, temp_count + 1);
      ArrayResize(temp_volume, temp_count + 1);
      ArrayResize(merge1, temp_count + 1);
      ArrayResize(merge2, temp_count + 1);
      if(FastUpPts[ii] > 0.001) {

         // a zigzag high point
         isWeak = true;
         if(SlowUpPts[ii] > 0.001)
            isWeak = false;

         if (point_type == high_low)
            hival = High[ii];
         else
            hival = MathMax(Close[ii], Open[ii]);

         if(zone_extend == true)
            hival += fu;

         if (enableATR)
            loval = MathMax(MathMin(Close[ii], High[ii] - fu), High[ii] - fu * 2);
         else if (point_type == high_low)
            loval = MathMax(MathMin(Close[ii], High[ii] - fu), High[ii] - fu);
         else if (point_type == open_close)
            loval = hival - fu;
         //else
         //   loval = Open[ii];

         turned = false;
         hasturned = false;
         isBust = false;

         bustcount = 0;
         testcount = 0;
         volumecount = 0;

         for(int i = ii - 1; i >= timeFrameBarTo + 0; i--) {
            hasGap = false;
            openval = Open[i];
            closeval = Close[i + 1];
            if (MathAbs(openval - closeval) >= openval * 0.001)
               hasGap = true;

            if((turned == false && FastUpPts[i] >= loval && FastUpPts[i] <= hival) || (turned == true && FastDnPts[i] <= hival && FastDnPts[i] >= loval)) {
               // Potential touch, just make sure its been 10+candles since the prev one
               touchOk = true;
               for(j = i + 1; j < i + recentBars * 2 + 1; j++) {
                  if((turned == false && FastUpPts[j] >= loval && FastUpPts[j] <= hival) || (turned == true && FastDnPts[j] <= hival && FastDnPts[j] >= loval)) {
                     touchOk = false;
                     break;
                  }
               }

               if(touchOk == true) {
                  // we have a touch_  If its been busted once, remove bustcount
                  // as we know this level is still valid & has just switched sides
                  bustcount = 0;
                  testcount++;
                  volumecount = volumecount + Volume[i];
               }
            }

            if((turned == false && High[i] > hival) || (turned == true && Low[i] < loval)) {
               // this level has been busted at least once
               bustcount++;
               //testcount++;

               hasturned = true;
               //if (hasGap && considerGaps) {
               //   hasturned = false;
               //}

               if(bustcount > input_bust_count || isWeak == true) {
                  // busted twice or more
                  isBust = true;
                  break;
               }

               if(turned == true)
                  turned = false;
               else if(turned == false)
                  turned = true;

               // forget previous hits
               testcount = 0;
               volumecount = volumecount + Volume[i];
            }
         }

         if(isBust == false) {
            // level is still valid, add to our list
            //if (point_type == high_low) {
            temp_hi[temp_count] = hival;
            temp_lo[temp_count] = loval;
            //} else {
            //   temp_hi[temp_count] = MathMax(Open[ii], Close[ii]);
            //   temp_lo[temp_count] = MathMin(Open[ii], Close[ii]);
            //}
            temp_turn[temp_count] = hasturned;
            temp_hits[temp_count] = testcount;
            temp_volume[temp_count] = Volume[ii] + volumecount;
            temp_start[temp_count] = ii;
            temp_merge[temp_count] = false;

            if(testcount > 6)
               temp_strength[temp_count] = ZONE_SUPER;
            else if(testcount > 3)
               temp_strength[temp_count] = ZONE_PROVEN;
            else if(testcount > 0)
               temp_strength[temp_count] = ZONE_VERIFIED;
            else if(hasturned == true)
               temp_strength[temp_count] = ZONE_TURNCOAT;
            else if(isWeak == false)
               temp_strength[temp_count] = ZONE_UNTESTED;
            else
               temp_strength[temp_count] = ZONE_WEAK;

            temp_count++;
         }
      } else if(FastDnPts[ii] > 0.001) {
         // a zigzag low point
         isWeak = true;
         if(SlowDnPts[ii] > 0.001)
            isWeak = false;

         if (!enableATR) {
            atr = Low[ii] * 0.01;
            fu = atr / (1 / inputZoneSize) * zone_fuzzfactor;
         }

         if (point_type == high_low)
            loval = Low[ii];
         else
            loval = MathMin(Close[ii], Open[ii]);

         if(zone_extend == true)
            loval -= fu;

         if (enableATR)
            hival = MathMin(MathMax(Close[ii], Low[ii] + fu), Low[ii] + fu * 2);
         else if (point_type == high_low)
            hival = MathMin(MathMax(Close[ii], Low[ii] + fu), Low[ii] + fu);
         else if (point_type == open_close)
            hival = loval + fu;

         turned = false;
         hasturned = false;

         bustcount = 0;
         testcount = 0;
         volumecount = 0;
         isBust = false;

         for(int i = ii - 1; i >= timeFrameBarTo + 0; i--) {
            hasGap = false;
            openval = Open[i];
            closeval = Close[i + 1];
            if (MathAbs(openval - closeval) >= openval * 0.001)
               hasGap = true;

            if((turned == true && FastUpPts[i] >= loval && FastUpPts[i] <= hival) || (turned == false && FastDnPts[i] <= hival && FastDnPts[i] >= loval)) {
               // Potential touch, just make sure its been 10+candles since the prev one
               touchOk = true;
               for(j = i + 1; j < i + 11; j++) {
                  if((turned == true && FastUpPts[j] >= loval && FastUpPts[j] <= hival) || (turned == false && FastDnPts[j] <= hival && FastDnPts[j] >= loval)) {
                     touchOk = false;
                     break;
                  }
               }

               if(touchOk == true) {
                  // we have a touch_  If its been busted once, remove bustcount
                  // as we know this level is still valid & has just switched sides
                  bustcount = 0;
                  testcount++;
                  volumecount = volumecount + Volume[i];
               }
            }

            if((turned == true && High[i] > hival) || (turned == false && Low[i] < loval)) {
               // this level has been busted at least once
               bustcount++;

               hasturned = true;
               //if (hasGap && considerGaps) {
               //   hasturned = false;
               //}

               if(bustcount > input_bust_count || isWeak == true) {
                  // busted twice or more
                  isBust = true;
                  break;
               }

               if(turned == true)
                  turned = false;
               else if(turned == false)
                  turned = true;

               // forget previous hits
               testcount = 0;
               volumecount = volumecount + Volume[i];
            }
         }

         if(isBust == false) {
            // level is still valid, add to our list
            //if (point_type == high_low) {
            temp_hi[temp_count] = hival;
            temp_lo[temp_count] = loval;
            //} else {
            //   temp_hi[temp_count] = MathMax(Open[ii], Close[ii]);
            //   temp_lo[temp_count] = MathMin(Open[ii], Close[ii]);
            //}
            temp_turn[temp_count] = hasturned;
            temp_hits[temp_count] = testcount;
            temp_volume[temp_count] = Volume[ii] + volumecount;
            temp_start[temp_count] = ii;
            temp_merge[temp_count] = false;

            if(testcount > 6)
               temp_strength[temp_count] = ZONE_SUPER;
            else if(testcount > 3)
               temp_strength[temp_count] = ZONE_PROVEN;
            else if(testcount > 0)
               temp_strength[temp_count] = ZONE_VERIFIED;
            else if(hasturned == true)
               temp_strength[temp_count] = ZONE_TURNCOAT;
            else if(isWeak == false)
               temp_strength[temp_count] = ZONE_UNTESTED;
            else
               temp_strength[temp_count] = ZONE_WEAK;

            temp_count++;
         }
      }
   }

   for(i = 0; i < temp_count; i++) {
      if(temp_count < 1000) {
         if(temp_hi[i] < Close[timeFrameBarTo + 4])
            temp_type[i] = ZONE_SUPPORT;
         else if(temp_lo[i] > Close[timeFrameBarTo + 4])
            temp_type[i] = ZONE_RESIST;
         else {
            int sh = MathMin(Bars(ativo, timeframe) - 1, timeFrameBarFrom);
            for(j = timeFrameBarTo + recentBars; j < sh; j++) {
               if(Close[j] < temp_lo[i]) {
                  temp_type[i] = ZONE_RESIST;
                  break;
               } else if(Close[j] > temp_hi[i]) {
                  temp_type[i] = ZONE_SUPPORT;
                  break;
               }
            }

            if(j == sh)
               temp_type[i] = ZONE_SUPPORT;
         }
      }
   }
// look for overlapping zones___
   if(zone_merge == true) {
      merge_count = 1;
      int iterations = 0;
      while(merge_count > 0 && iterations < 3) {
         merge_count = 0;
         iterations++;

         for(i = 0; i < temp_count; i++)
            temp_merge[i] = false;

         for(i = 0; i < temp_count - 1; i++) {
            if(temp_hits[i] == -1 || temp_merge[i] == true)
               continue;

            for(j = i + 1; j < temp_count; j++) {
               if(temp_hits[j] == -1 || temp_merge[j] == true)
                  continue;

               if (!zone_merge_weak && (((temp_strength[i] >= ZONE_VERIFIED && temp_strength[j] <= ZONE_UNTESTED) || (temp_strength[j] >= ZONE_VERIFIED && temp_strength[i] <= ZONE_UNTESTED)))) //dont merge strong and weak zones
                  continue;

               if((temp_hi[i] >= temp_lo[j] && temp_hi[i] <= temp_hi[j]) ||
                     (temp_lo[i] <= temp_hi[j] && temp_lo[i] >= temp_lo[j]) ||
                     (temp_hi[j] >= temp_lo[i] && temp_hi[j] <= temp_hi[i]) ||
                     (temp_lo[j] <= temp_hi[i] && temp_lo[j] >= temp_lo[i])) {
                  merge1[merge_count] = i;
                  merge2[merge_count] = j;
                  temp_merge[i] = true;
                  temp_merge[j] = true;
                  merge_count++;
               }
            }
         }

         // ___ and merge them ___
         for(i = 0; i < merge_count; i++) {
            int target = merge1[i];
            int source = merge2[i];

            temp_hi[target] = MathMax(temp_hi[target], temp_hi[source]);
            temp_lo[target] = MathMin(temp_lo[target], temp_lo[source]);
            temp_hits[target] += temp_hits[source];
            temp_start[target] = MathMax(temp_start[target], temp_start[source]);
            temp_strength[target] = MathMax(temp_strength[target], temp_strength[source]);

            if(temp_hits[target] > 6)
               temp_strength[target] = ZONE_SUPER;
            else if(temp_hits[target] > 3)
               temp_strength[target] = ZONE_PROVEN;

            if(temp_hits[target] == 0 && temp_turn[target] == false) {
               temp_hits[target] = 1;
               if(temp_strength[target] < ZONE_VERIFIED)
                  temp_strength[target] = ZONE_VERIFIED;
            }

            if(temp_turn[target] == false || temp_turn[source] == false)
               temp_turn[target] = false;

            if(temp_turn[target] == true)
               temp_hits[target] = 0;

            temp_hits[source] = -1;
         }
      }
   }

   if(zone_sum == true) {
      merge_count = 1;
      int iterations = 0;
      while(merge_count > 0 && iterations < 3) {
         merge_count = 0;
         iterations++;

         for(i = 0; i < temp_count; i++)
            temp_merge[i] = false;

         for(i = 0; i < temp_count - 1; i++) {
            if(temp_hits[i] == -1 || temp_merge[i] == true)
               continue;

            for(j = i + 1; j < temp_count; j++) {
               if(temp_hits[j] == -1 || temp_merge[j] == true)
                  continue;

               if (temp_type[i] != temp_type[j])
                  continue;

               if (temp_strength[i] != temp_strength[j])
                  continue;

               if((temp_hi[i] >= temp_lo[j] && temp_hi[i] <= temp_hi[j]) ||
                     (temp_lo[i] <= temp_hi[j] && temp_lo[i] >= temp_lo[j]) ||
                     (temp_hi[j] >= temp_lo[i] && temp_hi[j] <= temp_hi[i]) ||
                     (temp_lo[j] <= temp_hi[i] && temp_lo[j] >= temp_lo[i])) {
                  merge1[merge_count] = i;
                  merge2[merge_count] = j;
                  temp_merge[i] = true;
                  temp_merge[j] = true;
                  merge_count++;
               }
            }
         }

         // ___ and merge them ___
         for(i = 0; i < merge_count; i++) {
            int target = merge1[i];
            int source = merge2[i];

            temp_hi[target] = MathMax(temp_hi[target], temp_hi[source]);
            temp_lo[target] = MathMin(temp_lo[target], temp_lo[source]);
            temp_hits[target] += temp_hits[source];
            temp_volume[target] += temp_volume[source];
            temp_start[target] = MathMax(temp_start[target], temp_start[source]);
            temp_strength[target] = MathMax(temp_strength[target], temp_strength[source]);

            if(temp_hits[target] > 6)
               temp_strength[target] = ZONE_SUPER;
            else if(temp_hits[target] > 3)
               temp_strength[target] = ZONE_PROVEN;

            if(temp_hits[target] == 0 && temp_turn[target] == false) {
               temp_hits[target] = 1;
               if(temp_strength[target] < ZONE_VERIFIED)
                  temp_strength[target] = ZONE_VERIFIED;
            }

            if(temp_turn[target] == false || temp_turn[source] == false)
               temp_turn[target] = false;

            if(temp_turn[target] == true)
               temp_hits[target] = 0;

            temp_hits[source] = -1;
         }
      }
   }


// copy the remaining list into our official zones arrays
   zone_count = 0;
   ArrayResize(zone_hi, temp_count + 1);
   ArrayResize(zone_lo, temp_count + 1);
   ArrayResize(zone_start, temp_count + 1);
   ArrayResize(zone_age, temp_count + 1);
   ArrayResize(zone_hits, temp_count + 1);
   ArrayResize(zone_type, temp_count + 1);
   ArrayResize(zone_strength, temp_count + 1);
   ArrayResize(zone_turn, temp_count + 1);
   ArrayResize(zone_volume, temp_count + 1);
   ArrayResize(zone_amplitude, temp_count + 1);
   ArrayResize(zone_power, temp_count + 1);

   ArrayInitialize(zone_hi, 0);
   ArrayInitialize(zone_lo, 0);
   ArrayInitialize(zone_start, 0);
   ArrayInitialize(zone_age, 0);
   ArrayInitialize(zone_hits, 0);
   ArrayInitialize(zone_type, 0);
   ArrayInitialize(zone_strength, 0);
   ArrayInitialize(zone_turn, 0);
   ArrayInitialize(zone_volume, 0);
   ArrayInitialize(zone_amplitude, 0);

   for(i = 0; i < temp_count; i++) {
      if(temp_hits[i] >= 0 && zone_count < 1000) {
         zone_hi[zone_count]       = temp_hi[i];
         zone_lo[zone_count]       = temp_lo[i];
         zone_type[zone_count]     = temp_type[i];
         zone_hits[zone_count]     = temp_hits[i];
         zone_volume[zone_count]   = temp_volume[i];
         zone_turn[zone_count]     = temp_turn[i];
         zone_start[zone_count]    = temp_start[i];
         zone_strength[zone_count] = temp_strength[i];

         if(zone_hi[zone_count] < Close[timeFrameBarTo + 4])
            zone_type[zone_count] = ZONE_SUPPORT;
         else if(zone_lo[zone_count] > Close[timeFrameBarTo + 4])
            zone_type[zone_count] = ZONE_RESIST;
         else {
            int sh = MathMin(Bars(ativo, timeframe) - 1, timeFrameBarFrom);
            for(j = timeFrameBarTo + recentBars; j < sh; j++) {
               if(Close[j] < zone_lo[zone_count]) {
                  zone_type[zone_count] = ZONE_RESIST;
                  break;
               } else if(Close[j] > zone_hi[zone_count]) {
                  zone_type[zone_count] = ZONE_SUPPORT;
                  break;
               }
            }

            if(j == sh)
               zone_type[zone_count] = ZONE_SUPPORT;
         }
         zone_count++;
      }
   }

// process to merge (near) identical zones
   double onetick = SymbolInfoDouble(ativo, SYMBOL_TRADE_TICK_VALUE) * 3;
   if(zone_merge_identical == true) {
      for(i = 0; i < temp_count - 1; i++) {
         if(zone_hits[i] == -1)
            continue;

         for(j = i + 1; j < temp_count; j++) {
            if(zone_hits[j] == -1)
               continue;

            if(zone_type[i] == zone_type[j] && zone_hi[i] <= zone_hi[j] + onetick && zone_hi[i] >= zone_hi[j] - onetick) {
               zone_hi[i] = MathMax(zone_hi[i], zone_hi[j]);
               zone_lo[i] = MathMin(zone_lo[i], zone_lo[j]);
               zone_hits[i] += zone_hits[j];
               zone_volume[i] += zone_volume[j];
               zone_start[i] = MathMax(zone_start[i], zone_start[j]);
               zone_strength[i] = MathMax(zone_strength[i], zone_strength[j]);

               zone_hi[j] = 0;
               zone_lo[j] = 0;
               zone_hits[j] = 0;
               zone_age[j] = 0;
               zone_start[j] = 0;
               zone_strength[j] = 0;
               zone_turn[j] = 0;
               zone_volume[j] = 0;
            }
         }
      }
   }



}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawZones() {

   double lower_nerest_zone_P1 = 0;
   double lower_nerest_zone_P2 = 0;
   double higher_nerest_zone_P1 = 99999;
   double higher_nerest_zone_P2 = 99999;

   double fech = iClose(NULL, PERIOD_CURRENT, 0);

   int firstBar = WindowFirstVisibleBar();
   datetime timeFirstBar = iTime(ativo, PERIOD_CURRENT, firstBar);
   datetime filterUpToTime = iTime(ativo, PERIOD_D1, filterException);
   datetime current_time, start_time;
   if (extendZoneToRight)
      current_time = iTime(ativo, PERIOD_CURRENT, 0 + rightOffset);
   else
      current_time = iTime(ativo, PERIOD_CURRENT, barTo + rightOffset);

   int filterUpToBar = Bars(ativo, timeframe, current_time, filterUpToTime);

   if(SetGlobals == true) {
      GlobalVariableSet(Id + "_" + "SSSR_Count_" + ativo + TFTS(timeframe), zone_count);
      GlobalVariableSet(Id + "_" + "SSSR_Updated_" + ativo + TFTS(timeframe), TimeCurrent());
   }

   for(int i = 0; i < zone_count; i++) {
      zone_age[i] = MathAbs(iBarShift(ativo, PERIOD_CURRENT, current_time) - zone_start[i]);
      zone_amplitude[i] = NormalizeDouble(zone_hi[i] - zone_lo[i], digitos);
      zone_power[i] = (zone_age[i] * ((zone_hits[i] + 1) + zone_strength[i]));
   }

   double maxPower = zone_power[ArrayMaximum(zone_power)];
   double minPower = zone_power[ArrayMinimum(zone_power)];

   for(int i = 0; i < zone_count; i++) {
      zone_power[i] = NormalizeDouble(zone_power[i] / maxPower * 100, 4);
      sumForce = sumForce + zone_power[i];
   }

   if (extendZoneToLeft) {
      for(int i = 0; i < zone_count; i++) {
         zone_start[i] = timeFirstBar;
      }
   }

   if (zone_count > 0)
      averageForce = sumForce / zone_count;
   else
      averageForce = 0;

   for(int i = 0; i < zone_count; i++) {
      //if (zone_start[i] >= filterUpToBar) {
      if (zone_age[i] < ageFilter)
         continue;

      if (zone_amplitude[i] < amplitudeFilter)
         continue;

      if (distanceFilter > 0)
         if ((zone_lo[i] >= (1 + distanceFilter / 100) * fech) || (zone_hi[i] <= (1 - distanceFilter / 100) * fech))
            continue;

      if (zone_volume[i] < volumeFilterSuper && zone_strength[i] == ZONE_SUPER)
         continue;

      if (zone_volume[i] < volumeFilterProven && zone_strength[i] == ZONE_PROVEN)
         continue;

      if (zone_volume[i] < volumeFilterVerified && zone_strength[i] == ZONE_VERIFIED)
         continue;

      if (zone_volume[i] < volumeFilterUntested && zone_strength[i] == ZONE_UNTESTED)
         continue;

      if (zone_volume[i] < volumeFilterWeak && zone_strength[i] == ZONE_WEAK)
         continue;

      if (zone_volume[i] < volumeFilterBroken && zone_strength[i] == ZONE_TURNCOAT)
         continue;

      if (zone_power[i] < averageForce * (averageFilter / 100))
         continue;

      if(zone_strength[i] == ZONE_WEAK && zone_show_weak == false)
         continue;

      if(zone_strength[i] == ZONE_UNTESTED && zone_show_untested == false)
         continue;

      if(zone_strength[i] == ZONE_TURNCOAT && zone_show_turncoat == false)
         continue;
      //}

      //name sup
      string s;
      s = Id + "_" + "SSSR#" + string(i) + " Strength=";

      if(zone_strength[i] == ZONE_SUPER) {
         if (zone_short_naming)
            s = s + "S" + string(zone_hits[i]) + "+" + " " + zone_volume[i];
         else
            s = s + "Super, Test Count=" + string(zone_hits[i]);
      } else if(zone_strength[i] == ZONE_PROVEN) {
         if (zone_short_naming)
            s = s + "S" + string(zone_hits[i]) + " " + zone_volume[i];
         else
            s = s + "Proven, Test Count=" + string(zone_hits[i]);
      } else if(zone_strength[i] == ZONE_VERIFIED) {
         if (zone_short_naming)
            s = s + "A" + string(zone_hits[i]) + " " + zone_volume[i];
         else
            s = s + "Verified, Test Count=" + string(zone_hits[i]);
      } else if(zone_strength[i] == ZONE_UNTESTED) {
         if (zone_short_naming)
            s = s + "C" + " " + zone_volume[i];
         else
            s = s + "Untested";
      } else if(zone_strength[i] == ZONE_TURNCOAT) {
         if (zone_short_naming)
            s = s + "D" + " " + zone_volume[i];
         else
            s = s + "Broken";
      } else {
         if (zone_short_naming)
            s = s + "B" + " " + zone_volume[i];
         else
            s = s + "Weak";
      }

      if(CopyTime(ativo, timeframe, 0, zone_start[i] + 1, ZoneTime) == -1) {
         Comment(comment);
         return;
      } else {
         if(StringFind(ChartGetString(0, CHART_COMMENT), comment) >= 0)
            Comment("");
      }

      start_time = iTime(ativo, timeframe, zone_start[i]);
      if (shortMode) {
         start_time = iTime(ativo, PERIOD_CURRENT, 0) + PeriodSeconds() * input_start;
         current_time = iTime(ativo, PERIOD_CURRENT, 0) + PeriodSeconds() * input_end;
      }

      ObjectCreate(0, s, OBJ_RECTANGLE, 0, 0, 0, 0, 0);
      ObjectSetInteger(0, s, OBJPROP_TIME, 0, start_time);
      ObjectSetInteger(0, s, OBJPROP_TIME, 1, current_time);
      ObjectSetDouble(0, s, OBJPROP_PRICE, 0, zone_hi[i]);
      ObjectSetDouble(0, s, OBJPROP_PRICE, 1, zone_lo[i]);
      ObjectSetInteger(0, s, OBJPROP_BACK, true);
      ObjectSetInteger(0, s, OBJPROP_FILL, zone_solid);
      //ObjectSetInteger(0,s,OBJPROP_FILL, 0);
      ObjectSetInteger(0, s, OBJPROP_WIDTH, zone_linewidth);
      ObjectSetInteger(0, s, OBJPROP_STYLE, zone_style);
      ObjectSetInteger(0, s, OBJPROP_ZORDER, 0);
      ObjectSetInteger(0, s, OBJPROP_HIDDEN, 1);
      ObjectSetString(0, s, OBJPROP_TOOLTIP,
                      "TF:      " + GetTimeFrame(Timeframe) +
                      "\nStart:  " + iTime(ativo, timeframe, zone_start[i]) +
                      "\nEnd:   " + current_time +
                      "\nHigh:  " + DoubleToString(zone_hi[i], digitos) +
                      "\nLow:   " + DoubleToString(zone_lo[i], digitos) +
                      "\nSize:   " + DoubleToString(zone_hi[i] - zone_lo[i], digitos) +
                      "\nAge:    " + DoubleToString(zone_age[i], 0) +
                      "\nVolume: " + DoubleToString(zone_volume[i], 0) +
                      "\nStr:     " + DoubleToString(zone_strength[i], 0));

      string sProj1 = s + "proj1";
      string sProj2 = s + "proj2";
      string sProj3 = s + "proj3";
      if (!enableATR && enablePercentProj1 > 0) {
         ObjectCreate(0, sProj1, OBJ_TREND, 0, 0, 0, 0, 0);
         ObjectSetInteger(0, sProj1, OBJPROP_TIME, 0, start_time);
         ObjectSetInteger(0, sProj1, OBJPROP_TIME, 1, current_time);

         ObjectSetInteger(0, sProj1, OBJPROP_BACK, true);
         ObjectSetInteger(0, sProj1, OBJPROP_FILL, zone_solid);
         //ObjectSetInteger(0,s,OBJPROP_FILL, 0);
         ObjectSetInteger(0, sProj1, OBJPROP_WIDTH, zone_linewidth);
         ObjectSetInteger(0, sProj1, OBJPROP_STYLE, STYLE_DASH);
         ObjectSetInteger(0, sProj1, OBJPROP_ZORDER, 0);
         ObjectSetInteger(0, sProj1, OBJPROP_HIDDEN, 1);
         ObjectSetString(0, sProj1, OBJPROP_TOOLTIP,
                         "TF:      " + GetTimeFrame(Timeframe) + " (" + enablePercentProj1 + "%)" +
                         "\nStart:  " + iTime(ativo, timeframe, zone_start[i]) +
                         "\nEnd:   " + current_time +
                         "\nHigh:  " + DoubleToString(zone_hi[i], digitos) +
                         "\nLow:   " + DoubleToString(zone_lo[i], digitos) +
                         "\nSize:   " + DoubleToString(zone_hi[i] - zone_lo[i], digitos) +
                         "\nAge:    " + DoubleToString(zone_age[i], 0) +
                         "\nStr:     " + DoubleToString(zone_strength[i], 0));
      }

      if (!enableATR && enablePercentProj2 > 0) {
         ObjectCreate(0, sProj2, OBJ_TREND, 0, 0, 0, 0, 0);
         ObjectSetInteger(0, sProj2, OBJPROP_TIME, 0, start_time);
         ObjectSetInteger(0, sProj2, OBJPROP_TIME, 1, current_time);

         ObjectSetInteger(0, sProj2, OBJPROP_BACK, true);
         ObjectSetInteger(0, sProj2, OBJPROP_FILL, zone_solid);
         //ObjectSetInteger(0,s,OBJPROP_FILL, 0);
         ObjectSetInteger(0, sProj2, OBJPROP_WIDTH, zone_linewidth);
         ObjectSetInteger(0, sProj2, OBJPROP_STYLE, STYLE_DASH);
         ObjectSetInteger(0, sProj2, OBJPROP_ZORDER, 0);
         ObjectSetInteger(0, sProj2, OBJPROP_HIDDEN, 1);
         ObjectSetString(0, sProj2, OBJPROP_TOOLTIP,
                         "TF:      " + GetTimeFrame(Timeframe) + " (" + enablePercentProj2 + "%)" +
                         "\nStart:  " + iTime(ativo, timeframe, zone_start[i]) +
                         "\nEnd:   " + current_time +
                         "\nHigh:  " + DoubleToString(zone_hi[i], digitos) +
                         "\nLow:   " + DoubleToString(zone_lo[i], digitos) +
                         "\nSize:   " + DoubleToString(zone_hi[i] - zone_lo[i], digitos) +
                         "\nAge:    " + DoubleToString(zone_age[i], 0) +
                         "\nStr:     " + DoubleToString(zone_strength[i], 0));
      }

      if (!enableATR && enablePercentProj3 > 0) {
         ObjectCreate(0, sProj3, OBJ_TREND, 0, 0, 0, 0, 0);
         ObjectSetInteger(0, sProj3, OBJPROP_TIME, 0, start_time);
         ObjectSetInteger(0, sProj3, OBJPROP_TIME, 1, current_time);

         ObjectSetInteger(0, sProj3, OBJPROP_BACK, true);
         ObjectSetInteger(0, sProj3, OBJPROP_FILL, zone_solid);
         //ObjectSetInteger(0,s,OBJPROP_FILL, 0);
         ObjectSetInteger(0, sProj3, OBJPROP_WIDTH, zone_linewidth);
         ObjectSetInteger(0, sProj3, OBJPROP_STYLE, STYLE_DASH);
         ObjectSetInteger(0, sProj3, OBJPROP_ZORDER, 0);
         ObjectSetInteger(0, sProj3, OBJPROP_HIDDEN, 1);
         ObjectSetString(0, sProj3, OBJPROP_TOOLTIP,
                         "TF:      " + GetTimeFrame(Timeframe) + " (" + enablePercentProj3 + "%)" +
                         "\nStart:  " + iTime(ativo, timeframe, zone_start[i]) +
                         "\nEnd:   " + current_time +
                         "\nHigh:  " + DoubleToString(zone_hi[i], digitos) +
                         "\nLow:   " + DoubleToString(zone_lo[i], digitos) +
                         "\nSize:   " + DoubleToString(zone_hi[i] - zone_lo[i], digitos) +
                         "\nAge:    " + DoubleToString(zone_age[i], 0) +
                         "\nStr:     " + DoubleToString(zone_strength[i], 0));
      }

      if(zone_type[i] == ZONE_SUPPORT) {
         // support zone
         if (!enableATR && enablePercentProj1 > 0) {
            ObjectSetDouble(0, sProj1, OBJPROP_PRICE, 0, zone_lo[i] + zone_lo[i] * enablePercentProj1 / 100);
            ObjectSetDouble(0, sProj1, OBJPROP_PRICE, 1, zone_lo[i] + zone_lo[i] * enablePercentProj1 / 100);
         }

         if (!enableATR && enablePercentProj2 > 0) {
            ObjectSetDouble(0, sProj2, OBJPROP_PRICE, 0, zone_lo[i] + zone_lo[i] * enablePercentProj2 / 100);
            ObjectSetDouble(0, sProj2, OBJPROP_PRICE, 1, zone_lo[i] + zone_lo[i] * enablePercentProj2 / 100);
         }

         if (!enableATR && enablePercentProj3 > 0) {
            ObjectSetDouble(0, sProj3, OBJPROP_PRICE, 0, zone_lo[i] + zone_lo[i] * enablePercentProj3 / 100);
            ObjectSetDouble(0, sProj3, OBJPROP_PRICE, 1, zone_lo[i] + zone_lo[i] * enablePercentProj3 / 100);
         }

         if(zone_strength[i] == ZONE_TURNCOAT) {
            ObjectSetInteger(0, s, OBJPROP_COLOR, color_support_turncoat);
            ObjectSetInteger(0, sProj1, OBJPROP_COLOR, color_support_turncoat);
            ObjectSetInteger(0, sProj2, OBJPROP_COLOR, color_support_turncoat);
            ObjectSetInteger(0, sProj3, OBJPROP_COLOR, color_support_turncoat);
         } else if(zone_strength[i] == ZONE_SUPER) {
            ObjectSetInteger(0, s, OBJPROP_COLOR, color_support_super);
            ObjectSetInteger(0, sProj1, OBJPROP_COLOR, color_support_super);
            ObjectSetInteger(0, sProj2, OBJPROP_COLOR, color_support_super);
            ObjectSetInteger(0, sProj3, OBJPROP_COLOR, color_support_super);
         } else if(zone_strength[i] == ZONE_PROVEN) {
            ObjectSetInteger(0, s, OBJPROP_COLOR, color_support_proven);
            ObjectSetInteger(0, sProj1, OBJPROP_COLOR, color_support_proven);
            ObjectSetInteger(0, sProj2, OBJPROP_COLOR, color_support_proven);
            ObjectSetInteger(0, sProj3, OBJPROP_COLOR, color_support_proven);
         } else if(zone_strength[i] == ZONE_VERIFIED) {
            ObjectSetInteger(0, s, OBJPROP_COLOR, color_support_verified);
            ObjectSetInteger(0, sProj1, OBJPROP_COLOR, color_support_verified);
            ObjectSetInteger(0, sProj2, OBJPROP_COLOR, color_support_verified);
            ObjectSetInteger(0, sProj3, OBJPROP_COLOR, color_support_verified);
         } else if(zone_strength[i] == ZONE_UNTESTED) {
            ObjectSetInteger(0, s, OBJPROP_COLOR, color_support_untested);
            ObjectSetInteger(0, sProj1, OBJPROP_COLOR, color_support_untested);
            ObjectSetInteger(0, sProj2, OBJPROP_COLOR, color_support_untested);
            ObjectSetInteger(0, sProj3, OBJPROP_COLOR, color_support_untested);
         } else {
            ObjectSetInteger(0, s, OBJPROP_COLOR, color_support_weak);
            ObjectSetInteger(0, sProj1, OBJPROP_COLOR, color_support_weak);
            ObjectSetInteger(0, sProj2, OBJPROP_COLOR, color_support_weak);
            ObjectSetInteger(0, sProj3, OBJPROP_COLOR, color_support_weak);
         }
      } else {
         // resistance zone
         if (!enableATR && enablePercentProj1) {
            ObjectSetDouble(0, sProj1, OBJPROP_PRICE, 0, zone_hi[i] - zone_hi[i] * enablePercentProj1 / 100);
            ObjectSetDouble(0, sProj1, OBJPROP_PRICE, 1, zone_hi[i] - zone_hi[i] * enablePercentProj1 / 100);
         }

         if (!enableATR && enablePercentProj2) {
            ObjectSetDouble(0, sProj2, OBJPROP_PRICE, 0, zone_hi[i] - zone_hi[i] * enablePercentProj2 / 100);
            ObjectSetDouble(0, sProj2, OBJPROP_PRICE, 1, zone_hi[i] - zone_hi[i] * enablePercentProj2 / 100);
         }

         if (!enableATR && enablePercentProj3) {
            ObjectSetDouble(0, sProj3, OBJPROP_PRICE, 0, zone_hi[i] - zone_hi[i] * enablePercentProj3 / 100);
            ObjectSetDouble(0, sProj3, OBJPROP_PRICE, 1, zone_hi[i] - zone_hi[i] * enablePercentProj3 / 100);
         }

         if(zone_strength[i] == ZONE_TURNCOAT) {
            ObjectSetInteger(0, s, OBJPROP_COLOR, color_resist_turncoat);
            ObjectSetInteger(0, sProj1, OBJPROP_COLOR, color_resist_turncoat);
            ObjectSetInteger(0, sProj2, OBJPROP_COLOR, color_resist_turncoat);
            ObjectSetInteger(0, sProj3, OBJPROP_COLOR, color_resist_turncoat);
         } else if(zone_strength[i] == ZONE_SUPER) {
            ObjectSetInteger(0, s, OBJPROP_COLOR, color_resist_super);
            ObjectSetInteger(0, sProj1, OBJPROP_COLOR, color_resist_super);
            ObjectSetInteger(0, sProj2, OBJPROP_COLOR, color_resist_super);
            ObjectSetInteger(0, sProj3, OBJPROP_COLOR, color_resist_super);
         } else if(zone_strength[i] == ZONE_PROVEN) {
            ObjectSetInteger(0, s, OBJPROP_COLOR, color_resist_proven);
            ObjectSetInteger(0, sProj1, OBJPROP_COLOR, color_resist_proven);
            ObjectSetInteger(0, sProj2, OBJPROP_COLOR, color_resist_proven);
            ObjectSetInteger(0, sProj3, OBJPROP_COLOR, color_resist_proven);
         } else if(zone_strength[i] == ZONE_VERIFIED) {
            ObjectSetInteger(0, s, OBJPROP_COLOR, color_resist_verified);
            ObjectSetInteger(0, sProj1, OBJPROP_COLOR, color_resist_verified);
            ObjectSetInteger(0, sProj2, OBJPROP_COLOR, color_resist_verified);
            ObjectSetInteger(0, sProj3, OBJPROP_COLOR, color_resist_verified);
         } else if(zone_strength[i] == ZONE_UNTESTED) {
            ObjectSetInteger(0, s, OBJPROP_COLOR, color_resist_untested);
            ObjectSetInteger(0, sProj1, OBJPROP_COLOR, color_resist_untested);
            ObjectSetInteger(0, sProj2, OBJPROP_COLOR, color_resist_untested);
            ObjectSetInteger(0, sProj3, OBJPROP_COLOR, color_resist_untested);
         } else {
            ObjectSetInteger(0, s, OBJPROP_COLOR, color_resist_weak);
            ObjectSetInteger(0, sProj1, OBJPROP_COLOR, color_resist_weak);
            ObjectSetInteger(0, sProj2, OBJPROP_COLOR, color_resist_weak);
            ObjectSetInteger(0, sProj3, OBJPROP_COLOR, color_resist_weak);
         }
      }

      if(SetGlobals == true) {
         GlobalVariableSet(Id + "_" + "SSSR_HI_" + ativo + TFTS(timeframe) + string(i), zone_hi[i]);
         GlobalVariableSet(Id + "_" + "SSSR_LO_" + ativo + TFTS(timeframe) + string(i), zone_lo[i]);
         GlobalVariableSet(Id + "_" + "SSSR_HITS_" + ativo + TFTS(timeframe) + string(i), zone_hits[i]);
         GlobalVariableSet(Id + "_" + "SSSR_STRENGTH_" + ativo + TFTS(timeframe) + string(i), zone_strength[i]);
         GlobalVariableSet(Id + "_" + "SSSR_AGE_" + ativo + TFTS(timeframe) + string(i), zone_start[i]);
      }

      //nearest zones
      double price = SymbolInfoDouble(ativo, SYMBOL_BID);
      if(zone_lo[i] > lower_nerest_zone_P2 && price > zone_lo[i]) {
         lower_nerest_zone_P1 = zone_hi[i];
         lower_nerest_zone_P2 = zone_lo[i];
      }

      if(zone_hi[i] < higher_nerest_zone_P1 && price < zone_hi[i]) {
         higher_nerest_zone_P1 = zone_hi[i];
         higher_nerest_zone_P2 = zone_lo[i];
      }
   }
   ner_hi_zone_P1[0] = higher_nerest_zone_P1;
   ner_hi_zone_P2[0] = higher_nerest_zone_P2;
   ner_lo_zone_P1[0] = lower_nerest_zone_P1;
   ner_lo_zone_P2[0] = lower_nerest_zone_P2;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void showLabels() {
   datetime Time = iTime(NULL, timeframe, barTo);
   int firstBar = WindowFirstVisibleBar();
   datetime timeFirstBar = iTime(ativo, PERIOD_CURRENT, firstBar);
   datetime filterUpToTime = iTime(ativo, PERIOD_D1, filterException);
   datetime current_time, start_time;
   string s;
   if (extendZoneToRight)
      current_time = iTime(ativo, PERIOD_CURRENT, 0);
   else
      current_time = iTime(ativo, PERIOD_CURRENT, barTo);

   int filterUpToBar = Bars(ativo, timeframe, current_time, filterUpToTime);

   double vpos;
   color lblColor;
   double fech = iClose(NULL, PERIOD_CURRENT, 0);
   ENUM_ANCHOR_POINT ancoragem = anchor;

   for(int i = 0; i < zone_count; i++) {
      string lbl;

      //if (zone_start[i] >= filterUpToBar) {

      if (zone_age[i] < ageFilter)
         continue;

      if (zone_amplitude[i] < amplitudeFilter)
         continue;

      if (distanceFilter > 0)
         if ((zone_lo[i] >= (1 + distanceFilter / 100) * fech) || (zone_hi[i] <= (1 - distanceFilter / 100) * fech))
            continue;

      if (zone_volume[i] < volumeFilterSuper && zone_strength[i] == ZONE_SUPER)
         continue;

      if (zone_volume[i] < volumeFilterProven && zone_strength[i] == ZONE_PROVEN)
         continue;

      if (zone_volume[i] < volumeFilterVerified && zone_strength[i] == ZONE_VERIFIED)
         continue;

      if (zone_volume[i] < volumeFilterUntested && zone_strength[i] == ZONE_UNTESTED)
         continue;

      if (zone_volume[i] < volumeFilterWeak && zone_strength[i] == ZONE_WEAK)
         continue;

      if (zone_volume[i] < volumeFilterBroken && zone_strength[i] == ZONE_TURNCOAT)
         continue;

      //}

      //if (zone_power[i] < averageForce * (averageFilter / 100))
      //   continue;

      if(zone_type[i] == ZONE_SUPPORT) {
         if(zone_strength[i] == ZONE_SUPER) {
            if (zone_short_naming)
               lbl = "S" + string(zone_hits[i]) + "+" + " " + zone_volume[i];
            else
               lbl = "Super" + string(zone_hits[i]);
            lblColor = color_support_super;
         } else if(zone_strength[i] == ZONE_PROVEN) {
            if (zone_short_naming)
               lbl = "S" + string(zone_hits[i]) + " " + zone_volume[i];
            else
               lbl = "Proven" + string(zone_hits[i]);
            lblColor = color_support_proven;
         } else if(zone_strength[i] == ZONE_VERIFIED) {
            if (zone_short_naming)
               lbl = "A" + string(zone_hits[i]) + " " + zone_volume[i];
            else
               lbl = "Verified" + string(zone_hits[i]);
            lblColor = color_support_verified;
         } else if(zone_strength[i] == ZONE_UNTESTED) {
            if (zone_short_naming)
               lbl = "C" + " " + zone_volume[i];
            else
               lbl = "Untested";
            lblColor = color_support_untested;
         } else if(zone_strength[i] == ZONE_TURNCOAT) {
            if (zone_short_naming)
               lbl = "D" + " " + zone_volume[i];
            else
               lbl = "Broken";
            lblColor = color_support_turncoat;
         } else {
            if (zone_short_naming)
               lbl = "B" + " " + zone_volume[i];
            else
               lbl = "Weak";
            lblColor = color_support_weak;
         }
      } else {
         if(zone_strength[i] == ZONE_SUPER) {
            if (zone_short_naming)
               lbl = "S" + string(zone_hits[i]) + "+" + " " + zone_volume[i];
            else
               lbl = "Super" + string(zone_hits[i]);
            lblColor = color_resist_super;
         } else if(zone_strength[i] == ZONE_PROVEN) {
            if (zone_short_naming)
               lbl = "S" + string(zone_hits[i]) + " " + zone_volume[i];
            else
               lbl = "Proven" + string(zone_hits[i]);
            lblColor = color_resist_proven;
         } else if(zone_strength[i] == ZONE_VERIFIED) {
            if (zone_short_naming)
               lbl = "A" + string(zone_hits[i]) + " " + zone_volume[i];
            else
               lbl = "Verified" + string(zone_hits[i]);
            lblColor = color_resist_verified;
         } else if(zone_strength[i] == ZONE_UNTESTED) {
            if (zone_short_naming)
               lbl = "C" + " " + zone_volume[i];
            else
               lbl = "Untested";
            lblColor = color_resist_untested;
         } else if(zone_strength[i] == ZONE_TURNCOAT) {
            if (zone_short_naming)
               lbl = "D" + " " + zone_volume[i];
            else
               lbl = "Broken";
            lblColor = color_resist_turncoat;
         } else {
            if (zone_short_naming)
               lbl = "B" + " " + zone_volume[i];
            else
               lbl = "Weak";
            lblColor = color_resist_weak;
         }
      }

      if(zone_type[i] == ZONE_SUPPORT) {
         lbl = lbl + sup_name;
         ancoragem = ANCHOR_LEFT_LOWER;
         if (price_distance == far_from_price)
            vpos = zone_hi[i];
         else
            vpos = zone_lo[i];
      } else {
         lbl = lbl + res_name;
         ancoragem = ANCHOR_LEFT_UPPER;
         if (price_distance == far_from_price)
            vpos = zone_lo[i];
         else
            vpos = zone_hi[i];
      }

      //if(zone_hits[i] > 0 && zone_strength[i] > ZONE_UNTESTED) {
      //   lbl = lbl + "(" + test_name + string(zone_hits[i]) + ")";
      //}

      datetime timeLeft = iTime(ativo, timeframe, zone_start[i]);


      if (timeLeft < timeFirstBar) {
         timeLeft = timeFirstBar;
      }

      if(zone_strength[i] == ZONE_WEAK && zone_show_weak == false)
         continue;
      if(zone_strength[i] == ZONE_UNTESTED && zone_show_untested == false)
         continue;
      if(zone_strength[i] == ZONE_TURNCOAT && zone_show_turncoat == false)
         continue;

      if (showLabelPowerInsideBox) {
         if(zone_type[i] == ZONE_SUPPORT) {
            if (price_distance == far_from_price)
               vpos = zone_hi[i];
            else
               vpos = zone_lo[i];
         } else {
            if (price_distance == far_from_price)
               vpos = zone_lo[i];
            else
               vpos = zone_hi[i];
         }

         s = Id + "_" + "SSSR#" + string(i) + "LBLINSIDE";
         ObjectCreate(0, s, OBJ_TEXT, 0, 0, 0);
         ObjectSetInteger(0, s, OBJPROP_TIME, iTime(NULL, timeframe, barTo) + PeriodSeconds() * 2);
         if (zone_power[i] <= 0.01)
            ObjectSetString(0, s, OBJPROP_TEXT, DoubleToString(zone_power[i], 4));
         else
            ObjectSetString(0, s, OBJPROP_TEXT, DoubleToString(zone_power[i], 2));

      } else {

         if (showAmplitude) {
            lbl = lbl + "(" + DoubleToString(zone_amplitude[i], digitos) + " pts)";
         }

         if (showAge) {
            lbl = lbl + "(" + DoubleToString(zone_age[i], 0) + " b)";
         }

         if (showPower) {
            if (zone_power[i] <= 0.01)
               lbl = lbl + "(" + DoubleToString(zone_power[i], 4) + ")";
            else
               lbl = lbl + "(" + DoubleToString(zone_power[i], 2) + ")";
         }

         s = Id + "_" + "SSSR#" + string(i) + "LBL";

         if (labelOnRight)
            timeLeft = iTime(ativo, PERIOD_CURRENT, barTo);

         if (shortMode)
            timeLeft = iTime(ativo, PERIOD_CURRENT, 0) + PeriodSeconds() * input_start;

      }

      ObjectCreate(0, s, OBJ_TEXT, 0, 0, 0);
      ObjectSetInteger(0, s, OBJPROP_TIME, timeLeft);
      ObjectSetDouble(0, s, OBJPROP_PRICE, vpos);
      ObjectSetString(0, s, OBJPROP_TEXT, lbl);
      ObjectSetString(0, s, OBJPROP_FONT, Text_font);
      ObjectSetInteger(0, s, OBJPROP_FONTSIZE, Text_size);

      if (Text_color_sync)
         ObjectSetInteger(0, s, OBJPROP_COLOR, lblColor);
      else
         ObjectSetInteger(0, s, OBJPROP_COLOR, Text_color);

      ObjectSetInteger(0, s, OBJPROP_ANCHOR, ancoragem);
      ObjectSetInteger(0, s, OBJPROP_HIDDEN, 1);
      ObjectSetInteger(0, s, OBJPROP_ZORDER, 9999999);
      ObjectSetString(0, s, OBJPROP_TOOLTIP,
                      "TF:" + GetTimeFrame(Timeframe) +
                      "\nType:" + GetZoneType(zone_type[i]) +
                      "\nStart:" + iTime(ativo, timeframe, zone_start[i]) +
                      "\nEnd:" + current_time +
                      "\nHigh:" + DoubleToString(zone_hi[i], digitos) +
                      "\nLow:" + DoubleToString(zone_lo[i], digitos) +
                      "\nSize:" + DoubleToString(zone_hi[i] - zone_lo[i], digitos) +
                      "\nAge:" + DoubleToString(zone_age[i], 0) +
                      "\nVolume:" + DoubleToString(zone_volume[i], 0) +
                      "\nStr:" + GetZoneType(zone_strength[i]));
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void FindFractals() {
//--- FindFractals
   FastUpPts[0] = 0.0;
   FastUpPts[1] = 0.0;
   FastDnPts[0] = 0.0;
   FastDnPts[1] = 0.0;

   SlowUpPts[0] = 0.0;
   SlowUpPts[1] = 0.0;
   SlowDnPts[0] = 0.0;
   SlowDnPts[1] = 0.0;

   for(int shift = limitCurrentTimeframe; shift > timeFrameBarTo + 1; shift--) {
      if(Fractal(UP_POINT, P1, shift) == true) {
         //if (point_type == high_low)
         FastUpPts[shift] = High[shift];
         //else
         //   FastUpPts[shift] = MathMax(Open[shift], Close[shift]);
      } else {
         FastUpPts[shift] = 0.0;
      }

      if(Fractal(DN_POINT, P1, shift) == true) {
         //if (point_type == high_low)
         FastDnPts[shift] = Low[shift];
         //else
         //FastDnPts[shift] = MathMin(Open[shift], Close[shift]);
      } else {
         FastDnPts[shift] = 0.0;
      }

      if(Fractal(UP_POINT, P2, shift) == true) {
         //if (point_type == high_low)
         SlowUpPts[shift] = High[shift];
         //else
         //SlowUpPts[shift] = MathMax(Open[shift], Close[shift]);
      } else {
         SlowUpPts[shift] = 0.0;
      }

      if(Fractal(DN_POINT, P2, shift) == true) {
         //if (point_type == high_low)
         SlowDnPts[shift] = Low[shift];
         //else
         //SlowDnPts[shift] = MathMin(Open[shift], Close[shift]);
      } else {
         SlowDnPts[shift] = 0.0;
      }

      ner_hi_zone_P1[shift] = 0;
      ner_hi_zone_P2[shift] = 0;
      ner_lo_zone_P1[shift] = 0;
      ner_lo_zone_P2[shift] = 0;
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Fractal(int M, int P, int pShift) {

   if(timeframe > P)
      P = timeframe;

   P = int(P / int(timeframe) * 2 + MathCeil(P / timeframe / 2));

   if(pShift < P)
      return(false);

   if(pShift > Bars(ativo, timeframe) - P - 1)
      return(false);

   for(int i = 1; i <= P; i++) {
      if(M == UP_POINT) {
         if(High[pShift + i] > High[pShift])
            return(false);
         if(High[pShift - i] >= High[pShift])
            return(false);
      }
      if(M == DN_POINT) {
         if(Low[pShift + i] < Low[pShift])
            return(false);
         if(Low[pShift - i] <= Low[pShift])
            return(false);
      }
   }

   return(true);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool NewBar() {
   static datetime LastTime;
   if(iTime(ativo, timeframe, 0) + time_offset != LastTime) {
      LastTime = iTime(ativo, timeframe, 0) + time_offset;
      return (true);
   } else
      return (false);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteZones() {
   int len = 5 + StringLen(Id + "_");
   int i = 0;
   while(i < ObjectsTotal(0, 0, -1)) {
      string objName = ObjectName(0, i, 0, -1);
      if(StringSubstr(objName, 0, len) != (Id + "_" + "SSSR#")) {
         i++;
         continue;
      }
      ObjectDelete(0, objName);
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string TFTS(int tf) { //--- Timeframe to string
   string tfs;

   switch(tf) {
   case PERIOD_M1:
      tfs = "M1";
      break;
   case PERIOD_M2:
      tfs = "M2";
      break;
   case PERIOD_M3:
      tfs = "M3";
      break;
   case PERIOD_M4:
      tfs = "M4";
      break;
   case PERIOD_M5:
      tfs = "M5";
      break;
   case PERIOD_M6:
      tfs = "M6";
      break;
   case PERIOD_M10:
      tfs = "M10";
      break;
   case PERIOD_M12:
      tfs = "M12";
      break;
   case PERIOD_M15:
      tfs = "M15";
      break;
   case PERIOD_M20:
      tfs = "M20";
      break;
   case PERIOD_M30:
      tfs = "M30";
      break;
   case PERIOD_H1:
      tfs = "H1";
      break;
   case PERIOD_H2:
      tfs = "H2";
      break;
   case PERIOD_H3:
      tfs = "H3";
      break;
   case PERIOD_H4:
      tfs = "H4";
      break;
   case PERIOD_H6:
      tfs = "H6";
      break;
   case PERIOD_H8:
      tfs = "H8";
      break;
   case PERIOD_H12:
      tfs = "H12";
      break;
   case PERIOD_D1:
      tfs = "D1";
      break;
   case PERIOD_W1:
      tfs = "W1";
      break;
   case PERIOD_MN1:
      tfs = "MN1";
      break;
   }
   return(tfs);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int clickCount = 0;
#define KEY_RIGHT   68
#define KEY_LEFT  65

void OnChartEvent(const int id, const long & lparam, const double & dparam, const string & sparam) {

   if(id == CHARTEVENT_OBJECT_DRAG) {
      if((sparam == _timeFromLine) || (sparam == _timeToLine)) {

         _lastOK = false;
         Update();
         //verifyDates();
         //ChartRedraw();
         //ObjectSetInteger(0, _timeToLine, OBJPROP_SELECTED, true);
      }
   }

//   if(id == CHARTEVENT_OBJECT_CLICK) {
//      if(StringFind(sparam, Id + "_" + "LBLINSIDE", 0) != -1) {
//         string str = sparam;
//         StringReplace(str, Id + "_" + "LBLINSIDE", "");
//         //StringReplace(str, "SSSR#R","");
//         //StringReplace(str, "SSSR#S","");
//         StringReplace(str, Id + "_" + "SSSR#", "");
//         long index = StringToInteger(str);
//         string s = Id + "_" + "SSSR#" + string(index) + "LBLINSIDE";
//         string lbl;
//
//         if (StringLen(ObjectGetString(0, s, OBJPROP_TEXT)) > 8) {
//            lbl = lbl + DoubleToString(zone_power[index], 3);
//            ObjectSetString(0, sparam, OBJPROP_TEXT, lbl);
//            //ObjectSetInteger(0, s, OBJPROP_TIME, iTime(NULL, timeframe, barTo + StringLen(ObjectGetString(0, s,OBJPROP_TEXT))));
//            ChartRedraw();
//         } else {
//            datetime Time = iTime(NULL, timeframe, barTo);
//            int firstBar = WindowFirstVisibleBar();
//            double vpos;
//            color lblColor;
//            ENUM_ANCHOR_POINT ancoragem = anchor;
//
//            if(zone_type[index] == ZONE_SUPPORT) {
//               if(zone_strength[index] == ZONE_SUPER) {
//                  if (zone_short_naming)
//                     lbl = "S+";
//                  else
//                     lbl = "Super";
//
//                  lblColor = color_support_super;
//               } else if(zone_strength[index] == ZONE_PROVEN) {
//                  if (zone_short_naming)
//                     lbl = "S";
//                  else
//                     lbl = "Proven";
//                  lblColor = color_support_proven;
//               } else if(zone_strength[index] == ZONE_VERIFIED) {
//                  if (zone_short_naming)
//                     lbl = "A";
//                  else
//                     lbl = "Verified";
//                  lblColor = color_support_verified;
//               } else if(zone_strength[index] == ZONE_UNTESTED) {
//                  if (zone_short_naming)
//                     lbl = "C";
//                  else
//                     lbl = "Untested";
//                  lblColor = color_support_untested;
//               } else if(zone_strength[index] == ZONE_TURNCOAT) {
//                  if (zone_short_naming)
//                     lbl = "D";
//                  else
//                     lbl = "Broken";
//                  lblColor = color_support_turncoat;
//               } else {
//                  if (zone_short_naming)
//                     lbl = "B";
//                  else
//                     lbl = "Weak";
//                  lblColor = color_support_weak;
//               }
//            } else {
//               if(zone_strength[index] == ZONE_SUPER) {
//                  if (zone_short_naming)
//                     lbl = "S+";
//                  else
//                     lbl = "Super";
//                  lblColor = color_resist_super;
//               } else if(zone_strength[index] == ZONE_PROVEN) {
//                  if (zone_short_naming)
//                     lbl = "S";
//                  else
//                     lbl = "Proven";
//                  lblColor = color_resist_proven;
//               } else if(zone_strength[index] == ZONE_VERIFIED) {
//                  if (zone_short_naming)
//                     lbl = "A";
//                  else
//                     lbl = "Verified";
//                  lblColor = color_resist_verified;
//               } else if(zone_strength[index] == ZONE_UNTESTED) {
//                  if (zone_short_naming)
//                     lbl = "C";
//                  else
//                     lbl = "Untested";
//                  lblColor = color_resist_untested;
//               } else if(zone_strength[index] == ZONE_TURNCOAT) {
//                  if (zone_short_naming)
//                     lbl = "D";
//                  else
//                     lbl = "Broken";
//                  lblColor = color_resist_turncoat;
//               } else {
//                  if (zone_short_naming)
//                     lbl = "B";
//                  else
//                     lbl = "Weak";
//                  lblColor = color_resist_weak;
//               }
//            }
//
//            if(zone_type[index] == ZONE_SUPPORT) {
//               lbl = lbl + sup_name;
//               ancoragem = ANCHOR_LEFT_UPPER;
//               vpos = zone_lo[index];
//            } else {
//               lbl = lbl + res_name;
//               ancoragem = ANCHOR_LEFT_LOWER;
//               vpos = zone_hi[index];
//            }
//
//            if(zone_hits[index] > 0 && zone_strength[index] > ZONE_UNTESTED) {
//               if(zone_hits[index] == 1)
//                  lbl = lbl + "(" + test_name + string(zone_hits[index]) + ")";
//               else
//                  lbl = lbl + "(" + test_name + string(zone_hits[index]) + ")";
//            }
//
//            datetime timeLeft = iTime(ativo, timeframe, zone_start[index]);
//            datetime timeFirstBar = iTime(ativo, PERIOD_CURRENT, firstBar);
//
//            if (timeLeft < timeFirstBar) {
//               timeLeft = timeFirstBar;
//            }
//
//            if (showAmplitude) {
//               lbl = lbl + "(" + DoubleToString(zone_amplitude[index], digitos) + " pts)";
//            }
//
//            if (showAge) {
//               lbl = lbl + "(" + DoubleToString(zone_age[index], 0) + " b)";
//            }
//
//            if (showPower) {
//               lbl = lbl + "(" + DoubleToString(zone_power[index], 3) + ")";
//            }
//
//            //ObjectCreate(0, s, OBJ_TEXT, 0, 0, 0);
//            //ObjectSetInteger(0, sparam, OBJPROP_TIME, timeLeft);
//            //ObjectSetDouble(0, sparam, OBJPROP_PRICE, vpos);
//            ObjectSetString(0, sparam, OBJPROP_TEXT, lbl);
//
//            ChartRedraw();
//         }
//      }
//   }
//
//   if(id == CHARTEVENT_CHART_CHANGE && calculating == false) {
//      _lastOK = true;
//      CheckTimer();
//      if(zone_show_info == true)
//         showLabels();
//
//   }
//
//   static bool keyPressed = false;
//   long barraLimite, barraNova, barraFrom, barraTo, primeiraBarraVisivel = totalRates, ultimaBarraVisivel, ultimaBarraSerie;
//   datetime tempoTimeFrom, tempoTimeTo, tempoBarra0, tempoUltimaBarraSerie;
//   int totalCandles;
//
//   if(id == CHARTEVENT_KEYDOWN && calculating == false && EnableEvents == true) {
//      if(lparam == KEY_RIGHT || lparam == KEY_LEFT) {
//         if(!keyPressed)
//            keyPressed = true;
//         else
//            keyPressed = false;
//
//         // definição das variáveis comuns
//         //if ((ObjectGetInteger(0, _timeToLine, OBJPROP_SELECTED) == true)) {
//         totalCandles = Bars(ativo, PERIOD_CURRENT);
//         ultimaBarraSerie = totalCandles - 1;
//         ultimaBarraVisivel = WindowFirstVisibleBar();
//         barraFrom = iBarShift(ativo, PERIOD_CURRENT, ObjectGetInteger(0, _timeFromLine, OBJPROP_TIME));
//         barraTo = iBarShift(ativo, PERIOD_CURRENT, ObjectGetInteger(0, _timeToLine, OBJPROP_TIME));
//         tempoTimeFrom = iTime(ativo, PERIOD_CURRENT, barraFrom);
//         tempoTimeTo = iTime(ativo, PERIOD_CURRENT, barraTo);
//         tempoBarra0 = iTime(ativo, PERIOD_CURRENT, 0);
//         tempoUltimaBarraSerie = iTime(ativo, PERIOD_CURRENT, totalCandles - 1);
//         //}
//
//         switch(int(lparam))  {
//         case KEY_RIGHT: {
//            //if ((ObjectGetInteger(0, _timeToLine, OBJPROP_SELECTED) == true)) {
//            if (barraFrom <= primeiraBarraVisivel)
//               barraLimite = barraFrom;
//            else
//               barraLimite = primeiraBarraVisivel;
//
//            EnableEvents == true ? barraNova = barraTo - 1 : barraNova = barraTo;
//            if (barraNova >= 0) {
//               datetime tempoNovo = iTime(ativo, PERIOD_CURRENT, barraNova);
//               ObjectSetInteger(0, _timeToLine, OBJPROP_TIME, 0, tempoNovo);
//               //ObjectSetInteger(0, _timeToLine, OBJPROP_SELECTED, true);
//               timeTo = tempoNovo;
//               _lastOK = false;
//               CheckTimer();
//            } else if (barraNova < 0) {
//               datetime tempoNovo = iTime(ativo, PERIOD_CURRENT, 0) + PeriodSeconds(PERIOD_CURRENT);
//               ObjectSetInteger(0, _timeToLine, OBJPROP_TIME, 0, tempoNovo);
//               //ObjectSetInteger(0, _timeToLine, OBJPROP_SELECTED, true);
//               timeTo = tempoNovo;
//               _lastOK = false;
//               CheckTimer();
//            }
//         }
//         break;
//
//         case KEY_LEFT:  {
//            //if ((ObjectGetInteger(0, _timeToLine, OBJPROP_SELECTED) == true)) {
//            barraTo = iBarShift(ativo, PERIOD_CURRENT, ObjectGetInteger(0, _timeToLine, OBJPROP_TIME));
//            if (tempoTimeTo <= tempoUltimaBarraSerie) {
//               barraNova = 0;
//            } else {
//               if (tempoTimeTo > tempoBarra0) {
//                  barraNova = 0;
//               } else {
//                  EnableEvents == true ? barraNova = barraTo + 1 : barraNova = barraTo;
//               }
//            }
//
//            datetime tempoNovo = iTime(ativo, PERIOD_CURRENT, barraNova);
//            ObjectSetInteger(0, _timeToLine, OBJPROP_TIME, 0, tempoNovo);
//            //ObjectSetInteger(0, _timeToLine, OBJPROP_SELECTED, true);
//            timeTo = tempoNovo;
//            _lastOK = false;
//            CheckTimer();
//         }
//         break;
//         }
//
//      }
//   } else if(id == CHARTEVENT_KEYDOWN && calculating == false && EnableEvents == false) {
//      if(lparam == KEY_RIGHT || lparam == KEY_LEFT) {
//         _lastOK = false;
//         CheckTimer();
//      }
//   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int barFrom, barTo;
datetime timeFrom;
datetime timeTo;
string _prefix;
string _timeFromLine;
string _timeToLine;
color _timeToColor;
color _timeFromColor;
int _timeToWidth;
int _timeFromWidth;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime GetObjectTime1(const string name) {
   datetime time;

   if(!ObjectGetInteger(0, name, OBJPROP_TIME, 0, time))
      return(0);

   return(time);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime GetBarTime(const int shift, ENUM_TIMEFRAMES period = PERIOD_CURRENT) {
   if(shift >= 0)
      return(miTime(ativo, period, shift));
   else
      return(miTime(ativo, period, 0) - shift * PeriodSeconds(period));
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool GetRangeBars(const datetime ptimeFrom, const datetime ptimeTo, int &barFrom, int &barTo) {
   barFrom = GetTimeBarRight(ptimeFrom);
   barTo = GetTimeBarRight(ptimeTo);
   if (barTo < 0)
      barTo = 0;
   return(true);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetTimeBarRight(datetime time, ENUM_TIMEFRAMES period = PERIOD_CURRENT) {
   int bar = miBarShift(ativo, period, time);
   datetime t = miTime(ativo, period, bar);

   if((t != time) && (bar == 0)) {
      bar = (int)((miTime(ativo, period, 0) - time) / PeriodSeconds(period));
   } else {
      if(t < time)
         bar--;
   }

   return(bar);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int miBarShift(string symbol, ENUM_TIMEFRAMES timeframe, datetime time, bool exact = false) {
   if(time < 0)
      return(-1);

   datetime arr[];
   datetime time1;
   CopyTime(symbol, timeframe, 0, 1, arr);

   if (ArraySize(arr) == 0)
      return -1;

   time1 = arr[0];

   if(CopyTime(symbol, timeframe, time, time1, arr) <= 0)
      return(-1);

   if(ArraySize(arr) > 2)
      return(ArraySize(arr) - 1);

   return(time < time1 ? 1 : 0);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int WindowBarsPerChart() {
   return((int)ChartGetInteger(0, CHART_WIDTH_IN_BARS));
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int WindowFirstVisibleBar() {
   return((int)ChartGetInteger(0, CHART_FIRST_VISIBLE_BAR));
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawVLine(const string name, const datetime time1, const color lineColor, const int width, const int style, const bool back = true, const bool hidden = true, const bool selectable = false, const int zorder = 0) {
   ObjectDelete(0, name);
   ObjectCreate(0, name, OBJ_VLINE, 0, time1, 0);
   ObjectSetInteger(0, name, OBJPROP_COLOR, lineColor);
   ObjectSetInteger(0, name, OBJPROP_BACK, back);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, hidden);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, selectable);
   ObjectSetInteger(0, name, OBJPROP_STYLE, style);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, width);
   ObjectSetInteger(0, name, OBJPROP_ZORDER, zorder);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime miTime(string symbol, ENUM_TIMEFRAMES timeframe, int index) {
   if(index < 0)
      return(-1);

   datetime arr[];

   if(CopyTime(symbol, timeframe, index, 1, arr) <= 0)
      return(-1);

   return(arr[0]);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ObjectEnable(const long chartId, const string name) {
   ObjectSetInteger(chartId, name, OBJPROP_HIDDEN, false);
   ObjectSetInteger(chartId, name, OBJPROP_SELECTABLE, true);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ObjectDisable(const long chartId, const string name) {
   ObjectSetInteger(chartId, name, OBJPROP_HIDDEN, true);
   ObjectSetInteger(chartId, name, OBJPROP_SELECTABLE, false);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
template<typename T>
void Swap(T & value1, T & value2) {
   T tmp = value1;
   value1 = value2;
   value2 = tmp;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class MillisecondTimer {
 private:
   int               _milliseconds;
 private:
   uint              _lastTick;

 public:
   void              MillisecondTimer(const int milliseconds, const bool reset = true) {
      _milliseconds = milliseconds;

      if(reset)
         Reset();
      else
         _lastTick = 0;
   }

 public:
   bool              Check() {
      uint now = getCurrentTick();
      bool stop = now >= _lastTick + _milliseconds;

      if(stop)
         _lastTick = now;

      return(stop);
   }

 public:
   void              Reset() {
      _lastTick = getCurrentTick();
   }

 private:
   uint              getCurrentTick() const {
      return(GetTickCount());
   }
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer() {
   CheckTimer();
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CheckTimer() {
   EventKillTimer();

   if(_updateTimer.Check() || !_lastOK) {
      if (calculating == false) {
         _lastOK = Update();
         //Print("Supply and Demand " + ativo + ":" + GetTimeFrame(Period()) + " ok");
      }
      EventSetMillisecondTimer(WaitMilliseconds);



      _updateTimer.Reset();
   } else {
      EventSetTimer(1);
   }
}

bool _lastOK = false;
MillisecondTimer *_updateTimer;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetZoneType(int p_type) {
   switch(p_type) {
   case ZONE_SUPER:
      return("Super");
   case ZONE_PROVEN:
      return("Proven");
   case ZONE_VERIFIED:
      return("Verified");
   case ZONE_UNTESTED:
      return("Untested");
   case ZONE_TURNCOAT:
      return("Turncoat");
   case ZONE_WEAK:
      return("Weak");
   default:
      return("Weak");

   }
//return IntegerToString(p_type);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetTimeFrame(int lPeriod) {
   switch(lPeriod) {
   case PERIOD_M1:
      return("M1");
   case PERIOD_M2:
      return("M2");
   case PERIOD_M3:
      return("M3");
   case PERIOD_M4:
      return("M4");
   case PERIOD_M5:
      return("M5");
   case PERIOD_M6:
      return("M6");
   case PERIOD_M10:
      return("M10");
   case PERIOD_M12:
      return("M12");
   case PERIOD_M15:
      return("M15");
   case PERIOD_M20:
      return("M20");
   case PERIOD_M30:
      return("M30");
   case PERIOD_H1:
      return("H1");
   case PERIOD_H2:
      return("H2");
   case PERIOD_H3:
      return("H3");
   case PERIOD_H4:
      return("H4");
   case PERIOD_H6:
      return("H6");
   case PERIOD_H8:
      return("H8");
   case PERIOD_H12:
      return("H12");
   case PERIOD_D1:
      return("D1");
   case PERIOD_W1:
      return("W1");
   case PERIOD_MN1:
      return("MN1");
   }
   return IntegerToString(lPeriod);
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
