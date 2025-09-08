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
  levt   = 200
  levb   = 1000

;;---------------------------------------------------------------------
  var_dims	    = "4D"
  var_dat       = "ERA5"
  var_name	    = "vo"
  var_filename	= "ERA5.mon.vorticity.1950-2022.nc" 
  var_filedir	  =  "/mnt/e/westsouth/data/"

  varz_name	    = "z"
  varz_filename	= "ERA5_z_mon_197901_202209.nc"
  ;;---------------------------------------------------------------
  t_ymstar	    = 198001
  t_ymend	      = 202012
  
  ymstar	    = (/198001,198001/)
  ymend	      = (/202012,202012/)

  ;climate year
  ymstar_c  = (/198001,198001/)
  ymend_c   = (/202012,202012/)
  ;;-----------------------------------------------------------------
  latmin	= 28;20; 
  latmax	= 33;80;
  lonmin	= 55;0;
  lonmax	= 80;35;

  need_month1 = (/3,3/)
  need_month2 = (/5,5/)
  need_month  = (/35,35/)
  need_save_month_name=(/"MAM","MAM"/)


  mon_num=dimsizes(need_month)
  ny    = t_ymend/100-t_ymstar/100+1

  lvl_1 = 1000
  lvl_2 = 100
  ;;-----------------------------------------------------------------
  Ts_dat        = "ERA5";CN05
  index_opt     = "EIP_SMI_MAM";eeof-ts1(DJF-MAM);;;SMI(SON,DJF,MAM);NA-SMI(SON,DJF,MAM);SNOWI(DJF-MAM);TP-SNOWI(DJFMAM)\
  ;EU-SNOWI(MAM,DJF);WEU-SMI(MAM);nino_DJF
  season_opt    = "MAM";DJF;MAM
  lv_flag=0

  if index_opt.eq."eeof-ts1"
   Ts_filename  = "output1.txt"
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

  if index_opt.eq."EIP_SMI_MAM"
   Ts_filename  = "EIP_SMI_MAM.txt"
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
  if lv_flag.eq.1
   lv_filename  = "nino34_MAM.txt"
   lv_filedir   = "/mnt/e/westsouth/data/"
   lv	      = asciiread(lv_filedir+lv_filename,-1,"float") 
   lv!0      = "year"
   lv&year   = ispan(t_ymstar/100,t_ymend/100,1)
   printVarSummary(lv)
   printMinMax(lv,0)
 
   lv = dim_standardize_n_Wrap(lv,1,0)
   printVarSummary(lv)
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
  savename	  = Ts_filename+"reg."+ var_name+"."+season_opt+"."+latmin+"-"+latmax+"."+lonmin+"-"+lonmax 
  if lv_flag.eq.1 then
  savename	  = savename+".lv_"+lv_filename 
  end if
  savedir    = plotdir
  ;**********************************************************************
  ;**read variables
  f		= addfile(var_filedir+var_filename,"r")
  var000	= short2flt(f->$var_name$(:,{lvl_1:lvl_2},{latmin:latmax},{lonmin:lonmax}))
  printVarSummary(var000)
  f2    = addfile(var_filedir+varz_filename,"r")
  varz000  = short2flt(f2->$varz_name$(:,{lvl_1:lvl_2},{latmin:latmax},{lonmin:lonmax}))
  varz000=(/varz000/9.8/)
  var     =  new((/mon_num,ny,dimsizes(var000&level),dimsizes(var000&latitude),dimsizes(var000&longitude)/),"float")
  var_int =  new((/mon_num,ny,dimsizes(var000&level),dimsizes(var000&latitude),dimsizes(var000&longitude)/),"float")
  varz    =  new((/mon_num,ny,dimsizes(varz000&level),dimsizes(varz000&latitude),dimsizes(varz000&longitude)/),"float")
  varz_int=  new((/mon_num,ny,dimsizes(varz000&level),dimsizes(varz000&latitude),dimsizes(varz000&longitude)/),"float")
  do i=0,dimsizes(need_month1)-1
  monmin  = need_month1(i) ;starting month for averaging,(monmin != 0,-12 <= monmin <= monmax <=12). negative value for previou year(year(-1)) 
  monmax  = need_month2(i) ;ending month for averaging,     1<= monmax <= 12
  tim   = f->time
  u_time_DATE = cd_calendar(tim,-1)
  tim2  = f2->time
  u_time_DATE2 = cd_calendar(tim2,-1)
  ;print(u_time_DATE)
  tstar   = ind(u_time_DATE .eq. ymstar(i))
  tlast   = ind(u_time_DATE .eq. ymend(i))
  tstar2  = ind(u_time_DATE2 .eq. ymstar(i))
  tlast2  = ind(u_time_DATE2 .eq. ymend(i))
  print(tstar)
  print(tlast)  
  var00     = var000(tstar:tlast,:,:,:)
  var00!0   = "time"
  var00!1   = "level"
  var00!2   = "lat"
  var00!3   = "lon"

  varz00    = varz000(tstar2:tlast2,:,:,:)
  varz00!0  = "time"
  varz00!1  = "level"
  varz00!2  = "lat"
  varz00!3  = "lon"
  printVarSummary(var00)
  printVarSummary(varz00)
  var0   = month_to_monave(var00,monmin,monmax)
  varz0  = month_to_monave(varz00,monmin,monmax)

 ; var0=var1/9.8
 ; copy_VarCoords(var1,var0)
  printVarSummary(var0)
  printVarSummary(varz0)
  var_int0     = var0
  varz_int0    = varz0

  if dtrend_flag .eq. 0
  var0         = var0
  var0@detrend  = dtrend_flag +"--(0 for raw data, else for detrended data)"
  varz0        = varz0
  varz0@detrend = dtrend_flag +"--(0 for raw data, else for detrended data)"
  else
  var0          = (/dtrend_msg_n(var0&year*1.0,var0,False,True,0)/)
  var0@detrend  = dtrend_flag +"--(0 for raw data, else for detrended data)"
  varz0         = (/dtrend_msg_n(varz0&year*1.0,varz0,False,True,0)/)
  varz0@detrend = dtrend_flag +"--(0 for raw data, else for detrended data)"
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
  varz(i,:,:,:,:)    = varz0({t_ymstar/100:t_ymend/100},:,:,:)
  varz_int(i,:,:,:,:) = varz_int0({t_ymstar/100:t_ymend/100},:,:,:)
  printVarSummary(var0)
  printVarSummary(var)
  delete([/tstar,tlast,var0,tim,u_time_DATE,monmin,monmax,var00,var_int0/])
  delete([/tstar2,tlast2,varz0,tim2,u_time_DATE2,varz00,varz_int0/])
  end do
  var!0="month"
  var&month=need_month
  printVarSummary(var)
  varz!0="month"
  varz&month=need_month
  printVarSummary(varz)

  var_int!0="month"
  var_int&month=need_month
  varz_int!0="month"
  varz_int&month=need_month
  ;;---------------------------------------------------------------------------
  printVarSummary(var_int)
  printVarSummary(varz_int)
  delete([/var000,varz000/])
 
  var_monave = var
  varz_monave= varz

  printVarSummary(var_monave)
  printVarSummary(varz_monave)
  
  delete([/var/]) 
  
  ;;------------------------average lon------------------------------------------
  var_latave   = dim_avg_n_Wrap(var_monave(1,:,:,{latmin:latmax},{lonmin:lonmax}),2)
  varz_latave  = dim_avg_n_Wrap(varz_monave(1,:,:,{latmin:latmax},{lonmin:lonmax}),2)
  ;var_latave   =(/var_latave*-1000./)
  printVarSummary(var_latave)
  printVarSummary(varz_latave)
  delete([/var_monave/])
  delete([/varz_monave/])
  
  ;;-----------Ts--------------------------------------------------------------------------
  nyear = t_ymend/100-t_ymstar/100+1
  if index_opt.eq."EIP_SMI_MAM"
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
 
 if index_opt.eq."ICP_SMI".or.index_opt.eq."WLB-SNOWI".or.index_opt.eq."WEU-SMI"
    Ts	      = asciiread(Ts_filedir+Ts_filename,-1,"float") 
    Ts!0      = "year"
    Ts&year   = ispan(t_ymstar/100,t_ymend/100,1)
    printVarSummary(Ts)
    printMinMax(Ts,0)

    Ts = dim_standardize_n_Wrap(Ts,1,0)
    Ts =[Ts*-1]
    printVarSummary(Ts)

    if dtrend_flag .eq. 0 then  
     Ts         = Ts  
    else
     Ts	        = (/dtrend_msg_n(ispan(1,dimsizes(Ts&year),1)*1.0,Ts,False,True,0)/)
    end if

  end if
     if lv_flag.eq.1 then
     Ts	        = (/dtrend_msg_n(lv,Ts,False,True,0)/)
     var_latave = (/dtrend_msg_n(lv,var_latave,False,True,0)/)
      varz_latave= (/dtrend_msg_n(lv,varz_latave,False,True,0)/)
      end if

  ;;----------mlgb&reg----------------------------------------------------------------
  nz		= dimsizes(var_latave&level)
  nx		= dimsizes(var_latave&lon)
 
  reg_var11					= new((/nz,nx/),"float")
  reg_var22          = new((/nz,nx/),"float")
  reg_var11(:,:)	= (/regCoef(Ts(year|:),var_latave(level|:,lon|:,year|:))/)
  reg_var22(:,:)	= (/regCoef(Ts(year|:),varz_latave(level|:,lon|:,year|:))/)
