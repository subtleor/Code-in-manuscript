load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "/mnt/e/mytool.ncl"
begin
;**********************************************************************
;A script calculating Correlation or Regresssion coefficients for several month averaged 3-Dimension  scalar field

;Plot the a prescribed statistic by cor_reg_flag( User should adjust the cnLevels and cnFillColors accroding to different statistics) 
;**********************************************************************
;user can select:

;				 1��Correlation or Regression

;				 2��detrend or not for each month

;                3��lead or lag time 

;                4��different plot for significant level
;**********************************************************************
  ;Options for user
  index=  "EIP_swvl";nino34_DJF;TS
  if index .eq. "NIOS_JJA" then
  ts_dat		= "ERA5"
  ts_name		= "SST"
  ts_filedir	="/mnt/e/westsouth/data/"
  ts_filename	= "NIOS_JJA.txt"
  end if 
  if index .eq. "EIP_swvl"then
  ts_dat		= "ERA5"
  ts_name		= "EIP_SMI"
  ts_filedir	="/mnt/e/westsouth/data/"
  ts_filename	= "EIP_SMI_MAM.txt"
  end if
  if index .eq. "TS" then
  ts_dat		= "EEOF"
  ts_name		= "TS1"
  ts_filedir	="/mnt/e/westsouth/data/"
  ts_filename	= "output1.txt"
  end if
  if index .eq. "ICP_swvl" then
  ts_dat		= "ERA5"
  ts_name		= "ICP_SMI"
  ts_filedir	="/mnt/e/westsouth/data/"
  ts_filename	= "ICP_swvl1_MAM.txt"
  end if 
  ts_ys			= 1980			;ts start year 
  ts_ye			= 2020 		;ts end year 
  
  zhenduan_dat		= "MSE"
  zhenduan_filedir	="/mnt/e/westsouth/yunnan/zhenduan/MSE/"
  zhenduan_filename1	= "ERA5.MSE.advh1_int1.Jan-Dec.1980-2020.nc"
  zhenduan_filename2  = "ERA5.MSE.advh2_int1.Jan-Dec.1980-2020.nc"
  zhenduan_filename3  = "ERA5.MSE.advh3_int1.Jan-Dec.1980-2020.nc"
  zhenduan_filename4  = "ERA5.MSE.advh4_int1.Jan-Dec.1980-2020.nc"
  zhenduan_filename5  = "ERA5.MSE.NL_int.Jan-Dec.1980-2020.nc"
  zhenduan_filename6  = "Fnet.nc"
  varname1="advh1_int1"
  varname2="advh2_int1"
  varname3="advh3_int1"
  varname4="advh4_int1"
  varname5="NL_int"
  varname6="fnet"

  zhenduan_ys			= 1980			;ts start year 
  zhenduan_ye			= 2020  		;ts end year 
    
  ymstar		= 198001
  ymend			= 202012
  
  
  dtrend_flag	= 1		; 0 for raw,else for detrend
  season="MAM(0)"
  xitong="ICP";"WNPAC";yn
  setup_name  = "MSE"
if xitong .eq. "BOBAC" then
latmin	=  17
latmax	=  22
lonmin	=  84
lonmax	=  89
end if

if xitong .eq. "WNPAC" then
latmin	=  1;18
latmax	=  14;23
lonmin	=  125;115
lonmax	=  160;120
end if

if xitong .eq. "yn" then  
latmin	=  21
latmax	=  30
lonmin	=  97
lonmax	=  106
end if
if xitong .eq. "ICP" then  
latmin	=  10
latmax	=  25
lonmin	=  95
lonmax	=  106
end if
if xitong .eq. "EIP" then
latmin	=  28
latmax	=  33
lonmin	=  60
lonmax	=  70
end if


  if season .eq. "DJF(-1)"
    monmin	=-12;starting month for averaging,(monmin != 0,-12 <= monmin <= monmax <=12). negative value for previou year(year(-1)) 
    monmax	=2;ending month for averaging,	   1<= monmax <= 12 
  end if
  if season .eq. "MAM(0)"
    monmin	=3;starting month for averaging,(monmin != 0,-12 <= monmin <= monmax <=12). negative value for previou year(year(-1)) 
    monmax	=5;ending month for averaging,	   1<= monmax <= 12 
  end if
  if season .eq. "JJA(0)"
    monmin	=6;starting month for averaging,(monmin != 0,-12 <= monmin <= monmax <=12). negative value for previou year(year(-1)) 
    monmax	=8;ending month for averaging,	   1<= monmax <= 12 
  end if

  months	= (/"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"/)
 
  ;options for output  
  plottype	= "pdf"                 ;type of plotting
  plotdir	= "./"


  savedir	= "./"
