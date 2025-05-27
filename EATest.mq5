//+------------------------------------------------------------------+
//|                                                       EATest.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Trade\Trade.mqh>
   
 #include "CustomLog.mq5";
 #include "CustomArrayHandler.mq5";
 #include "CustomIndicatorHandler.mq5";
 #include "CustomTradeHandler.mq5";
 #include "CustomCS_Seeker.mq5";
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Global declaration |
//+------------------------------------------------------------------+
datalogType LogSystemz = LogSystem;
datalogType LogErrorz = LogError;
datalogType LogTransactionz = LogTransaction;



// Input parameters
input int pipThreshold; // Threshold in pips to merge peaks/valleys into a single line
input int  totalBars = 100;
input int RiskPercentage;
input int RiskRewardRatio;
input int CushionStopLoss;


input int RiskPercentage_LT;
input int RiskRewardRation_LT;

datetime lastCandleTime = 0; // Global variable to track the last checked candle
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
    string templateName = "standard_Temp.tpl";  // Name of your template
   long chartID = ChartID();  // Get the current chart ID

   // Apply the template
   if (!ChartApplyTemplate(chartID, templateName))
   {
      Print("Failed to apply template: ", templateName);
   }
   else
   {
      Print("Template applied successfully: ", templateName);
   }
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
  
void OnTick()
{
   datetime currentCandleTime = iTime(_Symbol, PERIOD_CURRENT, 0); // Get the current candle's open time

   // Only execute when a new candle appears
   if (currentCandleTime != lastCandleTime)
   {
      lastCandleTime = currentCandleTime; // Update last candle time
      mainProg();
   }
   mainTickProg();
}



void mainProg()
{
   int emaPeriod = 5;
   
   double ema_a[], red_b[], blue_c[], Level_d[], Horizontal_e[], emaTest[];
   datetime timeArray_a[], timeArray_b[],timeArray_c[], timeArray_d[], timeArray_e[];

   // Retrieve EMA values
   if(!CopyBuffer(iMA(_Symbol, PERIOD_CURRENT, emaPeriod, 0, MODE_EMA,PRICE_CLOSE), 0, 0, totalBars, ema_a))
   {
      Print("Failed to retrieve EMA values");
      return;
   }

   if(!CopyBuffer(iMA(_Symbol, PERIOD_CURRENT, emaPeriod, 0, MODE_EMA,PRICE_CLOSE), 0, 0, totalBars, emaTest))
   {
      Print("Failed to retrieve EMA values");
      return;
   }

   // Retrieve time values
   if(!CopyTime(_Symbol, PERIOD_CURRENT, 0, totalBars, timeArray_a))
   {
      return;
   }

   // Convert pip threshold to price level difference
   double pointValue = SymbolInfoDouble(_Symbol, SYMBOL_POINT);

   // Loop through EMA values to detect turning points
   for(int i = 1; i < totalBars - 1; i++)
   {
      double prevSlope = ema_a[i] - ema_a[i + 1];   // Previous slope
      double currSlope = ema_a[i - 1] - ema_a[i];   // Current slope

      if(prevSlope > 0 && currSlope < 0) // Peak (Resistance)
      {
         StoreInEmptySlot(red_b,ema_a[i]);
         StoreInEmptySlot_DT(timeArray_b,timeArray_a[i]);
        
         StoreInEmptySlot(Level_d,ema_a[i]);
         StoreInEmptySlot_DT(timeArray_d,timeArray_a[i]);
      }
      else if(prevSlope < 0 && currSlope > 0) // Valley (Support)
      {
         StoreInEmptySlot(blue_c,ema_a[i]);
         StoreInEmptySlot_DT(timeArray_c,timeArray_a[i]);
        
         StoreInEmptySlot(Level_d,ema_a[i]);
         StoreInEmptySlot_DT(timeArray_d,timeArray_a[i]);
      }
   }
                 
    GroundSeeking_Func(Level_d,timeArray_d,Horizontal_e, timeArray_e , pipThreshold );
    
  
   
   
   DeleteAllHorizontalLines();
   DeleteYellowIndicators();
   // update Indicator'
   
   
   
   
    double HighestPriceLevel;
    double LowestPriceLevel;
    double SupportLevel;
    double ResistanceLevel;
    bool CandleStick_IsBuy;
    CSPatternType CSPattern_return;
    bool foundPattern = DetectCandlestickPattern(Symbol(), (ENUM_TIMEFRAMES)Period(), 1, Level_d, HighestPriceLevel, LowestPriceLevel, CandleStick_IsBuy,CSPattern_return );

    
   DrawHorizontalLines(Horizontal_e,timeArray_e ,ema_a[ArraySize(ema_a) - 1], ResistanceLevel, SupportLevel);
   if(foundPattern)
   {
        CustomTradeExec_Checker(SupportLevel,ResistanceLevel,CandleStick_IsBuy,HighestPriceLevel,LowestPriceLevel,CSPattern_return);
   }
   
   
   
   DrawArrowLinesDown(blue_c,timeArray_c);
   DrawArrowLinesUp(red_b,timeArray_b);
      

}




void mainTickProg()
{
   CleanupClosedTrades();
   ApplyTrailingStops();  
}