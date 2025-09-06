load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "/mnt/e/mytool.ncl"
begin
;**********************************************************************
;A script calculating Correlation or Regresssion coefficients for several month averaged 4-Dimension scalar field

;Plot the a prescribed statistic by cor_reg_flag( User should adjust the cnLevels and cnFillColors accroding to different statistics) 
;**********************************************************************
;user can select:

;				 1��Correlation or Regression

;				 2��detrend or not for each month

;                3��lead or lag time 

;                4��different plot for significant level
;**********************************************************************
  ;Options for user
  data="TS1"

  if data .eq. "EIP_SMI" then
  ts_dat		= "EIP_swvl1_MAM"
  ts_name		= "MAM"
  ts_filedir	="/mnt/e/westsouth/data/"
  ts_filename	= "EIP_SMI_MAM.txt"
  lv_filename  = "nino34_MAM.txt" 
  end if
  if data .eq. "TS1" then
  ts_dat		= "TS1"
  ts_name		= "TS1"
  ts_filedir	="/mnt/e/westsouth/data/"
  ts_filename	= "output1.txt"
  end if
  if data .eq. "EIP_SMI" then
  ts_dat		= "EIP_SMI"
  ts_name		= "MAM"
  ts_filedir	="/mnt/e/westsouth/data/"
  ts_filename	= "EIP_SMI_MAM.txt"
  lv_filename  = "EIP_swvl1_new_MAM.txt" 
  end if

  if data .eq. "other" then
  ts_dat		= "other"
  ts_name		= "other"
  ts_filedir	="/mnt/e/westsouth/data/"
  ts_filename	= "pc1.txt"
  lv_filename  = "EIP_swvl1_new_MAM.txt" 
  end if

  ts_ys			= 1980			;ts start year 
  ts_ye			= 2020			;ts end year 

  var_dat		= "ERA5"
  varname		= "z" 
  filedir		= "/mnt/e/westsouth/data/"
  filename		= "ERA5.mon.geopotential.1950-2022.nc";h_1979-2024

  lvl 		=200
  
  ymstar		= 198001
  ymend			= 202012
  
  cor_reg_flag	= "reg"		; "cor" or "reg"
  dtrend_flag	= 1			; 0 for raw,else for detrend
  maxy_flag		= 1			; years for lead or lag the currnet year(Y(0))   
  plot_flag		= 1 	; 0 for contour,1 for dot Shaded,2 for color shaded,3 for only significant area plot  
  lv_flag  =0
;----------Attention!!! plot_flag = 3 only for correlation and the cnlevel should be altered by yourself!!!------ 
  
latmin	=  10;10;0
latmax	=  60;30;50
lonmin	=  45;90;;45
lonmax	=  150;120;130
  
  season="JJA"
  monmin	= 6;starting month for averaging,(monmin != 0,-12 <= monmin <= monmax <=12). negative value for previou year(year(-1)) 
  monmax	= 8  ;ending month for averaging,	   1<= monmax <= 12 
	setup_name  = data+"_vs_"+lvl+ varname+"_"+season      	
  
  if lv_flag .eq. 1 then
	setup_name  = data+"_vs_"+lvl+ varname+"_"+season+"lv"+lv_filename     	
end if 
  months	= (/"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"/)
  
  LS="(d) Reg. "+lvl+varname+" on "+data
  RS=season+"(0)"
 
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
  
  if data .eq. "EIP_SMI"  then
  Ts			= Ts_init({year|ymstar/100:ymend/100})
  end if
  if data .eq. "TS1" then
  Ts			= -1*Ts_init({year|ymstar/100:ymend/100})
  end if
  if data .eq. "ICP_SMI" then
  Ts			= -1*Ts_init({year|ymstar/100:ymend/100})
  end if
  if data .eq. "other" then
  Ts			= Ts_init({year|ymstar/100:ymend/100})
  end if
  print(Ts)
  
