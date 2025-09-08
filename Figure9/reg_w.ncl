load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "/mnt/e/mytool.ncl"

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
begin
  stdlat = 28  ;section angle 
  levt   = 100
  levb   = 1000

;;---------------------------------------------------------------------
  var_dims	    = "4D"
  var_dat       = "ERA5"
  var_name	    = "w"
  var_filename	= "ERA5_vertical-velocity_mon_197901_202112.nc" 
  var_filedir	  =  "/mnt/e/westsouth/data/"
  ;;---------------------------------------------------------------
  t_ymstar	    = 198001
  t_ymend	      = 202012
  
  ymstar	    = (/198001,198001/)
  ymend	      = (/202012,202012/)

  ;climate year
  ymstar_c  = (/198001,198001/)
  ymend_c   = (/202012,202012/)
  ;;-----------------------------------------------------------------
  latmin	= 21;20; 
  latmax	= 30;80;
  lonmin	= 95;0;
  lonmax	= 110;35;

  need_month1 = (/6,6/)
  need_month2 = (/8,8/)
  need_month  = (/68,68/)
  need_save_month_name=(/"JJA(0)","JJA(0)"/)
  title_name="(d) Reg."+" w on ICP_SMI"
  mon_num=dimsizes(need_month)
  ny    = t_ymend/100-t_ymstar/100+1

  lvl_1 = 1000
  lvl_2 = 200
  ;;-----------------------------------------------------------------
  Ts_dat        = "ERA5";CN05
  index_opt     = "ICP_SMI";eeof-ts1(DJF-MAM);;;SMI(SON,DJF,MAM);NA-SMI(SON,DJF,MAM);SNOWI(DJF-MAM);TP-SNOWI(DJFMAM)\
  ;EU-SNOWI(MAM,DJF);WEU-SMI(MAM);nino34_DJF
  season_opt    = "JJA";DJF;MAM

  if index_opt.eq."ICP_SMI"
   Ts_filename  = "ICP_swvl1_MAM.txt"
   Ts_filedir   = "/mnt/e/westsouth/yunnan/essay1/"
  end if

  if index_opt.eq."nino34_DJF"
  Ts_filename  = "nino34_DJF.txt"
  Ts_filedir   = "/mnt/e/westsouth/data/"
 end if
  if index_opt.eq."NA-SMI"
    if season_opt.eq."SON"
        ym = "y1961-2021"
    else
        ym = "y1962-2022"
    end if
    Ts_filename  = "ERA5.area_avg_North Asia.swvl1."+season_opt+".dtrend0."+ym+".txt"
    Ts_filedir   = "drought/ncl-scripts/area-average/sm.index/"
  end if

  if index_opt.eq."SMI"
   if season_opt.eq."SON"
         ym = "y1961-2021"
   else
         ym = "y1962-2022"
   end if
   Ts_filename  = "ERA5.area_avg_SWC.swvl1."+season_opt+".dtrend0."+ym+".txt"
   Ts_filedir   = "drought/ncl-scripts/area-average/sm.index/"
  end if

  if index_opt.eq."NIOS_JJA"
   Ts_filename  = "nino34_DJF.txt"
   Ts_filedir   = "/mnt/e/westsouth/data/"
  end if

  if index_opt.eq."TP-SNOWI"
   Ts1_filename  = "ERA5.area_avg_TP.snowc.DJF.dtrend1."+"y"+t_ymstar/100+"-"+t_ymend/100+".txt"
   Ts1_filedir   = "drought/ncl-scripts/area-average/snow.index/"

   Ts2_filename  = "ERA5.area_avg_TP.snowc.MAM.dtrend1."+"y"+t_ymstar/100+"-"+t_ymend/100+".txt"
   Ts2_filedir   = "drought/ncl-scripts/area-average/snow.index/"
  end if

  if index_opt.eq."EU-SNOWI"
    Ts_filename  = "ERA5.area_avg_EU.snowc."+season_opt+".dtrend1.y"+t_ymstar/100+"-"+t_ymend/100+".txt"
    Ts_filedir   = "drought/ncl-scripts/area-average/snow.index/"
  end if

  if index_opt.eq."WEU-SMI"
    Ts_filename  = "ERA5.area_avg_WEU.swvl1."+season_opt+".dtrend1.y1962-2022"+".txt"
    Ts_filedir   = "drought/ncl-scripts/area-average/sm.index/"
  end if
  ;;---------------------------------------------------------------------------
  dtrend_flag  = 1
  anomaly_flag = 0
  area_flag		= 1			; significant area type,0 for x only, 1 for y only,2 for x or y,3,for sqrt(x^2,y^2)   
  ;;---------------------------------------------------------------------------
  cor_reg_flag	= "reg"		; "cor" or "reg"
  critic_flag	 = 1.0	; critical value for selecting year
  com_flag	   = 0	; -1 for low-ave, 0 for high-low, 1 for high-ave
  ;options for output
  plottype	  = "pdf";eps
  plotdir	    = "./"
  savename	  = var_dat+"-"+index_opt+"_"+season_opt+".comp."+var_name+"."+need_save_month_name(0)+"-"+need_save_month_name(mon_num-1)+\
  ".y"+ymstar(0)/100+"-"+ymend(mon_num-1)/100+".critic_flag"+critic_flag+"."+"com_flag"+com_flag+"."+"dtrend_flag"+dtrend_flag
  savedir    = plotdir
  ;**********************************************************************
  ;**read variables
  f		= addfile(var_filedir+var_filename,"r")
  var000	= short2flt(f->$var_name$(:,{lvl_1:lvl_2},{latmin:latmax},{lonmin:lonmax}))
  printVarSummary(var000)
  
  var     =  new((/mon_num,ny,dimsizes(var000&level),dimsizes(var000&latitude),dimsizes(var000&longitude)/),"float")
  var_int = new((/mon_num,ny,dimsizes(var000&level),dimsizes(var000&latitude),dimsizes(var000&longitude)/),"float")
  do i=0,dimsizes(need_month1)-1
  monmin  = need_month1(i) ;starting month for averaging,(monmin != 0,-12 <= monmin <= monmax <=12). negative value for previou year(year(-1)) 
  monmax  = need_month2(i) ;ending month for averaging,     1<= monmax <= 12
  tim   = f->time
  u_time_DATE = cd_calendar(tim,-1)
  ;print(u_time_DATE)
  tstar   = ind(u_time_DATE .eq. ymstar(i))
  tlast   = ind(u_time_DATE .eq. ymend(i))

  print(tstar)
  print(tlast)  
  var00     = var000(tstar:tlast,:,:,:)
  var00!0   = "time"
  var00!1   = "level"
  var00!2   = "lat"
  var00!3   = "lon"
  printVarSummary(var00)
  
  var0    = month_to_monave(var00,monmin,monmax)
  printVarSummary(var0)
  var_int0     = var0

  if dtrend_flag .eq. 0
  var0         = var0
  var0@detrend  = dtrend_flag +"--(0 for raw data, else for detrended data)"
  else
  var0          = (/dtrend_msg_n(var0&year*1.0,var0,False,True,0)/)
  var0@detrend  = dtrend_flag +"--(0 for raw data, else for detrended data)"
  end if

  if anomaly_flag .eq. 0
  var0         = var0
  var0@anomaly = anomaly_flag+"--(0 for raw data, else for anomaly data)"
  else

  var0       = var0-conform_dims(dimsizes(var0), dim_avg_n_Wrap(var0({ymstar_c(i)/100:ymend_c(i)/100},:,:),0), (/1,2/))  
  var0@anomaly=anomaly_flag+"--(0 for raw data, else for anomaly data)"
  end if
 
  var(i,:,:,:,:)     = var0({t_ymstar/100:t_ymend/100},:,:,:)
  var_int(i,:,:,:,:) = var_int0({t_ymstar/100:t_ymend/100},:,:,:)
  printVarSummary(var0)
  printVarSummary(var)
  delete([/tstar,tlast,var0,tim,u_time_DATE,monmin,monmax,var00,var_int0/])
  end do
  var!0="month"
  var&month=need_month
  printVarSummary(var)
  
  var_int!0="month"
  var_int&month=need_month
  printVarSummary(var_int)
  delete([/var000/])
 
  var_monave = var
  printVarSummary(var_monave)
  delete([/var/]) 
  
  ;;------------------------average lon------------------------------------------
  var_latave   = dim_avg_n_Wrap(var_monave(1,:,:,{latmin:latmax},:),2)
  var_latave   =(/var_latave*1000./)
  printVarSummary(var_latave)
  delete([/var_monave/])
  
  ;;-----------Ts--------------------------------------------------------------------------
  nyear = t_ymend/100-t_ymstar/100+1
  if index_opt.eq."ICP_SMI"
  Ts	      = asciiread(Ts_filedir+Ts_filename,-1,"float") 
  Ts!0      = "year"
  Ts&year   = ispan(t_ymstar/100,t_ymend/100,1)
  printVarSummary(Ts)
  printMinMax(Ts,0)

  Ts = -1*dim_standardize_n_Wrap(Ts,1,0)
  printVarSummary(Ts)

  if dtrend_flag .eq. 0 then  
   Ts         = Ts  
  else
   Ts	        = (/dtrend_msg_n(ispan(1,dimsizes(Ts&year),1)*1.0,Ts,False,True,0)/)
  end if


  end if

  if index_opt.eq."nino34_DJF"
  Ts	      = asciiread(Ts_filedir+Ts_filename,-1,"float") 
  Ts!0      = "year"
  Ts&year   = ispan(t_ymstar/100,t_ymend/100,1)
  printVarSummary(Ts)
  printMinMax(Ts,0)

  Ts = dim_standardize_n_Wrap(Ts,1,0)
  printVarSummary(Ts)

  if dtrend_flag .eq. 0 then  
   Ts         = Ts  
  else
   Ts	        = (/dtrend_msg_n(ispan(1,dimsizes(Ts&year),1)*1.0,Ts,False,True,0)/)
  end if


  end if