;**********************************************************************
;Handle variable
;**********************************************************************
  ;read time series
  Ts_init		= asciiread(ts_filedir+ts_filename,ts_ye-ts_ys+1,"float")
  Ts_init!0		= "year"
  Ts_init&year	= ispan(ts_ys,ts_ye,1)
  printVarSummary(Ts_init)
  print(Ts_init)
  if index .eq. "TS" then
  Ts			= -1*Ts_init({year|ymstar/100:ymend/100})
  end if
  if index .eq. "ICP_swvl" then
  Ts			= -1*Ts_init({year|ymstar/100:ymend/100})
  end if
  if index .eq. "EIP_swvl" then
  Ts			= Ts_init({year|ymstar/100:ymend/100})
  end if


  print(Ts)

  ;read variable 
  f1			= addfile(zhenduan_filedir+zhenduan_filename1,"r")
  
  var1		= short2flt(f1->$varname1$({ts_ys:ts_ye},{monmin:monmax},{latmin:latmax},{lonmin:lonmax}))
   ;var=(/var/9.8/)
  var1!0		= "year"
  var1!1		= "month"
  var1!2		= "lat"
  var1!3		= "lon"
  printVarSummary(var1)

  f2			= addfile(zhenduan_filedir+zhenduan_filename2,"r")
  var2		= short2flt(f2->$varname2$({ts_ys:ts_ye},{monmin:monmax},{latmin:latmax},{lonmin:lonmax}))
  var2!0		= "year"
  var2!1		= "month"
  var2!2		= "lat"
  var2!3		= "lon"
  printVarSummary(var2)

  f3			= addfile(zhenduan_filedir+zhenduan_filename3,"r")
  var3		= short2flt(f3->$varname3$({ts_ys:ts_ye},{monmin:monmax},{latmin:latmax},{lonmin:lonmax}))
  var3!0		= "year"
  var3!1		= "month"
  var3!2		= "lat"
  var3!3		= "lon"
  printVarSummary(var3)

  f4			= addfile(zhenduan_filedir+zhenduan_filename4,"r")
  var4		= short2flt(f4->$varname4$({ts_ys:ts_ye},{monmin:monmax},{latmin:latmax},{lonmin:lonmax}))
  var4!0		= "year"
  var4!1		= "month"
  var4!2		= "lat"
  var4!3		= "lon"
  printVarSummary(var4)

  f5			= addfile(zhenduan_filedir+zhenduan_filename5,"r")
  var5		= short2flt(f5->$varname5$({ts_ys:ts_ye},{monmin:monmax},{latmin:latmax},{lonmin:lonmax}))
  var5!0		= "year"
  var5!1		= "month"
  var5!2		= "lat"
  var5!3		= "lon"
  printVarSummary(var5)

  f6      = addfile(zhenduan_filedir+zhenduan_filename6,"r")
  tim		= f6->time
  u_time_DATE	= cd_calendar(tim,-1)
  tstar		= ind(u_time_DATE .eq. ymstar)
  tlast		= ind(u_time_DATE .eq. ymend)
  var6    = short2flt(f6->$varname6$(tstar:tlast,{latmin:latmax},{lonmin:lonmax}))
  var6!0  = "time"
  var6!1  = "lat"
  var6!2  = "lon"
  printVarSummary(var6)

  var6_monave		= month_to_monave(var6,monmin,monmax)

  nyear				= dimsizes(var5&year)
  
 print(nyear)
 
  ;detrend or not
  if dtrend_flag .eq. 0 
   
     Ts					= Ts
	 Ts@detrend			= dtrend_flag +"--(0 for raw data, else for detrended data)"  
	 
	   var1			= var1
    var1@detrend	= dtrend_flag +"--(0 for raw data, else for detrended data)" 

    var2			= var2
    var2@detrend	= dtrend_flag +"--(0 for raw data, else for detrended data)"

    var3			= var3
    var3@detrend	= dtrend_flag +"--(0 for raw data, else for detrended data)"

    var4			= var4
    var4@detrend	= dtrend_flag +"--(0 for raw data, else for detrended data)"

    var5			= var5
    var5@detrend	= dtrend_flag +"--(0 for raw data, else for detrended data)"

    var6_monave          = var6_monave
    var6_monave@detrend  = dtrend_flag +"--(0 for raw data, else for detrended data)"
  else
     				
     Ts					= (/dtrend_msg_n(ispan(1,nyear,1),Ts,False,True,0)/) 
	 Ts@detrend			= dtrend_flag +"--(0 for raw data, else for detrended data)" 

     var1           = (/dtrend_msg_n(ispan(1,nyear,1),var1,False,True,0)/)
     var1@detrend    = dtrend_flag +"--(0 for raw data, else for detrended data)"
  
      var2           = (/dtrend_msg_n(ispan(1,nyear,1),var2,False,True,0)/)
      var2@detrend    = dtrend_flag +"--(0 for raw data, else for detrended data)"

      var3           = (/dtrend_msg_n(ispan(1,nyear,1),var3,False,True,0)/)
      var3@detrend    = dtrend_flag +"--(0 for raw data, else for detrended data)"

      var4           = (/dtrend_msg_n(ispan(1,nyear,1),var4,False,True,0)/)
      var4@detrend    = dtrend_flag +"--(0 for raw data, else for detrended data)"

      var5           = (/dtrend_msg_n(ispan(1,nyear,1),var5,False,True,0)/)
      var5@detrend    = dtrend_flag +"--(0 for raw data, else for detrended data)"
      
      var6_monave          = (/dtrend_msg_n(ispan(1,nyear,1),var6_monave,False,True,0)/)
      var6_monave@detrend  = dtrend_flag +"--(0 for raw data, else for detrended data)"
  end if
  printVarSummary(Ts)
  printVarSummary(var1)

  var1_monave =dim_avg_n_Wrap(var1,1)
  var2_monave =dim_avg_n_Wrap(var2,1)
  var3_monave =dim_avg_n_Wrap(var3,1)
  var4_monave =dim_avg_n_Wrap(var4,1)
  var5_monave =dim_avg_n_Wrap(var5,1)
  rad					= 4.0*atan(1.0)/180.0
  lat_Tb					= f1->lat({latmin:latmax}) 
  clat_Tb					= cos(lat_Tb*rad)
  var6_areaave		= wgt_areaave_Wrap(var6_monave(year|:,{lat|latmin:latmax},{lon|lonmin:lonmax}),clat_Tb,1.0,1)

  var6_ano=dim_rmvmean_n_Wrap(var6_monave,0)

  delete([/var1,var2,var3,var4,var5/])


  var1_areaave		= wgt_areaave_Wrap(var1_monave(year|:,{lat|latmin:latmax},{lon|lonmin:lonmax}),clat_Tb,1.0,1)
