load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "/wind1/home/zhangh825/mytool.ncl"
begin

Cp=1004.0      ;! Specific heat of air at constant pressure (J/kg/K)
Lv=2.26e6       ;! Latent heat of vaporization (J/kg)    

ymstar	= 196001
ymend	  = 202212

monmin	= ispan(1,12,1)	;starting month for averaging,(monmin != 0,-12 <= monmin <= monmax <=12). negative value for previou year(year(-1)) 
monmax	= ispan(1,12,1)	;ending month for averaging,	   1<= monmax <= 12 
; mm      = 7
year = ispan(1960,2022,1)
nmon = dimsizes(monmin)
;;------------------------------------------------------
varname_x	= "u"             	;variable name
varname_y	= "v"
varname_w	= "w"
varname_q	= "q"
varname_sp	= "sp"
varname_t	= "t"
varname_z   = "z"
;;------------------------------------------------------
filename_x	= "ERA5.mon.u_component_of_wind.1950-2022.nc"	;filename
filename_y	= "ERA5.mon.v_component_of_wind.1950-2022.nc"
filename_w  = "ERA5.mon.vertical_velocity.1950-2022.nc"
filename_q  = "ERA5.mon.specific_humidity.1950-2022.nc"
filename_sp = "ERA5.mon.surface_pressure.1950-2022.nc"
filename_t  = "ERA5.mon.temperature.1950-2022.nc"
filename_z  = "ERA5.mon.geopotential.1950-2022.nc"
;;------------------------------------------------------
filedir_x	= "/wind1/home/zhangh825/data/ERA5/"			
filedir_y	= "/wind1/home/zhangh825/data/ERA5/"		
filedir_w	= "/wind1/home/zhangh825/data/ERA5/"		
filedir_q  = "/wind1/home/zhangh825/data/ERA5/"		
filedir_sp  = "/wind1/home/zhangh825/data/ERA5/"		
filedir_t  = "/wind1/home/zhangh825/data/ERA5/"		
filedir_z  = "/wind1/home/zhangh825/data/ERA5/"		
;;------------------------------------------------------
months	= (/"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"/)
dtrend_flag	= 0; 0 for row data, else for detrended data
;Options for output
savedir		= "./"
plotdir     = savedir
;;------------------------------------------------------
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

;;---------------------------------------------------
ft        = addfile(filedir_t+filename_t,"r")
time           = ft->time
u_time_DATE   = cd_calendar(time,-1)
tstar         = ind(u_time_DATE .eq. ymstar)
tlast         = ind(u_time_DATE .eq. ymend)
print(tstar)
; print(ft)
var_t    = short2flt(ft->$varname_t$(tstar:tlast,::-1,:,:))
; var_t = lonPivot(var_t,0.0)   ;;;Attention the longitude  
printVarSummary(var_t)
delete([/tstar,tlast,time,u_time_DATE/])

 ;;-----------------------------------------------
 fz       = addfile(filedir_z+filename_z,"r")
    time           = fz->time
    u_time_DATE   = cd_calendar(time,-1)
    tstar         = ind(u_time_DATE .eq. ymstar)
    tlast         = ind(u_time_DATE .eq. ymend)
    print(tstar)
    ; print(fh)
    var_z    = short2flt(fz->$varname_z$(tstar:tlast,::-1,:,:))
    ; var_h = lonPivot(var_h,0.0)   ;;;Attention the longitude
    printVarSummary(var_z)
    delete([/tstar,tlast,time,u_time_DATE/])
;;---------------------------------------------------
var_h = Cp*var_t+Lv*varq+var_z
copy_VarCoords(var_t,var_h)
printVarSummary(var_h)
cpt_plus_lvq= Cp*var_t+Lv*varq
copy_VarCoords(var_t,cpt_plus_lvq)
printVarSummary(cpt_plus_lvq)

