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
   int totalBars = 500;  // Number of bars to check
   double ema[];
   datetime timeArray[];

   // Retrieve EMA values
   if(!CopyBuffer(iMA(_Symbol, PERIOD_CURRENT, emaPeriod, 0, MODE_EMA,PRICE_CLOSE), 0, 0, totalBars, ema))
   {
      Print("Failed to retrieve EMA values");
      return;
   }

   // Retrieve time values
   if(!CopyTime(_Symbol, PERIOD_CURRENT, 0, totalBars, timeArray))
   {
      Print("Failed to retrieve time values");
      return;
   }

   // Check for turning points
   for(int i = 1; i < totalBars - 1; i++)
   {
      double prevSlope = ema[i] - ema[i + 1];   // Previous slope
      double currSlope = ema[i - 1] - ema[i];   // Current slope

      // Detect turning points
      if(prevSlope > 0 && currSlope < 0) // Peak (Resistance)
      {
         DrawArrow(timeArray[i], ema[i], "Peak", clrRed, 233);
      }
      else if(prevSlope < 0 && currSlope > 0) // Valley (Support)
      {
         DrawArrow(timeArray[i], ema[i], "Valley", clrBlue, 234);
      }
   }
}




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