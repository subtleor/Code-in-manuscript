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
load "/wind1/home/gongylin/zh/mytool.ncl"
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
varname_w	= "w"
varname_q	= "q"
varname_sp	= "sp"
;;------------------------------------------------------
filename_x	= "ERA5_u_mon_197901_202212.nc"	;filename
filename_y	= "ERA5_v_mon_197901_202212.nc"
filename_w  = "ERA5_vertical-velocity_mon_197901_202212.nc"
filename_q  = "ERA5.mon.specific_humidity.1950-2022.nc"
filename_sp = "ERA5.mon.surface_pressure.1950-2022.nc"
;;------------------------------------------------------
filedir_x	= "/wind1/home/gongylin/data/ERA5/monthly/"		
filedir_y	= "/wind1/home/gongylin/data/ERA5/monthly/"
filedir_w	= "/wind1/home/gongylin/data/ERA5/monthly/"
filedir_q  = "/wind1/home/gongylin/data/ERA5/monthly/"
filedir_sp  = "/wind1/home/gongylin/data/ERA5/monthly/"
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
  varx    =  short2flt(fx->$varname_x$(tstar:tlast,::-1,:,:)) ;level is from 1-1000
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
  vary    = short2flt(fy->$varname_y$(tstar:tlast,::-1,:,:))
  printVarSummary(vary)
  delete([/tstar,tlast,tim,v_time_DATE/])
  
  ;;------------------------------------------------------------
  fw		= addfile(filedir_w+filename_w,"r")
  tim           = fw->time
  u_time_DATE   = cd_calendar(tim,-1)
  tstar         = ind(u_time_DATE .eq. ymstar)      
  tlast         = ind(u_time_DATE .eq. ymend)
  print(tstar)
  ; print(fw)
  varw    = short2flt(fw->$varname_w$(tstar:tlast,::-1,:,:))
  ; varw = lonPivot(varw,0.0)   ;;;Attention the longitude
  printVarSummary(varw)
  delete([/tstar,tlast,tim,u_time_DATE/])
  
  ;;------------------------------------------------------------
  fq		= addfile(filedir_q+filename_q,"r")
  tim           = fq->time
  u_time_DATE   = cd_calendar(tim,-1)
  tstar         = ind(u_time_DATE .eq. ymstar)      
  tlast         = ind(u_time_DATE .eq. ymend)
  print(tstar)
  print(tlast)
  varq    = short2flt(fq->$varname_q$(tstar:tlast,::-1,:,:))
  ;var_q		= (/var_q/1000.0/)	;Attention!!! the q of era5 is kg/kg
  ; varq = lonPivot(varq,0.0)   ;;;Attention the longitude
  printVarSummary(varq)
  delete([/tstar,tlast,tim,u_time_DATE/])
 
  ;;---------------------------------------------------
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
  
 ;;------------------------------------------------
 nmon = dimsizes(monmin-1)
 dims = dimsizes(varq)
 varu_monave = new((/dims(0)/12,nmon,dims(1),dims(2),dims(3)/),float)
 varv_monave = new((/dims(0)/12,nmon,dims(1),dims(2),dims(3)/),float)
 varw_monave = new((/dims(0)/12,nmon,dims(1),dims(2),dims(3)/),float)
 varq_monave = new((/dims(0)/12,nmon,dims(1),dims(2),dims(3)/),float)
 varsp_monave = new((/dims(0)/12,nmon,dims(2),dims(3)/),float)
 do i = 0,nmon-1
 varu_monave(:,i,:,:,:)	= month_to_monave(varx,monmin(i),monmax(i))
 varv_monave(:,i,:,:,:)	= month_to_monave(vary,monmin(i),monmax(i))
 varw_monave(:,i,:,:,:)	= month_to_monave(varw,monmin(i),monmax(i))
 varq_monave(:,i,:,:,:)	= month_to_monave(varq,monmin(i),monmax(i))
 varsp_monave(:,i,:,:)	= month_to_monave(var_sp,monmin(i),monmax(i))
 end do
 varu_monave!1 = "month"
 varu_monave&month = monmin
 varu_monave!3 = "lat"
 varu_monave!4 = "lon"
