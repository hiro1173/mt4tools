//+------------------------------------------------------------------+
//|                                             ViewPositionInfo.mq4 |
//|                                  Copyright (c) 2011, MT4-traripi |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright (c) 2011, MT4-traripi"
#property link      "http://mt4-traripi.seesaa.net"
#property indicator_separate_window
// http://mt4-traripi.seesaa.net/article/181767571.html
// version 2013 0228 1414

// �f�t�H���g�ݒ�
extern int    targetPairCnt = 5;
extern string targetPair1 = "AUDJPY";
extern string targetPair2 = "USDJPY";
extern string targetPair3 = "EURUSD";
extern string targetPair4 = "GBPUSD";
extern string targetPair5 = "AUDUSD";
extern string targetPair6 = "";
extern string targetPair7 = "";
extern string targetPair8 = "";
extern string targetPair9 = "";
extern string targetPair10 = "";
extern color  headerColor = Gainsboro ;
extern color  valueColor  = Gainsboro ;
extern int    TimeFrame  = 1440;
extern int    def.x.offset= 5;    // ������
extern int    def.y.offset= 5;    // �c����
extern color  upColor   = Lime;
extern color  downColor = Red;

string fontName="Courier New Bold";
string jpnFontName="�l�r �S�V�b�N";
string labelNames;
string shortName;
int    labelFontSize = 10;
int    valFontSize   = 10;
int    totalLabels;
int    window;

string targetPair[];
double lastBid[];
color  lastColor[];

// JPN�̎��̏c�����I�t�Z�b�g��
int    y_jpan.offset= -20;


// --------------------------------------------------------
// Change font color
// --------------------------------------------------------
color getColor( double a, double b){
	color rColor ;
	if ( a > b ) {
		rColor = upColor ;
	} else if (a == b ){
		rColor = valueColor;
	} else {
		rColor = downColor ;
	}
	return ( rColor );
}


// --------------------------------------------------------
// Custom indicator initialization function
// --------------------------------------------------------
int init(){

	if(def.y.offset<10) def.y.offset=10;
	if(def.y.offset>20) def.y.offset=20;
	if(def.x.offset<0) def.x.offset=0;

	// ���O
	shortName = "ViewPositionInfo2";
	labelNames = shortName;
	IndicatorShortName(shortName);

	ArrayResize(targetPair,targetPairCnt);
	ArrayResize(lastBid,targetPairCnt);
	ArrayInitialize(lastBid,0);
	ArrayResize(lastColor,targetPairCnt);
	ArrayInitialize(lastColor,headerColor);

	string symbolSuffix = StringSubstr(Symbol(),6);

	targetPair[0] = StringConcatenate(StringSubstr(targetPair1, 0, 6), symbolSuffix);
	targetPair[1] = StringConcatenate(StringSubstr(targetPair2, 0, 6), symbolSuffix);
	targetPair[2] = StringConcatenate(StringSubstr(targetPair3, 0, 6), symbolSuffix);
	targetPair[3] = StringConcatenate(StringSubstr(targetPair4, 0, 6), symbolSuffix);
	targetPair[4] = StringConcatenate(StringSubstr(targetPair5, 0, 6), symbolSuffix);
	targetPair[5] = StringConcatenate(StringSubstr(targetPair6, 0, 6), symbolSuffix);
	targetPair[6] = StringConcatenate(StringSubstr(targetPair7, 0, 6), symbolSuffix);
	targetPair[7] = StringConcatenate(StringSubstr(targetPair8, 0, 6), symbolSuffix);
	targetPair[8] = StringConcatenate(StringSubstr(targetPair9, 0, 6), symbolSuffix);
	targetPair[9] = StringConcatenate(StringSubstr(targetPair10, 0, 6), symbolSuffix);

	return(0);
}

// �ĕ`��
int deinit() { 
	deleteAllObject();
	return(0);
}

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  

