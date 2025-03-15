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
//+------------------------------------------------------------------+
//| Classes |
//+------------------------------------------------------------------+
enum datalogType{
   LogSystem,
   LogError,
   LogTransaction
};

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
//| Logs a message to a text file (appending to all previous content, located in MQL5/Files folder)  |
//+------------------------------------------------------------------+
void LogMessage(datalogType datalogInput, string message)
  {
  
   // Filename in the terminal's "MQL5/Files" folder
   string filename = "MyLog.txt";
   string Header; 
   // Attempt to open the file with read/write and sharing flags
   int handle = FileOpen(filename, FILE_READ|FILE_WRITE|FILE_TXT|FILE_ANSI|FILE_SHARE_READ|FILE_SHARE_WRITE);
   
   // If file doesn't exist, create a new file
   if(handle == INVALID_HANDLE)
     {
      handle = FileOpen(filename, FILE_WRITE|FILE_TXT|FILE_ANSI|FILE_SHARE_READ|FILE_SHARE_WRITE);
      if(handle != INVALID_HANDLE)
         Print("Created new log file: ", filename);
     }
     
   if(handle != INVALID_HANDLE)
     {
      // Move to the end of file to append the new message
      FileSeek(handle, 0, SEEK_END);
      
      // Create a timestamp string
      string timeStr = TimeToString(TimeLocal(), TIME_DATE|TIME_SECONDS);
      if(datalogInput == LogSystem)
      Header = "SYSTEM LOG:";
      else if(datalogInput == LogError)
      Header = "ERROR LOG:";
      else if (datalogInput == LogTransaction)
      Header = "TRANSACTION LOG:";
      else 
      Header = "UNKNOWN HEADER:";
      
      
      message = Header + message;
      // Write timestamp and message to the file
      FileWrite(handle, timeStr, " - ", message);
      
      // Close the file (this flushes and saves the appended content)
      FileClose(handle);
     }
   else
     {
      Print("Failed to open or create file ", filename, " Error: ", GetLastError());
     }
  }


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


//+------------------------------------------------------------------+
//| Custom Array Handler
//+------------------------------------------------------------------+
//
void StoreInEmptySlot(double &arr[], double value) {
   for (int i = 0; i < ArraySize(arr); i++) {
      if (arr[i] == EMPTY_VALUE) {  // Find first empty slot
         arr[i] = value;
         return;
      }
   }
   // If no empty slot found, resize and add at the end
   int newSize = ArraySize(arr) + 1;
   ArrayResize(arr, newSize);
   arr[newSize - 1] = value;
}

//
void StoreInEmptySlot_int(int &arr[], int value) {
   for (int i = 0; i < ArraySize(arr); i++) {
      if (arr[i] == EMPTY_VALUE) {  // Find first empty slot
         arr[i] = value;
         return;
      }
   }
   // If no empty slot found, resize and add at the end
   int newSize = ArraySize(arr) + 1;
   ArrayResize(arr, newSize);
   arr[newSize - 1] = value;
}

void StoreInEmptySlot_DT(datetime &arr[], datetime value) {
   for (int i = 0; i < ArraySize(arr); i++) {
      if (arr[i] == EMPTY_VALUE) {  // Find first empty slot
         arr[i] = value;
         return;
      }
   }
   // If no empty slot found, resize and add at the end
   int newSize = ArraySize(arr) + 1;
   ArrayResize(arr, newSize);
   arr[newSize - 1] = value;
}


void RemoveAndShift(double &arr[], int index) {
   int size = ArraySize(arr);
   if (index < 0 || index >= size) return;

   for (int i = index; i < size - 1; i++) {
      arr[i] = arr[i + 1];  // Shift elements left
   }
   
   ArrayResize(arr, size - 1);  // Reduce array size
}
void RemoveAndShift_DT(datetime &arr[], int index) {
   int size = ArraySize(arr);
   if (index < 0 || index >= size) return;

   for (int i = index; i < size - 1; i++) {
      arr[i] = arr[i + 1];  // Shift elements left
   }
   
   ArrayResize(arr, size - 1);  // Reduce array size
}

