//+------------------------------------------------------------------+
//|                                           CustomArrayHandler.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Custom Array Handler
//+------------------------------------------------------------------+
//

// Define a struct to store both time and price together
struct PriceTime {
   datetime time;
   double price;
};


void StoreInEmptySlot(double &arr[], double value) {
   for (int i = 0; i < ArraySize(arr); i++) {
      if (arr[i] == EMPTY_VALUE) {  // Find first empty slot
         arr[i] = value;
         return;
      }
   }
   // If no empty slot found, resize and add at the end
   int newSize = ArraySize(arr) + 1;
   Print("expanding array Size for Value : ", value  );
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

void PT_RemoveAndShift(PriceTime &arr[], int index) {
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