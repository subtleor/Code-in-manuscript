
 ;-------------------------------------------------------------------
 begin
 ;;------------------------------------------------------------------
undef("read_height_data")
function read_height_data(topo_file)
local nlat,nlon,topo_file,lat,lon
begin
nlat = 2160
nlon = 4320
setfileoption("bin","ReadByteOrder","BigEndian")
elev = tofloat(cbinread(topo_file,(/nlat,nlon/),"short"))

lat = fspan(90,-90,nlat)
lon = fspan(0,360,nlon)
lat!0 = "lat"
lon!0 = "lon"
lat@units = "degrees_north"
lon@units = "degrees_east"
lat&lat = lat
lon&lon = lon

elev!0 = "lat"
elev!1 = "lon"
elev&lat = lat
elev&lon = lon

return(elev)
end

;; Main code
;;---------------------------------------------------------------------

 plot = new(1, graphic)
 plot2 = plot
 path = "/mnt/e/westsouth/data/"
 path_ts="/mnt/e/westsouth/yunnan/essay1/"
 pathout = "./"
 f = addfile(path+"dTdt.TQ_anom_5terms.2021.ason.1000-10hPa_MAM.nc", "r")
 varname="Q1_Cp_anom"
 ts_name="EIP_SMI_MAM"
 area="ICP"
 Ts_filename  = "EIP_SMI_MAM.txt"
 lv_filename  = "nino34_MAM.txt"
 season="MAM"
 dtrend_flag  = 1
 t_ymstar	    = 198001
 t_ymend	      = 202012
 savename="poumian_q_TS1"
 
 latmin	= 28;20; 
 latmax	= 33;80;
 lonmin	= 50;0;
 lonmax	= 80;35;
 ;-----------------read Q----------------------
 q_raw	= short2flt(f->$varname$(:,:,{latmin:latmax},{lonmin:lonmax}))
 q_raw=[q_raw*86400]
 q_raw@units="K/day"
 printMinMax(q_raw,0)
 lv_flag=0;0:lv 1:no lv
 ;-----------------q_ave and detrend----------------------

 var_latave   = dim_avg_n_Wrap(q_raw(:,:,{latmin:latmax},:),2)
printVarSummary(var_latave)

 ;-----------------index and detrend----------------------
 Ts	      = asciiread(path_ts+Ts_filename,-1,"float") 
 Ts!0      = "year"
 Ts&year   = ispan(t_ymstar/100,t_ymend/100,1)
 printVarSummary(Ts)
 printMinMax(Ts,0)
 
 Ts = dim_standardize_n_Wrap(Ts,1,0)
 ;Ts = (/Ts*-1/)
 printVarSummary(Ts)
 
 if lv_flag .eq. 1 then
lv_init		= asciiread(path_ts+lv_filename,-1,"float")
lv_init!0		= "year"
lv_init&year	= ispan(t_ymstar/100,t_ymend/100,1)
printVarSummary(lv_init)
print(lv_init)
lv			= lv_init({year|t_ymstar/100:t_ymend/100})
print(lv)
end if 
 if dtrend_flag .eq. 0 then 
  Ts         = Ts  
  var_latave     = var_latave
 else
  Ts	        = (/dtrend_msg_n(ispan(1,dimsizes(Ts&year),1)*1.0,Ts,False,True,0)/)
  var_latave		= (/dtrend_msg_n(ispan(1,dimsizes(q_raw&year),1)*1.0,var_latave,False,True,0)/) 
 
 end if
 if lv_flag .eq. 1 then
 var_latave            = (/dtrend_msg_n(lv,var_latave,False,True,0)/)
 var_latave@detrend    = dtrend_flag +"--(0 for raw data, else for detrended data)"
 Ts					= (/dtrend_msg_n(lv,Ts,False,True,0)/) 
