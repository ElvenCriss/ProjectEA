//+------------------------------------------------------------------+
//|                                           CustomTradeHandler.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

//+------------------------------------------------------------------+
//| Trade execution function                                         |
//+------------------------------------------------------------------+

 #include "CustomCS_Seeker.mq5";

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


int CustomTradeExec_Checker(double Support, double Resistance, bool Candlestick_isBuy, double CSPattern_High, double CSPattern_Low, CSPatternType &CSPattern)
{  
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   Print("Support : ", Support, "Resistance : " , Resistance , " CSPattern_High :  " , CSPattern_High, " CSPattern_Low : " , CSPattern_Low  );
   bool isBuy =  Candlestick_isBuy ? true : false;
   if (isBuy)
   {
      if (!(CSPattern_High >= Support && Support >= CSPattern_Low )) 
      {  
         Print(" buy Failed to achieve");
         return -1;
      }
      
   }
   else 
   {
      if (!(CSPattern_High >= Resistance && Resistance >= CSPattern_Low )) 
      
      {
         Print(" sell Failed to achieve");   
         return -1;
      }
   }
   
   Print("Checking Pattern:....");
   if(CSPattern == BullishEngulfing_B) 
   { 
   
      double askprice; 
      SymbolInfoDouble(_Symbol, SYMBOL_ASK, askprice);
      double stoploss = CSPattern_Low + 100 *_Point;
      double takeProfit = CalculateTakeProfitFromPrice(askprice,stoploss , 2, isBuy);
      customTrade(3, stoploss ,takeProfit, isBuy);
      Print("BullishEngulfing BUY Trade at Price at : ", ask, "S/L : " , stoploss , " T/P : ", Resistance );
   }
   else if(CSPattern == BeareshEngulfing_S)
   {
      double bidprice; 
      SymbolInfoDouble(_Symbol, SYMBOL_BID, bidprice);
      double stoploss = CSPattern_High + 100 *_Point;
      double takeProfit = CalculateTakeProfitFromPrice(bidprice,stoploss , 2, isBuy);
      customTrade(3, stoploss ,takeProfit, isBuy);
      Print("BearishEngulfing SELL Trade at Price : ", ask, "S/L : " , stoploss , " T/P : ", Support );
   }
    
   else if(CSPattern == MorningStar_B)
   {  
      double askprice;
      SymbolInfoDouble(_Symbol, SYMBOL_ASK, askprice);
      double stoploss = CSPattern_Low + 100 *_Point;
      double takeProfit = CalculateTakeProfitFromPrice(askprice,stoploss , 2, isBuy);
      customTrade(3, stoploss ,takeProfit, isBuy);
      Print("MorningStart Trade at Price : ", ask, "S/L : " , stoploss , " T/P : ", Resistance );
   }
   else if(CSPattern == EveningStar_S)
   {  
      double bidprice;
      SymbolInfoDouble(_Symbol, SYMBOL_BID, bidprice);
      double stoploss = CSPattern_High + 100 *_Point;
      double takeProfit = CalculateTakeProfitFromPrice(bidprice,stoploss , 2, isBuy);
      customTrade(3, stoploss ,takeProfit, isBuy);
      Print("EveningStar Trade at Price : ", ask, "S/L : " , stoploss , " T/P : ", Support  );
   }
   return 0;
}




//+------------------------------------------------------------------+
//| Calculates Take Profit price based on price-level SL            |
//| Inputs:                                                          |
//|   double entryPrice  - Entry price (Ask for buy, Bid for sell)   |
//|   double slPrice     - Stop Loss price level                     |
//|   double rrRatio     - Risk-to-Reward ratio                      |
//|   bool isBuy         - true for Buy, false for Sell              |
//| Returns:                                                        |
//|   double - Take Profit price                                     |
//+------------------------------------------------------------------+
double CalculateTakeProfitFromPrice(double entryPrice, double slPrice, double rrRatio, bool isBuy)
{
    double priceDiff, tpPrice;

    if (isBuy)
    {
        priceDiff = entryPrice - slPrice; // risk in price
        tpPrice = entryPrice + (priceDiff * rrRatio);
    }
    else
    {
        priceDiff = slPrice - entryPrice; // risk in price
        tpPrice = entryPrice - (priceDiff * rrRatio);
    }

    return tpPrice;
}
