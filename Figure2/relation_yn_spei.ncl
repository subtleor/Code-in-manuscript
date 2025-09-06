yload "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
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
data="TS1"
spei_choose=3

if data .eq. "EIP_SMI" then
ts_dat		= "EIP_SMI_JJA"
ts_name		= "JJA"
ts_filedir	="/mnt/e/westsouth/data/"
ts_filename	= "EIP_SMI_JJA.txt"
lv_filename  = "ICP_swvl1_MAM.txt" 
end if
if data .eq. "TS1" then
ts_dat		= "TS1"
ts_name		= "TS1"
ts_filedir	="/mnt/e/westsouth/yunnan/essay1/"
ts_filename	= "output1.txt"
end if
if data .eq. "ICP_SMI" then
ts_dat		= "ICP_SMI"
ts_name		= "MAM"
ts_filedir	="/mnt/e/westsouth/data/"
ts_filename	= "ICP_swvl1_MAM.txt"
lv_filename  = "EIP_swvl1_new_MAM.txt" 
end if

  var_dat		= "CRU"
  varname		= "spei" 
  filedir		= "/mnt/e/westsouth/data/"
  if spei_choose .eq. 1 then
  filename="spei01.nc"
  end if 
  if spei_choose .eq. 3 then
  filename="spei03.nc"
  end if
  
  setup_name  = data+"_vs_spei"+spei_choose
  ts_ys			= 1980			;ts start year 
  ts_ye			= 2020			;ts end year 
  ymstar		= 198001
  ymend			= 202012
  
  if spei_choose .eq. 1 then
    plotmon=(/3,4,5,6,7,8/)
    stringplot=(/"a","b","c","d","e","f"/)
    monname=(/"Mar","Apr","May","Jun","Jul","Aug"/)
end if

if spei_choose .eq. 3 then
    plotmon=(/5,8/)
    stringplot=(/"c","f"/)
    monname=(/"MAM","JJA"/)
end if

  cor_reg_flag	= "reg"		; "cor" or "reg"
  dtrend_flag	= 1			; 0 for raw,else for detrend
  maxy_flag		= 1			; years for lead or lag the currnet year(Y(0))   
  plot_flag		= 1	; 0 for contour,1 for dot Shaded,2 for color shaded,3 for only significant area plot  
  lv_flag    = 0			; 
;----------Attention!!! plot_flag = 3 only for correlation and the cnlevel should be altered by yourself!!!------ 
  if lv_flag .eq. 1
     setup_name	= setup_name+"_lv_"+lv_filename
  end if
latmin	= 21
latmax	= 30
lonmin	= 97
lonmax	= 107
  
  ;options for output  
  plottype	= "pdf"                 ;type of plotting
  plotdir	= "./"
  plotname	= setup_name
  savedir	= "./"
  savename	= setup_name
;**********************************************************************
;Handle variable
;**********************************************************************
  ;read time series
  Ts_init		= asciiread(ts_filedir+ts_filename,ts_ye-ts_ys+1,"float")
  Ts_init!0		= "year"
  Ts_init&year	= ispan(ts_ys,ts_ye,1)
  printVarSummary(Ts_init)
  print(Ts_init)
  Ts			= Ts_init({year|ymstar/100:ymend/100});
Ts =(/Ts*-1/)
  print(Ts)

  if lv_flag .eq. 1 then
  lv_init		= asciiread(ts_filedir+lv_filename,ts_ye-ts_ys+1,"float")
  lv_init!0		= "year"
  lv_init&year	= ispan(ts_ys,ts_ye,1)
  printVarSummary(lv_init)
  print(lv_init)
  lv			= lv_init({year|ymstar/100:ymend/100})
  print(lv)
