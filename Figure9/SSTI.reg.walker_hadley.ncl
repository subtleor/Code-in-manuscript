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

;------------------------------------------------------------------------------------ 
  ;var for space distribution
  var_dat       = "ERA5"  
  var_filedir   = "/mnt/e/westsouth/data/"
 
  varname1       = "u"
  var_filename1  = "ERA5_u_mon_197901_202209.nc"

  varname2       = "v"  
  var_filename2  = "ERA5_v_mon_197901_202209.nc"

  varname3      = "w"  
  var_filename3 = "ERA5_vertical-velocity_mon_197901_202112.nc"
;------------------------------------------------------------------------------------
 ;Options for user
 area_ave = "Y_N"
 
 ts_a  = 1
 ts_name      = "ICP_SMI_MAM"
 tsname  = ts_name+"_JA_PC"+ts_a

 ts_dat       = "ICP_SMI"
 ts_filedir   = "/mnt/e/westsouth/yunnan/essay1/"
 ts_filename  = "ICP_swvl1_MAM.txt"

;---------------------------------------------------------------
ts_ys     = 1980     ;ts start year 
ts_ye     = 2020     ;ts end year 

ymstar		= 198001
ymend			= 202012
monmin    =   6
monmax    =   8
season    = "JJA"

yearmin  = 1980
yearmax  = 2020
;---------------------------------------------------
dtrend_flag = 1     ; 0 for raw,else for detrend         ;detrend:去趋势
area_flag = 3
cor_reg_flag	= "reg"		; "cor" or "reg"
maxy_flag		= 0			; years for lead or lag the currnet year(Y(0)) 
;---------------------------------------------------

;spatial distribution
  lvlmin = 200
  lvlmax = 1000

  latmin_z     = 20;这个是对纬度平均的，最后输出改为z那个
  latmax_z     = 30;
  lonmin_z     = 90
  lonmax_z     = 120
  
  latmin	= 0 			;area range
  latmax	= 50
  lonmin	= 45
  lonmax	= 130

  latmin_m     = 10;m是对经度平均的，最后输出也要改成m那个
  latmax_m     = 35
  lonmin_m     = 95;85;120
  lonmax_m     = 106;95;140
  
  lonreverse = 290
  centerlon  = 180;(lonmin+lonmax)/2.
 ;options for draw_plot改了范围这里也要改
 monname  = "JJA"
 varnameplot = "VW"
 RS     = "JJA(0)";"75E-120E"
 LS    = "(d) Reg. v&w on "+ts_dat
 PN = ""
 plotarea = "XY"
 vcf = 0.3
  ;output 
 ;----------------------------------------
 plottype      = "pdf"
 plotdir       =  "./"
 plotname      = "walker"+LS+"_"+RS+"(mask)_"+season+"*-1"

;**********************************************************************
;Handle variable
;**********************************************************************
   ;read time series
   Ts_f=asciiread(ts_filedir+ts_filename, ts_ye-ts_ys+1, "float")
   Ts_f=-1*Ts_f
   Ts_f!0="year"
   Ts_f&year= ispan(1980,2020,1)

   printVarSummary(Ts_f)
   
   ;print(Ts_f({year|2019:2020},evn|1))
   ;exit
   Ts_data			= Ts_f({year|ymstar/100:ymend/100})
   copy_VarCoords(Ts_f,Ts_data)
   Ts = Ts_data ;已经标准化，去趋势
   printVarSummary(Ts) 
 
