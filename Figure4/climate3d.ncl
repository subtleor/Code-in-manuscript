load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "/mnt/e/mytool.ncl"
begin
;**********************************************************************
;A script calculating Correlation or Regresssion coefficients for monthal 3-Dimension vector field

;Plot the a prescribed statistic by cor_reg_flag( User should adjust the cnLevels and cnFillColors accroding to different statistics) 
;**********************************************************************
;user can select:

;				 1��Correlation or Regression

;				 2��detrend or not for each month

;                3��lead or lag time 

;                4��different plot for significant level
;**********************************************************************
;Options for user
;**********************************************************************

lvl 		= "WVT"

ts_ys			= 1980			;ts start year 
ts_ye			= 2020			;ts end year 

varname		= "q"

var_dat		= "ERA5"
varname_x		= "uq" 
filedir_x		=  "/mnt/e/westsouth/data/"
filename_x	= "ERA5.uq.mon.mean.195001_202212.nc"
 
varname_y		= "vq" 
filedir_y		= "/mnt/e/westsouth/data/"
filename_y	= "ERA5.vq.mon.mean.195001_202212.nc" 
 

dtrend_flag	= 1		; 0 for raw,else for detrend
  ymstar		= 198001
  ymend			= 202012

  
  latmin	=  0
  latmax	=  40
  lonmin	=  70
  lonmax	=  130
  season="JJA"
  setup_name  = season+"_"+lvl+"_ave "
  monmin	= 6;starting month for averaging,(monmin != 0,-12 <= monmin <= monmax <=12). negative value for previou year(year(-1)) 
  monmax	= 8	;ending month for averaging,	   1<= monmax <= 12 
  
  months	= (/"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"/)
 
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

  ;read variable 
  f				= addfile(filedir_x+filename_x,"r")
  tim			= f->time
  u_time_DATE	= cd_calendar(tim,-1)
  tstar		= ind(u_time_DATE .eq. ymstar)
  tlast		= ind(u_time_DATE .eq. ymend)
  print(tstar)
  print(tlast)  
  
  
  varx			= short2flt(f->$varname_x$(tstar:tlast,{latmin:latmax},{lonmin:lonmax}))
  varx!0		= "time"
  
  varx!1		= "lat"
  varx!2		= "lon"
  printVarSummary(varx)
  delete([/tim,u_time_DATE/])

  f				= addfile(filedir_y+filename_y,"r")
  tim			= f->time
  u_time_DATE	= cd_calendar(tim,-1)
  tstar		= ind(u_time_DATE .eq. ymstar)
  tlast		= ind(u_time_DATE .eq. ymend)
  print(tstar)
  print(tlast)  
  
  vary			= short2flt(f->$varname_y$(tstar:tlast,{latmin:latmax},{lonmin:lonmax}))
  vary!0		= "time"

  vary!1		= "lat"
  vary!2		= "lon"
  printVarSummary(vary)
  
  
  varx_monave	= month_to_monave(varx,monmin,monmax)
  printVarSummary(varx_monave)
  
  vary_monave	= month_to_monave(vary,monmin,monmax)
  printVarSummary(vary_monave)
  
  varm_monave	= sqrt(varx_monave^2+vary_monave^2)
  copy_VarCoords(varx_monave,varm_monave)
  varm_monave@long_name	= "sqrt(varx_monave^2+vary_monave^2)"
  printVarSummary(varm_monave)
  
  nyear		= dimsizes(varx_monave&year)
  ny		= dimsizes(varx_monave&lat)
  nx		= dimsizes(varx_monave&lon)
    
  ;detrend or not
  if dtrend_flag .eq. 0 
   

	 
	 varx_monave			= varx_monave
     varx_monave@detrend= dtrend_flag +"--(0 for raw data, else for detrended data)" 
     
	 vary_monave			= vary_monave
     vary_monave@detrend= dtrend_flag +"--(0 for raw data, else for detrended data)" 
	 
	 varm_monave			= varm_monave
     varm_monave@detrend= dtrend_flag +"--(0 for raw data, else for detrended data)" 
	 
  else
     				

	 
	 varx_monave			= (/dtrend_msg_n(ispan(1,nyear,1)*1.0,varx_monave,False,True,0)/) 
     varx_monave@detrend	= dtrend_flag +"--(0 for raw data, else for detrended data)" 
	 
	 vary_monave			= (/dtrend_msg_n(ispan(1,nyear,1)*1.0,vary_monave,False,True,0)/) 
     vary_monave@detrend	= dtrend_flag +"--(0 for raw data, else for detrended data)" 
	 
	 varm_monave			= (/dtrend_msg_n(ispan(1,nyear,1)*1.0,varm_monave,False,True,0)/) 
     varm_monave@detrend	= dtrend_flag +"--(0 for raw data, else for detrended data)" 
  
  end if

  printVarSummary(varx_monave)
  printVarSummary(vary_monave)
  printVarSummary(varm_monave)

  u=dim_avg_n_Wrap(varx_monave(:,:,:),0)
  v=dim_avg_n_Wrap(vary_monave(:,:,:),0)
  w=dim_avg_n_Wrap(varm_monave(:,:,:),0)
  printVarSummary(u)

  varx_plot		= u({lat|latmin:latmax},{lon|lonmin:lonmax})
  vary_plot		= v({lat|latmin:latmax},{lon|lonmin:lonmax})
 
  printMinMax(varx_plot,True)
  printMinMax(vary_plot,True)
  

  