end if 

  ;read variable 
  f			= addfile(filedir+filename,"r")
  tim		= f->time
  u_time_DATE	= cd_calendar(tim,-1)
  tstar		= ind(u_time_DATE .eq. ymstar)
  tlast		= ind(u_time_DATE .eq. ymend)
  print(tstar)
  print(tlast)  
  
  var		= short2flt(f->$varname$(tstar:tlast,{latmin:latmax},{lonmin:lonmax}))
  var!0		= "time"
  var!1		= "lat"
  var!2		= "lon"
  printVarSummary(var)

  nyear=ymend/100-ymstar/100+1
  nmonth=12
  dims= dimsizes(var)
  var_new=new((/nyear,nmonth,dims(1),dims(2)/),typeof(var),var@_FillValue)
  do i=1,nmonth  
    var_mon = month_to_monave(var,i,i)
    printVarSummary(var_mon)
    var_new(:,i-1,:,:)=var_mon
  end do

  var_new!1="month"
  var_new&month=ispan(1,12,1)
    printVarSummary(var_new)
  
  time=f->time
  var_time_DATE	= cd_calendar(time,-1)
  printMinMax(var_new,0)

  tstar		= ind(var_time_DATE .eq. ymstar)
  tlast		= ind(var_time_DATE .eq. ymend)

  nyear				= dimsizes(var_new&year)
  ny				= dimsizes(var_new&lat)
  nx				= dimsizes(var_new&lon)

  ;detrend or not
  if dtrend_flag .eq. 0 
   
     Ts					= Ts
	 Ts@detrend			= dtrend_flag +"--(0 for raw data, else for detrended data)"  
	 
	 var_new			= var_new
     var_new@detrend	= dtrend_flag +"--(0 for raw data, else for detrended data)" 
  
  else
     				
     Ts					= (/dtrend_msg_n(ispan(1,nyear,1),Ts,False,True,0)/) 
	 Ts@detrend			= dtrend_flag +"--(0 for raw data, else for detrended data)" 

     var_new            = (/dtrend_msg_n(ispan(1,nyear,1),var_new,False,True,0)/)
     var_new@detrend    = dtrend_flag +"--(0 for raw data, else for detrended data)"
  
  end if
  if lv_flag .eq. 1 then
  var_new            = (/dtrend_msg_n(lv,var_new,False,True,0)/)
  var_new@detrend    = dtrend_flag +"--(0 for raw data, else for detrended data)"
  Ts					= (/dtrend_msg_n(lv,Ts,False,True,0)/) 
Ts@detrend			= dtrend_flag +"--(0 for raw data, else for detrended data)" 
end if 
  printVarSummary(Ts)
  printVarSummary(var_new)
  

  cor								= new((/ny,nx,nmonth,2*maxy_flag+1/),"float")

  ;Correlation or Regression  
 ; do i=0,nmonth-1  

  ;Correlation
  cor_Ts_lead_var		= esccr(Ts,var_new(lat|:,lon|:,month|:,year|:),1);滞后？
  printVarSummary(cor_Ts_lead_var)
  
  cor_var_lead_Ts		= esccr(var_new(lat|:,lon|:,month|:,year|:),Ts,1)  
  printVarSummary(cor_var_lead_Ts)
 


  cor(:,:,:,0:maxy_flag)				= cor_var_lead_Ts(:,:,:,::-1)
  cor(:,:,:,maxy_flag+1:2*maxy_flag)	= cor_Ts_lead_var(:,:,:,1:maxy_flag)