printVarSummary(var1_areaave)
  var2_areaave		= wgt_areaave_Wrap(var2_monave(year|:,{lat|latmin:latmax},{lon|lonmin:lonmax}),clat_Tb,1.0,1)

  var3_areaave		= wgt_areaave_Wrap(var3_monave(year|:,{lat|latmin:latmax},{lon|lonmin:lonmax}),clat_Tb,1.0,1)
  var4_areaave		= wgt_areaave_Wrap(var4_monave(year|:,{lat|latmin:latmax},{lon|lonmin:lonmax}),clat_Tb,1.0,1)
  var5_areaave		= wgt_areaave_Wrap(var5_monave(year|:,{lat|latmin:latmax},{lon|lonmin:lonmax}),clat_Tb,1.0,1)
  var6_areaave		= wgt_areaave_Wrap(var6_ano(year|:,{lat|latmin:latmax},{lon|lonmin:lonmax}),clat_Tb,1.0,1)
  printVarSummary(var6_areaave)

;print(var6_ano)
  ;Correlation or Regression  
  ;Regression 
  reg					= new((/7/),"float")
  reg(0)	= regCoef(Ts,var1_areaave)
  reg(1)= regCoef(Ts,var6_areaave)
  reg(2)	= regCoef(Ts,var2_areaave)
  reg(3)	= regCoef(Ts,var3_areaave)
  reg(4)	= regCoef(Ts,var4_areaave)
  reg(5)	= regCoef(Ts,var5_areaave)
  reg(6)  = reg(0)-reg(1)-reg(2)-reg(3)-reg(4)-reg(5)
    print(reg)			