int start() {

	window = WindowFind(shortName);	
	deleteAllObject();

	int x_pos = def.x.offset ;      // ������
	int y_pos = def.y.offset + 50;  // �c����
	int hline_pos = 60;

	if(AccountCurrency() == "JPY"){
		y_pos     = y_pos + y_jpan.offset;  // �c����
		hline_pos = hline_pos+ y_jpan.offset;
	}

	setHLine(next(),   5, hline_pos);
	setHLine(next(), 305, hline_pos);

	setObject(next(), "�ʉ݃y�A", x_pos, y_pos, labelFontSize, jpnFontName, headerColor);
	x_pos += 100;
	setObject(next(), "���ݒl"  , x_pos, y_pos, labelFontSize, jpnFontName, headerColor);
	x_pos += 75;
	setObject(next(), "��������", x_pos, y_pos, labelFontSize, jpnFontName, headerColor);
	x_pos += 85;
	setObject(next(), "���ό��l", x_pos, y_pos, labelFontSize, jpnFontName, headerColor);
	x_pos += 85;
	setObject(next(), "�]�����v", x_pos, y_pos, labelFontSize, jpnFontName, headerColor);
	x_pos += 80;
	setObject(next(), "���萔��", x_pos, y_pos, labelFontSize, jpnFontName, headerColor);
	x_pos += 76;
	setObject(next(), "���ό��l", x_pos, y_pos, labelFontSize, jpnFontName, headerColor);
	x_pos += 90;
	setObject(next(), "�]�����v", x_pos, y_pos, labelFontSize, jpnFontName, headerColor);
	x_pos += 90;
	setObject(next(), "���v���v", x_pos, y_pos, labelFontSize, jpnFontName, headerColor);

	//�g�[�^��(JPY)
	if(AccountCurrency() != "JPY"){
		x_pos += 90;
		setObject(next(), "���v(�~)",x_pos, y_pos, labelFontSize, jpnFontName, headerColor);  
		setHLine(next(), 390, hline_pos);
	}

	for(int i=0;i<targetPairCnt;i++){
		printPair(i, 25*(i + 1));
	}
	// �������̕\��
	printAccountInfo(25*(targetPairCnt + 1));

	return(0);
}
  