if index_opt.eq."SMI".or.index_opt.eq."NA-SMI".or.index_opt.eq."SNOWI".or.index_opt.eq."CS-SNOWI"\
.or.index_opt.eq."NAO".or.index_opt.eq."EAEU-SMI"
  Ts0	      = asciiread(Ts_filedir+Ts_filename,-1,"float") 
  Ts0!0      = "year"
  Ts0&year   = ispan(t_ymstar/100,t_ymend/100,1)
  printVarSummary(Ts0)
  
  Ts = -1.0*Ts0
  copy_VarCoords(Ts0,Ts)
  Ts = dim_standardize_n_Wrap(Ts,1,0)
  printVarSummary(Ts)
  printMinMax(Ts,0)
  delete([/Ts0/])
  
  if dtrend_flag .eq. 0 then  
   Ts         = Ts  
  else
   Ts	        = (/dtrend_msg_n(ispan(1,dimsizes(Ts&year),1)*1.0,Ts,False,True,0)/)
  end if

end if
  
 if index_opt.eq."TP-SNOWI"
   Ts1	      = asciiread(Ts1_filedir+Ts1_filename,-1,"float") 
   Ts2	      = asciiread(Ts2_filedir+Ts2_filename,-1,"float") 
   Ts1!0      = "year"
   Ts1&year   = ispan(t_ymstar/100,t_ymend/100,1)
   copy_VarCoords(Ts1,Ts2)
   printVarSummary(Ts2)

   Ts1 = -1.0*dim_standardize_n_Wrap(Ts1,1,0)
   Ts2 = -1.0*dim_standardize_n_Wrap(Ts2,1,0)
   ; printVarSummary(Ts1)

  if dtrend_flag .eq. 0 then  
    Ts1         = Ts1  
    Ts2         = Ts2  
  else
    Ts1	        = (/dtrend_msg_n(ispan(1,dimsizes(Ts1&year),1)*1.0,Ts1,False,True,0)/)
    Ts2	        = (/dtrend_msg_n(ispan(1,dimsizes(Ts2&year),1)*1.0,Ts2,False,True,0)/)
  end if
  printVarSummary(Ts2)
 end if
 
 if index_opt.eq."NIOS_JJA".or.index_opt.eq."WLB-SNOWI".or.index_opt.eq."WEU-SMI"
    Ts	      = asciiread(Ts_filedir+Ts_filename,-1,"float") 
    Ts!0      = "year"
    Ts&year   = ispan(t_ymstar/100,t_ymend/100,1)
    printVarSummary(Ts)
    printMinMax(Ts,0)

    Ts = dim_standardize_n_Wrap(Ts,1,0)
    printVarSummary(Ts)

    if dtrend_flag .eq. 0 then  
     Ts         = Ts  
    else
     Ts	        = (/dtrend_msg_n(ispan(1,dimsizes(Ts&year),1)*1.0,Ts,False,True,0)/)
    end if

  end if
  ;;----------mlgb&reg----------------------------------------------------------------
  nz		= dimsizes(var_latave&level)
  nx		= dimsizes(var_latave&lon)
 
  reg_var11					= new((/nz,nx/),"float")
  reg_var11(:,:)	= (/regCoef(Ts(year|:),var_latave(level|:,lon|:,year|:))/)