;------------------------------------------------------------------------------------   
;*variable
;----------------------------------------------------------------------------------------
  ;--------------------------------------------------------
  ;red var
  fu             = addfile(var_filedir+var_filename1, "r")
  fv             = addfile(var_filedir+var_filename2, "r")
  fw             = addfile(var_filedir+var_filename3, "r")

  tim		= fu->time
  u_time_DATE	= cd_calendar(tim,-1)
  tstar		= ind(u_time_DATE .eq. ymstar)
  tlast		= ind(u_time_DATE .eq. ymend)
  print(tstar)
  print(tlast)  

  var_u		= short2flt(fu->$varname1$(tstar:tlast,:,{latmin:latmax},{lonmin:lonmax}))
  var_u!0		= "time"
  var_u!1		= "level"
  var_u!2		= "lat"
  var_u!3		= "lon"
  printVarSummary(var_u)
  printMinMax(var_u,0)

  varu_monave		= month_to_monave(var_u,monmin,monmax)
  delete([/var_u/])
  printVarSummary(varu_monave)
  printMinMax(varu_monave,0)
  nyear				= dimsizes(varu_monave&year)
  nz				= dimsizes(varu_monave&level)
  ny				= dimsizes(varu_monave&lat)
  nx				= dimsizes(varu_monave&lon)
  printVarSummary(varu_monave)

  var_v         = short2flt(fv->$varname2$(tstar:tlast,:,{latmin:latmax},{lonmin:lonmax}))
  var_v!0		= "time"
  var_v!1		= "level"
  var_v!2		= "lat"
  var_v!3		= "lon"
  varv_monave    = month_to_monave(var_v,monmin,monmax)
  delete([/var_v/])
  var_w         = short2flt(fw->$varname3$(tstar:tlast,:,{latmin:latmax},{lonmin:lonmax}))
  var_w!0		= "time"
  var_w!1		= "level"
  var_w!2		= "lat"
  var_w!3		= "lon"
  varw_monave    = month_to_monave(var_w,monmin,monmax)
  delete([/var_w/])
  printVarSummary(varw_monave)
;------------------------------------------------------
  ; system("/bin/rm -f "+plotdir+"ERA5_uvw_mon_1.0_1980_2022_JJA.nc")
  ; fo                 = addfile(plotdir+"ERA5_uvw_mon_1.0_1980_2022_JJA.nc","c")
  ; filedimdef(fo,"time",-1,True)
  ; fo->u        = var_u
  ; fo->v        = var_v
  ; fo->w        = var_w
;------------------------------
 varf2   = varu_monave
 varf3   = varv_monave
 varf4   = varw_monave
 printVarSummary(varf4)
 delete([/varu_monave,varv_monave,varw_monave/])
;------------------------------------------------------------------------------------------------------------
  varx = varf2({ts_ys:ts_ye},:,:,:) ;u
  vary = varf3({ts_ys:ts_ye},:,:,:) ;v
  varz = varf4(:,:,:,:)             ;w !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  varz =(/varz*-100./)
  printVarSummary(varz)
  delete([/varf2,varf3,varf4/])

  varxz	= sqrt(varx^2+varz^2)
  copy_VarCoords(varx,varxz)
  varxz@long_name	= "sqrt(varx^2+varz^2)"
  printVarSummary(varxz)

  varyz	= sqrt(vary^2+varz^2)
  copy_VarCoords(vary,varyz)
  varyz@long_name	= "sqrt(vary^2+varz^2)"
  printVarSummary(varyz)
  