if lv_flag .eq. 1 then
lv_init		= asciiread(ts_filedir+lv_filename,ts_ye-ts_ys+1,"float")
lv_init!0		= "year"
lv_init&year	= ispan(ts_ys,ts_ye,1)
printVarSummary(lv_init)
print(lv_init)
lv			= lv_init({year|ymstar/100:ymend/100})
lv=[-1*lv]
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
  
  var		= short2flt(f->$varname$(tstar:tlast,{(/1000,850,700,500,400,300,200/)},{latmin:latmax},{lonmin:lonmax}))
  var=(/var/9.8/)
  var!0		= "time"
  var!1		= "level"
  var!2		= "lat"
  var!3		= "lon"
  printVarSummary(var)
  printMinMax(var,0)

  var_monave		= month_to_monave(var,monmin,monmax)
  printVarSummary(var_monave)
  printMinMax(var_monave,0)
  nyear				= dimsizes(var_monave&year)
  nz				= dimsizes(var_monave&level)
  ny				= dimsizes(var_monave&lat)
  nx				= dimsizes(var_monave&lon)
 
  ;detrend or not
  if dtrend_flag .eq. 0 
   
     Ts					= Ts
	 Ts@detrend			= dtrend_flag +"--(0 for raw data, else for detrended data)" 
	 
	 var_monave			= var_monave
     var_monave@detrend	= dtrend_flag +"--(0 for raw data, else for detrended data)" 
  
  else
     				
     Ts					= (/dtrend_msg_n(ispan(1,nyear,1),Ts,False,True,0)/) 
	 Ts@detrend			= dtrend_flag +"--(0 for raw data, else for detrended data)" 
	 
	 var_monave			= (/dtrend_msg_n(ispan(1,nyear,1),var_monave,False,True,0)/) 
     var_monave@detrend	= dtrend_flag +"--(0 for raw data, else for detrended data)" 
  
  end if

  if lv_flag .eq. 1 then
  var_monave            = (/dtrend_msg_n(lv,var_monave,False,True,0)/)
  var_monave@detrend    = dtrend_flag +"--(0 for raw data, else for detrended data)"
  Ts					= (/dtrend_msg_n(lv,Ts,False,True,0)/) 
