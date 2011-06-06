#pragma once

class Filter {
public:
	float Zl[4];	
	float Nl[4];
	float Dl[4];
	
	
	void setDl(float a, float b, float c, float d){
		Dl[0] = a;
		Dl[1] = b;
		Dl[2] = c;
		Dl[3] = d;
	}
	
	void setNl(float a, float b, float c, float d){
		Nl[0] = a;
		Nl[1] = b;
		Nl[2] = c;
		Nl[3] = d;
	}
	
	
	Filter(){
		Zl[0] = 0.0;
		Zl[1] = 0.0;
		Zl[2] = 0.0;
		Zl[3] = 0.0;
		
		setNl(9.413137469932821686e-04, 2.823941240979846506e-03, 2.823941240979846506e-03, 9.413137469932821686e-04);
		setDl(1, -2.5818614306773719263, 2.2466666427559748864, -.65727470210265670262);

	}
	
	void setStartValue(float s){
		for(int i=0;i<400;i++){
			filter(s);
		}
	}
	
	float filter(float s){
		Zl[3]=Zl[2];
		Zl[2]=Zl[1];
		Zl[1]=Zl[0];
		
		Zl[0]= s - (Dl[1]*Zl[1] + Dl[2]*Zl[2] + Dl[3]*Zl[3]);
		return Zl[0]*Nl[0] + Zl[1]*Nl[1] + Zl[2]*Nl[2] + Zl[3]*Nl[3];
		
	}
	
};