;------------------------------------------------------------------------------------------------------------
  varx_z =dim_avg_n_Wrap(varx(:,{:lvlmax},{latmin_z:latmax_z},{lonmin_z:lonmax_z}), 2) 
  printVarSummary(varx_z)

  ; varx_m =dim_avg_n_Wrap(varx(:,{:lvlmax},{latmin_m:latmax_m},{lonmin_m:lonmax_m}), 3) 
  ; printVarSummary(varx_m)
  delete([/varx/])
  ;----------------------------------------------------------------------------------------
  ; vary_z =dim_avg_n_Wrap(vary(:,{:lvlmax},{latmin_z:latmax_z},{lonmin_z:lonmax_z}), 2) 
  ; printVarSummary(vary_z)

  vary_m =dim_avg_n_Wrap(vary(:,{:lvlmax},{latmin_m:latmax_m},{lonmin_m:lonmax_m}),3) 
  printVarSummary(vary_m)
  delete([/vary/])
  ;----------------------------------------------------------------------------------------
  varz_z =dim_avg_n_Wrap(varz(:,{:lvlmax},{latmin_z:latmax_z},{lonmin_z:lonmax_z}), 2) 
  printVarSummary(varz_z)

  varz_m =dim_avg_n_Wrap(varz(:,{:lvlmax},{latmin_m:latmax_m},{lonmin_m:lonmax_m}), 3) 
  printVarSummary(varz_m)
  delete([/varz/])
  ;--------------------------------------------------------------------------------------
  varxz_z =dim_avg_n_Wrap(varxz(:,{:lvlmax},{latmin_z:latmax_z},{lonmin_z:lonmax_z}), 2) 
  printVarSummary(varxz_z)

  varxz_m =dim_avg_n_Wrap(varxz(:,{:lvlmax},{latmin_m:latmax_m},{lonmin_m:lonmax_m}), 3) 
  printVarSummary(varxz_m)
  delete([/varxz/])
  ;----------------------------------------------------------------------------------------
  
  ; varyz_z =dim_avg_n_Wrap(varyz(:,{:lvlmax},{latmin_z:latmax_z},{lonmin_z:lonmax_z}), 2) 
  ; printVarSummary(varyz_z)

  varyz_m =dim_avg_n_Wrap(varyz(:,{:lvlmax},{latmin_m:latmax_m},{lonmin_m:lonmax_m}), 3) 
  printVarSummary(varyz_m)
  delete([/varyz/])
  ;----------------------------------------------------------------------------------------
  ; for zonal(walker) circulation
;-------------------------------------------------------------------------------------------------------
  var_latave11   = varx_z(:,:,:)  ;u_latave
  var_latave12   = varz_z(:,:,:)  ;w_latave
  varm_latave1   = varxz_z(:,:,:)  ;uw_latave

  var_latave21   = vary_m(:,:,:)  ;v_lonave
  var_latave22   = varz_m(:,:,:)  ;w_lonave
  varm_latave2   = varyz_m(:,:,:)  ;vw_lonave
  
  printVarSummary(var_latave11)
  printVarSummary(var_latave21)
  
  delete([/varx_z,varz_z,varxz_z,vary_m,varz_m,varyz_m/])

;;---------------------------------------------------------------------------------------------------------
  ;;-------------whether dtrended or not------------------------------
  if dtrend_flag .eq. 0 then  
     var_latave11 = var_latave11
     var_latave11@detrend				= dtrend_flag +"--(0 for raw data, else for detrended data)" 
     
     var_latave12 = var_latave12
     var_latave12@detrend				= dtrend_flag +"--(0 for raw data, else for detrended data)" 

     varm_latave1			= varm_latave1
     varm_latave1@detrend= dtrend_flag +"--(0 for raw data, else for detrended data)"

     var_latave21 = var_latave21
     var_latave21@detrend				= dtrend_flag +"--(0 for raw data, else for detrended data)" 
     
     var_latave22 = var_latave22
     var_latave22@detrend				= dtrend_flag +"--(0 for raw data, else for detrended data)" 

     varm_latave2			= varm_latave2
     varm_latave2@detrend= dtrend_flag +"--(0 for raw data, else for detrended data)"
     
     Ts         = Ts 
     Ts@detrend				= dtrend_flag +"--(0 for raw data, else for detrended data)" 
  else
     var_latave11	= (/dtrend_msg_n(ispan(1,dimsizes(var_latave11&year),1)*1.0,var_latave11,False,True,0)/)
     var_latave11@detrend				= dtrend_flag +"--(0 for raw data, else for detrended data)" 

     var_latave12	= (/dtrend_msg_n(ispan(1,dimsizes(var_latave12&year),1)*1.0,var_latave12,False,True,0)/)
     var_latave12@detrend				= dtrend_flag +"--(0 for raw data, else for detrended data)"
 
     varm_latave1			= (/dtrend_msg_n(ispan(1,dimsizes(varm_latave1&year),1)*1.0,varm_latave1,False,True,0)/)
     varm_latave1@detrend = dtrend_flag +"--(0 for raw data, else for detrended data)" 

     var_latave21	= (/dtrend_msg_n(ispan(1,dimsizes(var_latave21&year),1)*1.0,var_latave21,False,True,0)/)
     var_latave21@detrend				= dtrend_flag +"--(0 for raw data, else for detrended data)" 

     var_latave22	= (/dtrend_msg_n(ispan(1,dimsizes(var_latave22&year),1)*1.0,var_latave22,False,True,0)/)
     var_latave22@detrend				= dtrend_flag +"--(0 for raw data, else for detrended data)"
 
     varm_latave2			= (/dtrend_msg_n(ispan(1,dimsizes(varm_latave2&year),1)*1.0,varm_latave2,False,True,0)/)
     varm_latave2@detrend = dtrend_flag +"--(0 for raw data, else for detrended data)" 

     Ts	        = (/dtrend_msg_n(ispan(1,dimsizes(Ts&year),1)*1.0,Ts,False,True,0)/)
     Ts@detrend				= dtrend_flag +"--(0 for raw data, else for detrended data)" 
  end if