Ts@detrend			= dtrend_flag +"--(0 for raw data, else for detrended data)" 
end if 
  printVarSummary(Ts)
  printVarSummary(var_monave)
  
  ;overlay WNPH SAH
 
  ;elements for Composite
  critic_flag=0.75
  yeara			= ispan(ymstar/100,ymend/100,1)		
  yeara@long_name	= "year-all"
  
  hi			= ind(Ts .ge. critic_flag)
  li			= ind(Ts .le. -1.0*critic_flag)
  

  yearh			= yeara(hi)			
  yearh@long_name	= "year-high"
 
  ;if critic_flag .eq. 0.5
  yearl			= yeara(li);;;;改
  yearl@long_name	= "year-low"		
  ;end if
  print(yearh)
  print(yearl)


  xdata1  = var_monave({year|yearl},level|:,lat|:,lon|:)
  xdata2  = var_monave(year|:,level|:,lat|:,lon|:)
  xdata3	= var_monave({year|yearh},level|:,lat|:,lon|:)

  xave1    = dim_avg_n_Wrap(xdata1,0)
  xave2    = dim_avg_n_Wrap(xdata2,0)
  xave3    = dim_avg_n_Wrap(xdata3,0)
  printVarSummary(xave1)
   
  xave3_sah		= xave3({200},{0:latmax},{lonmin:lonmax});200高年平均
  printVarSummary(xave3_sah)
  print(" average regional Maximum value of xave3_sah: "+max(xave3_sah))
  print(" average regional Minimum value of xave3_sah: "+min(xave3_sah))

  xave2_sah		= xave2({200},{0:latmax},{lonmin:lonmax});200气候态
  printVarSummary(xave2_sah)
  print(" average regional Maximum value of xave2_sah: "+max(xave2_sah))
  print(" average regional Minimum value of xave2_sah: "+min(xave2_sah))
  
  xave1_sah		= xave1({200},{0:latmax},{lonmin:lonmax});200低年平均
  printVarSummary(xave1_sah)
  print(" average regional Maximum value of xave1_sah: "+max(xave1_sah))
  print(" average regional Minimum value of xave1_sah: "+min(xave1_sah))

  xave1_wnpsh=  xave1({500},{0:latmax},{70:lonmax});500低年平均
  ;xave1_wnpsh=new((/51,111/),float)
  ;xave1_wnpsh(:,50:110)=xave11_wnpsh(:,50:110)
  ;xave1_wnpsh(:,0:49)=-32767
 ; copy_VarCoords(xave11_wnpsh,xave1_wnpsh)
  printVarSummary(xave1_wnpsh)
  print(" average regional Maximum value of xave1_wnpsh: "+max(xave1_wnpsh))
  print(" average regional Minimum value of xave1_wnpsh: "+min(xave1_wnpsh))

  xave2_wnpsh=  xave2({500},{0:latmax},{70:lonmax});500气候态

  ;copy_VarCoords(xave22_wnpsh,xave2_wnpsh)
  printVarSummary(xave2_wnpsh)
  print(" average regional Maximum value of xave2_wnpsh: "+max(xave2_wnpsh))
  print(" average regional Minimum value of xave2_wnpsh: "+min(xave2_wnpsh))

  xave3_wnpsh=  xave3({500},{0:latmax},{70:lonmax});500高年平均

  ;copy_VarCoords(xave33_wnpsh,xave3_wnpsh)
  printVarSummary(xave3_wnpsh)
  print(" average regional Maximum value of xave3_wnpsh: "+max(xave3_wnpsh))
  print(" average regional Minimum value of xave3_wnpsh: "+min(xave3_wnpsh))




  ;Correlation or Regression  
  
  ;Correlation
  cor_Ts_lead_var		= esccr(Ts,var_monave(level|:,lat|:,lon|:,year|:),maxy_flag)
  printVarSummary(cor_Ts_lead_var)
  
  cor_var_lead_Ts		= esccr(var_monave(level|:,lat|:,lon|:,year|:),Ts,maxy_flag)  
  printVarSummary(cor_var_lead_Ts)
  
  cor									= new((/nz,ny,nx,2*maxy_flag+1/),"float")
  cor(:,:,:,0:maxy_flag)				= cor_var_lead_Ts(:,:,:,::-1)
  cor(:,:,:,maxy_flag+1:2*maxy_flag)	= cor_Ts_lead_var(:,:,:,1:maxy_flag)

  cor!0					= "level"
  cor&level				= var_monave&level
  cor!1					= "lat"
  cor&lat				= var_monave&lat
  cor!2					= "lon"
  cor&lon				= var_monave&lon
  cor!3					= "lead"
  cor&lead			    = ispan(-1*maxy_flag,maxy_flag,1)*1.0
  cor@long_name			= "Corrrelation--Ts lead var. If lead dimension is negative, Ts lag var" 
		
  ;Regression 
  reg					= new((/nz,ny,nx,2*maxy_flag+1/),"float")
  do i=0,maxy_flag
  
	reg(:,:,:,maxy_flag-i)	= regCoef(Ts(i:nyear-1),var_monave(level|:,lat|:,lon|:,year|0:nyear-i-1))			
    reg(:,:,:,maxy_flag+i)	= regCoef(Ts(0:nyear-i-1),var_monave(level|:,lat|:,lon|:,year|i:nyear-1))
		
  end do	
		
  reg!0					= "level"
  reg&level				= var_monave&level  
  reg!1					= "lat"
  reg&lat				= var_monave&lat
  reg!2					= "lon"
  reg&lon				= var_monave&lon
  reg!3					= "lead"
  reg&lead			    = ispan(-1*maxy_flag,maxy_flag,1)*1.0
  reg@long_name			= "Regression--Ts lead var. If lead dimension is negative, Ts lag var"   
  
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

  cor_plot_area			= cor_plot({level|lvl},{lat|latmin:latmax},{lon|lonmin:lonmax},lead|:)
  var_plot_area			= var_plot({level|lvl},{lat|latmin:latmax},{lon|lonmin:lonmax},lead|:)
  
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
  sres@tiMainString			= abs(monmin)+ " - " + monmax + "."+ lvl +" hPa." + varname + "."+ymstar/100+ " - " +ymend/100
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
	 plot								= gsn_csm_contour_map_overlay(wks,var_plot({lvl},:,:,i),cor_plot({lvl},:,:,i),sres,res)
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
  sres@cnLevels		        = ispan(-16,16,4)/2
  ;sres@cnFillColors			= (/2,4,5,7,8,12,13,14,15,17/)
  ;sres@cnFillPalette="ViBlGrWhYeOrRe"

  sres@gsnSpreadColors		= True
  sres@gsnSpreadColorStart	= 2 
  sres@gsnSpreadColorEnd	= 19 

  ; ; Resources for colorbar
  ; sres@lbOrientation			= "Vertical"
  ; sres@lbLabelBarOn				= True
  ; sres@pmLabelBarOrthogonalPosF	= 0.01
  ; sres@pmLabelBarParallelPosF	= 0.5
  ; sres@pmLabelBarWidthF			= 0.06
  ; sres@pmLabelBarHeightF		= 0.35

    ; Resources for colorbar
    sres@lbOrientation			= "horizontal"
    sres@lbLabelBarOn				= True
    sres@pmLabelBarOrthogonalPosF	= 0.11
   ; sres@pmLabelBarParallelPosF	= 0.5
    sres@pmLabelBarWidthF			= 0.55
    sres@pmLabelBarHeightF		= 0.06
 
  ; Resources for map
  sres@mpCenterLonF			= 180
  sres@mpMinLatF			= latmin
  sres@mpMaxLatF			= latmax
  sres@mpMinLonF			= lonmin
  sres@mpMaxLonF			= lonmax
 
     ;-----resource for China map 