printVarSummary(reg_var11)

reg_var11!0 ="level"
  reg_var11!1 ="lon"
  reg_var11@units = var_latave@units
  reg_var11@long_name = " reg "+var_latave@long_name
  copy_VarCoords(var_latave(0,:,:),reg_var11(:,:))
  printVarSummary(reg_var11)
  
  cor_var11					= new((/nz,nx/),"float")
  cor_var11(:,:) = escorc(Ts(year|:),var_latave(level|:,lon|:,year|:)) ; uq correlation

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

  ;;-----------------------------------------------------------------------
  ; dout = "drought/ncl-scripts/panel/Figure8/"
  ; outname = savename+".nc"
  ; system("/bin/rm -f " + dout+outname)	
  ; fout		= addfile(dout+outname,"c")
  ; filedimdef(fout,"time",-1,True)
  ; fout->$var_name$ = Mask_var(:,:,:);Attention!!!
  ; fout->tvalue = Mask_tvalue(:,:,:);Attention!!!
  ; exit
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
  printVarSummary(geog_lat)
    
  ;; Determine the terrain
  Mask_var  = reg_var11
  Mask_var@_FillValue = reg_var11@_FillValue
  tp3d_var   = conform(reg_var11,geog_lat,1)
  high3d_var = conform(reg_var11,reg_var11&level,0)
  Mask_var = (/mask(reg_var11,tp3d_var.lt.high3d_var,False)/)
  printVarSummary(Mask_var)

  Mask_tvalue  = cor_var11
  Mask_tvalue@_FillValue = cor_var11@_FillValue
  tp3d_tvalue   = conform(cor_var11,geog_lat,1)
  high3d_tvalue = conform(cor_var11,cor_var11&level,0)
  Mask_tvalue@_FillValue = cor_var11@_FillValue
  Mask_tvalue = (/mask(cor_var11,tp3d_tvalue.lt.high3d_tvalue,False)/)
  printVarSummary(Mask_tvalue)
  ;;----------------------------------------------------  
  ;;-------------------------------------------------------------
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
  vres@tmYRMode             = "Automatic" ;"remove right label"
 ;;-------------------------------------------------------------------
  vres@tmXBMajorLengthF			= 0.004
  vres@tmXBMajorOutwardLengthF	= 0.004
  vres@tmXBLabelDeltaF			= -0.5
  vres@tmYLMajorLengthF			= 0.004
  vres@tmYLMajorOutwardLengthF	= 0.004
  vres@tmYLLabelDeltaF			= -0.5
 ;;-------------------------------------------------------------------
  ;;-------------------------------------------------------------------  
  ;;Resource for vector
  vres@gsnFrame	= False
  vres@gsnDraw	= False
  ;;--------------------------------------------------------------------
  vres@vpHeightF	= 0.50
  vres@vpWidthF		= 0.75
  vres@tmXBMode              = "Explicit"
  vres@tmXBValues            = (/95,100,105,110/)
  vres@tmXBLabels            = vres@tmXBValues+"E"
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
 font_height               = 0.02                                
 vres@tmYLLabelFontHeightF  =  1.25*font_height
 vres@tmXBLabelFontHeightF  = 1.35*font_height
 vres@tiXAxisFontHeightF    = 1.4 * font_height
 vres@tiYAxisFontHeightF    = 1.25 * font_height
 vres@tiMainFontHeightF     = 1.2 * font_height
 vres@tiMainOffsetYF        = -0.01
 vres@gsnLeftStringFontHeightF= 1.3 *font_height
 vres@gsnRightStringFontHeightF=1.3 *font_height
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
  vres@lbOrientation		= "horizontal"
  vres@lbLabelFontThicknessF = 0.05
  vres@lbLabelFontHeightF = 0.025
  ; vres@lbBoxEndCapStyle   = "TriangleBothEnds";RectangleEnds
  vres@pmLabelBarHeightF  = 0.15
  vres@pmLabelBarWidthF    = 0.75
 ; vres@pmLabelBarOrthogonalPosF = -0.03
  ;;-----------------------------------------------------------------
  vres@cnLevelSelectionMode ="ExplicitLevels" 
  vres@cnLevels = ispan(-12,12,3)
  ; vres@cnFillPalette   = "colormap1"  ; nrl_sirkes;choose color map
  vres@cnMissingValFillColor    = "gray40" ; set color for missing areas
  vres@gsnSpreadColors		= True
  vres@gsnSpreadColorStart	= 2 
  vres@gsnSpreadColorEnd	= 19 
  vres@pmLabelBarOrthogonalPosF = -0.05;-0.015
  ;;---------------------------------------------------------------
  vres@tmYROn		= False
  vres@tmXTOn		= False
  vres@tmYLOn    = False
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
  ;resp@tmYRMode             = "Automatic" ;"remove right label"
  resp@gsnLeftString        = ""
  resp@gsnRightString       = ""
  resp@tmXBOn               = False
  resp@tmXBMinorOn        = False
  resp@tmYLMinorOn        = False
  resp@tmXTOn             = False
  resp@tmYROn             = False
  resp@tmYRLabelsOn       = False
 ; resp@tmYRMode           = "Automatic"
  resp@tmYLMode              = "Explicit"
  resp@tmYLValues            = (/100,150,200,250,300,400,500,600,700,850,1000/)
  resp@tmYLLabels            = resp@tmYLValues+"hPa"
  resp@tmYLLabelFontHeightF  =  1.4*font_height

  resp@pmTickMarkDisplayMode="Always"
  resp@tmYLMinorOn        = False
  resp@tiYAxisString=""


  ;;-------------------------------------------------------------------------------
  plotname = savename
  nn    = mon_num
  plot1  = new(nn,graphic)
  plot2  = new(nn,graphic)
  dum  = new(nn,graphic)
  dum1  = new(nn,graphic)
  wks		= gsn_open_wks("pdf",plotdir+plotname)
   m = 0
   ;vres@tiMainString			= "reg_w"
   vres@gsnLeftString		=title_name
   vres@gsnRightString     = need_save_month_name(0)
   vres@tiMainFontHeightF = 0.020
   ;vres@gsnRightStringFontHeightF = 0.018


   ;vres@gsnLeftStringFontHeightF  = 0.018
   vres@gsnLeftStringOrthogonalPosF	= -0.0
   vres@gsnRightStringOrthogonalPosF	= -0.0
   gsn_define_colormap(wks,"BlueDarkRed18");cmp_b2r;BlueDarkRed18；NCV_blue_red
   nc 						= NhlNewColor(wks,0.83,0.83,0.83)
  ; gsn_reverse_colormap(wks)	;Reverse the colormap
   ;;;;----------label bar---------------------------------
   ;vres@lbBoxMinorExtentF   = 0.30 ;每个色块宽度
   ;vres@lbLabelFont         = "times-roman"
   ;vres@lbRightMarginF      = 0.78
   ;vres@lbLeftMarginF       = 0.0002
 
   ;;-----------------------------------------------------------
   ; gsn_reverse_colormap(wks)	;Reverse the colormap
   plot1(m) = gsn_csm_pres_hgt(wks,Mask_var(:,{lonmin:lonmax}),vres)
  
   plot2(m) = gsn_csm_pres_hgt(wks,Mask_tvalue(:,{lonmin:lonmax}),resp)
   overlay(plot1(m),plot2(m))
  printMinMax(Mask_var,0)
   draw(plot1(m))
   frame(wks)
  
   ;;-------------------------------------------------------------------


  end