;--------------------------------------------------------------------------------------------------------------
;;----------regression----------------------------------------------------------------

  nz		= dimsizes(var_latave11&level)
  nx		= dimsizes(var_latave11&lon)
  ny    = dimsizes(var_latave21&lat)

  reg_var11					= new((/nz,nx/),"float")
  reg_var12					= new((/nz,nx/),"float")

  reg_var21					= new((/nz,ny/),"float")
  reg_var22					= new((/nz,ny/),"float")

  ;;;u_latave  
  reg_var11(:,:)	= (/regCoef(Ts(year|:),var_latave11(level|:,lon|:,year|:))/)
  ;;;w_latave 
  reg_var12(:,:)	= (/regCoef(Ts(year|:),var_latave12(level|:,lon|:,year|:))/)
  ;;;v_lonave  
  reg_var21(:,:)	= (/regCoef(Ts(year|:),var_latave21(level|:,lat|:,year|:))/)
  ;;;w_lonave 
  reg_var22(:,:)	= (/regCoef(Ts(year|:),var_latave22(level|:,lat|:,year|:))/)

  reg_var11!0 ="level"
  reg_var11!1 ="lon"
  reg_var11@units = var_latave11@units
  reg_var11@long_name = tsname+" reg "+var_latave11@long_name
  copy_VarCoords(var_latave11(0,:,:),reg_var11(:,:))
  printVarSummary(reg_var11)
  ;;--------------------------------------------------------------------------------------
  copy_VarCoords(reg_var11,reg_var12)
  reg_var12@units = var_latave12@units
  reg_var12@long_name = tsname+" reg "+var_latave12@long_name
  printVarSummary(reg_var12)
  ;-----------------------------------------------------------------------------------------------------------

  reg_var21!0 ="level"
  reg_var21!1 ="lat"
  reg_var21@units = var_latave21@units
  reg_var21@long_name = tsname+" reg "+var_latave21@long_name
  copy_VarCoords(var_latave21(0,:,:),reg_var21(:,:))
  printVarSummary(reg_var21)
  ;;--------------------------------------------------------------------------------------
  copy_VarCoords(reg_var21,reg_var22)
  reg_var22@units = var_latave22@units
  reg_var22@long_name = tsname+" reg "+var_latave22@long_name
  printVarSummary(reg_var22)