// --------------------------------------------------------
// printPair
// �ʉ݃y�A���Ƃ̕\��
// --------------------------------------------------------
void printPair(int targetIndex,int y_offset){

	string pairName = targetPair[targetIndex];
	double buyLot, buyPrice, buyProfit, buySwap;
	double sellLot, sellPrice, sellProfit, sellSwap;

	int digits = MarketInfo(pairName,MODE_DIGITS);
	if ( digits==2 || digits==3 ) digits=3;
	if ( digits==4 || digits==5 ) digits=5;

	for(int i=0; i < OrdersTotal(); i++) { 
		OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
		if(OrderSymbol() == pairName) {
				int orderType = OrderType();
				if(orderType == OP_BUY){
					buyLot += OrderLots();
					buyPrice += OrderOpenPrice()*OrderLots();
					buyProfit += OrderProfit();
					buySwap += OrderSwap();
				} else if(orderType == OP_SELL){
					sellLot += OrderLots();
					sellPrice += OrderOpenPrice()*OrderLots();
					sellProfit += OrderProfit();
					sellSwap += OrderSwap();
				}
		}
	}
	
	double avgBuyPrice;
	if(buyLot > 0){
		avgBuyPrice = buyPrice/buyLot;
	} else {
		avgBuyPrice = 0;
	}

	double avgSellPrice;
	if(sellLot > 0){
		avgSellPrice = sellPrice/sellLot;
	} else {
		avgSellPrice = 0;
	}

	int currencyDigit = 0;
	if(AccountCurrency() == "JPY") {
		currencyDigit = 0;
	} else {
		currencyDigit = 2;
	}
	double buyTotalProfit = buyProfit + buySwap;
	double sellTotalProfit = sellProfit + sellSwap;
	double totalProfit = buyTotalProfit + sellTotalProfit;
	
	int x_pos = def.x.offset ;                 // ������
	int y_pos = def.y.offset + 45 + y_offset;  //�c����

	int vline_x_pos =  -15 + def.x.offset;
	int vline_y_pos = 35 + y_offset;
	int hline_pos   = 55 + y_offset;

	if(AccountCurrency() == "JPY"){
		vline_y_pos = vline_y_pos + y_jpan.offset  ;
		hline_pos   = hline_pos + y_jpan.offset;
    	y_pos = y_pos + y_jpan.offset;  //�c����
	}

	//�ʉ݃y�A
	setObject(next(), StringSubstr(pairName, 0, 6), x_pos, y_pos, valFontSize, fontName, valueColor);
	//���[�g�iBid - Ask�j
	double bidRate = NormalizeDouble(MarketInfo(pairName,MODE_BID),MarketInfo(pairName,MODE_DIGITS));
	string bidStr  = formatNumber(bidRate,MarketInfo(pairName,MODE_DIGITS),7);
	string askStr  = formatNumber(MarketInfo(pairName,MODE_ASK),MarketInfo(pairName,MODE_DIGITS),7);
	int askStrLen  = StringLen(askStr);

	color rateColor = getColor(bidRate,lastBid[targetIndex]);
	if(lastBid[targetIndex] == bidRate){
		rateColor = lastColor[targetIndex];
	}

	lastBid[targetIndex] = bidRate;
	lastColor[targetIndex] = rateColor;

	string rateStr = bidStr + "-" + StringSubstr(askStr,askStrLen-2-MathMod(digits,2));
	x_pos += 70;
	setObject(next(), rateStr , x_pos, y_pos , valFontSize, fontName, rateColor);  

	//��������
	x_pos += 115;
	if (buyLot > 0) {
		setObject(next(), formatNumber(buyLot , 2, 5) , x_pos, y_pos , valFontSize, fontName, headerColor);  
	} else {
		setObject(next(), "----", x_pos+10, y_pos, valFontSize, fontName, headerColor);
	}

	//�������ό��l
	x_pos += 70;
	if(avgBuyPrice > 0) {
	setObject(next(), formatNumber(avgBuyPrice ,digits, 7), x_pos, y_pos , valFontSize, fontName, headerColor);
	} else {
		setObject(next(), "----", x_pos+10, y_pos, valFontSize, fontName, headerColor);
	}

	//�����]�����v
	x_pos += 60;
	setObject(next(), moneyToString(buyTotalProfit ,currencyDigit, 7), x_pos, y_pos, valFontSize, fontName, getColor(buyTotalProfit,0));

	//���萔��
	x_pos += 115;
	if (sellLot > 0) {
		setObject(next(), formatNumber(sellLot ,2, 5), x_pos, y_pos, valFontSize, fontName, headerColor);
	} else {
		setObject(next(), "----", x_pos+10, y_pos, valFontSize, fontName, headerColor);
	}
	
	//���蕽�ό��l
	x_pos += 70;
	if(avgSellPrice > 0) {
		setObject(next(), formatNumber(avgSellPrice ,digits, 7), x_pos, y_pos, valFontSize, fontName, headerColor);
	} else {
		setObject(next(), "----", x_pos+10, y_pos, valFontSize, fontName, headerColor);	}

	//����]�����v
	x_pos += 60;
	setObject(next(), moneyToString(sellTotalProfit ,currencyDigit, 7), x_pos, y_pos , valFontSize, fontName,getColor(sellTotalProfit,0));

	//���v���v
	x_pos += 90;
	setObject(next(), moneyToString(totalProfit ,currencyDigit, 7), x_pos, y_pos , valFontSize, fontName,getColor(totalProfit,0));

	// ����
	setHLine(next(), 5, hline_pos);
	setHLine(next(), 305, hline_pos);

	//�g�[�^��(JPY)
	if(AccountCurrency() != "JPY"){
		string toJpnSymbol = AccountCurrency() + "JPY" + StringSubstr(pairName,6);
		double jpnTick	=MarketInfo(toJpnSymbol,MODE_BID);
		x_pos += 90;
		setObject(next(), moneyToString(totalProfit*jpnTick ,0,7), x_pos, y_pos , valFontSize, fontName,getColor(totalProfit,0));
      setHLine(next(), 390, hline_pos);
	}


}

