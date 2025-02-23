//+------------------------------------------------------------------+
//|                                                       EATest.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
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
void OnTick()
  {
//---
   LogMessage("test");
   
  }



//+------------------------------------------------------------------+
//| Trade execution function                                         |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| Log messages function                                         |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Logs a message to a text file (located in MQL5/Files folder)       |
//+------------------------------------------------------------------+
void LogMessage(string message)
  {
   // Specify the filename (this file will be saved in the terminal's Files folder)
   string filename = "MyLog.txt";
   
   // Open the file for writing (FILE_WRITE creates a new file or overwrites by default,
   // so we use FILE_WRITE|FILE_TXT|FILE_ANSI to open in text mode)
   int handle = FileOpen(filename, FILE_WRITE|FILE_TXT|FILE_ANSI);
   if(handle != INVALID_HANDLE)
     {
      // Move to the end of file if you want to append messages
      FileSeek(handle, 0, SEEK_END);
      
      // Optionally include a timestamp with your message
      string timeStr = TimeToString(TimeCurrent(), TIME_DATE|TIME_SECONDS);
      FileWrite(handle, timeStr, " - ", message);
      
      // Close the file to save changes
      FileClose(handle);
     }
   else
     {
      Print("Failed to open file ", filename, " Error: ", GetLastError());
     }
  }

//+------------------------------------------------------------------+