;end do 
  cor!0				= "lat"
  cor&lat				= var_new&lat
  cor!1					= "lon"
  cor&lon				= var_new&lon
  cor!2					= "month"
  cor&month			= ispan(1,12,1)
  cor!3					= "lead"
  cor&lead			    = ispan(-1*maxy_flag,maxy_flag,1)*1.0
  cor@long_name			= "Corrrelation--Ts lead var. If lead dimension is negative, Ts lag var" 
		printVarSummary(cor)
    
  ;Regression 
  reg					= new((/ny,nx,nmonth,2*maxy_flag+1/),"float")
  do i=0,maxy_flag
  
	reg(:,:,:,maxy_flag-i)	= regCoef(Ts(i:nyear-1),var_new(lat|:,lon|:,month|:,year|0:nyear-i-1))			
    reg(:,:,:,maxy_flag+i)	= regCoef(Ts(0:nyear-i-1),var_new(lat|:,lon|:,month|:,year|i:nyear-1))
		
  end do	

  reg!0					= "lat"
  reg&lat				= var_new&lat
  reg!1					= "lon"
  reg&lon				= var_new&lon
  reg!2					= "month"
  reg&month			= ispan(1,12,1)
  reg!3					= "lead"
  reg&lead			    = ispan(-1*maxy_flag,maxy_flag,1)*1.0
  reg@long_name			= "Regression--Ts lead var. If lead dimension is negative, Ts lag var"   
  printVarSummary(reg)
  
  if cor_reg_flag .eq. "cor"
   
	cor_reg				= cor
   
  end if 
   
  if cor_reg_flag .eq. "reg"
	
	cor_reg				= reg
		
  end if
  printVarSummary(cor_reg)

  
  ;Critical t value and correlation coefficients for 0.10,0.05 and 0,01
  
  tValue				= new((/2*maxy_flag+1,3/),"float")				
  rflag					= new((/2*maxy_flag+1,3/),"float")
  
  
  do i=0,2*maxy_flag
        n				= nyear-abs(i-maxy_flag)
		tValue(i,:)		= cdft_t((/1-0.05,1-0.025,1-0.005/),(/n-2,n-2,n-2/))
		rflag(i,:)		= sqrt(tValue(i,:)^2/(n-2+tValue(i,:)^2))
  end do
  rflag					= round(rflag*100.0,0)/100.0		;round the float data
 
  write_matrix(tValue,"3f8.2",False)
  write_matrix(rflag,"3f8.2",False)
  
  cor@tValue			= tValue
  cor@tValue_desc		= "Critical t Value for 0.1,0.05,001 significant level"
  
  cor@rflag				= rflag
  cor@rflag_desc		= "Critical correlation for 0.1,0.05,001 significant level"
  
  printVarSummary(cor)
  printVarSummary(reg)

;**********************************************************************
;Saving data
;********************************************************************** 
  system("/bin/rm -f "+savedir+savename+".nc")
  fo            			= addfile(savedir+savename+".nc","c")
  filedimdef(fo,"time",-1,True)
  fo->cor					= cor
  fo->reg					= reg
  
;**********************************************************************
;Plotting
;**********************************************************************
  cor_plot				= cor
  var_plot				= cor_reg

  cor_plot_area			= cor_plot({lat|latmin:latmax},{lon|lonmin:lonmax},month|:,lead|:)
  var_plot_area			= var_plot({lat|latmin:latmax},{lon|lonmin:lonmax},month|:,lead|:)
  
  printMinMax(cor_plot_area,True)
  printMinMax(var_plot_area,True)

  i_flag				= "(" + ispan(-maxy_flag,maxy_flag,1) + ")"  

;------------------------------------------------------------------------  
if plot_flag .eq. 0
; Resources for shaded Plot
  sres						= True
  sres@gsnFrame				= False
  sres@gsnDraw				= False
  
  sres@cnFillOn				= True
  sres@cnLinesOn			= False
  sres@cnLineLabelsOn		= False
  sres@cnInfoLabelOn		= False
  sres@cnLevelSelectionMode	= "ExplicitLevels"
  sres@cnLevels		        = ispan(-8,8,2)/10.0
  sres@cnFillColors			= (/2,4,5,7,8,12,13,14,15,17/)
