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
  ts_dat		= "TS1"
  ts_name		= "TS1"
  ts_filedir	="/mnt/e/westsouth/data/"
  ts_filename	= "output1.txt"

  lv_filename="nino34_MAM.txt"
  ts_ys			= 1980			;ts start year 
  ts_ye			= 2020			;ts end year 
  
  var_dat		= "ERA5"
  varname		= "swvl1" 
  filedir		= "/mnt/e/westsouth/data/"
  filename		= "ERA5.mon.volumetric_soil_water_layer_1.1950-2022.nc";total_flux_at_surface;"ERA5.mon.surface_latent_heat_flux.1950-2022.nc";"ERA5.mon.volumetric_soil_water_layer_1.1950-2022.nc"
  ;cru_ts4.05.1901.2020.pre.dat.nc;ERA5.advect.T_int_500-700(detrend).Jan-Dec.1980-2020；ERA5.mon.snow_cover.1950-2022

  setup_name  = "TS1 vs "+varname
  ymstar		= 198001
  ymend			= 202012
  
  cor_reg_flag	= "reg"		; "cor" or "reg"
  dtrend_flag	= 1		; 0 for raw,else for detrend
  maxy_flag		= 1			; years for lead or lag the currnet year(Y(0))   
  plot_flag		= 1	; 0 for contour,1 for dot Shaded,2 for color shaded,3 for only significant area plot 
  lv_flag  =0;1 for lv,0 for ts 
;----------Attention!!! plot_flag = 3 only for correlation and the cnlevel should be altered by yourself!!!------ 

latmin	=  20;10;0
latmax	=  35;30;50
lonmin	=  50;90;;45
lonmax	=  80;120;130

  
  monmin	=3;starting month for averaging,(monmin != 0,-12 <= monmin <= monmax <=12). negative value for previou year(year(-1)) 
  monmax	=5;ending month for averaging,	   1<= monmax <= 12 
  title_name	= "(a) Reg"+". swvl"+ " on "+ts_name; lv nino34_MAM"
  season="MAM(0)"
  months	= (/"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"/)
 
  ;options for output  
  plottype	= "pdf"                 ;type of plotting
  plotdir	= "./"
  plotname	= ts_name+"-"+ts_name+"."+cor_reg_flag+"."+var_dat+"-"+varname+".monave"+abs(monmin)+"-"+monmax+ \
              ".dtrend"+dtrend_flag +".plot"+plot_flag+"."+ymstar/100+"-"+ymend/100
  savedir	= "./"
  savename	= ts_name+"-"+ts_name+".cor_reg."+var_dat+"-"+varname+".monave"+abs(monmin)+"-"+monmax+ \
			  ".dtrend"+dtrend_flag+"."+ymstar/100+"-"+ymend/100
if lv_flag .eq. 1 then
  savename	= ts_name+"-"+ts_name+"_lv_"+lv_filename+".cor_reg."+var_dat+"-"+varname+".monave"+abs(monmin)+"-"+monmax+ \
  ".dtrend"+dtrend_flag+"."+ymstar/100+"-"+ymend/100
  plotname	= ts_name+"-"+ts_name+"_lv_"+lv_filename+"."+cor_reg_flag+"."+var_dat+"-"+varname+".monave"+abs(monmin)+"-"+monmax+ \
  ".dtrend"+dtrend_flag +".plot"+plot_flag+"."+ymstar/100+"-"+ymend/100
end if
;**********************************************************************
;Handle variable
;**********************************************************************
  ;read time series
  Ts_init		= asciiread(ts_filedir+ts_filename,ts_ye-ts_ys+1,"float")
  Ts_init!0		= "year"
  Ts_init&year	= ispan(ts_ys,ts_ye,1)
  printVarSummary(Ts_init)
  print(Ts_init)
  Ts			= Ts_init({year|ymstar/100:ymend/100})
  Ts=[Ts*-1]
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
  ;var=[var/86400.0]
 ;var=[var*-1.0]
  var!0		= "time"
  var!1		= "lat"
  var!2		= "lon"
  printVarSummary(var)

  var_monave		= month_to_monave(var,monmin,monmax)
  printVarSummary(var_monave)
  
  nyear				= dimsizes(var_monave&year)
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

     var_monave            = (/dtrend_msg_n(ispan(1,nyear,1),var_monave,False,True,0)/)
     var_monave@detrend    = dtrend_flag +"--(0 for raw data, else for detrended data)"

     if lv_flag .eq. 1 then
     var_monave            = (/dtrend_msg_n(lv,var_monave,False,True,0)/)
     var_monave@detrend    = dtrend_flag +"--(0 for raw data, else for detrended data)"
     Ts					= (/dtrend_msg_n(lv,Ts,False,True,0)/) 
	 Ts@detrend			= dtrend_flag +"--(0 for raw data, else for detrended data)" 
