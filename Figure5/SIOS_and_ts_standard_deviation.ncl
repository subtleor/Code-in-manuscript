;;text2 teachs how to print ascii data 
;;how to put more line in a picture
;;how to add label of different line in the picture


begin
filedir="/mnt/e/westsouth/yunnan/essay1/"
filedir1="./"
filename="EIP_SMI_MAM.txt"
varname1=" EIP_SMI_MAM"

filename2="output1.txt"
varname2="TS1"

lv_name="nino34_MAM.txt"
ts_ys			= 1980			;ts start year 
ts_ye			= 2020			;ts end year 

dtrend_flag = 1
ymstar		= 198001
ymend			= 202012
lv_flag    = 0

fre_init	= asciiread(filedir+filename,ts_ye-ts_ys+1,"float")
Ts_init	= asciiread(filedir+filename2,ts_ye-ts_ys+1,"float")
EIP_MAM	= asciiread(filedir+lv_name,ts_ye-ts_ys+1,"float")
Ts_init!0	= "year"
Ts_init&year	= ispan(ts_ys,ts_ye,1)
fre_init!0	= "year"
fre_init&year	= ispan(ts_ys,ts_ye,1)
EIP_MAM!0	= "year"
EIP_MAM&year	= ispan(ts_ys,ts_ye,1)

yrs01=ispan(ts_ys,ts_ye,1)

Ts		= Ts_init({year|ymstar/100:ymend/100})
Ts=(/Ts*-1/)
fre   	= fre_init({year|ymstar/100:ymend/100})
EIP_MAM	= EIP_MAM({year|ymstar/100:ymend/100})

nyear				= dimsizes(Ts&year)
  ;detrend or not
  if dtrend_flag .eq. 0 
   
     Ts					= Ts
	 Ts@detrend			= dtrend_flag +"--(0 for raw data, else for detrended data)"  
	 
	 fre			= fre
    fre@detrend	= dtrend_flag +"--(0 for raw data, else for detrended data)" 
  
  else
     				
     Ts					= (/dtrend_msg_n(ispan(1,nyear,1),Ts,False,True,0)/) 
     ;Ts         =(/dtrend_msg_n(EIP_MAM,Ts,False,True,0)/) 
	 Ts@detrend			= dtrend_flag +"--(0 for raw data, else for detrended data)" 

     fre            = (/dtrend_msg_n(ispan(1,nyear,1),fre,False,True,0)/)
    ;fre         =(/dtrend_msg_n(EIP_MAM,fre,False,True,0)/) 
     fre@detrend    = dtrend_flag +"--(0 for raw data, else for detrended data)"

  end if
     if lv_flag .eq. 1
          Ts         =(/dtrend_msg_n(EIP_MAM,Ts,False,True,0)/) 
          fre         =(/dtrend_msg_n(EIP_MAM,fre,False,True,0)/)
      end if

  printVarSummary(Ts)

fre		= dim_standardize_n_Wrap(fre,0,0)
Ts		= dim_standardize_n_Wrap(Ts,0,0)

print(fre)

;;NAO和AO一起丢进去然后画
indx=new((/2,41/),"float")
indx(0,:) = fre
indx(1,:) = Ts
corr=esccr(fre,Ts,0);相关性计算
prob=  rtest(corr, 41, 0)
print(prob)
print(corr)

;;;绘图
plottype  = "pdf"                 ;type of plotting
plotdir = "./"
plotname   = varname1+" and "+varname2+"_standard deviation"
wks        = gsn_open_wks(plottype,plotdir+plotname)
;-----------------------------------------------------------------------------------------
tres=True
tres@gsnDraw=False;;这个两个false即让图先不出，避免后面有两个图
tres@gsnFrame=False
tres@trXMinF=1980
tres@trXMaxF=2020
tres@trYMinF=-3
tres@trYMaxF=3
tres@gsnYRefLine=0;标准线

tres@xyMarkLineModes=(/"MarkLines","MarkLines"/)
tres@xyMarkerSizeF=(/0.008,0.008/)
tres@xyMarker=(/16,16/)
tres@xyLineColors=(/"Red","Blue"/);color chosen，后面有s是因为两条线，三条线同理，单条不需要复数
tres@xyLineThicknesses=(/3.,3./)
tres@xyDashPatterns=(/0.,0./)
;;--------------------------------------

  ;;;----------------------------------------------------