;  sres@gsnSpreadColors		= True
;  sres@gsnSpreadColorStart	= 2 
;  sres@gsnSpreadColorEnd	= 17  

  ; Resources for colorbar
  sres@lbOrientation			= "Vertical"
  sres@lbLabelBarOn				= True
  sres@pmLabelBarOrthogonalPosF	= 0.01
  sres@pmLabelBarParallelPosF	= 0.5
  sres@pmLabelBarWidthF			= 0.06
  sres@pmLabelBarHeightF		= 0.35

  ; Resources for map
  sres@mpCenterLonF			= 180
  sres@mpMinLatF			= latmin
  sres@mpMaxLatF			= latmax
  sres@mpMinLonF			= lonmin
  sres@mpMaxLonF			= lonmax
 
  sres@mpFillOn				= True
  sres@mpLandFillColor		= 20
  sres@mpOutlineOn			= True
  sres@mpGeophysicalLineColor	= "blue"
  sres@gsnAddCyclic			= False

 ; Resources for Axis
  font_height				= 0.018								       
  sres@tmYLLabelFontHeightF	= font_height
  sres@tmXBLabelFontHeightF	= font_height
  sres@tiXAxisFontHeightF	= 1.2 * font_height
  sres@tiYAxisFontHeightF	= 1.2 * font_height
  sres@tiMainFontHeightF	= 1.2 * font_height

; sres@gsnRightString		= "~S~o~N~C"
  sres@gsnLeftStringOrthogonalPosF	= -0.0
  sres@tiMainString			= abs(monmin)+ " - " + monmax + "." + varname + "."+ymstar/100+ " - " +ymend/100
  sres@tiMainOffsetYF 		= -0.02

  
;  sres@tmXBValues		= (/30,60,90,120/)
;  sres@tmXBLabels		= (/"30~S~o~N~E","60~S~o~N~E","90~S~o~N~E","120~S~o~N~E"/)
;  sres@tmYLValues		= (/-60,-30,0,30/)
;  sres@tmYLLabels		= (/"60~S~o~N~S","30~S~o~N~S","Eq","30~S~o~N~N"/)
;  sres@tmXBMinorValues		= ispan(40,120,10)
;  sres@tmYLMinorValues		= ispan(-60,30,10)
  
  sres@tmXBMinorOn		= False
  sres@tmYLMinorOn		= False
  sres@tmYROn			= False
  sres@tmXTOn			= False
  
  sres@tmXBMajorLengthF			= 0.004
  sres@tmXBMajorOutwardLengthF	= 0.004
  sres@tmXBLabelDeltaF			= -0.5
  sres@tmYLMajorLengthF			= 0.004
  sres@tmYLMajorOutwardLengthF	= 0.004
  sres@tmYLLabelDeltaF			= -0.5
 
  ;Resources for contour plot
  res					= True
  res@gsnDraw			= False
  res@gsnFrame			= False
  
  res@cnLineLabelsOn			= False
  res@cnInfoLabelOn    			= False
  res@cnLineLabelFormat			= "@*+^sg"
  res@cnLineLabelPlacementMode	= "Computed"
  res@cnLabelMasking			= True
  res@cnLineLabelBackgroundColor= "white"  
  res@cnLineLabelInterval		= 1
  res@cnLineLabelFontHeightF   	= 0.01
  res@cnLevelSelectionMode		= "ExplicitLevels"
  
  res@gsnContourNegLineDashPattern	= 5
;  res@gsnContourZeroLineThicknessF	= 0.0
  res@gsnAddCyclic					= False
  
  do i=0,2*maxy_flag
  
	 res@cnLevels						= (/-1.0*rflag(i,1),-1.0*rflag(i,0),rflag(i,0),rflag(i,1)/)
     sres@gsnLeftString					= "lead-"+i_flag(i)
	 wks                 				= gsn_open_wks(plottype,plotdir+plotname+".lead"+i_flag(i))
	 gsn_define_colormap(wks,"BlueDarkRed18")
	 nc 								= NhlNewColor(wks,0.83,0.83,0.83)
	 plot								= gsn_csm_contour_map_overlay(wks,var_plot(:,:,i),cor_plot(:,:,i),sres,res)
	 draw(plot)
     frame(wks)  
	 
  end do 
end if
;------------------------------------------------------------------------