;--------------------------------------------------------------------------------------------------------------
  cor_var11					= new((/nz,nx/),"float")
  cor_var12					= new((/nz,nx/),"float")
  cor_varm1					= new((/nz,nx/),"float")

  cor_var21					= new((/nz,ny/),"float")
  cor_var22					= new((/nz,ny/),"float")
  cor_varm2					= new((/nz,ny/),"float")
 
 
  ;;---------------correlation1------------------------------------------
  cor_var11(:,:) = escorc(Ts(year|:),var_latave11(level|:,lon|:,year|:)) ; uq correlation
  cor_var12(:,:) = escorc(Ts(year|:),var_latave12(level|:,lon|:,year|:)) ; uq correlation
  ;;;-----------------sqrt(vay^2)---------------------------------
  cor_varm1(:,:) = escorc(Ts(year|:),varm_latave1(level|:,lon|:,year|:)) 
  
  cor_var21(:,:) = escorc(Ts(year|:),var_latave21(level|:,lat|:,year|:)) ; uq correlation
  cor_var22(:,:) = escorc(Ts(year|:),var_latave22(level|:,lat|:,year|:)) ; uq correlation
  cor_varm2(:,:) = escorc(Ts(year|:),varm_latave2(level|:,lat|:,year|:)) 
 
  ;--------------------------------------------------------------------------------------------------------------
   tValue		= new(3,"float")				
   rflag	  = new(3,"float")
    n				= dimsizes(Ts&year)
   tValue	  = cdft_t((/1-0.05,1-0.025,1-0.005/),(/n-2,n-2,n-2/))
   rflag		= sqrt(tValue^2/(n-2+tValue^2))
   rflag		= round(rflag*100.0,0)/100.0		;round the float data
  ;--------------------------------------------------------------------------------------------------------------
   copy_VarCoords(reg_var11,cor_var11)
   cor_var11@tValue			  = tValue
   cor_var11@tValue_desc	= "Critical t Value for 0.1,0.05,001 significant level"
   cor_var11@rflag				= rflag
   cor_var11@rflag_desc		= "Critical correlation for 0.1,0.05,001 significant level"
   printVarSummary(cor_var11)
   ;;;;------------------------------------------------------------------------
   copy_VarCoords(cor_var11,cor_var12)
   cor_var12@tValue			  = tValue
   cor_var12@tValue_desc	= "Critical t Value for 0.1,0.05,001 significant level"
   cor_var12@rflag				= rflag
   cor_var12@rflag_desc		= "Critical correlation for 0.1,0.05,001 significant level"
   printVarSummary(cor_var12)
   ;;;-----------------sqrt(varx^2+vary^2)---------------------------------
   copy_VarCoords(cor_var11,cor_varm1)
   cor_varm1@tValue			  = tValue
   cor_varm1@tValue_desc	= "Critical t Value for 0.1,0.05,001 significant level"
   cor_varm1@rflag				= rflag
   cor_varm1@rflag_desc		= "Critical correlation for 0.1,0.05,001 significant level"
   printVarSummary(cor_varm1)
   ;;---------------------------------------------------------------------------
   corxymax1				= where(abs(cor_var11) .gt. abs(cor_var12),abs(cor_var11),abs(cor_var12))
   copy_VarCoords(cor_var11,corxymax1)
   corxymax1@tValue			  = tValue
   corxymax1@tValue_desc	= "Critical t Value for 0.1,0.05,001 significant level"
   corxymax1@rflag				= rflag
   corxymax1@rflag_desc		= "Critical correlation for 0.1,0.05,001 significant level"
   corxymax1@long_name	= "an element-by-element minimum or maximum between abs(corx) and abs(cory)"
   printVarSummary(corxymax1) 
;--------------------------------------------------------------------------------------------------------------
   ;;---------------correlation2------------------------------------------
  copy_VarCoords(reg_var21,cor_var21)
   cor_var21@tValue			  = tValue
   cor_var21@tValue_desc	= "Critical t Value for 0.1,0.05,001 significant level"
   cor_var21@rflag				= rflag
   cor_var21@rflag_desc		= "Critical correlation for 0.1,0.05,001 significant level"
   printVarSummary(cor_var21)
   ;;;;------------------------------------------------------------------------
   copy_VarCoords(cor_var21,cor_var22)
   cor_var22@tValue			  = tValue
   cor_var22@tValue_desc	= "Critical t Value for 0.1,0.05,001 significant level"
   cor_var22@rflag				= rflag
   cor_var22@rflag_desc		= "Critical correlation for 0.1,0.05,001 significant level"
   printVarSummary(cor_var22)
   ;;;-----------------sqrt(varx^2+vary^2)---------------------------------
   copy_VarCoords(cor_var21,cor_varm2)
   cor_varm2@tValue			  = tValue
   cor_varm2@tValue_desc	= "Critical t Value for 0.1,0.05,001 significant level"
   cor_varm2@rflag				= rflag
   cor_varm2@rflag_desc		= "Critical correlation for 0.1,0.05,001 significant level"
   printVarSummary(cor_varm2)
   ;;---------------------------------------------------------------------------
   corxymax2				= where(abs(cor_var21) .gt. abs(cor_var22),abs(cor_var21),abs(cor_var22))
   copy_VarCoords(cor_var21,corxymax2)
   corxymax2@tValue			  = tValue
   corxymax2@tValue_desc	= "Critical t Value for 0.1,0.05,001 significant level"
   corxymax2@rflag				= rflag
   corxymax2@rflag_desc		= "Critical correlation for 0.1,0.05,001 significant level"
   corxymax2@long_name	= "an element-by-element minimum or maximum between abs(corx) and abs(cory)"
   printVarSummary(corxymax2) 