// --------------------------------------------------------
// moneyToString �ʉ݌`���̕\��
// --------------------------------------------------------
string moneyToString(double val, int digits, int length) {

	// ������̏�����
	string money_str_0 = "";
	string money_str_1 = "";
	string money_str_2 = "";
	string money_str_3 = "";

	// ���l�̏�����
	int money_val_0 = 0;
	int money_val_1 = 0;
	int money_val_2 = 0;
	int money_val_3 = 0;

	// ��Βl�ɕϊ�
	int abs_val = MathAbs(val);

	// ������ϊ�
	// �l�̌ܓ�����
	int val_1 = MathRound(abs_val);

	int strlen = 0;

	//----------------------------------------------------------
	// money_str_0 1000�ȉ��̐��l�𕶎���ɂ���
	//----------------------------------------------------------
	money_val_0 = MathMod(abs_val ,1000);
	money_str_0 = money_val_0;
	//�������̃J�E���g
	strlen = StringLen(money_str_0);
	if (abs_val >= 1000) {
		// �\���ʒu�𑵂���
		for( int j=3; j>strlen; j--){
			money_str_0 = StringConcatenate("0",money_str_0);
		}
	}

	//----------------------------------------------------------
	// 1,000�̈�
	//----------------------------------------------------------
	money_val_1 = abs_val /1000;
	if (abs_val >= 1000) {
		money_val_1 = MathMod(money_val_1 ,1000);
		if (money_val_1 == 0) {
			money_str_1 = "000";
		} else {
		    if (money_val_1 >= 1000) {
		    }
			money_str_1 = money_val_1;
		}
		//�������̃J�E���g
		strlen = StringLen(money_str_1);
		if (abs_val >= 1000000) {
			// �\���ʒu�𑵂���
			for( int j2=3; j2>strlen; j2--){
				money_str_1 = StringConcatenate("0",money_str_1);
			}
		}
		money_str_1 =  money_str_1+",";
	}
	//----------------------------------------------------------
	// 1,000,000�̈�
	//----------------------------------------------------------
	money_val_2 = abs_val /1000000;
	if (abs_val >= 1000000) {
		money_val_2 = MathMod(money_val_2 ,1000);
		if (money_val_2 == 0) {
			money_str_2 = "000";
		} else {
			money_str_2 = money_val_2;
		}
		money_str_2 =   money_str_2+",";
	}

	// ��������쐬
	string money_str = money_str_3 + money_str_2 + money_str_1 +  money_str_0;

	// �}�C�i�X��\������
	if(val < 0){
		money_str = "-" + money_str ;
	} 


	//----------------------------------------------------------
	// �\���ׂ̈ɋ󔒂̕�����Ŗ��߂�
	//----------------------------------------------------------
	int money_strlen = StringLen(money_str);
	for( int j3=11; j3>money_strlen; j3--){
		money_str = StringConcatenate(" ",money_str);
	}

	return(money_str);
}

// --------------------------------------------------------
// printPair
// --------------------------------------------------------
string formatNumber(double val, int digits, int length) {

	string str = DoubleToStr(val ,digits);
	int strlen = StringLen(str);
	for( int j=length; j>strlen; j--){
		str = StringConcatenate(" ",str);
	}
	return(str);
}