;########################################################################
if plot_flag .eq. 1
; Resources for shaded Plot
  sres						= True
  sres@gsnFrame				= False
  sres@gsnDraw				= False
  
  sres@cnFillOn				= True
  sres@cnLinesOn			= False
  sres@cnLineLabelsOn		= False
  sres@cnInfoLabelOn		= False
  sres@cnLevelSelectionMode	= "ExplicitLevels"
  levels=(/-1,-0.9,-0.8,-0.4,0,0.4,0.8,0.9,1/)
  sres@cnLevels		        = levels
  ;sres@cnLevels		        = ispan(-60,60,15)/100.0
 ; sres@cnFillColors			= (/2,4,5,7,8,12,13,14,15,17/)
  sres@gsnSpreadColors		= True
  sres@gsnSpreadColorStart	= 2 
  sres@gsnSpreadColorEnd	= 19

  ; Resources for colorbar
  sres@lbOrientation			= "Horizontal";"vertical"
  sres@lbLabelBarOn				= True
  ;sres@pmLabelBarOrthogonalPosF	= 0.05
 ; sres@pmLabelBarParallelPosF	= 0.5
 ; sres@pmLabelBarWidthF			= 0.06
  ;sres@pmLabelBarHeightF		= 0.35
 
  ; Resources for map
  sres@mpCenterLonF			= 180
  sres@mpMinLatF			= latmin
  sres@mpMaxLatF			= latmax
  sres@mpMinLonF			= lonmin
  sres@mpMaxLonF			= lonmax
 
  sres@mpFillOn				= True
 ; sres@mpLandFillColor		= 20
 ; sres@mpGeophysicalLineColor	= "blue"
  sres@gsnAddCyclic			= False
;-----resource for China map 
sres@mpDataSetName     = "/mnt/e/nclstudy/nclscripts/Earth..4" 
sres@mpDataBaseVersion     = "MediumRes" ; or "Ncarg4_1"
sres@mpOutlineOn       = True

;sres@mpOutlineSpecifiers   = (/"China","China:Yunnan"/)  
sres@mpOutlineSpecifiers   = (/"China:Yunnan"/)  
sres@mpGeophysicalLineColor    = "black"
sres@mpOutlineBoundarySets = "NoBoundaries"
sres@mpNationalLineThicknessF  = 2.0
sres@mpFillAreaSpecifiers      = (/"land","water","China:Yunnan"/)
sres@mpSpecifiedFillColors     = (/"white","white","transparent"/)
sres@mpFillDrawOrder           = "PostDraw"

 ; Resources for Axis
  font_height				= 0.018								       
  sres@tmYLLabelFontHeightF	= font_height
  sres@tmXBLabelFontHeightF	= font_height
  sres@tiXAxisFontHeightF	= 1.2 * font_height
  sres@tiYAxisFontHeightF	= 1.2 * font_height
  sres@tiMainFontHeightF	= 1.2 * font_height
; sres@gsnRightString		= "~S~o~N~C"
  sres@tiMainString			= ""

  sres@tiMainOffsetYF 		= -0.02

;  sres@tmXBValues		= (/30,60,90,120/)
;  sres@tmXBLabels		= (/"30~S~o~N~E","60~S~o~N~E","90~S~o~N~E","120~S~o~N~E"/)
;  sres@tmYLValues		= (/-60,-30,0,30/)
;  sres@tmYLLabels		= (/"60~S~o~N~S","30~S~o~N~S","Eq","30~S~o~N~N"/)
;  sres@tmXBMinorValues		= ispan(40,120,10)
;  sres@tmYLMinorValues		= ispan(-60,30,10)

  sres@tmXBMinorOn		= False
  sres@tmYLMinorOn		= False
  sres@tmYROn			= False
  sres@tmXTOn			= False
  
  sres@tmXBMajorLengthF			= 0.004
  sres@tmXBMajorOutwardLengthF	= 0.004
  sres@tmXBLabelDeltaF			= -0.5
  sres@tmYLMajorLengthF			= 0.004
  sres@tmYLMajorOutwardLengthF	= 0.004
  sres@tmYLLabelDeltaF			= -0.5
  sres@gsnLeftStringOrthogonalPosF    = 0.01
  sres@gsnRightStringOrthogonalPosF   = 0.02
  ;Resources for contour plot
  res					= True
  res@gsnDraw			= False
  res@gsnFrame			= False
  
  res@cnFillOn					= True
  res@cnLinesOn					= False
  res@cnLineLabelsOn			= False
  res@cnInfoLabelOn    			= False
  res@cnMonoFillPattern			= False
  
  res@cnFillPatterns			= (/17,-1,17/)
  ;res@cnFillDotSizeF			= 0.004
  res@cnFillDotSizeF			= 0.008
  res@cnFillScaleF=3
  res@cnLevelSelectionMode		= "ExplicitLevels"
  res@cnFillColors=(/"black","white","black"/)
  res@gsnAddCyclic					= False
  res@cnLevels				= (/-1.0*rflag(1,1),rflag(1,1)/)
  
  wks                 		= gsn_open_wks(plottype,plotdir+plotname)
  gsn_define_colormap(wks,"BlueDarkRed18")
  ;gsn_reverse_colormap(wks)
  nc 						= NhlNewColor(wks,0.83,0.83,0.83)
  n=num(plotmon)-1
  plot=new(num(plotmon),graphic)
  dum=new(num(plotmon),graphic)
  do i=0,n
  ;do i=0,2*maxy_flag
