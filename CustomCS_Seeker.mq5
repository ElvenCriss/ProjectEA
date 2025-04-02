//+------------------------------------------------------------------+
//|                                              CustomCS_Seeker.mq5 |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+

// Function to detect candlestick patterns
string DetectCandlestickPattern(string symbol, ENUM_TIMEFRAMES timeframe, int shift)
{
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

    // Bullish Engulfing Pattern
    bool isBullishEngulfing = (close_current > open_current) &&  
                              (close_prev < open_prev) &&       
                              (close_current > open_prev) &&    
                              (open_current < close_prev);
    
    // Bearish Engulfing Pattern
    bool isBearishEngulfing = (close_current < open_current) &&  
                              (close_prev > open_prev) &&       
                              (close_current < open_prev) &&    
                              (open_current > close_prev);

    // Doji Pattern (small body)
    bool isDoji = (MathAbs(open_prev - close_prev) <= (high_prev - low_prev) * 0.1); 

    // Morning Star (Bullish Reversal)
    bool isMorningStar = (close_prev2 < open_prev2) &&  // First candle is bearish
                         isDoji &&                      // Second candle is small-bodied
                         (close_current > open_current) && // Third candle is bullish
                         (close_current > (open_prev2 + close_prev2) / 2); // Closes above midpoint of first candle

    // Evening Star (Bearish Reversal)
    bool isEveningStar = (close_prev2 > open_prev2) &&  // First candle is bullish
                         isDoji &&                      // Second candle is small-bodied
                         (close_current < open_current) && // Third candle is bearish
                         (close_current < (open_prev2 + close_prev2) / 2); // Closes below midpoint of first candle

    // Return detected pattern
    if (isBullishEngulfing)
        return "Bullish Engulfing";
    else if (isBearishEngulfing)
        return "Bearish Engulfing";
    else if (isMorningStar)
        return "Morning Star";
    else if (isEveningStar)
        return "Evening Star";
    else if (isDoji)
        return "Doji";

    return "No pattern";
}




// Function to detect candlestick patterns near support/resistance levels and highlight them
bool DetectCandlestickPattern(string symbol, ENUM_TIMEFRAMES timeframe, int shift, double &srLevels[], int srCount)
{
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
 
    double body_prev = MathAbs(open_prev - close_prev); // Body size of previous candle
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

    bool isMorningStar = (close_prev2 < open_prev2) &&  
                         isDoji &&                     
                         (close_current > open_current) && 
                         (close_current > (open_prev2 + close_prev2) / 2);

    bool isEveningStar = (close_prev2 > open_prev2) &&  
                         isDoji &&                     
                         (close_current < open_current) && 
                         (close_current < (open_prev2 + close_prev2) / 2);

    // Check if price is near a support/resistance level
    double tolerance = 5 * _Point; // Define a tolerance level
    for (int i = 0; i < srCount; i++)
    {
        double srLevel = srLevels[i];

        if (//(low_current <= srLevel + tolerance && high_current >= srLevel - tolerance) &&
            (isBullishEngulfing || isBearishEngulfing || isMorningStar || isEveningStar /*|| isDoji*/))
        {
            string patternName;
            if (isBullishEngulfing) patternName = "Bullish Engulfing";
            else if (isBearishEngulfing) patternName = "Bearish Engulfing";
            else if (isMorningStar) patternName = "Morning Star";
            else if (isEveningStar) patternName = "Evening Star";
            //else if (isDoji) patternName = "Doji";

            // Define box coordinates
            datetime time_start = iTime(symbol, timeframe, shift + 2); // Start time of the 3rd previous candle
            datetime time_end = iTime(symbol, timeframe, shift); // End time of the current candle
            double high_box = MathMax(MathMax(high_current, high_prev), high_prev2); // Highest high
            double low_box = MathMin(MathMin(low_current, low_prev), low_prev2); // Lowest low

            // Create a rectangle to highlight the pattern
            string objName = "PatternBox_" + patternName + "_" + IntegerToString(shift);
            ObjectCreate(0, objName, OBJ_RECTANGLE, 0, time_start, high_box, time_end, low_box);
            
            
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