nmon = dimsizes(monmin-1)
dims = dimsizes(varq)
varu_monave = new((/dims(0)/12,nmon,dims(1),dims(2),dims(3)/),float)
varv_monave = new((/dims(0)/12,nmon,dims(1),dims(2),dims(3)/),float)
varw_monave = new((/dims(0)/12,nmon,dims(1),dims(2),dims(3)/),float)
varsp_monave = new((/dims(0)/12,nmon,dims(2),dims(3)/),float)
varh_monave = new((/dims(0)/12,nmon,dims(1),dims(2),dims(3)/),float)
cpt_plus_lvq_monave = new((/dims(0)/12,nmon,dims(1),dims(2),dims(3)/),float)

do i = 0,nmon-1
varu_monave(:,i,:,:,:)	= month_to_monave(varx,monmin(i),monmax(i))
varv_monave(:,i,:,:,:)	= month_to_monave(vary,monmin(i),monmax(i))
varw_monave(:,i,:,:,:)	= month_to_monave(varw,monmin(i),monmax(i))
varsp_monave(:,i,:,:)	= month_to_monave(var_sp,monmin(i),monmax(i))
varh_monave(:,i,:,:,:)	= month_to_monave(var_h,monmin(i),monmax(i))
cpt_plus_lvq_monave(:,i,:,:,:)	= month_to_monave(cpt_plus_lvq,monmin(i),monmax(i))
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
copy_VarCoords(varu_monave,varh_monave)
copy_VarCoords(varu_monave,cpt_plus_lvq_monave)

varsp_monave!1 = "month"
varsp_monave&month = monmin
varsp_monave!2 = "lat"
varsp_monave!3 = "lon"
copy_VarCoords(varu_monave(0,0,0,:,:),varsp_monave(0,0,:,:))
printVarSummary(varsp_monave)
delete([/varx,vary,varw,varq,var_sp,var_t,var_z/])
printVarSummary(varh_monave)
printVarSummary(cpt_plus_lvq_monave)
;;-------------------------------------------------------------

 ;;-------------------------------------------------------------
 if dtrend_flag .eq. 0 
   
 varu_monave		= varu_monave
 varu_monave@detrend	= dtrend_flag +"--(0 for raw data, else for detrended data)" 

 varv_monave		= varv_monave
 varv_monave@detrend	= dtrend_flag +"--(0 for raw data, else for detrended data)" 
 
 varw_monave		= varw_monave
 varw_monave@detrend	= dtrend_flag +"--(0 for raw data, else for detrended data)" 

 varsp_monave		= varsp_monave
    varsp_monave@detrend	= dtrend_flag +"--(0 for raw data, else for detrended data)"

varh_monave       = varh_monave
varh_monave@detrend = dtrend_flag +"--(0 for raw data, else for detrended data)"

    cpt_plus_lvq_monave        = cpt_plus_lvq_monave
    cpt_plus_lvq_monave@detrend = dtrend_flag +"--(0 for raw data, else for detrended data)"
else

 varu_monave			= (/dtrend_msg_n(ispan(1,dimsizes(varu_monave&year),1)*1.0,varu_monave,False,True,0)/) 
 varu_monave@detrend	= dtrend_flag +"--(0 for raw data, else for detrended data)" 

 varv_monave			= (/dtrend_msg_n(ispan(1,dimsizes(varv_monave&year),1)*1.0,varv_monave,False,True,0)/) 
 varv_monave@detrend	= dtrend_flag +"--(0 for raw data, else for detrended data)" 

 varw_monave			= (/dtrend_msg_n(ispan(1,dimsizes(varw_monave&year),1)*1.0,varw_monave,False,True,0)/) 
 varw_monave@detrend	= dtrend_flag +"--(0 for raw data, else for detrended data)" 


 varsp_monave			= (/dtrend_msg_n(ispan(1,dimsizes(varsp_monave&year),1)*1.0,varsp_monave,False,True,0)/) 
 varsp_monave@detrend	= dtrend_flag +"--(0 for raw data, else for detrended data)" 

    varh_monave			= (/dtrend_msg_n(ispan(1,dimsizes(varh_monave&year),1)*1.0,varh_monave,False,True,0)/)
    varh_monave@detrend	= dtrend_flag +"--(0 for raw data, else for detrended data)"

    cpt_plus_lvq_monave			= (/dtrend_msg_n(ispan(1,dimsizes(cpt_plus_lvq_monave&year),1)*1.0,cpt_plus_lvq_monave,False,True,0)/)
    cpt_plus_lvq_monave@detrend	= dtrend_flag +"--(0 for raw data, else for detrended data)"
