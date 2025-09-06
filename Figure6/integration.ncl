;;------------------------------------------------------
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "/mnt/e/mytool.ncl"
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
varname_x	= "Tadv"             	;variable name
varname_sp = "sp"                 ;variable name for control experiment
;;------------------------------------------------------
filename_x	= "ERA5.advect.T.mon.mean.195001_202212.nc"	;filename
filename_sp = "ERA5.mon.surface_pressure.1950-2022.nc"

;;-----------------------------------------------------
filedir_x	= "/mnt/e/westsouth/data/"		
filedir_sp  = "/mnt/e/westsouth/data/"

;;-----------------------------------------------------
months	= (/"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"/)
dtrend_flag	= 1	; 0 for row data, else for detrended data
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
  varx    =  short2flt(fx->$varname_x$(tstar:tlast,::-1,:,:)) ;level is from 1-1000
  printVarSummary(varx)
  delete([/tstar,tlast,tim,u_time_DATE/])
  ;;-------------------------------------------------------------
  f1		= addfile(filedir_sp+filename_sp,"r")
  time           = f1->time
  u_time_DATE   = cd_calendar(time,-1)
  tstar         = ind(u_time_DATE .eq. ymstar)      
  tlast         = ind(u_time_DATE .eq. ymend)
  print(tstar)
  ; print(f1)
  var_sp    = short2flt(f1->$varname_sp$(tstar:tlast,:,:))
  ; var_sp = lonPivot(var_sp,0.0)   ;;;Attention the longitude
  printVarSummary(var_sp)
  delete([/tstar,tlast,time,u_time_DATE/])

 ;;-------------------------------------------------------------
 nmon = dimsizes(monmin-1)
 dims = dimsizes(varx)

 varu_monave = new((/dims(0)/12,nmon,dims(1),dims(2),dims(3)/),float)

 varsp_monave = new((/dims(0)/12,nmon,dims(2),dims(3)/),float)
 do i = 0,nmon-1
 varu_monave(:,i,:,:,:)	= month_to_monave(varx,monmin(i),monmax(i))

 varsp_monave(:,i,:,:)	= month_to_monave(var_sp,monmin(i),monmax(i))
 end do

 varu_monave!1 = "month"
 varu_monave&month = monmin
 varu_monave!3 = "lat"
 varu_monave!4 = "lon"
printVarSummary(varu_monave)
 varsp_monave!1 = "month"
 varsp_monave&month = monmin
 varsp_monave!2 = "lat"
 varsp_monave!3 = "lon"

 copy_VarCoords(varu_monave(0,0,0,:,:),varsp_monave(0,0,:,:))
 printVarSummary(varsp_monave)
 delete([/varx,var_sp/])
 
   if dtrend_flag .eq. 0 
   
     varu_monave		= varu_monave
     varu_monave@detrend	= dtrend_flag +"--(0 for raw data, else for detrended data)" 
     varsp_monave		= varsp_monave
     varsp_monave@detrend	= dtrend_flag +"--(0 for raw data, else for detrended data)" 
  
   else

     varu_monave			= (/dtrend_msg_n(ispan(1,dimsizes(varu_monave&year),1)*1.0,varu_monave,False,True,0)/) 
     varu_monave@detrend	= dtrend_flag +"--(0 for raw data, else for detrended data)" 
     varsp_monave			= (/dtrend_msg_n(ispan(1,dimsizes(varsp_monave&year),1)*1.0,varsp_monave,False,True,0)/) 
     varsp_monave@detrend	= dtrend_flag +"--(0 for raw data, else for detrended data)" 
   end if
   sp = varsp_monave(:,:,::-1,:)
   printVarSummary(sp)
 ;;-----------------------------------------------------------------------------------
 ;;----------Vertical integration of the whole atmosphere---------------------------------
 plev0 = varx&level
 plev = plev0*100.0 ;need to change [hPa] to [Pa]
 plev@units	= "Pa"
 
  ptop  = 100*100                     ; Pa
  pbot  = sp;max(plev)
  vopt  = 1 ;;iopt=1 weighted vertical sum;iopt=0 weighted vertical average

  p       = plev                                     ; Pa  [100000,...,10000]
  p@units = "Pa"
  p!0     = "p"
  p&p     =  p                   ; not necessary
  printVarSummary(p)
  print("---")

  g     = 9.80665                      ; [m/s2] gravity at 45 deg lat used by the WMO
  dims  = dimsizes(varu_monave)
  print(dims)
  
  ; dp    = new((/dims(0),dims(1),dims(2),dims(3)/),float)
  dpg    = new((/dims(0),dims(1),dims(2),dims(3),dims(4)/),float)
  do m  = 0,dimsizes(pbot&month)-1
  dp    = dpres_plevel_Wrap(p,pbot(:,m,:,:),ptop,0)
  dpg00   = dp/g  
  printVarSummary(dpg00) 
  
  dpg(:,m,:,:,:)       = dpg00(:,:,:,:)              ; Pa/(m/s2)=> (Pa-s2)/m   
  dpg@long_name = "Layer Mass Weighting"
  dpg@units     = "kg/m2"               ; dp/g     => Pa/(m/s2) => [kg/(m-s2)][m/s2] reduce to (kg/m2)
                                        ;             Pa (s2/m) => [kg/(m-s2)][s2/m]=>[kg/m2]
  ; dpg  := conform(advq_1,dpg,1)             ; reassign [convenience]
  delete([/dpg00/])
  end do
  copy_VarCoords(varu_monave,dpg)
  printVarSummary(dpg)
  ; print(p(:,:,0,0))
 
  varu_monave_dpg = varu_monave*dpg 
  varu_monave_int1 = dim_sum_n(varu_monave_dpg, 2)
  varu_monave_int1@long_name = "vertically integrated advect.T from 500 to 1000"
  copy_VarCoords(varu_monave(:,:,0,:,:),varu_monave_int1)
  printMinMax(varu_monave_int1,0)
  printVarSummary(varu_monave_int1)
  print("-----")
  

  ;;---------------------------------------------------------
  ;;-------------save nc---------------------------------------
  savename1 = "ERA5.advect.T_int_500-1000(detrend)"+"."+months(0)+"-"+months(nmon-1)+"."+ymstar/100+"-"+ymend/100+".nc"
  system("/bin/rm -f "+savedir+savename1)
  fout1		= addfile(savedir+savename1,"c")
  fout1->advT_int	= varu_monave_int1(:,:,::-1,:)
  fout1@title	= "vertically integrated advect.T from 500 to 1000"
  fout1@detrend	= dtrend_flag +"--(0 for raw data, else for detrended data)" 

end