// Function to insert value at a specific index
void InsertIntoArray(double &Arr_Input[], int Index, double NewArr_Value) {
   int currentSize = ArraySize(Arr_Input);
   
   // If index is out of bounds, resize the array
   if (Index >= currentSize) {
      ArrayResize(Arr_Input, Index + 1);
   }

   // Insert the new value at the specified index
   Arr_Input[Index] = NewArr_Value;
}
//
// Function to insert value at a specific index
void InsertIntoArray_DT(datetime &Arr_Input[], int Index, datetime NewArr_Value) {
   int currentSize = ArraySize(Arr_Input);
   
   // If index is out of bounds, resize the array
   if (Index >= currentSize) {
      ArrayResize(Arr_Input, Index + 1);
   }

   // Insert the new value at the specified index
   Arr_Input[Index] = NewArr_Value;
}
//

//+------------------------------------------------------------------+
//| Trade execution function                                         |
//+------------------------------------------------------------------+


void customTrade(double Risk, double stopLossPrice, double takeProfitPrice, bool isBuy)
{
   
   // Get account balance
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   // Calculate risk amount
   double riskAmount = balance * (Risk / 100.0);
   Print("Account balance:" ,balance);
   Print("risk amount in USD: ", riskAmount);
   
   // Get trading parameters
   double tickSize   = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   double tickValue  = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double contractSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_CONTRACT_SIZE);
   
   Print("tickSize:", tickSize);
   Print("tickValue:", tickValue);
   Print("contractSize:", contractSize);
   // Ensure tick value is not zero
   if (tickValue == 0 || contractSize == 0)
   {
      Print("Error: Unable to retrieve trading parameters.");
      return;
   }

   // Get current Ask and Bid prices
   double askPrice = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bidPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   Print("askPrice:", askPrice);
   Print("bidPrice:", bidPrice);

   
   // Determine the correct entry price based on trade direction
   double entryPrice = isBuy ? askPrice : bidPrice;

   // Validate Stop Loss and Take Profit prices
   if (isBuy && (stopLossPrice >= entryPrice || takeProfitPrice <= entryPrice))
   {
      Print("Error: For Buy, Stop Loss must be below Ask, and Take Profit must be above Ask.");
      return;
   }
   if (!isBuy && (stopLossPrice <= entryPrice || takeProfitPrice >= entryPrice))
   {
      Print("Error: For Sell, Stop Loss must be above Bid, and Take Profit must be below Bid.");
      return;
   }
   // Calculate Stop Loss and Take Profit distances in points
   double stopLossPips = fabs(entryPrice - stopLossPrice) / SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   double takeProfitPips = fabs(takeProfitPrice - entryPrice) / SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   Print("stop Loss Pips: " ,stopLossPips);
   Print(" takeProfitPips :", takeProfitPips);
   // Calculate lot size based on risk amount
   double lotSize = NormalizeDouble(riskAmount / (stopLossPips * tickValue), 2);

   // Ensure the lot size is within allowed limits
   double minLot  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maxLot  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);

   if (lotSize < minLot) lotSize = minLot;
   if (lotSize > maxLot) lotSize = maxLot;
   lotSize = NormalizeDouble(lotSize, 2); // Adjust to step size

   // Execute trade based on direction
   if (isBuy)
   {
      trade.Buy(lotSize, _Symbol, entryPrice, stopLossPrice, takeProfitPrice, "Risk-based Buy trade with SL/TP");
   }
   else
   {
      trade.Sell(lotSize, _Symbol, entryPrice, stopLossPrice, takeProfitPrice, "Risk-based Sell trade with SL/TP");
   }
}


//+------------------------------------------------------------------+
//| Function to Draw Arrows on Turning Points                        |
//+------------------------------------------------------------------+
void DrawArrow(datetime timeValue, double price, string name, color clr, int arrowCode)
{
   string objName = name + "_" + IntegerToString(timeValue);

   if(ObjectFind(0, objName) == -1)
   {
      ObjectCreate(0, objName, OBJ_ARROW, 0, timeValue, price);
      ObjectSetInteger(0, objName, OBJPROP_COLOR, clr);
      ObjectSetInteger(0, objName, OBJPROP_ARROWCODE, arrowCode);
      ObjectSetInteger(0, objName, OBJPROP_WIDTH, 2);
   }
}