end if
printVarSummary(varu_monave)
printVarSummary(varsp_monave)

sp = varsp_monave(:,:,::-1,:)
printVarSummary(sp)

;;----------------------------------------------------
;; -----calculate the climatology and anomalies of u,v,w,q,t
varu_clm = dim_avg_n_Wrap(varu_monave(:,:,:,::-1,:),0)
 varv_clm = dim_avg_n_Wrap(varv_monave(:,:,:,::-1,:),0)
 varw_clm = dim_avg_n_Wrap(varw_monave(:,:,:,::-1,:),0)
 varh_clm = dim_avg_n_Wrap(varh_monave(:,:,:,::-1,:),0)
cpt_plus_lvq_clm = dim_avg_n_Wrap(cpt_plus_lvq_monave(:,:,:,::-1,:),0)

 printVarSummary(varu_clm)
 
 u_ano = dim_rmvmean_n_Wrap(varu_monave,0)
 v_ano = dim_rmvmean_n_Wrap(varv_monave,0)
 w_ano = dim_rmvmean_n_Wrap(varw_monave,0)
 h_ano = dim_rmvmean_n_Wrap(varh_monave,0)
cpt_plus_lvq_ano1 = dim_rmvmean_n_Wrap(cpt_plus_lvq_monave,0)

 printVarSummary(u_ano)
 delete([/varu_monave,varv_monave,varw_monave,varsp_monave,varh_monave,cpt_plus_lvq_monave/])

;;----------------------------------------------------
varu_ano = u_ano(:,:,:,::-1,:)
varv_ano = v_ano(:,:,:,::-1,:)
varw_ano = w_ano(:,:,:,::-1,:)
varh_ano = h_ano(:,:,:,::-1,:)
cpt_plus_lvq_ano = cpt_plus_lvq_ano1(:,:,:,::-1,:)
printVarSummary(varu_ano)
delete([/u_ano,v_ano,w_ano,h_ano,cpt_plus_lvq_ano1/])

;;----------------------------------------------------
nyear = dimsizes(year)
advh_1=new(dimsizes(varu_ano),typeof(varu_ano))
advh_2=new(dimsizes(varu_ano),typeof(varu_ano))
advh_3=new(dimsizes(varu_ano),typeof(varu_ano))
advh_4=new(dimsizes(varu_ano),typeof(varu_ano))



do n = 0,nyear-1
plev0 = varu_ano&level
plev = plev0*100.0 ;need to change [hPa] to [Pa]
plev@units	= "Pa"
print(plev)
 opt_adv   = 0 ;opt=0 means only return the advection result.
 gridType  = 1  ;gridType=0 means gaussian grid; gridType=1 means regular or fixed grid.
 units     = "W/KG"     ; (Pa/s)*(J/kg)*(1/pa)

 advh_1(n,:,:,:,:)      = varw_ano(n,:,:,:,:)*center_finite_diff_n(varh_clm,plev,False,0,1)
 advh_1@longname = "anomalous vertical advections of the climatological MSE"
 advh_1@units = units
 copy_VarCoords(varw_ano,advh_1)
 printVarSummary(advh_1) 

 delete([/units/])

long_name="the horizontal advection of anomalous enthalpy by climatological wind"
units="W/KG";(m/s)*(J/Kg)*(1/m)
 advh_2(n,:,:,:,:) = -1.0*advect_variable(varu_clm,varv_clm,cpt_plus_lvq_ano(n,:,:,:,:),gridType,long_name,units,opt_adv) 
 copy_VarCoords(varu_ano,advh_2)
    printVarSummary(advh_2)
delete([/long_name/])

