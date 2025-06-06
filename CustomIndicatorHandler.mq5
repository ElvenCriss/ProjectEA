//+------------------------------------------------------------------+
//|                                       CustomIndicatorHandler.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

//+------------------------------------------------------------------+
//| Function to Draw Arrows on Turning Points                        |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//Custom Struct Declaration
//+------------------------------------------------------------------+



#include "CustomArrayHandler.mq5"

void DeleteAllHorizontalLines()
{
   int totalObjects = ObjectsTotal(0, 0, OBJ_HLINE); // Count all horizontal lines
   for (int i = totalObjects - 1; i >= 0; i--)  
   {
      string objName = ObjectName(0, i, 0, OBJ_HLINE); // Get object name
      if (objName != "")  
      {
         ObjectDelete(0, objName); // Delete the horizontal line
      }
   }
}

void DeleteYellowIndicators()
{
   int totalObjects = ObjectsTotal(0, 0); // Get total objects on the chart

   for (int i = totalObjects - 1; i >= 0; i--)  
   {
      string objName = ObjectName(0, i); // Get object name
      
      // Check if the object exists
      if (ObjectFind(0, objName) != 0)
         continue;

      // Get object type
      ENUM_OBJECT objType = (ENUM_OBJECT)ObjectGetInteger(0, objName, OBJPROP_TYPE);

      // Get object color
      color objColor = (color)ObjectGetInteger(0, objName, OBJPROP_COLOR);

      // Check if it's an indicator and has yellow color
      if (objColor == clrYellow && (objType == OBJ_TREND || objType == OBJ_CHANNEL))
      {
         ObjectDelete(0, objName); // Delete the object
      }
   }
}


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
      //Print("drawing RedArrow ", ArrayInput[i]);
      string arrowName = "ArrowUp_" + ArrayInput[i] + "_TimeValue_" + TimeArray[i];
      double priceLevel = ArrayInput[i];
      datetime arrowTime = TimeArray[i];
      
      if(ObjectFind(0, arrowName) == -1)
      {
         if (!ObjectCreate(0, arrowName, OBJ_ARROW, 0, arrowTime, priceLevel))
         {
         Print("Failed to create UP arrow at time: ", arrowTime, " price: ", priceLevel);
         continue;
         }
         // Set arrow properties
         ObjectSetInteger(0, arrowName, OBJPROP_COLOR, clrRed); // Red color
         ObjectSetInteger(0, arrowName, OBJPROP_ARROWCODE, 233); // Upward Arrow (↑)
         ObjectSetInteger(0, arrowName, OBJPROP_WIDTH, 1);
         
         // Create the arrow object
         //Print("Arrow drawn at: ", priceLevel, " | Time: ", TimeToString(arrowTime, TIME_SECONDS));
      }
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
      //Print("drawing BlueArrow ", ArrayInput[i]);
      string arrowName = "ArrowDown_" + ArrayInput[i] + "_TimeValue_" + TimeArray[i];
      double priceLevel = ArrayInput[i];
      datetime arrowTime = TimeArray[i];
      
      if(ObjectFind(0, arrowName) == -1)
      {
         // Create the arrow object
         if (!ObjectCreate(0, arrowName, OBJ_ARROW, 0, arrowTime, priceLevel))
         {
            Print("Failed to create Down arrow at time: ", arrowTime, " price: ", priceLevel);
            continue;
         }

         // Set arrow properties
         ObjectSetInteger(0, arrowName, OBJPROP_COLOR, clrBlue); // Blue color
         ObjectSetInteger(0, arrowName, OBJPROP_ARROWCODE, 234); // Upward Arrow (↑)
         ObjectSetInteger(0, arrowName, OBJPROP_WIDTH, 1);

      }
   }
}


