//+------------------------------------------------------------------+
//|                                                    CustomLog.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| Classes |
//+------------------------------------------------------------------+
enum datalogType{
   LogSystem,
   LogError,
   LogTransaction
};

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