;  printVarSummary(varu_monave)
 delete([/dims/])
 copy_VarCoords(varu_monave,varv_monave)
 printVarSummary(varv_monave)
 
 copy_VarCoords(varu_monave,varw_monave)
 copy_VarCoords(varu_monave,varq_monave)

 varsp_monave!1 = "month"
 varsp_monave&month = monmin
 varsp_monave!2 = "lat"
 varsp_monave!3 = "lon"
 copy_VarCoords(varu_monave(0,0,0,:,:),varsp_monave(0,0,:,:))
 printVarSummary(varsp_monave)
 delete([/varx,vary,varw,varq,var_sp/])
 
 ;;-------------------------------------------------------------
   if dtrend_flag .eq. 0 
   
     varu_monave		= varu_monave
     varu_monave@detrend	= dtrend_flag +"--(0 for raw data, else for detrended data)" 

     varv_monave		= varv_monave
     varv_monave@detrend	= dtrend_flag +"--(0 for raw data, else for detrended data)" 
     
     varw_monave		= varw_monave
     varw_monave@detrend	= dtrend_flag +"--(0 for raw data, else for detrended data)" 

     varq_monave		= varq_monave
     varq_monave@detrend	= dtrend_flag +"--(0 for raw data, else for detrended data)" 
  
   else

     varu_monave			= (/dtrend_msg_n(ispan(1,dimsizes(varu_monave&year),1)*1.0,varu_monave,False,True,0)/) 
     varu_monave@detrend	= dtrend_flag +"--(0 for raw data, else for detrended data)" 
  
     varv_monave			= (/dtrend_msg_n(ispan(1,dimsizes(varv_monave&year),1)*1.0,varv_monave,False,True,0)/) 
     varv_monave@detrend	= dtrend_flag +"--(0 for raw data, else for detrended data)" 

     varw_monave			= (/dtrend_msg_n(ispan(1,dimsizes(varw_monave&year),1)*1.0,varw_monave,False,True,0)/) 
     varw_monave@detrend	= dtrend_flag +"--(0 for raw data, else for detrended data)" 

     varq_monave			= (/dtrend_msg_n(ispan(1,dimsizes(varq_monave&year),1)*1.0,varq_monave,False,True,0)/) 
     varq_monave@detrend	= dtrend_flag +"--(0 for raw data, else for detrended data)" 

     varsp_monave			= (/dtrend_msg_n(ispan(1,dimsizes(varsp_monave&year),1)*1.0,varsp_monave,False,True,0)/) 
     varsp_monave@detrend	= dtrend_flag +"--(0 for raw data, else for detrended data)" 
   end if
   printVarSummary(varq_monave)
   printVarSummary(varsp_monave)
   
   sp = varsp_monave(:,:,::-1,:)
   printVarSummary(sp)
   
 ;;----------------------------------------------------
 ;; -----calculate the climatology and anomalies of u,v,w,q
 varu_clm = dim_avg_n_Wrap(varu_monave(:,:,:,::-1,:),0)
 varv_clm = dim_avg_n_Wrap(varv_monave(:,:,:,::-1,:),0)
 varw_clm = dim_avg_n_Wrap(varw_monave(:,:,:,::-1,:),0)
 varq_clm = dim_avg_n_Wrap(varq_monave(:,:,:,::-1,:),0)
 printVarSummary(varq_clm)
 
 u_ano = dim_rmvmean_n_Wrap(varu_monave,0)
 v_ano = dim_rmvmean_n_Wrap(varv_monave,0)
 w_ano = dim_rmvmean_n_Wrap(varw_monave,0)
 q_ano = dim_rmvmean_n_Wrap(varq_monave,0)
 printVarSummary(q_ano)
 delete([/varu_monave,varv_monave,varw_monave,varq_monave,varsp_monave/])
 ;;----------------------------------------------------
 varu_ano = u_ano(:,:,:,::-1,:)
 varv_ano = v_ano(:,:,:,::-1,:)
 varw_ano = w_ano(:,:,:,::-1,:)
 varq_ano = q_ano(:,:,:,::-1,:)
 printVarSummary(varq_ano)
 delete([/u_ano,v_ano,w_ano,q_ano/])
 
 ;;--------------------------------------------------------
 nyear = dimsizes(year)
 print(nyear)
 
 advq_1 = new(dimsizes(varu_ano),typeof(varu_ano))
 advq_2 = new(dimsizes(varu_ano),typeof(varu_ano))
 adv_z1 = new(dimsizes(varu_ano),typeof(varu_ano))
 adv_z2 = new(dimsizes(varu_ano),typeof(varu_ano))
 do n = 0,nyear-1
 opt_adv   = 0 ;opt=0 means only return the advection result.
 gridType  = 1  ;gridType=0 means gaussian grid; gridType=1 means regular or fixed grid.
 long_name = "moisture advection caused by climatological wind and anomalous q"
 units     = "kg/(kg-s)"     ; (m/s)*(kg/kg)*(1/m)
 advq_1(n,:,:,:,:)      = -1.0*advect_variable(varu_clm,varv_clm,varq_ano(n,:,:,:,:),gridType,long_name,units,opt_adv) 
 copy_VarCoords(varu_ano,advq_1)
 printVarSummary(advq_1) 
 delete([/long_name,units/])

 long_name = "moisture advection caused by anomalous wind and mean q"
 units     = "kg/(kg-s)"     ; (m/s)*(kg/kg)*(1/m)
 advq_2(n,:,:,:,:)      = -1.0*advect_variable(varu_ano(n,:,:,:,:),varv_ano(n,:,:,:,:),varq_clm,gridType,long_name,units,opt_adv) 
 copy_VarCoords(varu_ano,advq_2)
 printVarSummary(advq_2) 
 delete([/long_name,units/])
 
 ;;-----------------------------------------------------------
 plev0 = varq_ano&level
 plev = plev0*100.0 ;need to change [hPa] to [Pa]
 plev@units	= "Pa"

 adv_z1(n,:,:,:,:)	= -1.0*varw_clm*center_finite_diff_n(varq_ano(n,:,:,:,:),plev,False,0,1)
 adv_z1@longname = "Vertical Moisture Transport caused by mean w and anomalous q"
 adv_z1@units    = "kg/(kg*s)"       ; [(Pa/s)(kg/kg)/Pa)]  
 copy_VarCoords(varu_ano,adv_z1)
 printVarSummary(adv_z1) 

 adv_z2(n,:,:,:,:)	= -1.0*varw_ano(n,:,:,:,:)*center_finite_diff_n(varq_clm,plev,False,0,1)
 adv_z2@longname = "Vertical Moisture Transport caused by anomalous w and mean q"
 adv_z2@units    = "kg/(kg*s)"       ; [(Pa/s)(kg/kg)/Pa)] 
 copy_VarCoords(varu_ano,adv_z2)
 printVarSummary(adv_z2) 
 end do