//+------------------------------------------------------------------+
//| Function to Draw or Update Horizontal Support/Resistance Line   |
//+------------------------------------------------------------------+
void DrawHorizontalLines(const double &ArrayInput[] , const datetime &TimeInput[] ,  double EMA_ref, double &Resistance_Out, double &Support_Out)
{
   double support, resistance;
   // Check if the input array is empty
   int arraySize = ArraySize(ArrayInput);
   if (arraySize == 0)
   {
      Print("ArrayInput is empty. No lines to draw.");
      return;
   }
   FindClosestDifferences(ArrayInput, support, resistance, EMA_ref);
   
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
      if(priceLevel == support)
      {  
         Support_Out = support;
         ObjectSetInteger(0, lineName, OBJPROP_COLOR, clrGreen);
      }
      else if(priceLevel == resistance)
      {
         Resistance_Out = resistance;
         ObjectSetInteger(0, lineName, OBJPROP_COLOR, clrRed);
      }
      else
      {
         ObjectSetInteger(0, lineName, OBJPROP_COLOR, clrGray);
      }
      ObjectSetInteger(0, lineName, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, lineName, OBJPROP_STYLE, STYLE_DASH);
      //---------------------------------------------------------
      //Draw yellow Arrow// 
      //---------------------------------------------------------
      
      string arrowName = "YellowArrow" + ArrayInput[i] + "_TimeValue_" + TimeInput[i];
      double yellowPriceLevel = ArrayInput[i];
      datetime arrowTime = TimeInput[i];
      
      if(ObjectFind(0, arrowName) == -1)
      {
         if (!ObjectCreate(0, arrowName, OBJ_ARROW, 0, arrowTime, yellowPriceLevel))
         {
         Print("Failed to create UP arrow at time: ", arrowTime, " price: ", yellowPriceLevel);
         continue;
         }
         // Set arrow properties
         ObjectSetInteger(0, arrowName, OBJPROP_COLOR, clrYellow); // Red color
         ObjectSetInteger(0, arrowName, OBJPROP_ARROWCODE, 235); // Upward Arrow (↑)
         ObjectSetInteger(0, arrowName, OBJPROP_WIDTH, 1);
         
       }
   }
}


int PipsDifference(double price1, double price2)
{
   double pipSize = SymbolInfoDouble(_Symbol, SYMBOL_POINT); // Get pip size (for 5-digit brokers)
   return (MathAbs(price1 - price2) / pipSize); // Absolute difference in pips
}

int PT_PipsDifference(PriceTime &price1, PriceTime &price2)
{
   double pipSize = SymbolInfoDouble(_Symbol, SYMBOL_POINT); // Get pip size (for 5-digit brokers)
   return (MathAbs(price1.price - price2.price) / pipSize); // Absolute difference in pips
}


// Function to populate the struct array from two separate arrays
void FillPriceTimeArray(datetime &timeArray[], double &priceArray[], PriceTime &dataArray[]) {
   int size = ArraySize(timeArray);
   if (size != ArraySize(priceArray)) {
      Print("Error: Arrays must have the same size.");
      return;
   }

   ArrayResize(dataArray, size);  // Resize struct array

   for (int i = 0; i < size; i++) {
      dataArray[i].time = timeArray[i];
      dataArray[i].price = priceArray[i];
   }
}


// Function to print the struct array
void PrintPriceTimeArray(PriceTime &dataArray[]) {
   int size = ArraySize(dataArray);
   for (int i = 0; i < size; i++) {
      PrintFormat("Index: %d | Time: %d | Price: %.5f", 
                  i, 
                  TimeToString(dataArray[i].time, TIME_SECONDS), 
                  dataArray[i].price);
   }
}


