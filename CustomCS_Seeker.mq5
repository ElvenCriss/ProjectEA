//+------------------------------------------------------------------+
//|                                              CustomCS_Seeker.mq5 |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Classes |
//+------------------------------------------------------------------+
enum CSPatternType{
   BullishEngulfing_B,
   BeareshEngulfing_S,
   MorningStar_B,
   EveningStar_S,
};


// Function to detect candlestick patterns near support/resistance levels and highlight them
bool DetectCandlestickPattern(string symbol, ENUM_TIMEFRAMES timeframe, int shift, double &srLevels[], double &HighestPriceLevel , double &LowestPriceLevel, bool &isBuy, CSPatternType &CSReturn )
{
    int srCount = ArraySize(srLevels); 
    // Get candle data for the current, previous, and 2nd previous candles
    double open_current  = iOpen(symbol, timeframe, shift);
    double close_current = iClose(symbol, timeframe, shift);
    double high_current  = iHigh(symbol, timeframe, shift);
    double low_current   = iLow(symbol, timeframe, shift);
    
    double open_prev  = iOpen(symbol, timeframe, shift + 1);
    double close_prev = iClose(symbol, timeframe, shift + 1);
    double high_prev  = iHigh(symbol, timeframe, shift + 1);
    double low_prev   = iLow(symbol, timeframe, shift + 1);
    
    double open_prev2  = iOpen(symbol, timeframe, shift + 2);
    double close_prev2 = iClose(symbol, timeframe, shift + 2);
    double high_prev2  = iHigh(symbol, timeframe, shift + 2);
    double low_prev2   = iLow(symbol, timeframe, shift + 2);
 
     // Define body sizes
    double body_prev2 = MathAbs(open_prev2 - close_prev2); // First candle body
    double body_prev = MathAbs(open_prev - close_prev); // Middle candle body
 
    double body_current = MathAbs(open_current - close_current); // Body size of current candle
    double range_prev = high_prev - low_prev; // High-Low range of previous candle

    bool currentCandleBigEnough = (body_current > body_prev * 1.5);
    
    // Define a minimum size requirement (e.g., previous candle should be at least 30% of its range)
    bool prevCandleValid = (body_prev >= range_prev * 0.3);  

    // Define pattern conditions
    bool isBullishEngulfing = (close_current > open_current) &&  
                              (close_prev < open_prev) &&       
                              (close_current > open_prev) &&    
                              (open_current < close_prev) &&
                              prevCandleValid &&                 // Ensure the first candle is not too small
                              currentCandleBigEnough;            // Ensure the engulfing candle is large enough
    
    bool isBearishEngulfing = (close_current < open_current) &&  
                              (close_prev > open_prev) &&       
                              (close_current < open_prev) &&    
                              (open_current > close_prev) && 
                              prevCandleValid &&                 // Ensure the first candle is not too small
                              currentCandleBigEnough;            // Ensure the engulfing candle is large enough
    

    bool isDoji = (MathAbs(open_prev - close_prev) <= (high_prev - low_prev) * 0.1); 

    // Improved Morning Star (Bullish Reversal)
    bool isMorningStar = (close_prev2 < open_prev2) &&  // First candle is bearish
                         (body_prev2 > range_prev * 0.6) && // Strong first candle (big body)
                         (body_prev < range_prev * 0.4) && // Second candle has a small body
                         (close_current > open_current) && // Third candle is bullish
                         (body_current > range_prev * 0.6) && // Third candle has a big body
                         (close_current > (open_prev2 + close_prev2) / 2) && // Closes above midpoint of first candle
                         !(body_prev2 *1.2 <= body_current);                // Limit first candle size

    // Improved Evening Star (Bearish Reversal)
    bool isEveningStar = (close_prev2 > open_prev2) &&  // First candle is bullish
                         (body_prev2 > range_prev * 0.6) && // Strong first candle (big body)
                         (body_prev < range_prev * 0.4) && // Second candle has a small body
                         (close_current < open_current) && // Third candle is bearish
                         (body_current > range_prev * 0.6) && // Third candle has a big body
                         (close_current < (open_prev2 + close_prev2) / 2)&& // Closes below midpoint of first candle
                         !(body_prev2*1.2 <= body_current);                // Limit first candle size
    // Check if price is near a support/resistance level
    double tolerance = 5 * _Point; // Define a tolerance level
    for (int i = 0; i < srCount; i++)
    {
        double srLevel = srLevels[i];

        if (//(low_current <= srLevel + tolerance && high_current >= srLevel - tolerance) &&
            (isBullishEngulfing || isBearishEngulfing || isMorningStar || isEveningStar /*|| isDoji*/))
        {
            string patternName;
            if (isBullishEngulfing) {patternName = "Bullish Engulfing"; isBuy = true; CSReturn = BullishEngulfing_B;}
            else if (isBearishEngulfing) {patternName = "Bearish Engulfing"; isBuy =false;CSReturn = BeareshEngulfing_S;}
            else if (isMorningStar) {patternName = "Morning Star"; isBuy = true; CSReturn = MorningStar_B;}
            else if (isEveningStar) {patternName = "Evening Star";isBuy = false;CSReturn = EveningStar_S;}
            //else if (isDoji) patternName = "Doji";

            // Define box coordinates
            datetime time_start = iTime(symbol, timeframe, shift + 2); // Start time of the 3rd previous candle
            datetime time_end = iTime(symbol, timeframe, shift); // End time of the current candle
            double high_box = MathMax(MathMax(high_current, high_prev), high_prev2); // Highest high
            double low_box = MathMin(MathMin(low_current, low_prev), low_prev2); // Lowest low

            // Unique object name for each pattern
            string objName = "PatternBox_" + patternName + "_" + IntegerToString(time_start);
            HighestPriceLevel = high_box;
            LowestPriceLevel = low_box;
            
            ObjectCreate(0, objName, OBJ_RECTANGLE, 0, time_start, high_box, time_end, low_box);
            
            // Check if the object already exists, if not, create it
            
               if (isBullishEngulfing)      ObjectSetInteger(0, objName, OBJPROP_COLOR, clrLightGreen); // Box color
               else if (isBearishEngulfing) ObjectSetInteger(0, objName, OBJPROP_COLOR, clrPink); // Box color
               else if (isMorningStar)      ObjectSetInteger(0, objName, OBJPROP_COLOR, clrGreen); // Box color
               else if (isEveningStar)      ObjectSetInteger(0, objName, OBJPROP_COLOR, clrCrimson); // Box color
               ObjectSetInteger(0, objName, OBJPROP_WIDTH, 2); // Box border thickness
               ObjectSetInteger(0, objName, OBJPROP_RAY_RIGHT, false); // Do not extend

               Print("Detected ", patternName, " at level ", srLevel);
            
            return true;
        }
    }
    
    return false;
}