// --------------------------------------------------------
// printAccountInfo
// �����̏�
// --------------------------------------------------------
   void printAccountInfo(int y_offset){
	int x_pos = def.x.offset + 155 ;      // ��������ʒu
	int y_pos = def.y.offset -12;         // �c������ʒu
	int val_x_pos = def.x.offset + 135;   // ���l�\��������
	int val_y_pos = def.y.offset + 2;     // ���l�\ 

	int vline_x_pos1 = -10;
	int vline_x_pos2 =  70;
	int vline_x_pos3 = 175;

	string toJpnSymbol = AccountCurrency() + "JPY" + StringSubstr(Symbol(),6);
	double jpnTick = MarketInfo(toJpnSymbol,MODE_BID);

	// --------------------------------------------------------
	//�؋���
	// --------------------------------------------------------
	setObject(next(), "�؋����c��", x_pos, y_pos, valFontSize, jpnFontName, valueColor);
	setObject(next(), moneyToString(AccountBalance(), 0, 8), val_x_pos, val_y_pos, valFontSize, fontName, valueColor);
	if(AccountCurrency() != "JPY"){
		setObject(next(), "�~���Z", val_x_pos-35 , val_y_pos+15, valFontSize, jpnFontName, valueColor);
		setObject(next(), moneyToString(AccountBalance()*jpnTick, 0, 8), val_x_pos, val_y_pos+15, valFontSize, fontName, valueColor);
		setHLine(next(), val_x_pos-40, y_pos+30);
		setHLine(next(), val_x_pos+130, y_pos+30);
	}

	// --------------------------------------------------------
	//�L���؋���
	// --------------------------------------------------------
	x_pos     += 100;    // ����
	val_x_pos += 100;    // ���l
	setObject(next(), "�L���؋���", x_pos, y_pos, valFontSize, jpnFontName, valueColor);
	setObject(next(), moneyToString(AccountEquity(), 0, 8), val_x_pos, val_y_pos, valFontSize, fontName, valueColor);
	if(AccountCurrency() != "JPY"){
		setObject(next(), moneyToString(AccountEquity()*jpnTick, 0, 8), val_x_pos, val_y_pos+15, valFontSize, fontName, valueColor);
	}

	// --------------------------------------------------------
	//�K�v�؋���
	// --------------------------------------------------------
	x_pos     += 100;    // ����
	val_x_pos += 100;    // ���l
	setObject(next(), "�K�v�؋���", x_pos, y_pos, valFontSize, jpnFontName, valueColor);
	setObject(next(), moneyToString(AccountMargin(), 0, 8), val_x_pos, val_y_pos, valFontSize, fontName, valueColor);
	if(AccountCurrency() != "JPY"){
		setObject(next(), moneyToString(AccountMargin()*jpnTick, 0, 8), val_x_pos, val_y_pos+15, valFontSize, fontName, valueColor);
	}

	// --------------------------------------------------------
	//�]��؋���
	// --------------------------------------------------------
	x_pos     += 100;    // ����
	val_x_pos += 100;    // ���l
	setObject(next(), "�]��؋���", x_pos, y_pos, valFontSize, jpnFontName, valueColor);
	setObject(next(), moneyToString(AccountFreeMargin(), 0, 8), val_x_pos, val_y_pos, valFontSize, fontName, valueColor);
	if(AccountCurrency() != "JPY"){
		setObject(next(), moneyToString(AccountFreeMargin()*jpnTick, 0, 8), val_x_pos, val_y_pos+15, valFontSize, fontName, valueColor);
	}

	// --------------------------------------------------------
	//�ێ���
	// --------------------------------------------------------
	x_pos     += 95;    // ����
	val_x_pos += 105;    // ���l
	setObject(next(), "  �ێ���", x_pos, y_pos, valFontSize, jpnFontName, valueColor);
	if(AccountMargin() != 0){
		setObject(next(), formatNumber(AccountEquity()/AccountMargin()*100, 2, 7)+"%", val_x_pos, val_y_pos, valFontSize, fontName, valueColor);
	}


	// --------------------------------------------------------
	//�]�����v
	// --------------------------------------------------------
	x_pos += 100;
	val_x_pos += 80;
	setObject(next(), "�]�����v", x_pos, y_pos, valFontSize, jpnFontName, valueColor);
	setObject(next(), moneyToString(AccountProfit(), 0, 8), val_x_pos, val_y_pos , valFontSize, fontName, getColor(AccountProfit(),0));
	// �~���Z�\��
	if(AccountCurrency() != "JPY"){
		setObject(next(), moneyToString(AccountProfit()*jpnTick, 0, 8), val_x_pos, val_y_pos+15, valFontSize, fontName, getColor(AccountProfit(),0));
	}
}

// --------------------------------------------------------
// deleteAllObject
// --------------------------------------------------------
void deleteAllObject(){
	while (totalLabels>0) { 
		ObjectDelete(StringConcatenate(labelNames,totalLabels));
		totalLabels--;
	}
}  


// --------------------------------------------------------
// next
// --------------------------------------------------------
string next() { 
	totalLabels++;
	return(totalLabels);
}  


// --------------------------------------------------------
// setHLine
// --------------------------------------------------------
void setHLine(string name,int x,int y,color theColor = DimGray){
	string hlineText = "__________________________________________________";
	setObject(name, hlineText, x, y, 11, fontName, theColor);
}

// --------------------------------------------------------
// setObject
// --------------------------------------------------------
void setObject(string name,string text,int x,int y,int size=10, string font = "Arial",color theColor = Gainsboro,int angle=0){
	string labelName = StringConcatenate(labelNames,name);
	x = x + def.x.offset;
	y = y + def.y.offset;
		if (ObjectFind(labelName) == -1) {
		ObjectCreate(labelName,OBJ_LABEL,window,0,0);
		ObjectSet(labelName,OBJPROP_CORNER,0);
		if (angle != 0){
				ObjectSet(labelName,OBJPROP_ANGLE,angle);
		}
	}
	ObjectSet(labelName,OBJPROP_XDISTANCE,x);
	ObjectSet(labelName,OBJPROP_YDISTANCE,y);
	ObjectSetText(labelName,text,size,font,theColor);
	return(0);
}