;--------------------------------------------------------------------------------------------------------------  
  ;;----------------------------------------------------------------------------
   if area_flag .eq. 0 	; x-> only
   
    corxy_plot1		= cor_var11
    corxy_plot2		= cor_var21

  end if  
  ;;-------------------------------------------------------------------------
  if area_flag .eq. 1	; y-> only
  
		corxy_plot1		= cor_var12
    corxy_plot2		= cor_var22
  
  end if 
 ;;-------------------------------------------------------------------------
  if area_flag .eq. 2	; x-> or y-> 
    	
		corxy_plot1		= corxymax1
    corxy_plot2		= corxymax2
		
  end if 
  ;;-------------------------------------------------------------------------
  if area_flag .eq. 3	; sqrt(x^2+y^2) 
  
		corxy_plot1		= cor_varm1
    corxy_plot2		= cor_varm2
  
  end if
 delete([/var_latave11,var_latave12,varm_latave1,var_latave21,var_latave22,varm_latave2,Ts/])
;---------------------------------------------------------------------------------------
  ;save anomaly data 
  savedir    =  "./"
  area1      = abs(latmin_z)+"S"+"-"+abs(latmax_z)+"N"
  savename1  = var_dat+"."+tsname+".reg.Walker.uw."+area1+".mon.nc"
  area2      = abs(lonmin_m)+"E"+"-"+abs(lonmax_m)+"E"
  savename2  = var_dat+"."+tsname+".reg.Hadley.vw."+area2+".mon.nc"
  system("/bin/rm -f " +(savedir+savename1))
  fo1 = addfile(savedir+savename1, "c")
  fo1 ->u_reg     = reg_var11
  fo1 ->w_reg     = reg_var12
  fo1 ->u_cor     = cor_var11
  fo1 ->w_cor     = cor_var12
  fo1 ->uwmax_cor = corxymax1
  fo1 ->uwm_cor   = cor_varm1
  fo1@title = tsname+".reg.Walker.mean in "+area1
  print(fo1)

  system("/bin/rm -f " +(savedir+savename2))
  fo2 = addfile(savedir+savename2, "c")
  fo2 ->v_reg     = reg_var21
  fo2 ->w_reg     = reg_var22
  fo2 ->v_cor     = cor_var21
  fo2 ->w_cor     = cor_var22
  fo2 ->vwmax_cor = corxymax2
  fo2 ->vwm_cor   = cor_varm2
  fo2@title = tsname+".reg.Hadley.mean in "+area2
  print(fo2)
