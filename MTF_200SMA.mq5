/**=              MTF_200SMA.mq5  (TyphooN's Multi Timeframe 200SMA)
 *               Copyright 2023, TyphooN (https://www.decapool.net/)
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
#property copyright "TyphooN"
#property link      "http://decapool.net"
#property version   "1.003"
#property indicator_chart_window
#property indicator_buffers 9
#property indicator_plots   9
#property indicator_label1  "H1 200SMA"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrMagenta
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
#property indicator_label2  "H4 200SMA"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrMagenta
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2
#property indicator_label3  "D1 200SMA"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrMagenta
#property indicator_style3  STYLE_SOLID
#property indicator_width3  2
#property indicator_label4  "W1 200SMA"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrMagenta
#property indicator_style4  STYLE_SOLID
#property indicator_width4  2
#property indicator_label5  "MN1 200SMA"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrMagenta
#property indicator_style5  STYLE_SOLID
#property indicator_width5  2
#property indicator_label6  "M1 200SMA"
#property indicator_type6   DRAW_LINE
#property indicator_color6  clrOrange
#property indicator_style6  STYLE_SOLID
#property indicator_width6  2
#property indicator_label7  "M5 200SMA"
#property indicator_type7   DRAW_LINE
#property indicator_color7  clrOrange
#property indicator_style7  STYLE_SOLID
#property indicator_width7  2
#property indicator_label8  "M15 200SMA"
#property indicator_type8   DRAW_LINE
#property indicator_color8  clrOrange
#property indicator_style8  STYLE_SOLID
#property indicator_width8  2
#property indicator_label9  "M30 200SMA"
#property indicator_type9   DRAW_LINE
#property indicator_color9  clrOrange
#property indicator_style9  STYLE_SOLID
#property indicator_width9  2
// Input variables
input bool Enable_H1_200SMA = true;
input bool Enable_H4_200SMA = true;
input bool Enable_D1_200SMA = true;
input bool Enable_W1_200SMA = true;
input bool Enable_M1_200SMA = true;
input bool Enable_M5_200SMA = true;
input bool Enable_M15_200SMA = true;
input bool Enable_M30_200SMA = true;
input bool Enable_MN1_200SMA = false;
int MAPeriod = 200;
ENUM_APPLIED_PRICE MAPrice = PRICE_CLOSE;
// Handles
int HandleH1, HandleH4, HandleD1, HandleW1, HandleMN1, HandleM1, HandleM5, HandleM15, HandleM30;
// Buffers
double MABufferH1[], MABufferH4[], MABufferD1[], MABufferW1[], MABufferMN1[], MABufferM1[], MABufferM5[], MABufferM15[], MABufferM30[];
bool W1_Enable, MN1_Enable;
bool isTimerSet = false;
int lastCheckedCandle = -1;
int OnInit()
{
   isTimerSet = EventSetTimer(300);
   if (!isTimerSet) {
      Print("Error setting timer");
   }
   W1_Enable = Enable_W1_200SMA;
   MN1_Enable = Enable_MN1_200SMA;
   //--- indicator buffers mapping
   SetIndexBuffer(0, MABufferH1, INDICATOR_DATA);
   SetIndexBuffer(1, MABufferH4, INDICATOR_DATA);
   SetIndexBuffer(2, MABufferD1, INDICATOR_DATA);
   SetIndexBuffer(3, MABufferW1, INDICATOR_DATA);
   SetIndexBuffer(4, MABufferMN1, INDICATOR_DATA);
   SetIndexBuffer(5, MABufferM1, INDICATOR_DATA);
   SetIndexBuffer(6, MABufferM5, INDICATOR_DATA);
   SetIndexBuffer(7, MABufferM15, INDICATOR_DATA);
   SetIndexBuffer(8, MABufferM30, INDICATOR_DATA);
   UpdateBuffers();
   return 0;
}
void OnDeinit(const int reason)
{
   if (isTimerSet) {
      EventKillTimer();
   }
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
   int start;
   if (prev_calculated == 0)
   {
      start = 0;
   }
   else
   {
      start = prev_calculated - 1;
   }
   if (lastCheckedCandle != rates_total - 1)
   {
      Print("New candle has formed, updating MA Data");
      // Update the last checked candle index
      lastCheckedCandle = rates_total - 1;
      UpdateBuffersOnCalculate(start, rates_total);
   }
   static int waitCount = 4;
   if (waitCount > 0)
   {
      UpdateBuffersOnCalculate(start, rates_total);
      waitCount--;
      //PrintFormat("Waiting for MA data");
      return (prev_calculated);
   }
   //PrintFormat("MA Data is now available");
   return rates_total;
}
void OnTimer()
{
   UpdateBuffers();
   Print("Timer Function ran");
}
void UpdateBuffers()
{
   if (Enable_H1_200SMA)
   {
      HandleH1 = iMA(NULL, PERIOD_H1, MAPeriod, 0, MODE_SMA, MAPrice);
      CopyBuffer(HandleH1, 0, 0, 0, MABufferH1);
   }
   if (Enable_H4_200SMA)
   {
      HandleH4 = iMA(NULL, PERIOD_H4, MAPeriod, 0, MODE_SMA, MAPrice);
      CopyBuffer(HandleH4, 0, 0, 0, MABufferH4);
   }
   if (Enable_D1_200SMA)
   {
      HandleD1 = iMA(NULL, PERIOD_D1, MAPeriod, 0, MODE_SMA, MAPrice);
      CopyBuffer(HandleD1, 0, 0, 0, MABufferD1);
   }
   if (W1_Enable == true)
   {
      HandleW1 = iMA(NULL, PERIOD_W1, MAPeriod, 0, MODE_SMA, MAPrice);
      if(HandleW1 != INVALID_HANDLE)
      {
         int copySizeW1 = CopyBuffer(HandleW1, 0, 0, 0, MABufferW1);
         if(copySizeW1 > 0)
         {
            bool isEmptyValueExist = false;
            for(int i = 0; i < copySizeW1; i++)
            {
               if(MABufferW1[i] == EMPTY_VALUE)
               {
                  isEmptyValueExist = true;
                  break;
               }
            }
            if(isEmptyValueExist)
            {
               Print("Warning: W1 SMA data contains EMPTY_VALUE!");
            }
         }
         }
      else
      {
         Print("Warning: Unable to calculate W1 SMA! Disabling!");
         W1_Enable = false;
      }
   }
   if (MN1_Enable == true)
   {
      HandleMN1 = iMA(NULL, PERIOD_MN1, MAPeriod, 0, MODE_SMA, MAPrice);
      if(HandleMN1 != INVALID_HANDLE)
      {
         int copySizeMN1 = CopyBuffer(HandleMN1, 0, 0, 0, MABufferMN1);
         if(copySizeMN1 > 0)
         {
            bool isEmptyValueExist = false;
            for(int i = 0; i < copySizeMN1; i++)
            {
               if(MABufferMN1[i] == EMPTY_VALUE)
               {
                  isEmptyValueExist = true;
                  break;
               }
            }
            if(isEmptyValueExist)
            {
               Print("Warning: MN1 SMA data contains EMPTY_VALUE!");
            }
         }
      }
      else
      {
         Print("Warning: Unable to calculate MN1 SMA! Disabling!");
         MN1_Enable = false;
      }
   }
   if (Enable_M1_200SMA)
   {
      HandleM1 = iMA(NULL, PERIOD_M1, MAPeriod, 0, MODE_SMA, MAPrice);
      CopyBuffer(HandleM1, 0, 0, 0, MABufferM1);
   }
   if (Enable_M5_200SMA)
   {
      HandleM5 = iMA(NULL, PERIOD_M5, MAPeriod, 0, MODE_SMA, MAPrice);
      CopyBuffer(HandleM5, 0, 0, 0, MABufferM5);
   }
   if (Enable_M15_200SMA)
   {
      HandleM15 = iMA(NULL, PERIOD_M15, MAPeriod, 0, MODE_SMA, MAPrice);
      CopyBuffer(HandleM15, 0, 0, 0, MABufferM15);
   }
   if (Enable_M30_200SMA)
   {
      HandleM30 = iMA(NULL, PERIOD_M30, MAPeriod, 0, MODE_SMA, MAPrice);
      CopyBuffer(HandleM30, 0, 0, 0, MABufferM30);
   }
}
void UpdateBuffersOnCalculate(int start, int rates_total)
{
   if (Enable_M1_200SMA)
      CopyBuffer(HandleM1, 0, 0, rates_total - start, MABufferM1);
   if (Enable_M5_200SMA)
      CopyBuffer(HandleM5, 0, 0, rates_total - start, MABufferM5);
   if (Enable_M15_200SMA)
      CopyBuffer(HandleM15, 0, 0, rates_total - start, MABufferM15);
   if (Enable_M30_200SMA)
      CopyBuffer(HandleM30, 0, 0, rates_total - start, MABufferM30);
   if (Enable_H1_200SMA)
      CopyBuffer(HandleH1, 0, 0, rates_total - start, MABufferH1);
   if (Enable_H4_200SMA)
      CopyBuffer(HandleH4, 0, 0, rates_total - start, MABufferH4);
   if (Enable_D1_200SMA)
      CopyBuffer(HandleD1, 0, 0, rates_total - start, MABufferD1);
   if (W1_Enable == true)
   {
      HandleW1 = iMA(NULL, PERIOD_W1, MAPeriod, 0, MODE_SMA, MAPrice);
      if(HandleW1 != INVALID_HANDLE)
      {
         int copySizeW1 = CopyBuffer(HandleW1, 0, 0, rates_total - start, MABufferW1);;
         if(copySizeW1 > 0)
         {
            bool isEmptyValueExist = false;
            for(int i = 0; i < copySizeW1; i++)
            {
               if(MABufferW1[i] == EMPTY_VALUE)
               {
                  isEmptyValueExist = true;
                  break;
               }
            }
            if(isEmptyValueExist)
            {
               Print("Warning: W1 SMA data contains EMPTY_VALUE!");
            }
         }
      }
      else
      {
         Print("Warning: Unable to calculate W1 SMA! Disabling!");
         W1_Enable = false;
      }
   }
   if (MN1_Enable == true)
   {
      HandleMN1 = iMA(NULL, PERIOD_MN1, MAPeriod, 0, MODE_SMA, MAPrice);
      if(HandleMN1 != INVALID_HANDLE)
      {
         int copySizeMN1 = CopyBuffer(HandleMN1, 0, 0, rates_total - start, MABufferMN1);
         if(copySizeMN1 > 0)
         {
         bool isEmptyValueExist = false;
         for(int i = 0; i < copySizeMN1; i++)
         {
            if(MABufferMN1[i] == EMPTY_VALUE)
            {
               isEmptyValueExist = true;
               break;
            }
         }
         if(isEmptyValueExist)
         {
            Print("Warning: MN1 SMA data contains EMPTY_VALUE!");
         }
      }
      }
      else
      {
         Print("Warning: Unable to calculate MN1 SMA! Disabling!");
         MN1_Enable = false;
      }
   }
}