end if 

  end if
  printVarSummary(Ts)
  printVarSummary(var_monave)
  
  ;Correlation or Regression  
  
  ;Correlation
  cor_Ts_lead_var		= esccr(Ts,var_monave(lat|:,lon|:,year|:),maxy_flag);滞后？
  printVarSummary(cor_Ts_lead_var)
  
  cor_var_lead_Ts		= esccr(var_monave(lat|:,lon|:,year|:),Ts,maxy_flag)  
  printVarSummary(cor_var_lead_Ts)
  

  cor								= new((/ny,nx,2*maxy_flag+1/),"float")
  cor(:,:,0:maxy_flag)				= cor_var_lead_Ts(:,:,::-1)
  cor(:,:,maxy_flag+1:2*maxy_flag)	= cor_Ts_lead_var(:,:,1:maxy_flag)

  cor!0				= "lat"
  cor&lat				= var_monave&lat
  cor!1					= "lon"
  cor&lon				= var_monave&lon
  cor!2					= "lead"
  cor&lead			    = ispan(-1*maxy_flag,maxy_flag,1)*1.0
  cor@long_name			= "Corrrelation--Ts lead var. If lead dimension is negative, Ts lag var" 
		
  ;Regression 
  reg					= new((/ny,nx,2*maxy_flag+1/),"float")
  do i=0,maxy_flag
  
	reg(:,:,maxy_flag-i)	= regCoef(Ts(i:nyear-1),var_monave(lat|:,lon|:,year|0:nyear-i-1))			
    reg(:,:,maxy_flag+i)	= regCoef(Ts(0:nyear-i-1),var_monave(lat|:,lon|:,year|i:nyear-1))
		
  end do	

  reg!0					= "lat"
  reg&lat				= var_monave&lat
  reg!1					= "lon"
  reg&lon				= var_monave&lon
  reg!2					= "lead"
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

  cor_plot_area			= cor_plot({lat|latmin:latmax},{lon|lonmin:lonmax},lead|:)
  var_plot_area			= var_plot({lat|latmin:latmax},{lon|lonmin:lonmax},lead|:)
  
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
  sres@cnLevels		        = ispan(-5,5,1)/10.0
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
  ;sres@cnLevels		        = ispan(-600000,600000,150000)/2;sshf
 ; sres@cnLevels		        = ispan(-8,8,2)/1000.
  ;sres@cnLevels		        = ispan(-8,8,2)/2.
  sres@cnLevels		        = ispan(-20,20,5)/1000.
 ; sres@cnLevels		        = ispan(-20,20,5)/1000.
  ;sres@cnLevels		        = ispan(-8,8,2)/1000.
  ;sres@cnLevels		        = ispan(-8,8,2)/1000.
  ;sres@cnLevels		        = ispan(-12,12,3)/10.;res
 ;sres@cnLevels		        = ispan(-5,5,1) ;turang
 ;sres@cnLevels		        = ispan(-5,5,1)/200.;skt
   ; levels=(/-1e-05,-5e-06,-1e-06,0,1e-06,5e-06,1e-05/)
 ; sres@cnLevels		        = levels
  ;sres@cnLevels		        = ispan(-6,6,3)/100000.0
 ; sres@cnFillColors			= (/2,4,5,7,8,12,13,14,15,17/)
  sres@gsnSpreadColors		= True
  sres@gsnSpreadColorStart	= 2 
  sres@gsnSpreadColorEnd	= 19;pre12;bluedarkred18 19

  ; Resources for colorbar
  sres@lbOrientation			= "horizontal"
  sres@lbLabelBarOn				= True
  sres@pmLabelBarOrthogonalPosF	= 0.11
  ;sres@pmLabelBarParallelPosF	= 0.6
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

