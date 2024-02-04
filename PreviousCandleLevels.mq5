/**=   PreviousCandleLevels.mq5   (TyphooN's Previous Candlestick Level Indicator)
 *      Copyright 2023, TyphooN (https://www.marketwizardry.org/)
 *
 * Disclaimer and Licence
 *
 * This file is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * All trading involves risk. You should have received the risk warnings
 * and terms of use in the README.MD file distributed with this software.
 * See the README.MD file for more information and before using this software.
 *
 **/
#property copyright "Copyright 2023 TyphooN (MarketWizardry.org)"
#property link      "http://www.marketwizardry.info/"
#property version   "1.022"
#property description "TyphooN's PreviousCandleLevels"
#property indicator_chart_window
// Define input parameters
input color PreviousCandleColour = clrWhite;
input color JudasLevelColour = clrMagenta;
input int Line_Thickness = 2;
// Global vars
string objname1 = "Previous_";
string objname2 = "Current_";
double Previous_H1_High, Previous_H1_Low, Previous_H4_High, Previous_H4_Low, Previous_D1_High, Previous_D1_Low, Previous_W1_High, Previous_W1_Low,
   Previous_MN1_High, Previous_MN1_Low, Asian_High, Asian_Low, London_High, London_Low, Current_D1_Low, Current_D1_High, Ask, Bid;
