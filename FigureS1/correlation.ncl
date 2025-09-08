load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "/mnt/e/mytool.ncl"

begin

;**********************************************************************
  ;Options for user
  var_dat1		= "ERA5"
  varname1		= "skt" 
  filedir1		= "/mnt/e/westsouth/data/"
  filename1		= "ERA5.mon.skin_temperature.1950-2022.nc"
  
  var_dat2		= "ERA5"
  varname2		= "swvl1" 
  filedir2		= "/mnt/e/westsouth/data/"
  filename2		= "ERA5.mon.volumetric_soil_water_layer_1.1950-2022.nc";"ERA5.mon.volumetric_soil_water_layer_1.1950-2022.nc";ERA5.mon.evaporation.1950-2022
    ;ERA5.mon.skin_temperature.1950-2022
  ymstar		= 198001
  ymend			= 202012
  
  dtrend_flag	= 1			; 0 for raw,else for detrend

  
  latmin	= 20			;area range
  latmax	= 35
  lonmin	= 50
  lonmax	= 80
  
  monmin	= 3	;starting month for averaging,(monmin != 0,-12 <= monmin <= monmax <=12). negative value for previou year(year(-1)) 
  monmax	= 5	;ending month for averaging,	   1<= monmax <= 12 
	      		      
  months	= (/"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"/)
 
  ;options for output  
  plottype	= "pdf"                 ;type of plotting
  plotdir	= "./"
  plotname	= varname1+"_and_"+varname2+"_"+monmin+"_"+monmax
  savedir	= "./"
  savename	=  varname1+"_and_"+varname2+"_"+monmin+"_"+monmax
;**********************************************************************
;Handle variable
;**********************************************************************
  ;read time series
  f1			= addfile(filedir1+filename1,"r")
  tim		= f1->time
  u_time_DATE	= cd_calendar(tim,-1)
  tstar		= ind(u_time_DATE .eq. ymstar)
  tlast		= ind(u_time_DATE .eq. ymend)
  print(tstar)
  print(tlast) 
 
  ;read variable 
  f2			= addfile(filedir2+filename2,"r")
  tim		= f2->time
  u_time_DATE	= cd_calendar(tim,-1)
  tstar		= ind(u_time_DATE .eq. ymstar)
  tlast		= ind(u_time_DATE .eq. ymend)
  print(tstar)
  print(tlast)  
  
  var1		= short2flt(f1->$varname1$(tstar:tlast,{latmin:latmax},{lonmin:lonmax}))
  var1!0		= "time"
  var1!1		= "lat"
  var1!2		= "lon"
  printVarSummary(var1)
  var_monave1		= month_to_monave(var1,monmin,monmax)
 ; var_monave1=[var_monave1*-1]
  printVarSummary(var_monave1)
  nyear				= dimsizes(var_monave1&year)
  ny				= dimsizes(var_monave1&lat)
  nx				= dimsizes(var_monave1&lon)
 
  var2		= short2flt(f2->$varname2$(tstar:tlast,{latmin:latmax},{lonmin:lonmax}))
  var2!0		= "time"
  var2!1		= "lat"
  var2!2		= "lon"
  printVarSummary(var2)
  var_monave2		= month_to_monave(var2,monmin,monmax)
  printVarSummary(var_monave2)

  ;detrend or not
  if dtrend_flag .eq. 0 
	 var_monave1			= var_monave1
     var_monave1@detrend	= dtrend_flag +"--(0 for raw data, else for detrended data)" 
    var_monave2			= var_monave2
    var_monave2@detrend	= dtrend_flag +"--(0 for raw data, else for detrended data)"

  else
     var_monave1            = (/dtrend_msg_n(ispan(1,nyear,1),var_monave1,False,True,0)/)
     var_monave1@detrend    = dtrend_flag +"--(0 for raw data, else for detrended data)"
      var_monave2            = (/dtrend_msg_n(ispan(1,nyear,1),var_monave2,False,True,0)/)
      var_monave2@detrend    = dtrend_flag +"--(0 for raw data, else for detrended data)"
  
  end if
  printVarSummary(var_monave1)
  printVarSummary(var_monave2)
  ;Correlation or Regression  
  
  ;Correlation
  cor		= escorc(var_monave1(lat|:,lon|:,year|:),var_monave2(lat|:,lon|:,year|:))
  printVarSummary(cor)
 

  cor!0				= "lat"
  cor&lat				= var_monave1&lat
  cor!1					= "lon"
  cor&lon				= var_monave1&lon

  cor@long_name			= "Corrrelation" 
		
  ;Regression 
  
  ;Critical t value and correlation coefficients for 0.10,0.05 and 0,01
  
  tValue				= new((/3/),"float")				
  rflag					= new((/3/),"float")
  
  
        n				= nyear
		tValue		= cdft_t((/1-0.05,1-0.025,1-0.005/),(/n-2,n-2,n-2/))
		rflag	= sqrt(tValue^2/(n-2+tValue^2))
  rflag					= round(rflag*100.0,0)/100.0		;round the float data
 print(tValue)
  print(rflag)
  ;write_matrix(tValue,"3f8.2",False)
 ; write_matrix(rflag,"3f8.2",False)
  
  cor@tValue			= tValue
  cor@tValue_desc		= "Critical t Value for 0.1,0.05,001 significant level"
  
  cor@rflag				= rflag
  cor@rflag_desc		= "Critical correlation for 0.1,0.05,001 significant level"
  
  printVarSummary(cor)
  ;printVarSummary(reg)
  
;**********************************************************************
;Saving data
;********************************************************************** 
  system("/bin/rm -f "+savedir+savename+".nc")
  fo            			= addfile(savedir+savename+".nc","c")
  filedimdef(fo,"time",-1,True)
  fo->cor					= cor
  ;fo->reg					= reg
  