Ts@detrend			= dtrend_flag +"--(0 for raw data, else for detrended data)" 
end if 

 printVarSummary(var_latave)
 nz		= dimsizes(var_latave&level)
 nx		= dimsizes(var_latave&longitude)

 reg_var11					= new((/nz,nx/),"float")
 reg_var11(:,:)	= (/regCoef(Ts(year|:),var_latave(level|:,longitude|:,year|:))/)
 printVarSummary(reg_var11)
 reg_var11!0 ="level"
 reg_var11!1 ="lat"
 reg_var11@units = var_latave@units
 reg_var11@long_name = " reg "+var_latave@long_name
 copy_VarCoords(var_latave(0,:,:),reg_var11(:,:))
 printVarSummary(reg_var11)
 
 cor_var11					= new((/nz,nx/),"float")
 cor_var11(:,:) = escorc(Ts(year|:),var_latave(level|:,longitude|:,year|:)) ; uq correlation

 tValue		= new(3,"float")				
 rflag	  = new(3,"float")
  n				= dimsizes(Ts&year)
 tValue	  = cdft_t((/1-0.05,1-0.025,1-0.005/),(/n-2,n-2,n-2/))
 rflag		= sqrt(tValue^2/(n-2+tValue^2))
 rflag		= round(rflag*100.0,0)/100.0		;round the float data
 copy_VarCoords(reg_var11,cor_var11)
 cor_var11@tValue			  = tValue
 cor_var11@tValue_desc	= "Critical t Value for 0.1,0.05,001 significant level"
 cor_var11@rflag				= rflag
 cor_var11@rflag_desc		= "Critical correlation for 0.1,0.05,001 significant level"
 printVarSummary(cor_var11)
printVarSummary(reg_var11)

 ;;--------------plotting------------------------------------------------------
  ;; Read terrain data from a C binary file
  elev = read_height_data("/mnt/e/westsouth/data/ETOPO5.DAT")

  ;; Convert terrain data from units "m" to "hPa", it is described as a high pressure formula
  elev = 1013.25*(1-elev*0.0065/288.15)^5.25145
  printVarSummary(elev)
  printMinMax(elev,0)
    
  ;; The purpose of the interpolation is to make terrain data and variable data have the same resolution    
  lat  = fspan(90,-90,181)
  lon  = fspan(0,359,360)
  geog = area_hi2lores_Wrap(elev&lon,elev&lat,elev,True,1,lon,lat,False) 
  printVarSummary(geog)
    
  ; geog_lat = geog(:, {80})  
  geog_lat = dim_avg_n_Wrap(geog({latmin:latmax},{lonmin:lonmax}),0)
  geog_lon = dim_avg_n_Wrap(geog({latmin:latmax},{lonmin:lonmax}),1)
  printVarSummary(geog_lat)
    
  ;; Determine the terrain
  Mask_var1x  = reg_var11
  Mask_var1x@_FillValue = reg_var11@_FillValue
  tp3d_var1x   = conform(reg_var11,geog_lat,1)
  high3d_var1x = conform(reg_var11,reg_var11&level,0)
  Mask_var1x = (/mask(reg_var11,tp3d_var1x.lt.high3d_var1x,False)/)
  printVarSummary(Mask_var1x)


  Mask_tvalue1s  = cor_var11
  Mask_tvalue1s@_FillValue = cor_var11@_FillValue
  tp3d_tvalue1s  = conform(cor_var11,geog_lat,1)
  high3d_tvalue1s = conform(cor_var11,cor_var11&level,0)
  Mask_tvalue1s@_FillValue = cor_var11@_FillValue
  Mask_tvalue1s = (/mask(cor_var11,tp3d_tvalue1s.lt.high3d_tvalue1s,False)/)
  printVarSummary(Mask_tvalue1s)


  ;;-----------------------------------------------------------------------
;*********************************************************************************************************************
 ;;-------------------------------------------------------------
 vres		= True

 ;;------------------------------------------------------------------
 ; vres@tiMainFont                 = "helvetica-bold"
 ; vres@tiXAxisFont                = "helvetica-bold"
 ; vres@tmXBLabelFont              = "helvetica-bold"
 ; vres@tmYLLabelFont              = "helvetica-bold"
 ; vres@lbLabelFont                = "helvetica-bold"
 ; vres@lgLabelFont                = "helvetica-bold"
 ; vres@gsnStringFont              = "helvetica-bold"
 ; vres@tiMainFont                 = "helvetica-bold"
 ;;-----------------------------------------------------------------
  vres@tmXBMinorOn	= False
 vres@tmYLMinorOn	= False
 vres@tmYROn		= False
 vres@tmXTOn		= False
; vres@tmXBOn    = False
 vres@tmYRMode             = "Automatic" ;"remove right label"
;;-------------------------------------------------------------------
 vres@tmXBMajorLengthF			= 0.004
 vres@tmXBMajorOutwardLengthF	= 0.004
 vres@tmXBLabelDeltaF			= -0.5
 vres@tmYLMajorLengthF			= 0.002
 vres@tmYLMajorOutwardLengthF	= 0.004
 vres@tmYLLabelDeltaF			= -0.5