if i .eq. 1 then
   sres@cnLevels		        = ispan(-40,40,10)/100.0
end if 
   sres@gsnCenterString			= ""
	 sres@gsnLeftString			= "("+stringplot(i)+") Reg. SPEI on "+data
   sres@gsnRightString      = monname(i)

     plot(i) 						= gsn_csm_contour_map_overlay(wks,var_plot(:,:,plotmon(i)-1,1),cor_plot(:,:,plotmon(i)-1,1),sres,res)

  
  end do
  if spei_choose .eq. 1 then
  gsn_panel(wks, plot, (/2,3/), True)
  end if 
  if spei_choose .eq. 3 then
  gsn_panel(wks, plot, (/2,1/), True)
  end if

end if
;########################################################################

;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
if plot_flag .eq. 2
; Resources for shaded Plot
  sres						= True
  sres@gsnFrame				= False
  sres@gsnDraw				= False
  
  sres@cnFillOn				= True
  sres@cnLinesOn			= False
  sres@cnLineLabelsOn		= False
  sres@cnInfoLabelOn		= False
  sres@cnLevelSelectionMode	= "ExplicitLevels"
;  sres@cnLevels		        = ispan(-10,10,2)/10.0
  sres@cnFillColors			= (/5,8,-1,13,15/)
;  sres@gsnSpreadColors		= True
;  sres@gsnSpreadColorStart	= 2 
;  sres@gsnSpreadColorEnd	= 17  

  ; Resources for colorbar
  sres@lbOrientation			= "Vertical"
  sres@lbLabelBarOn				= False
  sres@pmLabelBarOrthogonalPosF	= 0.01
  sres@pmLabelBarParallelPosF	= 0.5
  sres@pmLabelBarWidthF			= 0.06
  sres@pmLabelBarHeightF		= 0.35
 
  ; Resources for map
  sres@mpCenterLonF			= 180
  sres@mpMinLatF			= latmin
  sres@mpMaxLatF			= latmax
  sres@mpMinLonF			= lonmin
  sres@mpMaxLonF			= lonmax
 
  sres@mpFillOn				= True
  sres@mpLandFillColor		= 20
  sres@mpOutlineOn			= True
  sres@mpGeophysicalLineColor	= "blue"
  sres@gsnAddCyclic			= False

 ; Resources for Axis
  font_height				= 0.018								       
  sres@tmYLLabelFontHeightF	= font_height
  sres@tmXBLabelFontHeightF	= font_height
  sres@tiXAxisFontHeightF	= 1.2 * font_height
  sres@tiYAxisFontHeightF	= 1.2 * font_height
  sres@tiMainFontHeightF	= 1.2 * font_height