sres@mpDataSetName = "/mnt/e/nclstudy/nclscripts/Earth..4"
sres@mpDataBaseVersion = "MediumRes" ; or "Ncarg4_1"
;sres@mpOutlineOn = True
;sres@mpOutlineSpecifiers = (/"China","China:Provinces"/)
sres@mpOutlineSpecifiers = (/"China:Yunnan"/)
sres@mpGeophysicalLineColor = "black"
;sres@mpOutlineBoundarySets = "NoBoundaries"
;sres@Geophysical = "NoBoundaries"
;sres@mpNationalLineThicknessF = 2.0
sres@mpFillAreaSpecifiers = (/"land","water","China"/)
sres@mpSpecifiedFillColors = (/"white","white","transparent"/)
sres@mpFillDrawOrder = "Draw"

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
  sres@gsnLeftStringFontHeightF  =1.2 *  font_height
  sres@gsnRightStringFontHeightF  =1.2 *  font_height

; sres@gsnRightString		= "~S~o~N~C"
  sres@gsnLeftStringOrthogonalPosF	= 0.01
  sres@tiMainString			= ""
  sres@tiMainOffsetYF 		= -0.01
  sres@gsnRightStringOrthogonalPosF	= -0.0
;  sres@tmXBValues		= (/30,60,90,120/)
;  sres@tmXBLabels		= (/"30~S~o~N~E","60~S~o~N~E","90~S~o~N~E","120~S~o~N~E"/)
;  sres@tmYLValues		= (/-60,-30,0,30/)
;  sres@tmYLLabels		= (/"60~S~o~N~S","30~S~o~N~S","Eq","30~S~o~N~N"/)
;  sres@tmXBMinorValues		= ispan(40,120,10)
;  sres@tmYLMinorValues		= ispan(-60,30,10)
  sres@tmXBMinorOn	= False
  sres@tmYLMinorOn	= False
  sres@tmYROn		= False
  sres@tmXTOn		= False

  
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
  
  res@cnFillOn					= True
  res@cnLinesOn					= False
  res@cnLineLabelsOn			= False
  res@cnInfoLabelOn    			= False
  res@cnMonoFillPattern			= False
  
  res@cnFillPatterns			= (/17,-1,17/)
  res@cnFillDotSizeF			= 0.008
  res@cnFillScaleF=2.5
  res@cnLevelSelectionMode		= "ExplicitLevels"
  res@cnFillColors=(/"black","white","black"/)
  res@gsnAddCyclic					= False



  ;do i=0,2*maxy_flag
  i=1
	 res@cnLevels				= (/-1.0*rflag(i,1),rflag(i,1)/)
	 sres@gsnLeftString			= LS
   sres@gsnMajorLatSpacing = 10
   sres@gsnRightString    = RS
   sres@gsnCenterString=  ""
   sres@gsnMajorLatSpacing	= 10
   sres@gsnLeftStringOrthogonalPosF	= 0.01
   ;sres@gsnLeftStringFontHeightF  = 0.02
   sres@gsnRightStringOrthogonalPosF	= 0.0
   ;sres@gsnRightStringFontHeightF  = 0.02
	 wks                 		= gsn_open_wks(plottype,plotdir+setup_name)
	 gsn_define_colormap(wks,"BlueDarkRed18")
	 nc 						= NhlNewColor(wks,0.83,0.83,0.83)