;;-------------------------------------------------------------------
 ;;-------------------------------------------------------------------  
 ;;Resource for vector
 vres@gsnFrame	= False
 vres@gsnDraw	= False
 
 ;;--------------------------------------------------------------------
 vres@vpHeightF	= 0.36
 vres@vpWidthF		= 0.75


;   vres@vpXF			= 0.1
;   vres@vpYF			= 0.9
 ;;---------------------------------------------------------------------
 ; vres@vcRefMagnitudeF			= 0.35
 ; vres@vcRefLengthF				= 0.045
 ; vres@vcMinDistanceF			= 0.019
 ; vres@vcMagnitudeFormat			= "@*+^sg"
 ; vres@vcRefAnnoOn				= True	
 ; vres@vcRefAnnoOrthogonalPosF	= -1.05
 ; vres@vcRefAnnoBackgroundColor 	= -1.20
 ; vres@vcRefAnnoPerimOn			= True	 
 ; vres@vcGlyphStyle				= "LineArrow";LineArrow;CurlyVector
 ; vres@vcLineArrowColor			= "blue"
 ; vres@vcLineArrowThicknessF	= 2.5
 ; vres@vcLineArrowHeadMaxSizeF = 0.010
 ; ; vres@vcVectorDrawOrder			= "PreDraw"
 ; vres@vcRefAnnoString1On    = True
 ; vres@vcRefAnnoString2On   = False
 ; ; vres@vcRefAnnoString1     = "0.3 m/s"
;;-------------------------------------------------------------------
vres@gsnLeftString			= ""
vres@gsnRightString         = ""
vres@tiMainString           = ""
 ; Resources for Axis
  font_height				= 0.024								       
  vres@tmYLLabelFontHeightF	= 0.95*font_height
  vres@tmXBLabelFontHeightF	=0.95*font_height
  vres@tiXAxisFontHeightF	= 1.6 * font_height
  vres@tiYAxisFontHeightF	= 0.9 * font_height
  vres@tiMainFontHeightF		= 1.2 * font_height
  vres@gsnLeftStringFontHeightF  = 1.2 * font_height
  vres@gsnRightStringFontHeightF  = 1.2*font_height

;;-----------------------------------------------------------------------------
vres@cnFillOn        = True               ; turn on color fill
vres@cnLineLabelsOn  = False                ; turn off line labels
vres@cnLinesOn       = False 
;vres@gsnScalarContour	= True		;required for contour
vres@lbLabelBarOn		= True
vres@cnInfoLabelOn		= False;False

 ;;-------------------------------------------------------
 ;vres@lbLabelStride   = 2                   
 vres@lbBoxMinorExtentF   = 0.25 
 ;res@lbLabelFont         = "times-roman"
 ; vres@lbTopMarginF      = -0.10
 ; vres@lbBottomMarginF       = 0.7
 ;vres@lbLabelStride       = 2
    ; Resources for colorbar
    vres@lbOrientation			= "horizontal"
    vres@lbLabelBarOn				= True
    vres@pmLabelBarOrthogonalPosF	= -0.03
    vres@pmLabelBarParallelPosF	= 0.5
    vres@pmLabelBarWidthF			= 0.7
    vres@pmLabelBarHeightF		= 0.1
    vres@mpLabelFontHeightF		= 0.9
 ;;-----------------------------------------------------------------
 vres@cnLevelSelectionMode ="ExplicitLevels" 
 vres@cnLevels = ispan(-60,60,15)/100.
 ; vres@cnFillPalette   = "colormap1"  ; nrl_sirkes;choose color map
 vres@cnMissingValFillColor    = "gray40" ; set color for missing areas
 vres@gsnSpreadColors		= True
 vres@gsnSpreadColorStart	= 2
 vres@gsnSpreadColorEnd	= 19
 ;;---------------------------------------------------------------
 vres@tmYROn		= False
 vres@tmXTOn		= False
 vres@tmYLOn    = False
 ;vres@tmXBOn    = False
 vres@tmYRLabelsOn = False 
 vres@tiYAxisOn    = False
 vres@tiYAxisSide  = "Right"
 ;;------------------------------------------------------------------------------
 resp					= True
 resp@gsnDraw			= False
 resp@gsnFrame			= False
 ;;----------------------------------------------------------------------------------------
 resp@cnFillOn					= True
 resp@cnLinesOn					= False
 resp@cnLineLabelsOn			= False
 resp@cnInfoLabelOn    			= False
 resp@cnMonoFillPattern			= False
 ;;----------------------------------------------------------------------------------------
 resp@cnFillOn					= True
 ; resp@cnFillScaleF       = 0.8
 resp@cnFillPatterns			= (/17,-1,17/)
 resp@cnFillDotSizeF			= 0.008
 resp@cnFillScaleF=3
 resp@cnFillColors           = (/"black","black","black","transparent","black","black","black"/)
 resp@cnLevelSelectionMode		= "ExplicitLevels"
 ;resp@cnFillDrawOrder="PreDraw" ;;设置先画，可以将中国以外的点覆盖住
 resp@gsnAddCyclic					= False
 resp@cnLevels				      =(/-rflag(1),rflag(1)/)
 resp@lbLabelBarOn		      = False
 resp@tmYRMode             = "Automatic" ;"remove right label"
 resp@gsnLeftString        = ""
 resp@gsnRightString       = ""
 ;resp@tmXBOn               = Falsetmylon
 resp@tmXBMinorOn        = False
 resp@tmYLMinorOn        = False
 resp@tmXTOn             = False
 resp@tmYROn             = False
 resp@tmXBOn              = False
 resp@tmYRLabelsOn       = False
 resp@tmYRMode           = "Automatic"
 resp@tmYLMode              = "Explicit"
 resp@tmYLValues            = (/200,250,300,400,500,600,700,850,1000/)
 resp@tmYLLabels            = resp@tmYLValues+"hPa"
 resp@tmYLLabelFontHeightF  =  1.65*font_height

 ;resp@tmXBLabelsOn       = False
 vres@tmXBMode           = "Automatic"
   vres@tmXBMode              = "Explicit"
 vres@tmXBValues            = (/55,60,65,70,75/)
 vres@tmXBLabels            = vres@tmXBValues+"E"