long_name="the horizontal advection of climatological enthalpy by anomalous wind"
advh_3(n,:,:,:,:)  = -1.0*advect_variable(varu_ano(n,:,:,:,:),varv_ano(n,:,:,:,:),cpt_plus_lvq_clm,gridType,long_name,units,opt_adv)
copy_VarCoords(varu_ano,advh_3)
printVarSummary(advh_3)
delete([/long_name/])

advh_4(n,:,:,:,:)      = -1.0*varw_clm*center_finite_diff_n(varh_ano(n,:,:,:,:),plev,False,0,1)
advh_4@longname = "climatological vertical advections of the anomalous MSE"
advh_4@units = units
copy_VarCoords(varu_ano,advh_4)
printVarSummary(advh_4)
end do

;;----------------------------------------------------------------
long_name = "MSE caused by anomalous horizontal advections and the anomalous MSE"
nl_uh       = -1.0*advect_variable(varu_ano,varv_ano,cpt_plus_lvq_ano,gridType,long_name,units,opt_adv) 
copy_VarCoords(varu_ano,nl_uh)
printVarSummary(nl_uh) 

nl_w	= -1.0*varw_ano*center_finite_diff_n(varh_ano,plev,False,0,2)
nl_w@longname = "anomalous vertical advections of the anomalous MSE"
nl_w@units    = units       
copy_VarCoords(varu_ano,nl_w)
printVarSummary(nl_w)

nl = nl_w+nl_uh
copy_VarCoords(varu_ano,nl)
nl@longname = "nonlinear term"
nl@units    = "W/(KG)"      ; [(Pa/s)(kg/kg)/Pa)] 
printVarSummary(nl)