void DrawArrowLinesUp(const double &ArrayInput[], const datetime &TimeArray[])
{
   int size1 = ArraySize(ArrayInput);
   int size2 = ArraySize(TimeArray);

   // Ensure both arrays have the same size
   if (size1 == 0 || size2 == 0 || size1 != size2)
   {
      Print("Error: ArrayInput and TimeArray must have the same non-zero size.");
      return;
   }

   // Loop through the arrays and draw arrow lines
   for (int i = 0; i < size1; i++)
   {
      string arrowName = "ArrowUp_" + IntegerToString(i);
      double priceLevel = ArrayInput[i];
      datetime arrowTime = TimeArray[i];

      // Create the arrow object
      if (!ObjectCreate(0, arrowName, OBJ_ARROW, 0, arrowTime, priceLevel))
      {
         Print("Failed to create arrow at time: ", arrowTime, " price: ", priceLevel);
         continue;
      }

      // Set arrow properties
      ObjectSetInteger(0, arrowName, OBJPROP_COLOR, clrRed); // Red color
      ObjectSetInteger(0, arrowName, OBJPROP_ARROWCODE, 233); // Upward Arrow (↑)
      ObjectSetInteger(0, arrowName, OBJPROP_WIDTH, 1);

      Print("Arrow drawn at: ", priceLevel, " | Time: ", TimeToString(arrowTime, TIME_SECONDS));
   }
}



void DrawArrowLinesDown(const double &ArrayInput[], const datetime &TimeArray[])
{
   int size1 = ArraySize(ArrayInput);
   int size2 = ArraySize(TimeArray);

   // Ensure both arrays have the same size
   if (size1 == 0 || size2 == 0 || size1 != size2)
   {
      Print("Error: ArrayInput and TimeArray must have the same non-zero size.");
      return;
   }

   // Loop through the arrays and draw arrow lines
   for (int i = 0; i < size1; i++)
   {
      string arrowName = "ArrowUp_" + IntegerToString(i);
      double priceLevel = ArrayInput[i];
      datetime arrowTime = TimeArray[i];

      // Create the arrow object
      if (!ObjectCreate(0, arrowName, OBJ_ARROW, 0, arrowTime, priceLevel))
      {
         Print("Failed to create arrow at time: ", arrowTime, " price: ", priceLevel);
         continue;
      }

      // Set arrow properties
      ObjectSetInteger(0, arrowName, OBJPROP_COLOR, clrBlue); // Red color
      ObjectSetInteger(0, arrowName, OBJPROP_ARROWCODE, 234); // Upward Arrow (↑)
      ObjectSetInteger(0, arrowName, OBJPROP_WIDTH, 1);

      Print("Arrow drawn at: ", priceLevel, " | Time: ", TimeToString(arrowTime, TIME_SECONDS));
   }
}