;  resp@tmXBMode              = "Explicit"
;  resp@tmXBValues            = (/55,60,65,70,75/)
;  resp@tmXBLabels            = resp@tmXBValues+"E"
;    resp@tmXBLabelFontHeightF = font_height


;   resp@tmXBMode              = "Explicit"
;  resp@tmXBValues            = (/55,60,65,70,75/)
;  resp@tmXBLabels            = resp@tmXBValues+"E"
 
 resp@pmTickMarkDisplayMode="Always"
 resp@tmYLMinorOn        = False
 resp@tiYAxisString=""
 resp@tmYLMajorLengthF			= 0.002
 resp@tmYLMajorOutwardLengthF	= 0.004
 resp@tmYLLabelDeltaF			= -0.5
 ;;-------------------------------------------------------------------------------
 plotname = savename
 nn    = 1
 plot1  = new(nn,graphic)
 plot2  = new(nn,graphic)
 dum  = new(nn,graphic)
 dum1  = new(nn,graphic)
 wks		= gsn_open_wks("pdf","./"+plotname)

;  vres@gsnPaperOrientation = "auto"          
;  vres@gsnMaximize         = True        ; must include w/ Paper Orientation
  m = 0
  ;vres@tiMainString			= "reg_w"
  vres@gsnLeftString		="(g) Reg. Q on EIP_SMI"
  vres@gsnRightString     = "MAM(0)"
  vres@tiMainFontHeightF = 0.020
  ;vres@gsnRightStringFontHeightF = 0.018


  ;vres@gsnLeftStringFontHeightF  = 0.018
  vres@gsnLeftStringOrthogonalPosF	= -0.0
  vres@gsnRightStringOrthogonalPosF	= -0.0
  gsn_define_colormap(wks,"BlueDarkRed18");cmp_b2r;BlueDarkRed18；NCV_blue_red
  nc 						= NhlNewColor(wks,0.83,0.83,0.83)
  ;gsn_reverse_colormap(wks)	;Reverse the colormap
  ;;;;----------label bar---------------------------------
  ;vres@lbBoxMinorExtentF   = 0.30 ;每个色块宽度
  ;vres@lbLabelFont         = "times-roman"
  ;vres@lbRightMarginF      = 0.78
  ;vres@lbLeftMarginF       = 0.0002

  ;;-----------------------------------------------------------
  ; gsn_reverse_colormap(wks)	;Reverse the colormap
  plot1(m) = gsn_csm_pres_hgt(wks,Mask_var1x({200:1000},{lonmin:lonmax}),vres)

  plot2(m) = gsn_csm_pres_hgt(wks,Mask_tvalue1s({200:1000},{lonmin:lonmax}),resp)
  overlay(plot1(m),plot2(m))
 printMinMax(reg_var11,0)
  draw(plot1(m))
  frame(wks)
 
  ;;-------------------------------------------------------------------

 end
 