; sres@gsnRightString		= "~S~o~N~C"
  sres@gsnLeftStringOrthogonalPosF	= -0.0
  sres@tiMainString			= abs(monmin)+ " - " + monmax + "." + varname + "."+ymstar/100+ " - " +ymend/100
  sres@tiMainOffsetYF 		= -0.02

;  sres@tmXBValues		= (/30,60,90,120/)
;  sres@tmXBLabels		= (/"30~S~o~N~E","60~S~o~N~E","90~S~o~N~E","120~S~o~N~E"/)
;  sres@tmYLValues		= (/-60,-30,0,30/)
;  sres@tmYLLabels		= (/"60~S~o~N~S","30~S~o~N~S","Eq","30~S~o~N~N"/)
;  sres@tmXBMinorValues	= ispan(40,120,10)
;  sres@tmYLMinorValues	= ispan(-60,30,10)

  sres@tmXBMinorOn		= False
  sres@tmYLMinorOn		= False
  sres@tmYROn			= False
  sres@tmXTOn			= False
  
  sres@tmXBMajorLengthF			= 0.004
  sres@tmXBMajorOutwardLengthF	= 0.004
  sres@tmXBLabelDeltaF			= -0.5
  sres@tmYLMajorLengthF			= 0.004
  sres@tmYLMajorOutwardLengthF	= 0.004
  sres@tmYLLabelDeltaF			= -0.5
 
  ;Resources for contour plot
  res					= True
  res@gsnDraw			= False
  res@gsnFrame			= False
  
  res@cnLineLabelsOn			= True
  res@cnInfoLabelOn    			= False
  res@cnLineLabelFormat			= "@*+^sg"
  res@cnLineLabelPlacementMode	= "Computed"
  res@cnLabelMasking			= True
  res@cnLineLabelBackgroundColor= "white"  
  res@cnLineLabelInterval		= 1
  res@cnLineLabelFontHeightF   	= 0.01
  res@cnLevelSelectionMode		= "ExplicitLevels"
  ;res@cnLevels					= ispan(-10,10,4)/10.0


  res@gsnContourNegLineDashPattern	= 5
;  res@gsnContourZeroLineThicknessF	= 0.0
  res@gsnAddCyclic					= False
  
  do i=0,2*maxy_flag
  
	 sres@cnLevels					= (/-1.0*rflag(i,1),-1.0*rflag(i,0),rflag(i,0),rflag(i,1)/)
     sres@gsnLeftString				= "lead-"+i_flag(i)
	 wks                 			= gsn_open_wks(plottype,plotdir+plotname+".lead"+i_flag(i))
	 gsn_define_colormap(wks,"BlueDarkRed18")
	 nc 							= NhlNewColor(wks,0.83,0.83,0.83)
	 plot							= gsn_csm_contour_map_overlay(wks,cor_plot(:,:,i),var_plot(:,:,i),sres,res)
	 draw(plot)
     frame(wks)  
	 
  end do 
end if
;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


;&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

if plot_flag .eq. 3

  if cor_reg_flag .eq. "reg"
  
	print("This selection (cor_reg_flag= 3) only for correlation!!!")
	print("exit...")
	exit
  
  end if 
  
; Resources for shaded Plot
  sres						= True
  sres@gsnFrame				= False
  sres@gsnDraw				= False
  
  sres@cnFillOn				= True
  sres@cnLinesOn			= False
  sres@cnLineLabelsOn		= False
  sres@cnInfoLabelOn		= False
  sres@cnLevelSelectionMode	= "ExplicitLevels"
  sres@cnFillColors			= (/2,3,4,5,7,-1,13,14,15,16,17/)