;**********************************************************************
;Plotting
;**********************************************************************
  cor_plot				= cor
  var_plot				= cor

  cor_plot_area			= cor_plot({lat|latmin:latmax},{lon|lonmin:lonmax})
  var_plot_area			= var_plot({lat|latmin:latmax},{lon|lonmin:lonmax})
  
  printMinMax(cor_plot_area,True)
  printMinMax(var_plot_area,True)

  
;------------------------------------------------------------------------  

;########################################################################
; Resources for shaded Plot
  sres						= True
  sres@gsnFrame				= False
  sres@gsnDraw				= False
  
  sres@cnFillOn				= True
  sres@cnLinesOn			= False
  sres@cnLineLabelsOn		= False
  sres@cnInfoLabelOn		= False
  sres@cnLevelSelectionMode	= "ExplicitLevels"
  ;sres@cnLevels		        = ispan(-10,10,2)/10.
  sres@cnLevels		        = (/-1,-0.9,-0.8,-0.7,0,0.7,0.8,0.9,1/)
 ; sres@cnFillColors			= (/2,4,5,7,8,12,13,14,15,17/)
  sres@gsnSpreadColors		= True
  sres@gsnSpreadColorStart	= 2 
  sres@gsnSpreadColorEnd	= 19

  ; Resources for colorbar
  sres@lbOrientation			= "Vertical"
  sres@lbLabelBarOn				= True
  sres@pmLabelBarOrthogonalPosF	= 0.1
  sres@pmLabelBarParallelPosF	= 0.5
  sres@pmLabelBarWidthF			= 0.06
  sres@pmLabelBarHeightF		= 0.35
 

  ; Resources for map
  sres@mpCenterLonF			= 180
  sres@mpMinLatF			= latmin
  sres@mpMaxLatF			= latmax
  sres@mpMinLonF			= lonmin
  sres@mpMaxLonF			= lonmax
 
  sres@mpDataSetName = "/mnt/e/nclstudy/nclscripts/Earth..4"
sres@mpDataBaseVersion = "MediumRes" ; or "Ncarg4_1"
;sres@mpOutlineOn = True
;sres@mpOutlineSpecifiers = (/"China","China:Provinces"/)
sres@mpOutlineSpecifiers = (/"China:Yunnan","Pakistan"/)
sres@mpGeophysicalLineColor = "black"
;sres@mpOutlineBoundarySets = "NoBoundaries"
;sres@Geophysical = "NoBoundaries"
;sres@mpNationalLineThicknessF = 2.0
sres@mpFillAreaSpecifiers = (/"land","water"/)
sres@mpSpecifiedFillColors = (/"transparent","white"/)
sres@mpFillDrawOrder = "PostDraw"

  sres@mpFillOn				= True
  sres@mpLandFillColor		= 20
  sres@mpOutlineOn			= True
  sres@mpGeophysicalLineColor	= "blue"
  sres@gsnAddCyclic			= False
  sres@mpOceanFillColor="white"

  ;sres@mpLandFillColor     = "transparent"
 ; Resources for Axis
  font_height				= 0.022								       
  sres@tmYLLabelFontHeightF	= font_height
  sres@tmXBLabelFontHeightF	= font_height
  sres@tiXAxisFontHeightF	= 1.2 * font_height
  sres@tiYAxisFontHeightF	= 1.2 * font_height
  sres@tiMainFontHeightF	= 1.2 * font_height
  sres@gsnLeftStringFontHeightF  = 1.2*font_height
  sres@gsnRightStringFontHeightF  = 1.2*font_height

; sres@gsnRightString		= "~S~o~N~C"
  sres@gsnLeftStringOrthogonalPosF	= 0.01
  sres@gsnRightStringOrthogonalPosF	= 0.02
  sres@tiMainString			= ""
  sres@tiMainOffsetYF 		= 0.02

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
  res@cnFillDotSizeF			= 0.008
  res@cnFillScaleF=1.5
  res@cnLevelSelectionMode		= "ExplicitLevels"
  res@cnFillColors=(/"black","white","black"/)

  
  res@gsnAddCyclic					= False
  
  
	 res@cnLevels				= (/-1.0*rflag(1),rflag(1)/)
	 sres@gsnLeftString			= "(c) Corr. (skt"+" and "+"swvl)"
   sres@gsnRightString			= "MAM"
	 wks                 		= gsn_open_wks(plottype,plotdir+plotname)
	 gsn_define_colormap(wks,"BlueDarkRed18")
	 nc 						= NhlNewColor(wks,0.83,0.83,0.83)
     plot						= gsn_csm_contour_map_overlay(wks,var_plot(:,:),cor_plot(:,:),sres,res)
 
  
            ;;-------------------------------------------------------------
            y           =(/28.,28.,33.,33.,28./)
            x           = (/60.,73.,73.,60.,60./) ;;NINO34

  y2           = (/10.,10.,25.,25.,10./)
  x2           = (/95.,106.,106.,95.,95./) 

  y3           =(/5.,5.,25.,25.,5./)
  x3           = (/45.,90.,90.,45.,45./) ;;NIOS
    resk=True
    resk@gsFillColor  =57
    resk@gsLineThicknessF = 4.0
    resk@gsLineDashPattern =0
    resk@gsLineColor  = "black"
    resk@cnFillDrawOrder ="PostDraw"
  ;;--------------------------------------------------------------------------------
  dum1=gsn_add_polyline(wks,plot, x, y, resk)
  resk@gsLineColor  = "red"
  ;dum2=gsn_add_polyline(wks,plot, x2, y2, resk)
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
     

     
end  