//+------------------------------------------------------------------+
//| Function to Draw or Update Horizontal Support/Resistance Line   |
//+------------------------------------------------------------------+
void GroundSeeking_Func(const double &Level_Array[], const datetime &Time_Array[] ,double &outputArray[], datetime &outputTime[] , int Range_InPIPs )
{
   double BufferArray[];
   datetime TimeBufferArray[];
   double CurrCheckingLevel;
   datetime CurrDateTime;
   int IndexArray[];
   
   bool exitLoops = false;  // Flag to signal break
   PriceTime TestStruct_Data[];
   
   
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
   
   ArrayResize(TimeBufferArray,ArraySize(Time_Array));
   ArrayCopy(TimeBufferArray,Time_Array);
   
   while (LoopActivator)
   { 
      switch (steps)
      {
         case 0:
            CurrCheckingLevel = BufferArray[0];
            CurrDateTime = TimeBufferArray[0];
            //Print("Step 0");
            steps = 10;  // Move to step 1
            break;
         
         case 10:
            //Print("Step 10");
            
            for(int i = 0; i < ArraySize(BufferArray); i++)
            {
               if(PipsDifference(BufferArray[i],CurrCheckingLevel) <= Range_InPIPs)
              {
               CurrCheckingLevel = BufferArray[i];
               StoreInEmptySlot_int(IndexArray,i);
              }
            }
            
            steps = 20;  // Move to step 2
            break;
         
         case 20:
            if (ArraySize(IndexArray) == 0){ steps = 60; break;  }
             for(int i = (ArraySize(IndexArray) -1); i >= 0 ; i--)
            {
               RemoveAndShift_DT(TimeBufferArray,IndexArray[i]);
               RemoveAndShift(BufferArray,IndexArray[i]);
            }
            ArrayRemove(IndexArray,0);
            StoreInEmptySlot(outputArray,CurrCheckingLevel);
            StoreInEmptySlot_DT(outputTime,CurrDateTime);
            steps = 30;  // Move to step 3
            break;
         
         case 30:
            ////Check if the Size of the BufferArray still available?
            
            if( ArraySize(BufferArray)>0) steps = 0; 
               
            else steps = 40;  // Move to step 3
            
            break;
            
         case 40:
         
            
            steps = 50;  // Move to step 3
            break;
            
         case 50:
            //Print("Step 50");
            
            steps = 60;  // Move to step 3
            break;
            
         case 60:
            //Print("Step 60");
            FillPriceTimeArray(outputTime,outputArray,TestStruct_Data);
            SortPriceTimeArray(TestStruct_Data);
            //PrintPriceTimeArray(TestStruct_Data);
            steps = 120;
            break;
         case 120:
         exitLoops= false;
           for(int i= 0; i<ArraySize(TestStruct_Data);i++)
            {
               for(int j = 0 ; j<ArraySize(TestStruct_Data);j++)
               {
                  if(i!=j && PT_PipsDifference(TestStruct_Data[i], TestStruct_Data[j]) < Range_InPIPs)
                  {
                     if(i<j) 
                     {
                        PT_RemoveAndShift(TestStruct_Data,i); 
                     }
                     else 
                     {
                        PT_RemoveAndShift(TestStruct_Data,j);
                     }
                     
                     steps = 120;
                     exitLoops = true;
                     break;
                  }
               } 
               if (exitLoops) break;
               if (i == (ArraySize(TestStruct_Data) - 1))steps = 130;
            }
            break;
            
         case 130:   
         ArrayResize(outputArray, 0);  
         ArrayResize(outputTime, 0);  
         ConvertToArrays(TestStruct_Data, outputArray,outputTime);
            LoopActivator = false; // Exit the loop
            break;
            
         default:
            Print("Unknown step");
            LoopActivator = false; // Safety exit if something goes wrong
            break;
      }
   }
   
}

void SortPriceTimeArray(PriceTime &arr[])
{
    int size = ArraySize(arr);
    if (size <= 1) return;  // No need to sort if only 1 element

    for (int i = 0; i < size - 1; i++)  // Outer loop (passes)
    {
        bool swapped = false;  // Optimization: Check if a swap happens

        for (int j = 0; j < size - i - 1; j++)  // Inner loop (comparisons)
        {
            if (arr[j].time > arr[j + 1].time)  // Compare by Time
            {
                // Swap elements
                PriceTime temp = arr[j];
                arr[j] = arr[j + 1];
                arr[j + 1] = temp;

                swapped = true;
            }
        }

        // If no swaps happened, the array is already sorted
        if (!swapped) break;
    }
}

void ConvertToArrays(const PriceTime &arr[], double &prices[], datetime &times[])
{
    int size = ArraySize(arr);  
    ArrayResize(prices, size);  // Resize price array
    ArrayResize(times, size);   // Resize time array

    for (int i = 0; i < size; i++)
    {
        prices[i] = arr[i].price;
        times[i] = arr[i].time;
    }
}

void FindClosestDifferences(const double &priceArray[], double &Support, double &Resistance, double &EMA_ref)
{
    // Get EMA(5) as reference
    double closestNegDiff;
    double closestPosDiff;
    double lastClose = iClose(_Symbol, PERIOD_CURRENT, 0);
    double ema5 = EMA_ref;
    
    int arraySize = ArraySize(priceArray);
    // Initialize with DBL_MAX for comparison
    double minNegDiff = DBL_MAX;
    double minPosDiff = DBL_MAX;
    
    // Default return values (0 if no valid difference found)
    closestNegDiff = 0;
    closestPosDiff = 0;

    // Loop through the array to find closest negative and positive differences
    for (int i = 0; i < arraySize; i++) 
    {
        double diff = priceArray[i] - ema5;  // Calculate difference

        if (diff < 0) // Negative difference (support)
        {
            double absDiff = -diff;  // Convert to positive for comparison
            if (absDiff < minNegDiff) 
            {
                minNegDiff = absDiff;
                closestNegDiff = diff;  // Store the actual negative difference
                Support = priceArray[i];
            }
        }
        else if (diff > 0) // Positive difference (resistance)
        {
            if (diff < minPosDiff) 
            {
                minPosDiff = diff;
                closestPosDiff = diff;  // Store the actual positive difference
                Resistance = priceArray[i];
            }
        }
    }

    // Debug output
   
}