//+------------------------------------------------------------------+
//| Function to Draw or Update Horizontal Support/Resistance Line   |
//+------------------------------------------------------------------+
void DrawHorizontalLines(const double &ArrayInput[])
{
   // Check if the input array is empty
   int arraySize = ArraySize(ArrayInput);
   if (arraySize == 0)
   {
      Print("ArrayInput is empty. No lines to draw.");
      return;
   }

   // Loop through the array and draw horizontal lines
   for (int i = 0; i < arraySize; i++)
   {
      string lineName = "HLine_" + IntegerToString(i); // Unique name for each line
      double priceLevel = ArrayInput[i];

      // Create the horizontal line
      if (!ObjectCreate(0, lineName, OBJ_HLINE, 0, 0, priceLevel))
      {
         Print("Failed to create line at price: ", priceLevel);
         continue;
      }

      // Set line properties
      ObjectSetInteger(0, lineName, OBJPROP_COLOR, clrRed);
      ObjectSetInteger(0, lineName, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, lineName, OBJPROP_STYLE, STYLE_DASH);

      // Add a text label at the price level
      string labelName = "Label_" + IntegerToString(i);
      if (!ObjectCreate(0, labelName, OBJ_TEXT, 0, TimeCurrent(), priceLevel))
      {
         Print("Failed to create label for price: ", priceLevel);
         continue;
      }

      // Set label properties
      ObjectSetString(0, labelName, OBJPROP_TEXT, DoubleToString(priceLevel, _Digits)); // Price as text
      ObjectSetInteger(0, labelName, OBJPROP_COLOR, clrWhite);
      ObjectSetInteger(0, labelName, 10, 10);
      ObjectSetInteger(0, labelName, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
      ObjectMove(0, labelName, 0, TimeCurrent(), priceLevel); // Move label to the correct location

      Print("Drawn horizontal line at: ", priceLevel);
   }
}


int PipsDifference(double price1, double price2)
{
   double pipSize = SymbolInfoDouble(_Symbol, SYMBOL_POINT); // Get pip size (for 5-digit brokers)
   return (MathAbs(price1 - price2) / pipSize); // Absolute difference in pips
}




//+------------------------------------------------------------------+
//| Function to Draw or Update Horizontal Support/Resistance Line   |
//+------------------------------------------------------------------+
void GroundSeeking_Func(const double &Level_Array[],double &outputArray[], int Range_InPIPs)
{

   double BufferArray[];
   double CurrCheckingLevel;
   int IndexArray[];
   
   bool LoopActivator= true;
   int steps = 0;
   
   if ((ArraySize(Level_Array))== 0 ) 
   {
      Print("Invalid Level_Array input size");
      return;
   }
   
   // initializing
   ArrayResize(BufferArray,ArraySize(Level_Array));
   ArrayCopy(BufferArray,Level_Array);
   
   
   while (LoopActivator)
   { 
      switch (steps)
      {
         case 0:
            CurrCheckingLevel = BufferArray[0];
            //Print("Step 0");
            steps = 10;  // Move to step 1
            break;
         
         case 10:
            //Print("Step 10");
            
            for(int i = 0; i < ArraySize(BufferArray); i++)
            {
               Print("ArrayNumber: ",i,"Comparing", CurrCheckingLevel," with ",BufferArray[i],"The difference: ", PipsDifference(BufferArray[i],CurrCheckingLevel));
              if(PipsDifference(BufferArray[i],CurrCheckingLevel) <= Range_InPIPs)
              {
               CurrCheckingLevel = BufferArray[i];
               StoreInEmptySlot_int(IndexArray,i);
               Print("Now new Curr Number : ", CurrCheckingLevel );
              }
            }
            
            steps = 20;  // Move to step 2
            break;
         
         case 20:
            //Print("Step 20");
            // move CurrCheckingLevel into new Array:
            if (ArraySize(IndexArray) == 0){ steps = 60; break;  }
             for(int i = (ArraySize(IndexArray) -1); i >= 0 ; i--)
            {
               Print("Removing array : ", IndexArray[i]," and the value is : ", BufferArray[(IndexArray[i])]);
               RemoveAndShift(BufferArray,IndexArray[i]);
            }
            ArrayRemove(IndexArray,0);
            Print("Removing Array Index (Size): ",ArraySize(IndexArray) , " and Buffer Array (size): ",ArraySize(BufferArray) );
            ArrayPrint(IndexArray);
            ArrayPrint(BufferArray);
            StoreInEmptySlot(outputArray,CurrCheckingLevel);
            Print("Add new value into Horizontal Level: ", CurrCheckingLevel);
            steps = 30;  // Move to step 3
            break;
         
         case 30:
            ////Check if the Size of the BufferArray still available?
            
            if( ArraySize(BufferArray)>0) steps = 0; 
               
            else steps = 40;  // Move to step 3
            
            break;
            
         case 40:
            //Print("Step 40");
            
            steps = 50;  // Move to step 3
            break;
            
         case 50:
            //Print("Step 50");
            
            ArrayPrint(outputArray);
            steps = 60;  // Move to step 3
            break;
            
         case 60:
            //Print("Step 60");
            steps = 3;  // Move to step 3
            LoopActivator = false; // Exit the loop
            break;
            
         default:
            Print("Unknown step");
            LoopActivator = false; // Safety exit if something goes wrong
            break;
      }
   }
   
}