;  sres@gsnSpreadColors		= True
;  sres@gsnSpreadColorStart	= 2 
;  sres@gsnSpreadColorEnd	= 17  

  ; Resources for colorbar
  sres@lbOrientation			= "Vertical"
  sres@lbLabelBarOn				= True
  sres@pmLabelBarOrthogonalPosF	= 0.01
  sres@pmLabelBarParallelPosF	= 0.5
  sres@pmLabelBarWidthF			= 0.06
  sres@pmLabelBarHeightF		= 0.35
  ; Resources for map
  sres@mpCenterLonF			= 180
  sres@mpMinLatF			= latmin
  sres@mpMaxLatF			= latmax
  sres@mpMinLonF			= lonmin
  sres@mpMaxLonF			= lonmax
 
  sres@mpFillOn				= True
  sres@mpLandFillColor		= 20
  sres@mpOutlineOn			= True
  sres@mpGeophysicalLineColor	= "blue"
  sres@gsnAddCyclic			= False

 ; Resources for Axis
  font_height				= 0.018								       
  sres@tmYLLabelFontHeightF	= font_height
  sres@tmXBLabelFontHeightF	= font_height
  sres@tiXAxisFontHeightF	= 1.2 * font_height
  sres@tiYAxisFontHeightF	= 1.2 * font_height
  sres@tiMainFontHeightF	= 1.2 * font_height

; sres@gsnRightString		= "~S~o~N~C"
  sres@gsnLeftStringOrthogonalPosF	= -0.0
  sres@tiMainString			= abs(monmin)+ " - " + monmax + "." + varname + "."+ymstar/100+ " - " +ymend/100
  sres@tiMainOffsetYF 		= -0.02

;  sres@tmXBValues		= (/30,60,90,120/)
;  sres@tmXBLabels		= (/"30~S~o~N~E","60~S~o~N~E","90~S~o~N~E","120~S~o~N~E"/)
;  sres@tmYLValues		= (/-60,-30,0,30/)
;  sres@tmYLLabels		= (/"60~S~o~N~S","30~S~o~N~S","Eq","30~S~o~N~N"/)
;  sres@tmXBMinorValues		= ispan(40,120,10)
;  sres@tmYLMinorValues		= ispan(-60,30,10)

  sres@tmXBMinorOn		= False
  sres@tmYLMinorOn		= False
  sres@tmYROn			= False
  sres@tmXTOn			= False
  
  sres@tmXBMajorLengthF			= 0.004
  sres@tmXBMajorOutwardLengthF	= 0.004
  sres@tmXBLabelDeltaF			= -0.5
  sres@tmYLMajorLengthF			= 0.004
  sres@tmYLMajorOutwardLengthF	= 0.004
  sres@tmYLLabelDeltaF			= -0.5
 
  ;Resources for contour plot
  res					= True
  res@gsnDraw			= False
  res@gsnFrame			= False
  
  res@cnLinesOn					= False
  res@cnLineLabelsOn			= False
  res@cnInfoLabelOn    			= False
  res@cnLineLabelFormat			= "@*+^sg"
  res@cnLineLabelPlacementMode	= "Computed"
  res@cnLabelMasking			= True
  res@cnLineLabelBackgroundColor= "white"  
  res@cnLineLabelInterval		= 1
  res@cnLineLabelFontHeightF   	= 0.01
  res@cnLevelSelectionMode		= "ExplicitLevels"
  
  res@gsnContourNegLineDashPattern	= 5
;  res@gsnContourZeroLineThicknessF	= 0.0
  res@gsnAddCyclic					= False
  
  do i=0,2*maxy_flag

	 sres@gsnLeftString				= "lead-"+i_flag(i)
	 sres@cnLevels				    = (/-0.8,-0.7,-0.6,-0.5,-1.0*rflag(i,1),rflag(i,1),0.5,0.6,0.7,0.8/)
	 res@cnLevels				    = (/-0.8,-0.7,-0.6,-0.5,-1.0*rflag(i,1),rflag(i,1),0.5,0.6,0.7,0.8/)
	 wks                 			= gsn_open_wks(plottype,plotdir+plotname+".lead"+i_flag(i))
	 gsn_define_colormap(wks,"BlueDarkRed18")
	 nc 							= NhlNewColor(wks,0.83,0.83,0.83)
	 plot							= gsn_csm_contour_map_overlay(wks,var_plot(:,:,i),var_plot(:,:,i),sres,res)
     draw(plot)
     frame(wks)  
  
  end do
   
end if
;&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
     
end  