;;-----------------------------------------------------------------------------------
 ;;----------Vertical integration of the whole atmosphere---------------------------------
 ptop  = 0*100                     ; Pa
 pbot  = sp;max(plev)
 vopt  = 1 ;;iopt=1 weighted vertical sum;iopt=0 weighted vertical average

 p       = plev                                     ; Pa  [100000,...,10000]
 p@units = "Pa"
 p!0     = "p"
 p&p     =  p                   ; not necessary
 printVarSummary(p)
 print("---")

 g     = 9.80665                      ; [m/s2] gravity at 45 deg lat used by the WMO
 dims  = dimsizes(advh_1)
 print(dims)
 
 ; dp    = new((/dims(0),dims(1),dims(2),dims(3)/),float)
 dpg    = new((/dims(0),dims(1),dims(2),dims(3),dims(4)/),float)
 do m  = 0,dimsizes(pbot&month)-1
 dp    = dpres_plevel_Wrap(p,pbot(:,m,:,:),ptop,0)
 dpg00   = dp/g  
 printVarSummary(dpg00) 
 
 dpg(:,m,:,:,:)       = dpg00(:,:,:,:)              ; Pa/(m/s2)=> (Pa-s2)/m   
 dpg@long_name = "Layer Mass Weighting"
 dpg@units     = "kg/m**2"               ; dp/g     => Pa/(m/s2) => [kg/(m-s2)][m/s2] reduce to (kg/m2)
                                       ;             Pa (s2/m) => [kg/(m-s2)][s2/m]=>[kg/m2]
 ; dpg  := conform(advh1,dpg,1)             ; reassign [convenience]
 delete([/dpg00/])
 end do
 copy_VarCoords(advh_1,dpg)
 printVarSummary(dpg)
 ; print(p(:,:,0,0))

 advh1_dpg = advh_1*dpg 
 advh1_int1 = dim_sum_n(advh1_dpg, 2)
 advh1_int1@long_name = "vertically integrated MSE advection caused by climatological MSE and anomalous W"
 advh1_int1@units     = "W/m**2"; J/(KG*s)*kg/m**2  
 copy_VarCoords(advh_1(:,:,0,:,:),advh1_int1)
 printMinMax(advh1_int1,0)
 printVarSummary(advh1_int1)
 print("-----")
 
 advh2_dpg = advh_2*dpg 
 advh2_int1 = dim_sum_n(advh2_dpg, 2)
 advh2_int1@long_name = "vertically integrated MSE advection caused by anomalous MSE and climatological u"
 advh2_int1@units     = "W/m**2";it is equal to mm/s
 copy_VarCoords(advh_2(:,:,0,:,:),advh2_int1)
 printMinMax(advh2_int1,0)
 printVarSummary(advh2_int1)
 print("-----")
 
 advh3_dpg = advh_3*dpg 
 advh3_int1 = dim_sum_n(advh3_dpg, 2)
 advh3_int1@long_name = "vertically integrated MSE advection caused by climatological MSE and anomalous u"
 advh3_int1@units     = "W/m**2";it is equal to mm/s
 copy_VarCoords(advh_3(:,:,0,:,:),advh3_int1)
 printMinMax(advh3_int1,0)
 printVarSummary(advh3_int1)
 print("-----")

 advh4_dpg = advh_4*dpg 
 advh4_int1 = dim_sum_n(advh4_dpg, 2)
 advh4_int1@long_name ="vertically integrated MSE advection caused by anomalous MSE and climatological W"
 advh4_int1@units     = "W/m**2";it is equal to mm/s
 copy_VarCoords(advh_4(:,:,0,:,:),advh4_int1)
 printMinMax(advh4_int1,0)
 printVarSummary(advh4_int1)
 print("-----")

 NL_dpg = nl*dpg 
 NL_int = dim_sum_n(NL_dpg, 2)
 NL_int@long_name = "vertically integrated nonlinear term"
 NL_int@units     = "W/m**2";it is equal to mm/s
 copy_VarCoords(nl(:,:,0,:,:),NL_int)
 printMinMax(NL_int,0)
 printVarSummary(NL_int)
 print("-----")
 
 ;;---------------------------------------------------------
 ;;-------------save nc---------------------------------------
   ;;-------------save nc---------------------------------------
   savename1 = "ERA5.MSE.advh1_int1"+"."+months(0)+"-"+months(nmon-1)+"."+ymstar/100+"-"+ymend/100+".nc"
   system("/bin/rm -f "+savedir+savename1)
   fout1		= addfile(savedir+savename1,"c")
   fout1->advh1_int1	= advh1_int1(:,:,::-1,:)
   fout1@title	= "vertically integrated MSE advection caused by climatological MSE and anomalous W"
 
   savename2 = "ERA5.MSE.advh2_int1"+"."+months(0)+"-"+months(nmon-1)+"."+ymstar/100+"-"+ymend/100+".nc"
   system("/bin/rm -f "+savedir+savename2)
   fout2		= addfile(savedir+savename2,"c")
   fout2->advh2_int1	= advh2_int1(:,:,::-1,:)
   fout2@title	= "vertically integrated MSE advection caused by anomalous MSE and climatological u"
 
   savename3 = "ERA5.MSE.advh3_int1"+"."+months(0)+"-"+months(nmon-1)+"."+ymstar/100+"-"+ymend/100+".nc"
   system("/bin/rm -f "+savedir+savename3)
   fout3		= addfile(savedir+savename3,"c")
   fout3->advh3_int1	= advh3_int1(:,:,::-1,:)
   fout3@title	= "vertically integrated MSE advection caused by climatological MSE and anomalous u"
 
   savename4 = "ERA5.MSE.advh4_int1"+"."+months(0)+"-"+months(nmon-1)+"."+ymstar/100+"-"+ymend/100+".nc"
   system("/bin/rm -f "+savedir+savename4)
   fout4		= addfile(savedir+savename4,"c")
   fout4->advh4_int1	= advh4_int1(:,:,::-1,:)
   fout4@title	= "vertically integrated MSE advection caused by anomalous MSE and climatological W"
 
   savename5 = "ERA5.MSE.NL_int"+"."+months(0)+"-"+months(nmon-1)+"."+ymstar/100+"-"+ymend/100+".nc"
   system("/bin/rm -f "+savedir+savename5)
   fout5		= addfile(savedir+savename5,"c")
   fout5->NL_int	= NL_int(:,:,::-1,:)
   fout5@title	= "vertically integrated nonlinear term"
 
 end