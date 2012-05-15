//+------------------------------------------------------------------+
//|                                               TradeCopySlave.mq4 |
//|                                                                  |
//| Copyright (c) 2011,2012 Vaclav Vobornik, Syslog.eu               |
//|                                                                  |
//| This program is free software: you can redistribute it and/or    |
//| modify it under the terms of the GNU General Public License      |
//| as published by the Free Software Foundation, either version 2   |
//| of the License, or (at your option) any later version.           |
//|                                                                  |
//| This program is distributed in the hope that it will be useful,  |
//| but WITHOUT ANY WARRANTY; without even the implied warranty of   |
//| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the     |
//| GNU General Public License for more details.                     |
//|                                                                  |
//| You should have received a copy of the GNU General Public        |
//| License along with this program.                                 |
//| If not, see http://www.gnu.org/licenses/gpl-2.0                  |
//| See legal implications: http://gpl-violations.org/               |
//|                                                                  |
//|                                                 http://syslog.eu |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, Syslog.eu, rel. 2012-05-15"
#property link      "http://syslog.eu"
// 2012-05-01 Prefix and Suffix added

extern string filename="TradeCopy";
extern string S1="recalculate Lot by this koeficient:";
extern double LotKoef=0.1;
extern string S2="if set, force Lot to this value:";
extern double ForceLot=0.01;
extern string S3="is set, use this amount for every 0.01 Lot if higher than calculated above:";
extern double MicroLotBalance=0;
extern int delay=1000;
extern double PipsTolerance=5;
extern int magic=20111219;
extern string Prefix="";
extern string Suffix="";
extern bool CopyDelayedTrades=false;

double Balance=0;
int start,TickCount;
int Size=0,RealSize=0,PrevSize=-1;
int cnt,TotalCounter=-1;
int mp=1;
string cmt;
string nl="\n";


int OrdId[],RealOrdId[];
string OrdSym[],RealOrdSym[];
string RealOrdOrig[];
int OrdTyp[],RealOrdTyp[];
double OrdLot[],RealOrdLot[];
double OrdPrice[],RealOrdPrice[];
double OrdSL[],RealOrdSL[];
double OrdTP[],RealOrdTP[];
string s[];
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init() {
//----
  Comment("Waiting for a tick...");
  Print("Waiting for a tick...");
  if (IsStopped()) {
    Print("Is Stopped!!!!!!!!!!!");
  }
  if (!IsExpertEnabled()) {
    Print("Expert Is NOT Enabled!!!!!!!!!!!");
  }

  if (Digits == 5 || Digits == 3){    // Adjust for five (5) digit brokers.
    mp=10;
  }

//----
  return(0);
}
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()

  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start() {
//----
  Print("Got a tick...");
  while(!IsStopped()) {
    if(!IsExpertEnabled()) break;
    
    start=GetTickCount();
 
    cmt="TickCount: "+start+nl+"Counter: "+TotalCounter;

    load_positions();

    for(int i=0;i<Size;i++) {
      cmt=cmt+nl+" [ "+OrdId[i]+" ] [ "+OrdSym[i]+" ] [ "+VerbType(OrdTyp[i])+" ] [ "+OrdLot[i]+" ] [ "+OrdPrice[i]+" ] [ "+OrdSL[i]+" ] [ "+OrdTP[i]+" ]";
    }  
    
// Make sense to make changes only when the market is open and trading allowed
    if(IsTradeAllowed() && IsConnected()) {
      compare_positions();
    }

    Comment(cmt);
    TickCount=GetTickCount()-start;
    if(delay>TickCount)Sleep(delay-TickCount-2);
  }
  Alert("end, TradeCopy EA stopped");
  Comment("");
  return(0);

}

void load_positions() {

  int handle=FileOpen(filename+".csv",FILE_CSV|FILE_READ,";");
  if(handle>0) {

    string line=FileReadString(handle);
    if (TotalCounter == StrToInteger(line)) {
      FileClose(handle);
      return;
    }else{
      TotalCounter=StrToInteger(line);
    }
    int cnt=0;
    while(FileIsEnding(handle)==false) {
    cmt=cmt+nl+"DEBUG: reading file";
      if (ArraySize(s)<cnt+1) ArrayResize(s,cnt+1);
      s[cnt]=FileReadString(handle);
      cnt++;
    }
    FileClose(handle);
    ArrayResize(s,cnt-1);
    cmt=cmt+nl+"DEBUG: file end";
    parse_s();
  }else Print("Error opening file ",GetLastError());
  return(0);
}
//+------------------------------------------------------------------+

