//+------------------------------------------------------------------+
//|                                                       EATest.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Trade\Trade.mqh>
   CTrade trade;
   
 #include "CustomLog.mq5";
 #include "CustomArrayHandler.mq5";
 #include "CustomIndicatorHandler.mq5";
 #include "CustomTradeHandler.mq5";
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Global declaration |
//+------------------------------------------------------------------+
datalogType LogSystemz = LogSystem;
datalogType LogErrorz = LogError;
datalogType LogTransactionz = LogTransaction;




// Input parameters
input int pipThreshold = 400; // Threshold in pips to merge peaks/valleys into a single line

// Global variables for tracking lines
double lastPeakLevel = 0;
double lastValleyLevel = 0;


string peakLineName = "Peak_Res_Line";
string valleyLineName = "Valley_Sup_Line";

//+------------------------------------------------------------------+



//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   
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
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//add support resistance detector
//
//+------------------------------------------------------------------+
//| Script to detect turning points of EMA 5 and mark them          |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Script to detect turning points of EMA 5 and mark them          |
//+------------------------------------------------------------------+
void OnTick()
{
   int emaPeriod = 5;
   int totalBars = 100;
   
   double ema_a[], red_b[], blue_c[], Level_d[], Horizontal_e[];
   datetime timeArray_a[], timeArray_b[],timeArray_c[], timeArray_d[], timeArray_e[];

   // Retrieve EMA values
   if(!CopyBuffer(iMA(_Symbol, PERIOD_CURRENT, emaPeriod, 0, MODE_EMA,PRICE_CLOSE), 0, 0, totalBars, ema_a))
   {
      Print("Failed to retrieve EMA values");
      return;
   }

   // Retrieve time values
   if(!CopyTime(_Symbol, PERIOD_CURRENT, 0, totalBars, timeArray_a))
   {
      Print("Failed to retrieve time values");
      return;
   }

   // Convert pip threshold to price level difference
   double pointValue = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   
//   for(int i = 1; i < totalBars - 1; i++)
//   {
//      double prevSlope = ema[i] - ema[i + 1];   // Previous slope
//      double currSlope = ema[i - 1] - ema[i];   // Current slope
//
//      if(prevSlope > 0 && currSlope < 0) // Peak (Resistance)
//      {
//         DrawArrow(timeArray[i], ema[i], "Peak", clrRed, 233);
//         //UpdateHorizontalLine(peakLineName, ema[i], lastPeakLevel, priceThreshold, clrRed);
//      }
//      else if(prevSlope < 0 && currSlope > 0) // Valley (Support)
//      {
//         DrawArrow(timeArray[i], ema[i], "Valley", clrBlue, 234);
//         //UpdateHorizontalLine(valleyLineName, ema[i], lastValleyLevel, priceThreshold, clrBlue);
//      }
//   }
//   
   // Loop through EMA values to detect turning points
   for(int i = 1; i < totalBars - 1; i++)
   {
      double prevSlope = ema_a[i] - ema_a[i + 1];   // Previous slope
      double currSlope = ema_a[i - 1] - ema_a[i];   // Current slope

      if(prevSlope > 0 && currSlope < 0) // Peak (Resistance)
      {
         //DrawArrow(timeArray[i], ema[i], "Peak", clrRed, 233);
         StoreInEmptySlot(red_b,ema_a[i]);
         StoreInEmptySlot_DT(timeArray_b,timeArray_a[i]);
         
         StoreInEmptySlot(Level_d,ema_a[i]);
         StoreInEmptySlot_DT(timeArray_d,timeArray_a[i]);
      }
      else if(prevSlope < 0 && currSlope > 0) // Valley (Support)
      {
         //DrawArrow(timeArray[i], ema[i], "Valley", clrBlue, 234);
         StoreInEmptySlot(blue_c,ema_a[i]);
         StoreInEmptySlot_DT(timeArray_c,timeArray_a[i]);
         
         StoreInEmptySlot(Level_d,ema_a[i]);
         StoreInEmptySlot_DT(timeArray_d,timeArray_a[i]);
      }
   }
   double testArray[12] = {2012.5,2015.75,2020.3,2018.6,2025.45,2025.1,2012.75,2035.2,2040.55,2012.8,2046.7,2046.4};
                           
   GroundSeeking_Func(Level_d,Horizontal_e, pipThreshold);
   
   
   DrawHorizontalLines(Horizontal_e);
   DrawArrowLinesDown(blue_c,timeArray_c);
   //DrawArrowLinesUp(red_b,timeArray_b);
   // Loop through blues and Red values to Draw turning points
//   for (int i = 1 ; i<ArraySize(red_b); i++)
//   {
//      DrawArrow(timeArray_b[i], red_b[i], "Peak", clrRed, 233);
//   }   
//   for (int i = 1 ; i<ArraySize(blue_c); i++)
//   {
//      DrawArrow(timeArray_c[i], blue_c[i], "Valley", clrBlue, 234);
//   }   
//    


}