; sres@gsnRightString		= "~S~o~N~C"
  ;sres@gsnLeftStringOrthogonalPosF	= -0.0
  sres@tiMainString			= abs(monmin)+ " - " + monmax + "."+ varname + "." + ymstar/100+ " - " +ymend/100
  sres@tiMainOffsetYF 		= 0.03

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
  
  res@cnFillOn					= True
  res@cnLinesOn					= False
  res@cnLineLabelsOn			= False
  res@cnInfoLabelOn    			= False
  res@cnMonoFillPattern			= False
  
  res@cnFillPatterns			= (/17,-1,17/)
  ;res@cnFillDotSizeF			= 0.004
  res@cnFillDotSizeF			= 0.005
  res@cnFillScaleF=1.5
  res@cnLevelSelectionMode		= "ExplicitLevels"
  res@cnFillColors=(/"black","white","black"/)
  res@gsnAddCyclic					= False
  res@gsnMajorLatSpacing	= 5
  res@vpWidthF=0.6
  sres@vpWidthF=0.6

 ; do i=0,2*maxy_flag
  i=1
	 res@cnLevels				= (/-1.0*rflag(i,1),rflag(i,1)/)
	 sres@gsnLeftString			= title_name
   sres@gsnRightString    =season
   sres@gsnMajorLatSpacing	= 5
   sres@gsnLeftStringOrthogonalPosF	= 0.01
   sres@gsnLeftStringFontHeightF  = 1.2*font_height
   sres@gsnRightStringOrthogonalPosF	= 0.01
   sres@gsnRightStringFontHeightF  = 1.2*font_height
	 wks                 		= gsn_open_wks(plottype,plotdir+plotname+".lead"+i_flag(i))
	 gsn_define_colormap(wks,"bluedarkred18");CBR_drywet;BlueDarkRed18
   gsn_reverse_colormap(wks)
	nc 						= NhlNewColor(wks,0.83,0.83,0.83)
  ;var_plot=(/var_plot*10^(-4)/)
  ;var_plot=(/var_plot*10^(6)/)
  ;var_plot=(/var_plot*10^(4)/);e
  ;var_plot=(/var_plot*10^(2)/);tcc
  ;var_plot=(/var_plot*10^(2)/);swvl1
  plot						= gsn_csm_contour_map_overlay(wks,var_plot(:,:,i),cor_plot(:,:,i),sres,res)
   ;;-------------------------------------------------------------
  y           =(/28.,28.,33.,33.,28./)
  x           = (/60.,73.,73.,60.,60./) ;;NINO34

  y2           = (/5.,5.,25.,25.,5./)
  x2           = (/45.,90.,90.,45.,45./) 

  y3           =(/5.,5.,25.,25.,5./)
  x3           = (/45.,90.,90.,45.,45./) ;;NIOS
    resk=True
    resk@gsFillColor  =57
    resk@gsLineThicknessF = 4.0
    resk@gsLineDashPattern =0
    resk@gsLineColor  = "black"
    resk@cnFillDrawOrder ="Draw"
  ;;--------------------------------------------------------------------------------
  dum1=gsn_add_polyline(wks,plot(0), x, y, resk)
  resk@gsLineColor  = "blue"
  ;dum2=gsn_add_polyline(wks,plot(0), x2, y2, resk)
  resk@gsLineColor  = "green"
  ;dum3=gsn_add_polyline(wks,plot(0), x3, y3, resk)


  pres = True
  ;pres@gsnPanelLabelBar = False
  filename = "/mnt/e/westsouth/data/tibetan_shp/tibetan.shp"
  pres@gsLineColor = "black"
  pres@gsLineThicknessF = 3
  pres@cnFillDrawOrder ="Draw"

  terrain1 =  gsn_add_shapefile_polylines(wks,plot,filename,pres) 
  draw(plot)
  frame(wks)
  ;end do
;########################################################################
end if
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