void parse_s() {

  if (Size!=ArraySize(s)) {
    Size=ArraySize(s);
    ArrayResize(OrdId,Size);
    ArrayResize(OrdSym,Size);
    ArrayResize(OrdTyp,Size);
    ArrayResize(OrdLot,Size);
    ArrayResize(OrdPrice,Size);
    ArrayResize(OrdSL,Size);
    ArrayResize(OrdTP,Size);
  }
  for(int i=0;i<ArraySize(s);i++) {
  
// get line length, starting position, find position of ",", calculate the length of the substring
    int Len=StringLen(s[i]);
    int start=0;
    int end=StringFind(s[i],",",start);
    int length=end-start;
// get Id
    OrdId[i]=StrToInteger(StringSubstr(s[i],start,length));

    start=end+1;
    end=StringFind(s[i],",",start);
    length=end-start;
    OrdSym[i]=Prefix+StringSubstr(s[i],start,length)+Suffix;
   
    start=end+1;
    end=StringFind(s[i],",",start);
    length=end-start;
    OrdTyp[i]=StrToInteger(StringSubstr(s[i],start,length));

    start=end+1;
    end=StringFind(s[i],",",start);
    length=end-start;
    OrdLot[i]=LotVol(StrToDouble(StringSubstr(s[i],start,length)),OrdSym[i]);

    start=end+1;
    end=StringFind(s[i],",",start);
    length=end-start;
    OrdPrice[i]=NormalizeDouble(StrToDouble(StringSubstr(s[i],start,length)),digits(OrdSym[i]));

    start=end+1;
    end=StringFind(s[i],",",start);
    length=end-start;
    OrdSL[i]=NormalizeDouble(StrToDouble(StringSubstr(s[i],start,length)),digits(OrdSym[i]));

    start=end+1;
    end=StringFind(s[i],",",start);
    length=end-start;
    OrdTP[i]=NormalizeDouble(StrToDouble(StringSubstr(s[i],start,length)),digits(OrdSym[i]));

  }
}


double LotVol(double lot,string symbol) {

  if (ForceLot > 0) {
    lot=ForceLot;
  }else{
    lot=lot*LotKoef;
  }

  if (Balance<AccountBalance()) Balance=AccountBalance();
  
  if (MicroLotBalance > 0) {
    if (MathFloor(Balance/MicroLotBalance)/100 > lot) {
      lot=MathFloor(Balance/MicroLotBalance)/100;
    }
  }
//  Print("Calculated lot size: ",lot);

  return(NormalizeDouble(lot,DigitsMinLot(symbol)));
}  
 
 

string VerbType (int type) {

  switch(type) {
    case 0:
      return ("BUY");
      break;
    case 1:
      return ("SELL");
      break;
    case 2:
      return ("BUY LIMIT");
      break;
    case 3:
      return ("SELL LIMIT");
      break;
    case 4:
      return ("BUY STOP");
      break;
    case 5:
      return ("SELL STOP");
      break;
  }
}


  
  
int DigitsMinLot(string symbol) {
   double ml=MarketInfo(symbol,MODE_MINLOT);
//--- 1/x of lot step
   double Dig=0;
   if(ml!=0)Dig=1.0/ml;
//--- conversion of 1/x to digits
   double res=0;
   if(Dig>1)res=1;
   if(Dig>10)res=2;
   if(Dig>100)res=3;
   if(Dig>1000)res=4;
   return(res);
}