;;----------------------------------------------------------------
 long_name = "moisture advection caused by anomalous wind and anomalous q"
 units     = "kg/(kg-s)"     ; (m/s)*(kg/kg)*(1/m)
 nl_z       = -1.0*advect_variable(varu_ano,varv_ano,varq_ano,gridType,long_name,units,opt_adv) 
 copy_VarCoords(varu_ano,nl_z)
 printVarSummary(nl_z) 

 nl_h	= -1.0*varw_ano*center_finite_diff_n(varq_ano,plev,False,0,2)
 nl_h@longname = "Vertical Moisture Transport caused by anomalous w and anomalous q"
 nl_h@units    = "kg/(kg*s)"       ; [(Pa/s)(kg/kg)/Pa)] 
 copy_VarCoords(varu_ano,nl_h)
 printVarSummary(nl_h)

 nl = nl_z+nl_h
 copy_VarCoords(varu_ano,nl)
 nl@longname = "nonlinear term"
 nl@units    = "kg/(kg*s)"       ; [(Pa/s)(kg/kg)/Pa)] 
 printVarSummary(nl)
 
 ;;-----------------------------------------------------------------------------------
 ;;----------Vertical integration of the whole atmosphere---------------------------------
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
  dims  = dimsizes(advq_1)
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
  copy_VarCoords(advq_1,dpg)
  printVarSummary(dpg)
  ; print(p(:,:,0,0))
 
  advq1_dpg = advq_1*dpg 
  advqh_int1 = dim_sum_n(advq1_dpg, 2)
  advqh_int1@long_name = "vertically integrated moisture advection caused by climatological wind and anomalous q"
  advqh_int1@units     = "kg/(s*m2)"; kg/(kg-s)*kg/m2  it is equal to mm/s
  copy_VarCoords(advq_1(:,:,0,:,:),advqh_int1)
  printMinMax(advqh_int1,0)
  printVarSummary(advqh_int1)
  print("-----")
  
  advq2_dpg = advq_2*dpg 
  advqh_int2 = dim_sum_n(advq2_dpg, 2)
  advqh_int2@long_name = "vertically integrated moisture advection caused by anomalous wind and mean q"
  advqh_int2@units     = "kg/(s*m2)";it is equal to mm/s
  copy_VarCoords(advq_2(:,:,0,:,:),advqh_int2)
  printMinMax(advqh_int2,0)
  printVarSummary(advqh_int2)
  print("-----")
  
  advqz1_dpg = adv_z1*dpg 
  advqz_int1 = dim_sum_n(advqz1_dpg, 2)
  advqz_int1@long_name = "vertically integrated Vertical Moisture Transport caused by mean w and anomalous q"
  advqz_int1@units     = "kg/(s*m2)";it is equal to mm/s
  copy_VarCoords(adv_z1(:,:,0,:,:),advqz_int1)
  printMinMax(advqz_int1,0)
  printVarSummary(advqz_int1)
  print("-----")

  advqz2_dpg = adv_z2*dpg 
  advqz_int2 = dim_sum_n(advqz2_dpg, 2)
  advqz_int2@long_name = "vertically integrated Vertical Moisture Transport caused by anomalous w and mean q"
  advqz_int2@units     = "kg/(s*m2)";it is equal to mm/s
  copy_VarCoords(adv_z2(:,:,0,:,:),advqz_int2)
  printMinMax(advqz_int2,0)
  printVarSummary(advqz_int2)
  print("-----")

  NL_dpg = nl*dpg 
  NL_int = dim_sum_n(NL_dpg, 2)
  NL_int@long_name = "vertically integrated nonlinear term"
  NL_int@units     = "kg/(s*m2)";it is equal to mm/s
  copy_VarCoords(nl(:,:,0,:,:),NL_int)
  printMinMax(NL_int,0)
  printVarSummary(NL_int)
  print("-----")
  
  ;;---------------------------------------------------------
  ;;-------------save nc---------------------------------------
  savename1 = "ERA5.advqh_int1_untrend"+"."+months(0)+"-"+months(nmon-1)+"."+ymstar/100+"-"+ymend/100+".nc"
  system("/bin/rm -f "+savedir+savename1)
  fout1		= addfile(savedir+savename1,"c")
  fout1->advqh_int1	= advqh_int1(:,:,::-1,:)
  fout1@title	= "vertically integrated moisture advection caused by climatological wind and anomalous q"
  fout1@detrend	= dtrend_flag +"--(0 for raw data, else for detrended data)" 

  savename2 = "ERA5.advqh_int2_untrend"+"."+months(0)+"-"+months(nmon-1)+"."+ymstar/100+"-"+ymend/100+".nc"
  system("/bin/rm -f "+savedir+savename2)
  fout2		= addfile(savedir+savename2,"c")
  fout2->advqh_int2	= advqh_int2(:,:,::-1,:)
  fout2@title	= "vertically integrated moisture advection caused by anomalous wind and mean q"
  fout2@detrend	= dtrend_flag +"--(0 for raw data, else for detrended data)"

  savename3 = "ERA5.advqz_int1_untrend"+"."+months(0)+"-"+months(nmon-1)+"."+ymstar/100+"-"+ymend/100+".nc"
  system("/bin/rm -f "+savedir+savename3)
  fout3		= addfile(savedir+savename3,"c")
  fout3->advqz_int1	= advqz_int1(:,:,::-1,:)
  fout3@title	= "vertically integrated Vertical Moisture Transport caused by mean w and anomalous q"
  fout3@detrend	= dtrend_flag +"--(0 for raw data, else for detrended data)"

  savename4 = "ERA5.advqz_int2_untrend"+"."+months(0)+"-"+months(nmon-1)+"."+ymstar/100+"-"+ymend/100+".nc"
  system("/bin/rm -f "+savedir+savename4)
  fout4		= addfile(savedir+savename4,"c")
  fout4->advqz_int2	= advqz_int2(:,:,::-1,:)
  fout4@title	= "vertically integrated Vertical Moisture Transport caused by anomalous w and mean q"
  fout4@detrend	= dtrend_flag +"--(0 for raw data, else for detrended data)"

  savename5 = "ERA5.NL_int_untrend"+"."+months(0)+"-"+months(nmon-1)+"."+ymstar/100+"-"+ymend/100+".nc"
  system("/bin/rm -f "+savedir+savename5)
  fout5		= addfile(savedir+savename5,"c")
  fout5->NL_int	= NL_int(:,:,::-1,:)
  fout5@title	= "vertically integrated nonlinear term"
  fout5@detrend	= dtrend_flag +"--(0 for raw data, else for detrended data)"



end