font_height   = 0.020			;font size
tres@tmYLLabelFontHeightF	= 1.2*font_height
tres@tmXBLabelFontHeightF	= 1.2*font_height
tres@tiXAxisFontHeightF	= 1.2 * font_height
tres@tiYAxisFontHeightF    	= 1.2 * font_height
tres@tiMainFontHeightF     	= 1.6 * font_height
tres@gsnLeftStringFontHeightF  = 1.2*font_height
tres@gsnRightStringFontHeightF = 1.2*font_height

tres@tmXBMajorLengthF		= 0.006
tres@tmXBMajorOutwardLengthF	= 0.006
tres@tmXBLabelDeltaF		= -0.8
tres@tmYLMajorLengthF		= 0.006
tres@tmYLMajorOutwardLengthF	= 0.006
tres@tmYLLabelDeltaF		= -0.8
;;-------------------------------------------------------
tres@tmXBValues		= ispan(ymstar/100,ymend/100,5)
tres@tmXBLabels		= ispan(ymstar/100,ymend/100,5)
tres@xyMarkLineMode="MarkLines"
;tres@xyMarker=(/1,1/)
tres@xyMarkerColors=(/"Red","Blue"/)
;tres@xyMarkerSizeF=(/0.015,0.015/)
;tres@tiXAxisFontHeightF=0.02;坐标轴字体大小
;tres@tiYAxisFontHeightF=0.02
;tres@gsnXYBarChart=True;折线改柱状
tres@gsnLeftString   = "(b)"
tres@gsnRightString   = ""
tres@gsnCenterString   = "Corr. = "+sprintf("%5.2f",corr)+" (p < 0.01)"
;图的宽度和高度:"
tres@vpWidthF	= 0.7 ;Plot area
tres@vpHeightF	= 0.35
tres@vpYF	= 0.7
tres@vpXF	= 0.12
;   tres@xyMarkrSizes         = (/0.005,0.005/)
tres@tmXBMinorOn		= False
tres@tmYLMinorOn		= False
tres@tmYROn			= False
tres@tmXTOn			= False
tres@gsnLeftStringOrthogonalPosF    = -0.01
tres@gsnRightStringOrthogonalPosF    = -0.01
tres@gsnCenterStringOrthogonalPosF    = -0.01
plot = gsn_csm_xy(wks,yrs01,indx,tres) ; 


;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\加标签，就是左上角啥线啥颜色那个，就是add_polyline，各线颜色加标注。gsn_add_polyline and text
res_text	= True	

res_text@txFontHeightF	=0.022
res_text@txJust	="CenterLeft"	

res_lines	=True	
res_lines@gsLineDashPattern =0.
res_lines@gsLineThicknessF	=7.	
res_lines@gsLineColor	="red"	

;XXYY即在图中位置
xx =(/1993,1996/)
yy =(/2.7,2.7/)
dum1 = gsn_add_polyline(wks,plot,xx,yy,res_lines)
dum2 = gsn_add_text(wks,plot,varname1,1980.5,2.7,res_text)

yy =(/2.2,2.2/)
res_lines@gsLineColor	="blue"	
res_lines@gsLineDashPattern=0.
res_lines@xyMarker=16
dum3 = gsn_add_polyline(wks,plot,xx,yy,res_lines)
dum4 = gsn_add_text(wks,plot,varname2,1988,2.2,res_text) 


xx =(/1980,2020/)
yy =(/1,1/)
res_lines@gsLineColor	="black"
res_lines@gsLineThicknessF	=1.	
res_lines@xyMarker=16
dum5 = gsn_add_polyline(wks,plot,xx,yy,res_lines)
xx =(/1980,2020/)
yy =(/-1,-1/)
res_lines@gsLineColor	="black"
res_lines@gsLineThicknessF	=1.	
dum6 = gsn_add_polyline(wks,plot,xx,yy,res_lines)
draw(plot)
frame(wks)

end