;-----------------------------------------------------------------------------------------
  ;;;绘图
  plottype  = "pdf"                 ;type of plotting
  plotdir = "./"
  plotname   = setup_name+"_equation"+xitong+season+ts_name+"reg"
  wks        = gsn_open_wks(plottype,plotdir+plotname)
  wks@wkWidth = 2500
wks@wkHeight = 2500 
tres=True
tres@gsnDraw=True;;这个两个false即让图先不出，避免后面有两个图
tres@gsnFrame=False
tres@gsnXYBarChart=True
tres@trXMinF=0
tres@trXMaxF=8
tres@trYMinF=-15
tres@trYMaxF=8
tres@gsnYRefLine=0;标准线
tres@tmXBMode="Explicit"
tres@tmXBValues=(/1,2,3,4,5,6,7/)
strings1           = (/"~F18~-~F34~a~F33~w~F35~)~F34~W"+"~F34~6"+"~F21~h"+"/~F34~6"+"~F21~p~"+"F34~q","~F21~Fnet~F35~)",\
"~F18~-~F34~a"+"~F21~u"+"~F34~WQ"+"~F21~M~F35~)"+"~F34~q","~F18~-~F34~a~F33~w~F34~W"+"~F34~6"+"~F21~h~F35~)~F21~/"+"~F34~6"+"~F21~p"+"~F34~q",\
"~F18~-~F34~a"+"~F21~u~F35~)"+"~F34~WQ"+"~F21~M~"+"F34~q","~F21~NL","~F21~Res"/)
tres@tmXBLabelDeltaF = -0.2
tres@tmXBLabelAngleF = 30.0
tres@tmXBLabels		= strings1



  ;;;----------------------------------------------------
font_height   = 0.018			;font size
tres@tmYLLabelFontHeightF	= font_height
tres@tmXBLabelFontHeightF	= font_height
tres@tiXAxisFontHeightF	= 1.2 * font_height
tres@tiYAxisFontHeightF    	= 1.2 * font_height
tres@tiMainFontHeightF     	= 1.4 * font_height
tres@gsnLeftStringFontHeightF=1.2 * font_height
tres@gsnRightStringFontHeightF=1.2 * font_height
tres@tmXBMajorLengthF		= 0.006
tres@tmXBMajorOutwardLengthF	= 0.006
tres@tmXBLabelDeltaF		= -0.8
tres@tmYLMajorLengthF		= 0.006
tres@tmYLMajorOutwardLengthF	= 0.006
tres@tmYLLabelDeltaF		= -0.8
tres@gsnXYBarChartBarWidth = 0.3        ; change bar widths
tres@gsnXYScatterPlot = False
;;-------------------------------------------------------

tres@tiMainFont = "helvetica"
tres@tiMainString =""
tres@gsnLeftString="(b)Mse equation"
tres@tmXBLabelFontHeightF = 0.0205
tres@tmXTLabelFontHeightF = 0.0205
tres@tmYLLabelFontHeightF = 0.0225
tres@tiMainFontHeightF = 0.025
;tres@gsnXYBarChart=True;折线改柱状
tres@gsnRightString   =season
;图的宽度和高度:
tres@vpWidthF	= 0.8 ;Plot area
tres@vpHeightF	= 0.4
tres@vpYF	= 0.7
tres@vpXF	= 0.12
;   tres@xyMarkrSizes         = (/0.005,0.005/)

tres@gsnAboveYRefLineColor = "red"           ; above ref line fill red
tres@gsnBelowYRefLineColor = "blue"          ; below ref line fill blue
plot2 = gsn_csm_xy(wks,ispan(1,7,1),reg,tres)		; draw each time series


res_text	= True	

res_text@txFontHeightF	=0.02	
res_text@txJust	="CenterLeft"	


labels = (/xitong+"_"+season/)

;gsn_text_ndc(wks,labels,0.15,0.65,res_text)	; add right label


draw(plot2)
frame(wks)
end