printVarSummary(reg_var11)
printVarSummary(reg_var22)

  reg_var11!0 ="level"
  reg_var11!1 ="lon"
  reg_var11@units = var_latave@units
  reg_var11@long_name = " reg "+var_latave@long_name
  copy_VarCoords(var_latave(0,:,:),reg_var11(:,:))
  printVarSummary(reg_var11)
  ;;-----------------------------------------------------------------------
  reg_var22!0 ="level"
  reg_var22!1 ="lon"
  reg_var22@units = var_latave@units
  reg_var22@long_name = " reg "+var_latave@long_name
  copy_VarCoords(varz_latave(0,:,:),reg_var22(:,:))
  printVarSummary(reg_var22)
  
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
;print(cor_var11)
print(rflag)

  ;;----------------------------------------------------------------------改改
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

  Mask_var2  = reg_var22
  Mask_var2@_FillValue = reg_var22@_FillValue
  tp3d_var2   = conform(reg_var22,geog_lat,1)
  high3d_var2 = conform(reg_var22,reg_var22&level,0)
  Mask_var2 = (/mask(reg_var22,tp3d_var2.lt.high3d_var2,False)/)
  printVarSummary(Mask_var2)
  printMinMax(Mask_var2,0)
 
    ;;-----------------------------------------------------------------------

  ; dout = "drought/ncl-scripts/panel/Figure8/"
  ; outname = savename+".nc"
  ; system("/bin/rm -f " + dout+outname)	
  ; fout		= addfile(dout+outname,"c")
  ; filedimdef(fout,"time",-1,True)
  ; fout->$var_name$ = Mask_var(:,:,:);Attention!!!
  ; fout->tvalue = Mask_tvalue(:,:,:);Attention!!!
  ; exit
  ;;-------------------------------------------------------------
  vres		= True
  font_height               = 0.022                                 
  vres@tmYLLabelFontHeightF  = font_height
  vres@tmXBLabelFontHeightF  = font_height
  vres@tiXAxisFontHeightF    = 1.2 * font_height
  vres@tiYAxisFontHeightF    = 1.2 * font_height
  vres@tiMainFontHeightF     = 1.2 * font_height
  vres@tiMainOffsetYF        = -0.01
  vres@gsnLeftStringFontHeightF= font_height
  vres@gsnRightStringFontHeightF=font_height
  ;;----------------------------------------------
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
   vres@vpWidthF		= 0.70
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
  vres@tiMainFontHeightF       = 0.0120

  ;;-----------------------------------------------------------------------------
  vres@cnFillOn        = True               ; turn on color fill
  vres@cnLineLabelsOn  = False                ; turn off line labels
  vres@cnLinesOn       = False 
  ;vres@gsnScalarContour	= True		;required for contour

  ;;-----------------------------------------------------------------
  vres@cnLevelSelectionMode ="ManualLevels"   
  vres@cnMinLevelValF       = -48
  vres@cnMaxLevelValF       = 48
  vres@cnLevelSpacingF      =  12
  ; vres@cnFillPalette   = "colormap1"  ; nrl_sirkes;choose color map
  vres@cnMissingValFillColor    = "gray40" ; set color for missing areas

  ;;---------------------------------------------------------------
  vres@tmYROn		= False
  vres@tmXTOn		= False
  vres@tmYRLabelsOn = False 
  vres@tiYAxisOn    = False
  vres@tiYAxisSide  = "Right"


  vres@tmYLOn    = False
  vres@tmXBMode="Explicit"
   vres@tmXBValues=(/55,60,65,70,75,80,100,120/)
  ;vres@tmXBValues=(/60,80,100,120/)
  vres@tmXBLabels=vres@tmXBValues+"E"
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
  resp@vpHeightF	= 0.50
  resp@vpWidthF		= 0.70


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

  resp@tmXBMinorOn        = False
  resp@tmYLMinorOn        = False
  resp@tmXTOn             = False
  resp@tmYROn             = False
  resp@tmYRLabelsOn       = False
  resp@tmXBOn             = False
  resp@tmYLMode              = "Explicit"
  resp@tmYLValues            = (/100,150,200,250,300,400,500,600,700,850,1000/)
  resp@tmYLLabels            = resp@tmYLValues+"hPa"
    resp@tmYLLabelFontHeightF = 0.020
  resp@pmTickMarkDisplayMode="Always"
  resp@tmYLMinorOn        = False
  resp@tiYAxisString=""
  ;;-------------------------------------------------------------------------------
  plotname = savename
  nn    = mon_num
  plot1  = new(nn,graphic)
  plot2  = new(nn,graphic)
  plot3  = new(nn,graphic)
  dum  = new(nn,graphic)
  dum1  = new(nn,graphic)
  wks		= gsn_open_wks("pdf",plotdir+plotname)
   m = 0
   vres@tiMainString			= ""
   vres@gsnLeftString		="(c) Reg. vo on "+index_opt
   vres@gsnRightString     = need_save_month_name(0)+"(0)"
   vres@tiMainFontHeightF = 0.016
   ;vres@gsnRightStringFontHeightF = 0.024
   ;vres@gsnLeftStringFontHeightF  = 0.024
   vres@gsnLeftStringOrthogonalPosF	= 0.01
   vres@gsnRightStringOrthogonalPosF	= 0.01
   vres@gsnLeftStringOrthogonalPosF	= 0.00
   vres@gsnRightStringOrthogonalPosF	= 0.00
   gsn_define_colormap(wks,"BlueDarkRed18");cmp_b2r;BlueDarkRed18；NCV_blue_red;MPL_RdBu
   ;gsn_reverse_colormap(wks)	;Reverse the colormap
   ;;;;----------label bar---------------------------------
   vres@lbBoxMinorExtentF   = 0.30 ;每个色块宽度
   ;vres@lbLabelFont         = "times-roman"
   ;vres@lbRightMarginF      = 0.78
   ;vres@lbLeftMarginF       = 0.0002
   vres@lbLabelBarOn		= True
   vres@cnInfoLabelOn		= False;False
   vres@lbOrientation		= "horizontal";horizontal
   vres@pmLabelBarHeightF=0.08
   vres@pmLabelBarOrthogonalPosF = -0.015;-0.015
    vres@pmLabelBarWidthF	= 0.70