int lastCheckedCandle = -1;
datetime lastJudasUpdate = 0;
input int AsianBeginningHour = 0;   // Asian session start hour
input int AsianEndingHour = 8;      // Asian session end hour
input int LondonBeginningHour = 8;  // London session start hour
input int LondonEndingHour = 16;    // London session end hour
int OnInit()
{
   return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, objname1);
   ObjectsDeleteAll(0, objname2);
}
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   Ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   Bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   static datetime prevTradeServerTime = 0;  // Initialize with 0 on the first run
   datetime currentTradeServerTime = 0;
   currentTradeServerTime = TimeTradeServer();
   // Check if it is a new H1 interval
   if (IsNewH1Interval(currentTradeServerTime, prevTradeServerTime))
   {
      UpdatePreviousData();
      UpdateJudasData();
      DrawLines();
      prevTradeServerTime = currentTradeServerTime;
      //Print("Updating ATR Data and Candlestick data due to 15 min server time.");
   }
   // Calculate the number of bars to be processed
   int limit = rates_total - prev_calculated;
   // If there are no new bars, return
   if (limit <= 0)
   {
      return 0;
   }
   // Check if a new candlestick has formed
   if (lastCheckedCandle != rates_total - 1)
   {
      //Print("New candle has formed, updating ATR & Candlestick Data");
      // Update the last checked candle index
      lastCheckedCandle = rates_total - 1;
      UpdatePreviousData();
      UpdateJudasData();
      DrawLines();
   }
   if (Bid > Current_D1_High || Bid > Asian_High || Bid > London_High || Ask < Current_D1_Low
      || Ask < Asian_Low || Ask < London_Low || TimeCurrent() > lastJudasUpdate + 60)
   {
      UpdateJudasData();
      DrawLines();
   }
   return(rates_total);
}
void UpdatePreviousData()
{
   Previous_H1_High = iHigh(_Symbol, PERIOD_H1, 1);
   Previous_H1_Low = iLow(_Symbol, PERIOD_H1, 1);
   Previous_H4_High = iHigh(_Symbol, PERIOD_H4, 1);
   Previous_H4_Low = iLow(_Symbol, PERIOD_H4, 1);
   Previous_D1_High = iHigh(_Symbol, PERIOD_D1, 1);
   Previous_D1_Low = iLow(_Symbol, PERIOD_D1, 1);
   Previous_W1_High = iHigh(_Symbol, PERIOD_W1, 1);
   Previous_W1_Low = iLow(_Symbol, PERIOD_W1, 1);
   Previous_MN1_High = iHigh(_Symbol, PERIOD_MN1, 1);
   Previous_MN1_Low = iLow(_Symbol, PERIOD_MN1, 1);
}
void UpdateJudasData()
{
   // Calculate Asian session high and low
   datetime asianSessionStart = iTime(_Symbol, PERIOD_H1, 1) + AsianBeginningHour * 3600;
   datetime asianSessionEnd = iTime(_Symbol, PERIOD_H1, 1) + AsianEndingHour * 3600;
   int asianSessionEndShift = iBarShift(_Symbol, PERIOD_H1, asianSessionEnd);
   int asianSessionStartShift = iBarShift(_Symbol, PERIOD_H1, asianSessionStart);
   Asian_High = iHigh(_Symbol, PERIOD_H1, asianSessionEndShift);
   Asian_Low = iLow(_Symbol, PERIOD_H1, asianSessionStartShift);
   // Calculate London session high and low
   datetime londonSessionStart = iTime(_Symbol, PERIOD_H1, 1) + LondonBeginningHour * 3600;
   datetime londonSessionEnd = iTime(_Symbol, PERIOD_H1, 1) + LondonEndingHour * 3600;
   int londonSessionEndShift = iBarShift(_Symbol, PERIOD_H1, londonSessionEnd);
   int londonSessionStartShift = iBarShift(_Symbol, PERIOD_H1, londonSessionStart);
   London_High = iHigh(_Symbol, PERIOD_H1, londonSessionEndShift);
   London_Low = iLow(_Symbol, PERIOD_H1, londonSessionStartShift);
   // Calculate current day's high and low
   int currentDayStartShift = iBarShift(_Symbol, PERIOD_D1, iTime(_Symbol, PERIOD_D1, 0));
   int currentDayEndShift = iBarShift(_Symbol, PERIOD_M1, iTime(_Symbol, PERIOD_M1, 0));
   Current_D1_High = iHigh(_Symbol, PERIOD_D1, currentDayEndShift);
   Current_D1_Low = iLow(_Symbol, PERIOD_D1, currentDayStartShift);
   lastJudasUpdate = TimeCurrent();
}
void DrawLines()
{
   if(_Period <= PERIOD_H1)
   {
      DrawHorizontalLine(Previous_H1_High, objname1 + "H1_High", PreviousCandleColour, iTime(_Symbol, PERIOD_H1, 1), iTime(_Symbol, PERIOD_CURRENT, 0));
      DrawHorizontalLine(Previous_H1_Low, objname1 + "H1_Low", PreviousCandleColour, iTime(_Symbol, PERIOD_H1, 1), iTime(_Symbol, PERIOD_CURRENT, 0));
      DrawHorizontalLine(Previous_H4_High, objname1 + "H4_High", PreviousCandleColour, iTime(_Symbol, PERIOD_H4, 1), iTime(_Symbol, PERIOD_CURRENT, 0));
      DrawHorizontalLine(Previous_H4_Low, objname1 + "H4_Low", PreviousCandleColour, iTime(_Symbol, PERIOD_H4, 1), iTime(_Symbol, PERIOD_CURRENT, 0));
      DrawHorizontalLine(Previous_D1_High, objname1 + "D1_High", JudasLevelColour, iTime(_Symbol, PERIOD_D1, 1), iTime(_Symbol, PERIOD_CURRENT, 0));
      DrawHorizontalLine(Previous_D1_Low, objname1 + "D1_Low", JudasLevelColour, iTime(_Symbol, PERIOD_D1, 1), iTime(_Symbol, PERIOD_CURRENT, 0));
      DrawHorizontalLine(Previous_W1_High, objname1 + "W1_High", JudasLevelColour, iTime(_Symbol, PERIOD_W1, 1), iTime(_Symbol, PERIOD_CURRENT, 0));
      DrawHorizontalLine(Previous_W1_Low, objname1 + "W1_Low", JudasLevelColour, iTime(_Symbol, PERIOD_W1, 1), iTime(_Symbol, PERIOD_CURRENT, 0));
      DrawHorizontalLine(Previous_MN1_High, objname1 + "MN1_High", PreviousCandleColour, iTime(_Symbol, PERIOD_MN1, 1), iTime(_Symbol, PERIOD_CURRENT, 0));
      DrawHorizontalLine(Previous_MN1_Low, objname1 + "MN1_Low", PreviousCandleColour, iTime(_Symbol, PERIOD_MN1, 1), iTime(_Symbol, PERIOD_CURRENT, 0));
      DrawHorizontalLine(Current_D1_High, objname2 + "D1_High", JudasLevelColour, iTime(_Symbol, PERIOD_D1, 1), iTime(_Symbol, PERIOD_CURRENT, 0));
      DrawHorizontalLine(Current_D1_Low, objname2 + "D1_Low", JudasLevelColour, iTime(_Symbol, PERIOD_D1, 1), iTime(_Symbol, PERIOD_CURRENT, 0));
      DrawHorizontalLine(Asian_High, objname2 + "Asian_High", JudasLevelColour, iTime(_Symbol, PERIOD_H1, 1), iTime(_Symbol, PERIOD_CURRENT, 0));
      DrawHorizontalLine(Asian_Low, objname2 + "Asian_Low", JudasLevelColour, iTime(_Symbol, PERIOD_H1, 1), iTime(_Symbol, PERIOD_CURRENT, 0));
      DrawHorizontalLine(London_High, objname2 + "London_High", JudasLevelColour, iTime(_Symbol, PERIOD_H1, 1), iTime(_Symbol, PERIOD_CURRENT, 0));
      DrawHorizontalLine(London_Low, objname2 + "London_Low", JudasLevelColour, iTime(_Symbol, PERIOD_H1, 1), iTime(_Symbol, PERIOD_CURRENT, 0));
   }
   if(_Period == PERIOD_H4)
   {
      if(ObjectCreate(0, objname1 + "H1_High", OBJ_TREND, 0, 0, 0, 0, 0))
      {
         ObjectDelete(0, objname1 + "H1_High");
      }
      if(ObjectCreate(0, objname1 + "H1_Low", OBJ_TREND, 0, 0, 0, 0, 0))
      {
         ObjectDelete(0, objname1 + "H1_Low");
      }
      DrawHorizontalLine(Previous_H4_High, objname1 + "H4_High", PreviousCandleColour, iTime(_Symbol, PERIOD_H4, 1), iTime(_Symbol, PERIOD_CURRENT, 0));
      DrawHorizontalLine(Previous_H4_Low, objname1 + "H4_Low", PreviousCandleColour, iTime(_Symbol, PERIOD_H4, 1), iTime(_Symbol, PERIOD_CURRENT, 0));
      DrawHorizontalLine(Previous_D1_High, objname1 + "D1_High", JudasLevelColour, iTime(_Symbol, PERIOD_D1, 1), iTime(_Symbol, PERIOD_CURRENT, 0));
      DrawHorizontalLine(Previous_D1_Low, objname1 + "D1_Low", JudasLevelColour, iTime(_Symbol, PERIOD_D1, 1), iTime(_Symbol, PERIOD_CURRENT, 0));
      DrawHorizontalLine(Previous_W1_High, objname1 + "W1_High", JudasLevelColour, iTime(_Symbol, PERIOD_W1, 1), iTime(_Symbol, PERIOD_CURRENT, 0));
      DrawHorizontalLine(Previous_W1_Low, objname1 + "W1_Low", JudasLevelColour, iTime(_Symbol, PERIOD_W1, 1), iTime(_Symbol, PERIOD_CURRENT, 0));
      DrawHorizontalLine(Previous_MN1_High, objname1 + "MN1_High", PreviousCandleColour, iTime(_Symbol, PERIOD_MN1, 1), iTime(_Symbol, PERIOD_CURRENT, 0));
      DrawHorizontalLine(Previous_MN1_Low, objname1 + "MN1_Low", PreviousCandleColour, iTime(_Symbol, PERIOD_MN1, 1), iTime(_Symbol, PERIOD_CURRENT, 0));
      DrawHorizontalLine(Current_D1_High, objname2 + "D1_High", JudasLevelColour, iTime(_Symbol, PERIOD_D1, 1), iTime(_Symbol, PERIOD_CURRENT, 0));
      DrawHorizontalLine(Current_D1_Low, objname2 + "D1_Low", JudasLevelColour, iTime(_Symbol, PERIOD_D1, 1), iTime(_Symbol, PERIOD_CURRENT, 0));
      DrawHorizontalLine(Asian_High, objname2 + "Asian_High", JudasLevelColour, iTime(_Symbol, PERIOD_H1, 1), iTime(_Symbol, PERIOD_CURRENT, 0));
      DrawHorizontalLine(Asian_Low, objname2 + "Asian_Low", JudasLevelColour, iTime(_Symbol, PERIOD_H1, 1), iTime(_Symbol, PERIOD_CURRENT, 0));
      DrawHorizontalLine(London_High, objname2 + "London_High", JudasLevelColour, iTime(_Symbol, PERIOD_H1, 1), iTime(_Symbol, PERIOD_CURRENT, 0));
      DrawHorizontalLine(London_Low, objname2 + "London_Low", JudasLevelColour, iTime(_Symbol, PERIOD_H1, 1), iTime(_Symbol, PERIOD_CURRENT, 0));
   }
   if(_Period == PERIOD_D1)
   {
      if(ObjectCreate(0, objname1 + "H1_High", OBJ_TREND, 0, 0, 0, 0, 0))
      {
         ObjectDelete(0, objname1 + "H1_High");
      }
      if(ObjectCreate(0, objname1 + "H1_Low", OBJ_TREND, 0, 0, 0, 0, 0))
      {
         ObjectDelete(0, objname1 + "H1_Low");
      }
      if(ObjectCreate(0, objname1 + "H4_High", OBJ_TREND, 0, 0, 0, 0, 0))
      {
         ObjectDelete(0, objname1 + "H4_High");
      }
      if(ObjectCreate(0, objname1 + "H4_Low", OBJ_TREND, 0, 0, 0, 0, 0))
      {
         ObjectDelete(0, objname1 + "H4_Low");
      }
      DrawHorizontalLine(Previous_D1_High, objname1 + "D1_High", JudasLevelColour, iTime(_Symbol, PERIOD_D1, 1), iTime(_Symbol, PERIOD_CURRENT, 0));
      DrawHorizontalLine(Previous_D1_Low, objname1 + "D1_Low", JudasLevelColour, iTime(_Symbol, PERIOD_D1, 1), iTime(_Symbol, PERIOD_CURRENT, 0));
      DrawHorizontalLine(Previous_W1_High, objname1 + "W1_High", JudasLevelColour, iTime(_Symbol, PERIOD_W1, 1), iTime(_Symbol, PERIOD_CURRENT, 0));
      DrawHorizontalLine(Previous_W1_Low, objname1 + "W1_Low", JudasLevelColour, iTime(_Symbol, PERIOD_W1, 1), iTime(_Symbol, PERIOD_CURRENT, 0));
      DrawHorizontalLine(Previous_MN1_High, objname1 + "MN1_High", PreviousCandleColour, iTime(_Symbol, PERIOD_MN1, 1), iTime(_Symbol, PERIOD_CURRENT, 0));
      DrawHorizontalLine(Previous_MN1_Low, objname1 + "MN1_Low", PreviousCandleColour, iTime(_Symbol, PERIOD_MN1, 1), iTime(_Symbol, PERIOD_CURRENT, 0));
      DrawHorizontalLine(Current_D1_High, objname2 + "D1_High", JudasLevelColour, iTime(_Symbol, PERIOD_D1, 1), iTime(_Symbol, PERIOD_CURRENT, 0));
      DrawHorizontalLine(Current_D1_Low, objname2 + "D1_Low", JudasLevelColour, iTime(_Symbol, PERIOD_D1, 1), iTime(_Symbol, PERIOD_CURRENT, 0));
      DrawHorizontalLine(Asian_High, objname2 + "Asian_High", JudasLevelColour, iTime(_Symbol, PERIOD_H1, 1), iTime(_Symbol, PERIOD_CURRENT, 0));
      DrawHorizontalLine(Asian_Low, objname2 + "Asian_Low", JudasLevelColour, iTime(_Symbol, PERIOD_H1, 1), iTime(_Symbol, PERIOD_CURRENT, 0));
      DrawHorizontalLine(London_High, objname2 + "London_High", JudasLevelColour, iTime(_Symbol, PERIOD_H1, 1), iTime(_Symbol, PERIOD_CURRENT, 0));
      DrawHorizontalLine(London_Low, objname2 + "London_Low", JudasLevelColour, iTime(_Symbol, PERIOD_H1, 1), iTime(_Symbol, PERIOD_CURRENT, 0));
   }
   if(_Period == PERIOD_W1)
   {
      if(ObjectCreate(0, objname1 + "H1_High", OBJ_TREND, 0, 0, 0, 0, 0))
      {
         ObjectDelete(0, objname1 + "H1_High");
      }
      if(ObjectCreate(0, objname1 + "H1_Low", OBJ_TREND, 0, 0, 0, 0, 0))
      {
         ObjectDelete(0, objname1 + "H1_Low");
      }
      if(ObjectCreate(0, objname1 + "H4_High", OBJ_TREND, 0, 0, 0, 0, 0))
      {
         ObjectDelete(0, objname1 + "H4_High");
      }
      if(ObjectCreate(0, objname1 + "H4_Low", OBJ_TREND, 0, 0, 0, 0, 0))
      {
         ObjectDelete(0, objname1 + "H4_Low");
      }
      if(ObjectCreate(0, objname1 + "D1_High", OBJ_TREND, 0, 0, 0, 0, 0))
      {
         ObjectDelete(0, objname1 + "D1_High");
      }
      if(ObjectCreate(0, objname1 + "D1_Low", OBJ_TREND, 0, 0, 0, 0, 0))
      {
         ObjectDelete(0, objname1 + "D1_Low");
      }
      if(ObjectCreate(0, objname2 + "D1_High", OBJ_TREND, 0, 0, 0, 0, 0))
      {
         ObjectDelete(0, objname2 + "D1_High");
      }
      if(ObjectCreate(0, objname2 + "D1_Low", OBJ_TREND, 0, 0, 0, 0, 0))
      {
         ObjectDelete(0, objname2 + "D1_Low");
      }
      if(ObjectCreate(0, objname2 + "London_Low", OBJ_TREND, 0, 0, 0, 0, 0))
      {
         ObjectDelete(0, objname2 + "London_Low");
      }
      if(ObjectCreate(0, objname2 + "London_High", OBJ_TREND, 0, 0, 0, 0, 0))
      {
         ObjectDelete(0, objname2 + "London_High");
      }
      if(ObjectCreate(0, objname2 + "Asian_Low", OBJ_TREND, 0, 0, 0, 0, 0))
      {
         ObjectDelete(0, objname2 + "Asian_Low");
      }
      if(ObjectCreate(0, objname2 + "Asian_High", OBJ_TREND, 0, 0, 0, 0, 0))
      {
         ObjectDelete(0, objname2 + "Asian_High");
      }
      DrawHorizontalLine(Previous_W1_High, objname2 + "W1_High", JudasLevelColour, iTime(_Symbol, PERIOD_W1, 1), iTime(_Symbol, PERIOD_CURRENT, 0));
      DrawHorizontalLine(Previous_W1_Low, objname2 + "W1_Low", JudasLevelColour, iTime(_Symbol, PERIOD_W1, 1), iTime(_Symbol, PERIOD_CURRENT, 0));
      DrawHorizontalLine(Previous_MN1_High, objname1 + "MN1_High", PreviousCandleColour, iTime(_Symbol, PERIOD_MN1, 1), iTime(_Symbol, PERIOD_CURRENT, 0));
      DrawHorizontalLine(Previous_MN1_Low, objname1 + "MN1_Low", PreviousCandleColour, iTime(_Symbol, PERIOD_MN1, 1), iTime(_Symbol, PERIOD_CURRENT, 0));
   }
   if(_Period == PERIOD_MN1)
   {
      if(ObjectCreate(0, objname1 + "H1_High", OBJ_TREND, 0, 0, 0, 0, 0))
      {
         ObjectDelete(0, objname1 + "H1_High");
      }
      if(ObjectCreate(0, objname1 + "H1_Low", OBJ_TREND, 0, 0, 0, 0, 0))
      {
         ObjectDelete(0, objname1 + "H1_Low");
      }
      if(ObjectCreate(0, objname1 + "H4_High", OBJ_TREND, 0, 0, 0, 0, 0))
      {
         ObjectDelete(0, objname1 + "H4_High");
      }
      if(ObjectCreate(0, objname1 + "H4_Low", OBJ_TREND, 0, 0, 0, 0, 0))
      {
         ObjectDelete(0, objname1 + "H4_Low");
      }
      if(ObjectCreate(0, objname1 + "D1_High", OBJ_TREND, 0, 0, 0, 0, 0))
      {
         ObjectDelete(0, objname1 + "D1_High");
      }
      if(ObjectCreate(0, objname1 + "D1_Low", OBJ_TREND, 0, 0, 0, 0, 0))
      {
         ObjectDelete(0, objname1 + "D1_Low");
      }
      if(ObjectCreate(0, objname1 + "W1_Low", OBJ_TREND, 0, 0, 0, 0, 0))
      {
         ObjectDelete(0, objname1 + "W1_Low");
      }
      if(ObjectCreate(0, objname1 + "W1_High", OBJ_TREND, 0, 0, 0, 0, 0))
      {
         ObjectDelete(0, objname1 + "W1_High");
      }
      if(ObjectCreate(0, objname2 + "D1_High", OBJ_TREND, 0, 0, 0, 0, 0))
      {
         ObjectDelete(0, objname2 + "D1_High");
      }
      if(ObjectCreate(0, objname2 + "D1_Low", OBJ_TREND, 0, 0, 0, 0, 0))
      {
         ObjectDelete(0, objname2 + "D1_Low");
      }
      if(ObjectCreate(0, objname2 + "London_Low", OBJ_TREND, 0, 0, 0, 0, 0))
      {
         ObjectDelete(0, objname2 + "London_Low");
      }
      if(ObjectCreate(0, objname2 + "London_High", OBJ_TREND, 0, 0, 0, 0, 0))
      {
         ObjectDelete(0, objname2 + "London_High");
      }
      if(ObjectCreate(0, objname2 + "Asian_Low", OBJ_TREND, 0, 0, 0, 0, 0))
      {
         ObjectDelete(0, objname2 + "Asian_Low");
      }
      if(ObjectCreate(0, objname2 + "Asian_High", OBJ_TREND, 0, 0, 0, 0, 0))
      {
         ObjectDelete(0, objname2 + "Asian_High");
      }
      DrawHorizontalLine(Previous_MN1_High, objname2 + "MN1_High", JudasLevelColour, iTime(_Symbol, PERIOD_MN1, 1), iTime(_Symbol, PERIOD_CURRENT, 0));
      DrawHorizontalLine(Previous_MN1_Low, objname2 + "MN1_Low", JudasLevelColour, iTime(_Symbol, PERIOD_MN1, 1), iTime(_Symbol, PERIOD_CURRENT, 0));
   }
}
void DrawHorizontalLine(double price, string label, color clr, datetime startTime, datetime endTime)
{
   ObjectCreate(0, label, OBJ_TREND, 0, startTime, price, endTime, price);
   ObjectSetInteger(0, label, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, label, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSetInteger(0, label, OBJPROP_RAY_LEFT, false);
   ObjectSetInteger(0, label, OBJPROP_RAY_RIGHT, false);
   ObjectSetInteger(0, label, OBJPROP_SELECTED, false);
   ObjectSetDouble(0, label, OBJPROP_PRICE, price);
   ObjectSetInteger(0, label, OBJPROP_WIDTH, Line_Thickness);
}
bool IsNewH1Interval(const datetime& currentTime, const datetime& prevTime)
{
   MqlDateTime currentMqlTime, prevMqlTime;
   TimeToStruct(currentTime, currentMqlTime);
   TimeToStruct(prevTime, prevMqlTime);
   //Print("IsNewH1Interval() has run.");
   // Check if the minutes have changed
   if (currentMqlTime.min != prevMqlTime.min)
   {
   // Check if the current time is at a a hourly interval
   if (currentMqlTime.min == 0  && prevMqlTime.hour < currentMqlTime.hour)
   {
      return true;
   }
   }
   return false;
}
