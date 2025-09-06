;;input data
;coordinate needed: time("seconds since ..."),lat(need to change to radian),lon(need to change to radian),P(Pa)
;var needed: q(kg/kg),u(m/s),v(m/s),omega(Pa/s)
; p       - Pressure [Pa]
; u,v     - zonal, meridional wind components[m/s]
; q       - specific humidity [kg/kg];ERA5_daily:kg/kg
; omega   - vertical velocity [Pa/s]
;;the script calculates the column-integrated atmospheric moisture flux equation according to the following equation:
;;­dq/dt-(udq/dx+vdq/dy)-wdq/dp=p-e
;;------------------------------------------------------
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "/wind1/home/zhangh825/mytool.ncl"
begin
;options for user
;**********************************************************************
ymstar	= 198001
ymend	  = 202012

monmin	= ispan(1,12,1)	;starting month for averaging,(monmin != 0,-12 <= monmin <= monmax <=12). negative value for previou year(year(-1)) 
monmax	= ispan(1,12,1)	;ending month for averaging,	   1<= monmax <= 12 
; mm      = 7
year = ispan(1980,2020,1)
nmon = dimsizes(monmin)
;;------------------------------------------------------
varname_x	= "u"             	;variable name
varname_y	= "v"
varname_t	= "t"
varname_sp	= "sp"
;;------------------------------------------------------
filename_x	= "ERA5.mon.u_component_of_wind.1950-2022.nc"	;filename
filename_y	= "ERA5.mon.v_component_of_wind.1950-2022.nc"
filename_t  = "ERA5.mon.temperature.1950-2022.nc"
filename_sp = "ERA5.mon.surface_pressure.1950-2022.nc"
;;------------------------------------------------------
filedir_x	= "/wind1/home/zhangh825/data/ERA5/"		
filedir_y	=  "/wind1/home/zhangh825/data/ERA5/"
filedir_t	=  "/wind1/home/zhangh825/data/ERA5/"
filedir_sp  =  "/wind1/home/zhangh825/data/ERA5/"
;;------------------------------------------------------
months	= (/"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"/)
dtrend_flag	= 0	; 0 for row data, else for detrended data
;Options for output
savedir		= "./"
plotdir     = savedir
;;-------------------------------------------------------------------
  ;;;handle the variable
  ;variable for Control experiment
  fx		= addfile(filedir_x+filename_x,"r")
  tim		= fx->time
  u_time_DATE	= cd_calendar(tim,-1)
  tstar		= ind(u_time_DATE .eq. ymstar)
  tlast		= ind(u_time_DATE .eq. ymend)
  print(tstar)
  print(tlast)
  varx    =  short2flt(fx->$varname_x$(tstar:tlast,::-1,::-1,:)) ;level is from 1-1000
  printVarSummary(varx)
  delete([/tstar,tlast,tim,u_time_DATE/])
  
  ;;------------------------------------------------------------
  fy		= addfile(filedir_y+filename_y,"r")
  tim           = fy->time
  v_time_DATE   = cd_calendar(tim,-1)
  tstar         = ind(v_time_DATE .eq. ymstar) 
  tlast         = ind(v_time_DATE .eq. ymend)
  print(tstar)
  print(tlast)
  vary    = short2flt(fy->$varname_y$(tstar:tlast,::-1,::-1,:))
  printVarSummary(vary)
  delete([/tstar,tlast,tim,v_time_DATE/])
  
  ;;------------------------------------------------------------
  ft		= addfile(filedir_t+filename_t,"r")
  tim           = ft->time
  u_time_DATE   = cd_calendar(tim,-1)
  tstar         = ind(u_time_DATE .eq. ymstar)      
  tlast         = ind(u_time_DATE .eq. ymend)
  print(tstar)
  vart    = short2flt(ft->$varname_t$(tstar:tlast,::-1,::-1,:))
  printVarSummary(vart)
  delete([/tstar,tlast,tim,u_time_DATE/])
  
 opt_adv   = 0 ;opt=0 means only return the advection result.
 gridType  = 1  ;gridType=0 means gaussian grid; gridType=1 means regular or fixed grid.
 long_name = "advection of temperature"
 units="kg/(s*m2)"
 advq_1      = -1.0*advect_variable(varx,vary,vart,gridType,long_name,units,opt_adv) 
 copy_VarCoords(vart,advq_1)
 printVarSummary(advq_1) 
 delete([/long_name,units/])

 savename1 = "ERA5.advT"+"."+ymstar/100+"-"+ymend/100+".nc"
 system("/bin/rm -f "+savedir+savename1)
 fout1		= addfile(savedir+savename1,"c")
 fout1->advT	= advq_1(:,:,::-1,:)
 fout1@title	= "advection of temperature"
 fout1@detrend	= dtrend_flag +"--(0 for raw data, else for detrended data)" 

end
 