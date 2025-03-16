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