;var_plot=(/var_plot*10^7/);vo
;var_plot=(/var_plot*10^5/);q
;var_plot=(/var_plot*10^5/);vo
     plot						= gsn_csm_contour_map_overlay(wks,var_plot({lvl},:,:,i),cor_plot({lvl},:,:,i),sres,res)

	    ;================================================================
  y_swc           = (/21.,21.,29.,29.,21./)
  x_swc           = (/97.,107.,107.,97.,97./) 

   y_swc1           = (/28.,28.,33.,33.,28./)
   x_swc1           = (/60.,70.,70.,60.,60./) 

  resk=True
  resk@gsFillColor  =57
  resk@gsLineThicknessF = 4.0
  resk@gsLineDashPattern = 0
  resk@gsLineColor  = "Purple"
  resk@cnFillDrawOrder ="PostDraw"
  dum1= gsn_add_polyline(wks, plot(0), x_swc , y_swc, resk)
  resk@gsLineColor  = "black"
 ; dum2 = gsn_add_polyline(wks, plot(0), x_swc1 , y_swc1, resk)
  ;resk@gsLineColor  = "green"
  ;dum3 = gsn_add_polyline(wks, plot(0), x_swc2 , y_swc2, resk)


if season .eq."JJA"

; Resources for shaded Plo
sres=True
  ; Resources for colorbar
  sres@lbLabelBarOn		= True
  sres@lbOrientation		= "vertical"
  sres@pmLabelBarOrthogonalPosF	= 0.05
  sres@pmLabelBarParallelPosF	= 0.5
  sres@pmLabelBarWidthF		= 0.06
  sres@pmLabelBarHeightF	= 0.35
 
  ; Resources for map
  sres@mpCenterLonF		= 180
  sres@mpMinLatF		= latmin
  sres@mpMaxLatF		= latmax
  sres@mpMinLonF		= lonmin
  sres@mpMaxLonF		= lonmax
  sres@gsnMajorLatSpacing=10
   ;-----resource for China map 
sres@mpDataSetName = "/mnt/e/nclstudy/nclscripts/Earth..4"
sres@mpDataBaseVersion = "MediumRes" ; or "Ncarg4_1"
sres@mpOutlineOn = True
;sres@mpOutlineSpecifiers = (/"China","China:Provinces"/)
sres@mpOutlineSpecifiers = (/"China:Yunnan"/)
sres@mpGeophysicalLineColor = "black"
;sres@mpOutlineBoundarySets = "NoBoundaries"
sres@mpNationalLineThicknessF = 2.0
sres@mpFillAreaSpecifiers = (/"land","water","China"/)
sres@mpSpecifiedFillColors = (/"white","white","transparent"/)

  sres@mpFillOn			=  False
  sres@gsnAddCyclic		= False

 ; Resources for Axis
  font_height			= 0.018								       
  sres@tmYLLabelFontHeightF	= font_height
  sres@tmXBLabelFontHeightF	= font_height
  sres@tiXAxisFontHeightF	= 1.2 * font_height
  sres@tiYAxisFontHeightF	= 1.2 * font_height
  sres@tiMainFontHeightF	= 1.2 * font_height

  sres@tmXBMinorOn		= False
  sres@tmYLMinorOn		= False
  sres@tmXTMinorOn		= False
  sres@tmYRMinorOn		= False
  sres@tmXTOn			= False
  sres@tmYROn			= False

;   sres@gsnRightString		= "~S~o~N~C"
 ; sres@tiMainString		= ""
 ; sres@gsnLeftString		= ""
  sres@gsnLeftStringOrthogonalPosF	= 0.02
  sres@gsnRightStringOrthogonalPosF	= 0.01