void compare_positions() {
// load real positions and compare them with master ones
  real_positions();
  int x[];
  ArrayResize(x,RealSize);
  if (RealSize>0)ArrayInitialize(x,0);
//  cmt=cmt+nl+"RealSize: "+RealSize;

//Master to Real comparations
  for (int i=0;i<Size;i++) {       // for all master orders
    bool found=false;
    for (int j=0;j<RealSize;j++) { // find the right real order
      if (DoubleToStr(OrdId[i],0)==RealOrdOrig[j]) {
        //compare values
        found=true;
        x[j]=1;

// if not market order, compare open prices - later 
        //compare volumes - TODO later
        //compare open price when delayed order
        if (OrdTyp[i]>1 && OrdPrice[i] != RealOrdPrice[j]) {
          OrderSelect(RealOrdId[j],SELECT_BY_TICKET);
          OrderModify(OrderTicket(),OrdPrice[i],OrderStopLoss(),OrderTakeProfit(),0);
        }
        //compare SL,TP
        if (OrdTP[i]!=RealOrdTP[j] || OrdSL[i]!=RealOrdSL[j]) {
          OrderSelect(RealOrdId[j],SELECT_BY_TICKET);
          OrderModify(OrderTicket(),OrderOpenPrice(),OrdSL[i],OrdTP[i],0);
        }
      }
    }
    if (!found) {
      //no position open with this ID, need to open now
      int result;
      if (OrdTyp[i]<2) {
// ------ market order (check Price and OpenPrice)
        double Price=MarketPrice(i);
 
// PipsTolerance for Price:
        if ((OrdTyp[i]==OP_BUY  && Price<OrdPrice[i]+PipsTolerance*mp*Point ) ||
           (OrdTyp[i]==OP_SELL && Price>OrdPrice[i]-PipsTolerance*mp*Point )) {
  
          result=OrderSend(OrdSym[i],OrdTyp[i],OrdLot[i],Price,5,0,0,DoubleToStr(OrdId[i],0),magic,0);
          if (result>0) OrderModify(result,OrderOpenPrice(),OrdSL[i],OrdTP[i],0);
          else Print ("Open ",OrdSym[i]," failed: ",GetLastError());
        }else Print ("Price out of tolerance ",DoubleToStr(OrdId[i],0),": ",OrdPrice[i],"/",Price);
      }else{
// ------ waiting order:
        if (CopyDelayedTrades) result=OrderSend(OrdSym[i],OrdTyp[i],OrdLot[i],OrdPrice[i],0,OrdSL[i],OrdTP[i],DoubleToStr(OrdId[i],0),magic,0);
      }
    }
  }
  for (j=0;j<RealSize;j++) {
//    cmt=cmt+nl+"checking "+j+" <> "+x[j];
    if (x[j]!=1) { //no master order, close the ticket
//      Price=MarketPrice(RealOrdSym[j],"close");
//      OrderClose(RealOrdId[j],RealOrdLot[j],Price,5,CLR_NONE);
      if (RealOrdTyp[j]<2) {
        Price=MarketPrice(j,"close");
        result=OrderClose(RealOrdId[j],RealOrdLot[j],Price,5,CLR_NONE);
        if (result<1) Print ("Close ",RealOrdId[j]," / ",RealOrdLot[j]," / ",Price," failed: ",GetLastError());
        if (Balance<AccountBalance()) Balance=AccountBalance();
      }else{
        OrderDelete(RealOrdId[j],CLR_NONE);
      }
    }
  }
}  

double MarketPrice(int i ,string typ="open") {
  RefreshRates();
  if (typ=="open") {
    if (OrdTyp[i]==0) {
      Print("Getting Ask open price for buy position...");
      return(NormalizeDouble(MarketInfo(OrdSym[i],MODE_ASK),digits(OrdSym[i])));
    }else{
      Print("Getting Bid open price for sell position...");
      return(NormalizeDouble(MarketInfo(OrdSym[i],MODE_BID),digits(OrdSym[i])));
    }
  }else {
//close:
    if (RealOrdTyp[i]==0) {
      Print("Getting Bid close price for buy position...");
      return(NormalizeDouble(MarketInfo(RealOrdSym[i],MODE_BID),digits(RealOrdSym[i])));
    }else{
      Print("Getting Ask close price for sell position...");
      return(NormalizeDouble(MarketInfo(RealOrdSym[i],MODE_ASK),digits(RealOrdSym[i])));
    }
  }
}

void real_positions() {

  int i=0;
  for(int cnt=0;cnt<OrdersTotal();cnt++) {
    OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
    if (OrderMagicNumber()==magic || ! magic) {
      if (RealSize<i+1)RealResize(i+1);    
      RealOrdId[i]=OrderTicket();
      RealOrdSym[i]=OrderSymbol();
      RealOrdTyp[i]=OrderType();
      RealOrdLot[i]=OrderLots();
      RealOrdPrice[i]=OrderOpenPrice();
      RealOrdSL[i]=OrderStopLoss();
      RealOrdTP[i]=OrderTakeProfit();
      RealOrdOrig[i]=OrderComment();
      i++;
    }
  }
  RealResize(i);
}   

void RealResize(int tmpsize) {

  if (RealSize != tmpsize) {
    RealSize = tmpsize;
    ArrayResize(RealOrdId,RealSize);
    ArrayResize(RealOrdSym,RealSize);
    ArrayResize(RealOrdTyp,RealSize);
    ArrayResize(RealOrdLot,RealSize);
    ArrayResize(RealOrdPrice,RealSize);
    ArrayResize(RealOrdSL,RealSize);
    ArrayResize(RealOrdTP,RealSize);
    ArrayResize(RealOrdOrig,RealSize);
  }

}

// To be used later:
//--- digits on the symbol
int digits(string symbol){return(MarketInfo(symbol,MODE_DIGITS));}
//--- point size
double point(string symbol){return(MarketInfo(symbol,MODE_POINT));}
//--- ask price
double ask(string symbol){return(MarketInfo(symbol,MODE_ASK));}
//--- bid price
double bid(string symbol){return(MarketInfo(symbol,MODE_BID));}
//--- spread
int spred(string symbol){return(MarketInfo(symbol,MODE_SPREAD));}
//--- stop level
int stlevel(string symbol){return(MarketInfo(symbol,MODE_STOPLEVEL));}
//--- max lot
double maxlot(string symbol){return(MarketInfo(symbol,MODE_MAXLOT));}
//--- min lot
double minlot(string symbol){return(MarketInfo(symbol,MODE_MINLOT));}