;------------------------------------------------------------------------  
  res			= True
  res@gsnFrame	= False
  res@gsnDraw	= False  
  
  ;Resources for Contour 
 
  res@gsnScalarContour	= True		;required for contour
  res@lbLabelBarOn		= False

  ;Resources for map
  res@mpMinLonF		= lonmin
  res@mpMaxLonF		= lonmax
  res@mpMinLatF		= latmin
  res@mpMaxLatF		= latmax

     ;-----resource for China map 
res@mpDataSetName = "/mnt/e/nclstudy/nclscripts/Earth..4"
res@mpDataBaseVersion = "MediumRes" ; or "Ncarg4_1"
;sres@mpOutlineOn = True
;sres@mpOutlineSpecifiers = (/"China","China:Provinces"/)
res@mpOutlineSpecifiers = (/"China:Yunnan"/)
res@mpGeophysicalLineColor = "black"
;sres@mpOutlineBoundarySets = "NoBoundaries"
;sres@Geophysical = "NoBoundaries"
;sres@mpNationalLineThicknessF = 2.0
res@mpFillAreaSpecifiers = (/"land","water","China"/)
res@mpSpecifiedFillColors = (/"white","white","transparent"/)
res@mpFillDrawOrder = "Draw"

  res@mpCenterLonF	= 180
  res@mpGeophysicalLineColor		= "black"
  res@mpGeophysicalLineThicknessF	= 1.0
  res@mpFillOn		= False
  res@gsnAddCyclic	= False 

  font_height			= 0.02								       
  res@tmYLLabelFontHeightF	= font_height
  res@tmXBLabelFontHeightF	= font_height
  res@tiXAxisFontHeightF	= 1.2 * font_height
  res@tiYAxisFontHeightF	= 1.2 * font_height
  res@tiMainFontHeightF		= 1.2 * font_height
  res@gsnLeftStringFontHeightF  = 1.2 * font_height
  ;res@gsnRightString		= "~S~o~N~C"
  res@gsnLeftStringOrthogonalPosF	= 0.01	;vcRefAnnoOrthogonalPosF+1.0
  res@gsnRightStringOrthogonalPosF=0.01
  res@tiMainString			= ""
  res@tiMainOffsetYF 		= 0

