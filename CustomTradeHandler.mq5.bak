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

void customTrade(double Risk, double stopLossPrice, double takeProfitPrice, bool isBuy, CSPatternType &CandlePattern)
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
   string commt;
   if(CandlePattern == BullishEngulfing_B) commt = "Bullish Engulfing Buy";
   else if(CandlePattern == BeareshEngulfing_S) commt = "Bearish Engulfing Sell";
   else if(CandlePattern == MorningStar_B) commt = "MorningStar_B Buy";
   else if(CandlePattern == EveningStar_S) commt = "EveningStar_S";
   
   
   // Execute trade based on direction
   if (isBuy)
   {
      trade.Buy(lotSize, _Symbol, entryPrice, stopLossPrice, takeProfitPrice, commt);
   }
   else
   {
      trade.Sell(lotSize, _Symbol, entryPrice, stopLossPrice, takeProfitPrice, commt);
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
      return 0;
      double askprice; 
      SymbolInfoDouble(_Symbol, SYMBOL_ASK, askprice);
      double stoploss = CSPattern_Low - 100 *_Point;
      double takeProfit = CalculateTakeProfitFromPrice(askprice,stoploss , 1, isBuy);
      customTrade(3, stoploss ,takeProfit, isBuy, CSPattern);
      Print("BullishEngulfing BUY Trade at Price at : ", ask, "S/L : " , stoploss , " T/P : ", Resistance );
   }
   else if(CSPattern == BeareshEngulfing_S)
   {  
      return 0;
      double bidprice; 
      SymbolInfoDouble(_Symbol, SYMBOL_BID, bidprice);
      double stoploss = CSPattern_High + 100 *_Point;
      double takeProfit = CalculateTakeProfitFromPrice(bidprice,stoploss , 1, isBuy);
      customTrade(3, stoploss ,takeProfit, isBuy, CSPattern);
      Print("BearishEngulfing SELL Trade at Price : ", ask, "S/L : " , stoploss , " T/P : ", Support );
   }
    
   else if(CSPattern == MorningStar_B)
   {  
      double askprice;
      SymbolInfoDouble(_Symbol, SYMBOL_ASK, askprice);
      double stoploss = CSPattern_Low - 100 *_Point;
      double takeProfit = CalculateTakeProfitFromPrice(askprice,stoploss , 2, isBuy);
      customTrade(3, stoploss ,takeProfit, isBuy, CSPattern);
      Print("MorningStart Trade at Price : ", ask, "S/L : " , stoploss , " T/P : ", Resistance );
   }
   else if(CSPattern == EveningStar_S)
   {  
      double bidprice;
      SymbolInfoDouble(_Symbol, SYMBOL_BID, bidprice);
      double stoploss = CSPattern_High + 100 *_Point;
      double takeProfit = CalculateTakeProfitFromPrice(bidprice,stoploss , 2, isBuy);
      customTrade(3, stoploss ,takeProfit, isBuy, CSPattern);
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




void MoveStopToBreakeven()
{
    int totalPositions = PositionsTotal();

    for (int i = 0; i < totalPositions; i++)
    {
        ulong ticket = PositionGetTicket(i);
        if (!PositionSelectByTicket(ticket))
            continue;

        string symbol = PositionGetString(POSITION_SYMBOL);
        if (symbol != _Symbol) // only manage trades on current symbol
            continue;

        double entryPrice = PositionGetDouble(POSITION_PRICE_OPEN);
        double stopLoss   = PositionGetDouble(POSITION_SL);
        double volume     = PositionGetDouble(POSITION_VOLUME);
        double sl_distance = 0.0;
        double currentPrice = 0.0;

        long type = PositionGetInteger(POSITION_TYPE);
        if (type == POSITION_TYPE_BUY)
        {
            SymbolInfoDouble(_Symbol, SYMBOL_BID, currentPrice);
            sl_distance = entryPrice - stopLoss;
            if (currentPrice - entryPrice >= sl_distance && stopLoss < entryPrice)
            {
                trade.PositionModify(ticket, entryPrice, PositionGetDouble(POSITION_TP));
            }
        }
        else if (type == POSITION_TYPE_SELL)
        {
            SymbolInfoDouble(_Symbol, SYMBOL_ASK, currentPrice);
            sl_distance = stopLoss - entryPrice;
            if (entryPrice - currentPrice >= sl_distance && stopLoss > entryPrice)
            {
                trade.PositionModify(ticket, entryPrice, PositionGetDouble(POSITION_TP));
            }
        }
    }
}