;----------------------------------------------------------------------------------------------------------------------
;*draw variable
  var1x     = reg_var11
  var1y     = reg_var12
  var1s     = corxy_plot1

  var2x     = reg_var21
  var2y     = reg_var22
  var2s     = corxy_plot2

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
  geog_lat = dim_avg_n_Wrap(geog({latmin_z:latmax_z},{lonmin_z:lonmax_z}),0)
  geog_lon = dim_avg_n_Wrap(geog({latmin_m:latmax_m},{lonmin_m:lonmax_m}),1)
  printVarSummary(geog_lat)
    
  ;; Determine the terrain
  Mask_var1x  = reg_var11
  Mask_var1x@_FillValue = reg_var11@_FillValue
  tp3d_var1x   = conform(reg_var11,geog_lat,1)
  high3d_var1x = conform(reg_var11,reg_var11&level,0)
  Mask_var1x = (/mask(reg_var11,tp3d_var1x.lt.high3d_var1x,False)/)
  printVarSummary(Mask_var1x)

  Mask_var1y  = reg_var12
  Mask_var1y@_FillValue = reg_var12@_FillValue
  tp3d_var1y   = conform(reg_var12,geog_lat,1)
  high3d_var1y = conform(reg_var12,reg_var12&level,0)
  Mask_var1y = (/mask(reg_var12,tp3d_var1y.lt.high3d_var1y,False)/)
  printVarSummary(Mask_var1y)

  Mask_tvalue1s  = corxy_plot1
  Mask_tvalue1s@_FillValue = corxy_plot1@_FillValue
  tp3d_tvalue1s  = conform(corxy_plot1,geog_lat,1)
  high3d_tvalue1s = conform(corxy_plot1,corxy_plot1&level,0)
  Mask_tvalue1s@_FillValue = corxy_plot1@_FillValue
  Mask_tvalue1s = (/mask(corxy_plot1,tp3d_tvalue1s.lt.high3d_tvalue1s,False)/)
  printVarSummary(Mask_tvalue1s)

  ;//补充关于reg_var22和cor_var22和corxymax2的mask
  Mask_var2x  = reg_var21
  Mask_var2x@_FillValue = reg_var21@_FillValue
  tp3d_var2x   = conform(reg_var21,geog_lon,1)
  high3d_var2x = conform(reg_var21,reg_var21&level,0)
  Mask_var2x = (/mask(reg_var21,tp3d_var2x.lt.high3d_var2x,False)/)
  printVarSummary(Mask_var2x)

  Mask_var2y  = reg_var22
  Mask_var2y@_FillValue = reg_var22@_FillValue
  tp3d_var2y   = conform(reg_var22,geog_lon,1)
  high3d_var2y = conform(reg_var22,reg_var22&level,0)
  Mask_var2y = (/mask(reg_var22,tp3d_var2y.lt.high3d_var2y,False)/)
  printVarSummary(Mask_var2y)

  Mask_tvalue2s  = corxy_plot2
  Mask_tvalue2s@_FillValue = corxy_plot2@_FillValue
  tp3d_tvalue2s  = conform(corxy_plot2,geog_lon,1)
  high3d_tvalue2s = conform(corxy_plot2,corxy_plot2&level,0)
  Mask_tvalue2s@_FillValue = corxy_plot2@_FillValue
  Mask_tvalue2s = (/mask(corxy_plot2,tp3d_tvalue2s.lt.high3d_tvalue2s,False)/)
  printVarSummary(Mask_tvalue2s)

  ;;-----------------------------------------------------------------------