;  res@tmXBValues		= (/30,60,90,120/)
;  res@tmXBLabels		= (/"30~S~o~N~E","60~S~o~N~E","90~S~o~N~E","120~S~o~N~E"/)
;  res@tmYLValues		= (/-60,-30,0,30/)
;  res@tmYLLabels		= (/"60~S~o~N~S","30~S~o~N~S","Eq","30~S~o~N~N"/)
;  res@tmXBMinorValues		= ispan(40,120,10)
;  res@tmYLMinorValues		= ispan(-60,30,10)

  res@tmXBMinorOn	= False
  res@tmYLMinorOn	= False
  res@tmYROn		= False
  res@tmXTOn		= False
  
  res@tmXBMajorLengthF			= 0.004
  res@tmXBMajorOutwardLengthF	= 0.004
  res@tmXBLabelDeltaF			= -0.5
  res@tmYLMajorLengthF			= 0.004
  res@tmYLMajorOutwardLengthF	= 0.004
  res@tmYLLabelDeltaF			= -0.5
  
;  res@vpHeightF	= 0.8
;  res@vpWidthF		= 0.7
;  res@vpXF			= 0.1
;  res@vpYF			= 0.9
  
  ;Resource for vector
  res@vcRefMagnitudeF			= 150
  res@vcRefLengthF				= 0.045
  res@vcMinDistanceF			= 0.022
  res@vcMagnitudeFormat			= "@*+^sg"
  res@vcRefAnnoOn				= True	
  res@vcRefAnnoOrthogonalPosF	= -1
  ;res@vcRefAnnoBackgroundColor 	= -1
  res@vcRefAnnoPerimOn			= True
  res@vcGlyphStyle				= "CurlyVector"
  res@vcLineArrowColor			= "Black"
  res@vcLineArrowThicknessF		= 1.2
  res@vcVectorDrawOrder			= "PreDraw"
  res@vcRefAnnoString1On    = True
  res@vcRefAnnoString2On   = False
 
  ;do i=0,2*maxy_flag
    font_height			= 0.018								       
    res@tmYLLabelFontHeightF	= font_height
    res@tmXBLabelFontHeightF	= font_height
    res@tiXAxisFontHeightF	= 1.2 * font_height
    res@tiYAxisFontHeightF	= 1.2 * font_height
    res@tiMainFontHeightF		= 1.2 * font_height
    res@gsnLeftStringFontHeightF  = 1.2 * font_height

	 res@gsnLeftString			= "(d) Clm.WVT"
   res@gsnCenterString=""
   	 res@gsnRightString			= "JJA(0)"

	 wks                 		= gsn_open_wks(plottype,plotdir+plotname)
   gsn_define_colormap(wks,"BlueDarkRed18")
	 nc 						= NhlNewColor(wks,0.83,0.83,0.83) ;add a named color
     plot	= gsn_csm_vector_map(wks,varx_plot(:,:),vary_plot(:,:),res)

       ;;;--------------------------------------------------------------------
  y_swc           = (/21.,21.,29.,29.,21./)
  x_swc           = (/97.,107.,107.,97.,97./) 

  ; y_swc           = (/40.,40.,60.,60.,40./)
  ; x_swc           = (/0.,35.,35.,0.,0./) 
  resk=True
  resk@gsFillColor  =57
  resk@gsLineThicknessF = 4.0
  resk@gsLineDashPattern = 0
  resk@gsLineColor  = "purple"
  resk@cnFillDrawOrder ="PostDraw"
  dum = gsn_add_polyline(wks, plot, x_swc , y_swc, resk)

	     ;地形遮罩
       pres = True
       ;pres@gsnPanelLabelBar = False
       filename = "/mnt/e/westsouth/data/tibetan_shp/tibetan.shp"
       pres@gsLineColor = "gainsboro"
       pres@gsLineThicknessF = 2
       pres@gsEdgesOn = True;True
       pres@gsFillColor = "white";grey70;white
       pres@cnFillDrawOrder ="Draw"
   
       if lvl .eq. 850 then
       terrain1 = gsn_add_shapefile_polygons(wks,plot,filename,pres) 
       end if 
       draw(plot)
       frame(wks)
  ;end do 



;------------------------------------------------------------------------

;######################################################################
end  