Mask_var=(/Mask_var*10000000.0/)
printMinMax(Mask_var,0)
   ;;-----------------------------------------------------------
   ; gsn_reverse_colormap(wks)	;Reverse the colormap
   plot1(m) = gsn_csm_pres_hgt(wks,Mask_var(:,{lonmin:lonmax}),vres)
   plot2(m) = gsn_csm_pres_hgt(wks,Mask_tvalue(:,{lonmin:lonmax}),resp)

   res					= True
   res@gsnDraw			= False
   res@gsnFrame			= False
   res@cnLineLabelPlacementMode="Computed"
res@cnLineLabelFontHeightF=0.020
   res@gsnLeftString=""
   res@gsnRightString=""
   res@cnLineThicknessF= 3
   res@tiMainString           = ""
   res@tiYAxisString=""
    res@vpHeightF	= 0.50
    res@vpWidthF		= 0.70
res@cnInfoLabelOn=False
res@gsnContourNegLineDashPattern = 1
res@cnLevelSelectionMode ="ManualLevels"
res@cnMaxLevelValF       = 8
res@cnMinLevelValF       = -4
res@cnLevelSpacingF      = 1


   ;plot3(m) = gsn_csm_contour(wks,Mask_var2(:,{latmin:latmax}),res)
   overlay(plot1(m),plot2(m))
   ; overlay(plot1(m),plot3(m))
    draw(plot1(m))
    frame(wks)

   ;;-------------------------------------------------------------------
	;  resP=True
  ;  resP@gsnDraw			= False
  ;  resP@gsnFrame			= False
  ;  resP@gsnMaximize=True
  ;  resP@gsnPanelLabelBar=True                     ;设置公共的colorbar
  ;  resP@lbLabelFontHeightF  = 0.012               ; make labels smaller（设置colorbar的字体）
  ;  resP@gsnPaperOrientation="Portrait"                       ;设置纸张形式
  ;  ;resP@gsnPanelFigureStrings=(/"a)Oct","b)Nov","c)Dec"/);给每个子图添加标注
  ;  resP@amJust="TopLeft"                                    ;标注的位置
  ;  ;resP@gsnPanelFigureStringsFontHeightF=0.008               ;图形标注的字体大小
  ;   resP@gsnPanelRowSpec=True
  ;  resP@gsnPanelDebug= True 
  ;  resP@pmLabelBarOrthogonalPosF	= 0.01                         
  ;  ;显示一些画图信息
  ;  ;gsn_panel(wks,plot1,(/mon_num,1/),resP)
  ;  gsn_panel(wks,plot1(0),1,resP)


  end