;*********************************************************************************************************************
;plotting
;*********************************************************************************************************************
  wks       = gsn_open_wks(plottype,plotdir+plotname)
  gsn_define_colormap(wks,"BlueDarkRed18") ; BlueDarkRed18   cmp_b2r

  res               = True
  res@gsnDraw       = False
  res@gsnFrame      = False
  res@gsnAddCyclic  = False  ; region only

  res@cnLinesOn         = False
  res@cnLineLabelsOn    = False
  res@cnInfoLabelOn     = False
  res@cnFillOn          = True
  res@cnFillDrawOrder       = "PreDraw"

  ; Resources for Axis
  font_height               = 0.022                                 
  res@tmYLLabelFontHeightF  = font_height
  res@tmXBLabelFontHeightF  = font_height
  res@tiXAxisFontHeightF    = 1.2 * font_height
  res@tiYAxisFontHeightF    = 1.2 * font_height
  res@tiMainFontHeightF     = 1.2 * font_height
  res@tiMainOffsetYF        = -0.01
  res@gsnLeftStringFontHeightF=0.025
  res@gsnRightStringFontHeightF=0.025
  res@gsnLeftStringOrthogonalPosF    = -0.01
  res@gsnRightStringOrthogonalPosF   = -0.01  

  ; res@gsnStringFont              =  "helvetica-bold"
  ; res@tiMainFont                 = "helvetica-bold"
  ; res@tiXAxisFont                = "helvetica-bold"
  ; res@tmXBLabelFont              = "helvetica-bold"
  ; res@tmYLLabelFont              = "helvetica-bold"
  ; res@lbLabelFont                = "helvetica-bold"
  ; res@vcRefAnnoFont              ="helvetica-bold"

  ; res@lgLabelFont                ="helvetica-bold"
  ; res@gsnStringFont              =  "helvetica-bold"
  ; res@tiMainFont                 = "helvetica-bold"

  ;Resource for vector
  res@vcRefMagnitudeF     = vcf
  res@vcRefLengthF        = 0.035
  res@vcMinDistanceF      = 0.022;0.025
  res@vcMagnitudeFormat     = "@*+^sg"
  res@vcFillArrowEdgeThicknessF = 0.3
  res@vcRefAnnoOn       = True  
  res@vcRefAnnoOrthogonalPosF = -1.06;-1.185
  res@vcRefAnnoParallelPosF = 0.97
  ;res@vcRefAnnoBackgroundColor  = "White"; -1.
  res@vcRefAnnoPerimOn      = True 
  ; res@vcGlyphStyle       = "CurlyVector"
  res@vcLineArrowColor   = "black"
  ;res@vcPositionMode     = "ArrowHead"
  res@vcGlyphStyle		   = "CurlyVector";FillArrow;LineArrow;CurlyVector
  res@vcRefAnnoString2On = False
  res@vcRefAnnoString1On    = True

  res@vcMinAnnoFontHeightF  = True
  res@vcMinAnnoFontHeightF   = 0.15

   res@vcLineArrowThicknessF = 3.

    res@tmXBMinorOn        = False
    res@tmYLMinorOn        = False
    res@tmXTOn             = False
    res@tmYROn             = False
    res@tmYRLabelsOn       = False
    res@tmYRMode           = "Automatic"

    res@tmYLMode              = "Explicit"
    res@tmYLValues            = (/200,250,300,400,500,600,700,850,1000/)
    res@tmYLLabels            = res@tmYLValues+"hPa"
    res@pmTickMarkDisplayMode="Always"




    res@tmYLMinorOn        = False
    res@tiYAxisString=""

    res@cnLevelSelectionMode	= "ExplicitLevels"
    res@cnFillColors			=  (/14,-1,14/);(/"yellow2","yellow","transparent","yellow","yellow2"/)
    res@cnLevels		       	= (/-rflag(1),rflag(1)/)
    res@cnMissingValFillColor    = "gray40" ; set color for missing areas

;------------------------------------------------------------------------------------------------------------------
  ; res@vpWidthF  = 0.43
  ; res@vpHeightF = 0.16
  res@vpHeightF	= 0.45
  res@vpWidthF		= 0.70


  ; res@lbOrientation                 = "Horizontal";"Vertical"
  ; res@lbLabelBarOn                  = True
  ; res@pmLabelBarParallelPosF        =  0.5
  ; res@pmLabelBarOrthogonalPosF      = 0.23
  ; res@pmLabelBarHeightF             = 0.05
  ; res@pmLabelBarWidthF              = 0.4
  ; res@lbLabelFontHeightF            = 0.012
;------------------------------------------------------------------------------------------------------------------
   res1=res
  res1@tmYRMode = "Automatic"
  res1@gsnMajorLatSpacing = 5
  res1@gsnMinorLatSpacing = 5
  
 ; res1@cnFillColors       = 
  res1@gsnLeftString  = LS
  res1@gsnRightString = RS

  
  plot  =  gsn_csm_pres_hgt_vector(wks,Mask_tvalue2s({lvlmin:lvlmax},{latmin_m:latmax_m}),\
  Mask_var2x({lvlmin:lvlmax},{latmin_m:latmax_m}),Mask_var2y({lvlmin:lvlmax},{latmin_m:latmax_m}),res1)
  ; plot  =  gsn_csm_pres_hgt_vector(wks,Mask_tvalue1s({lvlmin:lvlmax},{lonmin_z :lonmax_z}),\
  ; Mask_var1x({lvlmin:lvlmax},{lonmin_z:lonmax_z}),Mask_var1y({lvlmin:lvlmax},{lonmin_z:lonmax_z}),res1)
  draw(plot)
  frame(wks)

  end