delete(sres)
  ;叠加位势高度原始场的特定等值线
  sres = True
  sres@gsnLeftString   = ""
  sres@gsnRightString   = ""
  sres@gsnFrame            = False
  sres@gsnDraw             = False
  sres@cnLineLabelsOn         =False
  sres@cnInfoLabelOn=False

    ;sres@gsnAddCyclic = False                             ; 如果你的数据已经处理过周期性边界，则设为False
    sres@cnLevelSelectionMode = "ExplicitLevels"
    if lvl .eq. 200 then
    sres@cnLevels = (/12540/)  
    sres@cnLineThicknessF= 4.0
    sres@cnMonoLineColor=False
    sres@cnLineColors = "Red"  
    sres@cnLineDashPattern=0
 
  plot1 = gsn_csm_contour(wks, xave3_sah,sres)
  overlay(plot,plot1)
  ;叠加位势高度原始场的特定等值线
  sres@gsnLeftString   = ""
  sres@gsnRightString   = ""
  sres@cnLineColors = "Green"  
  sres@cnLineDashPattern=16
  ;sres@gsnAddCyclic = False                             ; 如果你的数据已经处理过周期性边界，则设为False
  contour1 = gsn_csm_contour(wks, xave2_sah, sres)
  overlay(plot, contour1)
    ;叠加位势高度原始场的特定等值线
   sres@cnLineColors = "Blue"  
    sres@cnLineDashPattern=0
    sres@gsnAddCyclic = False                             ; 如果你的数据已经处理过周期性边界，则设为False
    contour2= gsn_csm_contour(wks, xave1_sah, sres)
    overlay(plot, contour2)
    end if

    if lvl .eq. 500 then
  ;叠加位势高度原始场的特定等值线
  sres@cnLevels = (/5870/) 
  sres@cnLineThicknessF= 4.0
  sres@cnMonoLineColor=False
  sres@cnLineColors = "Red"  
  sres@cnLineDashPattern=0
  contour3 = gsn_csm_contour(wks, xave3_wnpsh, sres)

  overlay(plot, contour3)
    ;叠加位势高度原始场的特定等值线
    sres@cnLineColors = "Green"  
    ;sres@gsnAddCyclic = False                             ; 如果你的数据已经处理过周期性边界，则设为False
    sres@cnLineDashPattern=16
    contour4= gsn_csm_contour(wks, xave2_wnpsh, sres)
    overlay(plot, contour4)
    
    ;叠加位势高度原始场的特定等值线
    sres@cnLineColors = "Blue"  
    sres@gsnAddCyclic = False                             ; 如果你的数据已经处理过周期性边界，则设为False
    sres@cnLineDashPattern=0
    contour5= gsn_csm_contour(wks, xave1_wnpsh, sres)
    overlay(plot, contour5)
end if
 end if
 	     ;地形遮罩
        pres = True
        ;pres@gsnPanelLabelBar = False
        filename = "/mnt/e/westsouth/data/tibetan_shp/tibetan.shp"
        pres@gsLineColor = "gainsboro"
        pres@gsLineThicknessF = 2
        pres@gsEdgesOn = True;True
        pres@gsFillColor = "white";grey70;white
        pres@cnFillDrawOrder ="PreDraw"
    
        if lvl .eq. 850 then
        terrain1 = gsn_add_shapefile_polygons(wks,plot,filename,pres) 
        end if 
        pres = True
        ;pres@gsnPanelLabelBar = False
        filename = "/mnt/e/westsouth/data/tibetan_shp/tibetan.shp"
        pres@gsLineColor = "black"
        pres@gsLineThicknessF = 3
        pres@cnFillDrawOrder ="Draw"
      
        ;terrain1 =  gsn_add_shapefile_polylines(wks,plot,filename,pres) 
     
draw(plot)
 
     frame(wks)
	 
  ;end do 
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
  sres@tiMainString			= abs(monmin)+ " - " + monmax + "."+ lvl +" hPa." + varname + "."+ymstar/100+ " - " +ymend/100
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
  ;res@cnLineLabelPlacementMode="Constant"
  res@cnLevelSelectionMode		= "ExplicitLevels"
  ;res@cnLevels					= ispan(-10,10,4)/100.0
  ;res@cnLevelSpacingF = 0.04
  res@gsnContourNegLineDashPattern	= 5
  ;res@gsnContourZeroLineThicknessF	= 0.0
  res@gsnAddCyclic					= False
  
  do i=0,2*maxy_flag
  
	 sres@cnLevels					= (/-1.0*rflag(i,1),-1.0*rflag(i,0),rflag(i,0),rflag(i,1)/)
     sres@gsnLeftString				= "lead-"+i_flag(i)
	 wks                 			= gsn_open_wks(plottype,plotdir+plotname+".lead"+i_flag(i))
	 gsn_define_colormap(wks,"BlueDarkRed18")
	 nc 							= NhlNewColor(wks,0.83,0.83,0.83)
	 plot							= gsn_csm_contour_map_overlay(wks,cor_plot({lvl},:,:,i),var_plot({lvl},:,:,i),sres,res)
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
  sres@tiMainString			= abs(monmin)+ " - " + monmax + "."+ lvl +" hPa." + varname + "."+ymstar/100+ " - " +ymend/100
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
	 plot							= gsn_csm_contour_map_overlay(wks,var_plot({lvl},:,:,i),var_plot({lvl},:,:,i),sres,res)
     draw(plot)
     frame(wks)
     
  end do
   
end if
;&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
 
end  