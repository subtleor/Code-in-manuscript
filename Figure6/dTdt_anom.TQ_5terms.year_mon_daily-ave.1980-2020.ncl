 ;-------------------------------------------------------------------
 ; @Author: Gao Yanping
 ; @Date: 2023-05-12 10:32:53
 ; @LastEditors: Zhanghan
 ; @LastEditTime: 2023-05-29 16:31:58
 ; @FilePath: \undefinedc:\Users\zhangh\Documents\NetSarang Computer\7\Xftp\Temporary\dTdt_anom.TQ_5terms.year_mon_daily-ave.2020_5 [3].ncl
 ; @Description: Climate Dynamics and Climate Prediction skill
 ; @............................
 ; @Copyright (c) 2023 by Flood_Yang, All Rights Reserved. 
 ;-------------------------------------------------------------------
;tnermal dynamic equation diagnosis
;注意此脚本需要输入全球数据，仅用局地数据计算需另外计算
;分解计算
;++++++++++++++++++++++++++++++++++++++++++++
; References:
;ncl:https://www.ncl.ucar.edu/Applications/wind.shtml
;Q采用倒算法
; Yanai et al (1973): https://doi.org/10.1175/1520-0469(1973)030<0611:DOBPOT>2.0.CO;2

;2003 年夏季华南持续高温天气过程及热力诊断,doi: 10.11978/j.issn.1009-5470.2011.03.030
;++++++++++++++++++++++++++++++++++++++++++++
;input data
; p       - Pressure [Pa]
; u,v     - zonal, meridional wind components[m/s]
; T       - temperature [K]  or [C]
; omega   - vertical velocity [Pa/s]
;;+++++++++++++++++++++++++++++++++++++++++++++++++++++

begin
;--------------------------------------------------------------------------------------
;read daily data(ERA5_daily) year by year
;--------------------------------------------------------------------------------------
; ;inpput opt
month_need = "ason"
levhigh = 10
levlow  = 1000
yrstar  = 1980
yrend   = 2020
nyear = yrend-yrstar+1
; ;caculate opt
; yr_anom  = 2020
c_yrstar = 1991
c_yrend  = 2020

;var dir
var_dat = "ERA5"

varname_temp	= "t"
filedir_temp	= "/wind1/home/zhangh825/Q/t_jja/"
filename_temp   = "ERA5.t_daily_ason_"

varname_uwnd	= "u"
filedir_uwnd	= "/wind1/home/zhangh825/Q/u_jja/"
filename_uwnd   = "ERA5.u_daily_ason_"

varname_vwnd	= "v"
filedir_vwnd	= "/wind1/home/zhangh825/Q/v_jja/"
filename_vwnd   = "ERA5.v_daily_ason_"

varname_omega	= "w"
filedir_omega	= "/wind1/home/zhangh825/Q/w_jja/"
filename_omega  = "ERA5.w_daily_ason_"

filedir_clim         ="/wind1/home/zhangh825/Q/"
filename_clim_temp   = "ERA5.t_climatology.nc"
filename_clim_uwnd   = "ERA5.u_climatology.nc"
filename_clim_vwnd   = "ERA5.v_climatology.nc"
filename_clim_omega  = "ERA5.w_climatology.nc"

; Read climatology data
ft_c =addfile(filedir_temp+filename_clim_temp,"r")
t_clm=ft_c->$varname_temp$(:,:,::-1,:)

fu_c =addfile(filedir_uwnd+filename_clim_uwnd,"r")
u_clm=fu_c->$varname_uwnd$(:,:,::-1,:)

fv_c =addfile(filedir_vwnd+filename_clim_vwnd,"r")
v_clm=fv_c->$varname_vwnd$(:,:,::-1,:)

fw_c =addfile(filedir_omega+filename_clim_omega,"r")
w_clm=fw_c->$varname_omega$(:,:,::-1,:)

ndim= dimsizes(t_clm)
QT_dtdt_anom=new((/nyear,ndim(1),ndim(2),ndim(3)/), typeof(t_clm), u_clm@_FillValue)
QT_dtdt_anom!0="year"
QT_dtdt_anom&year=ispan(yrstar,yrend,1)
copy_VarCoords(t_clm(0,:,:,:),QT_dtdt_anom(0,:,:,:))
printVarSummary(QT_dtdt_anom)
QT_advT_H=QT_dtdt_anom
QT_VL=QT_dtdt_anom
QT_AD=QT_dtdt_anom
QT_Q1_Cp=QT_dtdt_anom
Q1=QT_dtdt_anom
delete(ndim)
printVarSummary(Q1)



do yr= yrstar, yrend ,1

ft	=addfile(filedir_temp+filename_temp+yr+".nc","r")
var_t=ft->$varname_temp$(:,:,::-1,:)

fu	=addfile(filedir_uwnd+filename_uwnd+yr+".nc","r")
var_u=fu->$varname_uwnd$(:,:,::-1,:)

fv	=addfile(filedir_vwnd+filename_vwnd+yr+".nc","r")
var_v=fv->$varname_vwnd$(:,:,::-1,:)

fw	=addfile(filedir_omega+filename_omega+yr+".nc","r")
var_w=fw->$varname_omega$(:,:,::-1,:)

;time of ERA5 daily data is "hours since 1900-01-01 00:00:00.0",need to change 'hours since' to 'seconds since'

var_time=ispan(0,dimsizes(var_t&day)-1,1)*24*3600
yr_sign=yr-1
var_time@units= "seconds since  "+yr_sign+"-3-01 00:00:00.0"
printVarSummary(var_t)

var_t&day=var_time
var_u&day=var_time
var_v&day=var_time
var_w&day=var_time

printVarSummary(var_t)
printVarSummary(t_clm)

print("---------------- 1 read data --------------------")

t_anom   = var_t(:,:,:,:)-t_clm
copy_VarCoords(var_t,t_anom)
u_anom   = var_u(:,:,:,:)-u_clm
copy_VarCoords(var_u,u_anom)
v_anom   = var_v(:,:,:,:)-v_clm
copy_VarCoords(var_v,v_anom)
w_anom   = var_w(:,:,:,:)-w_clm
copy_VarCoords(var_w,w_anom)


delete([/var_t,var_u,var_v,var_w/])

print("---------------- 2 anom data --------------------")

    ;---------------------------------------------------------------------
    ;dT/dt  = davT_H + omega*static_stability + Q1/Cp
    ;QT_dtdt = QT_advT + QT_w + QT_Q1_Cp,并分解
    ;F          F1        F2     F3
    ;------------------------------------------------

    ;*******************************************
    ;---Compute F: local dT/dt  [K/s]
    ;*******************************************
        ;time of ERA5 daily data is "hours since 1900-01-01 00:00:00.0",need to change 'hours since' to 'seconds since'
        dTdt_anom = center_finite_diff_n(t_anom(:,:,:,:),var_time,False,0,0)
        ;rCyclic = False,首尾分别用向后差分和向前差分;要都采用中央差分需多取前后的数据计算再选择对应日期结果
        dTdt_anom@longname = "Temperature: Local Time derivative"
        dTdt_anom@units = "K/s"
        copy_VarCoords(t_anom,dTdt_anom)
        printVarSummary(dTdt_anom)
        print("---------------- 3 dT'/dt --------------------")
exit
     ;****************************************
     ;Compute F1:advection term: spherical harmonics
     ;-1*(U*(dT/dx) + V*(dT/dy)):  [m/s][K/m] -> [K/s]
     ;H1:-u_anom*dT_clm/dx -v_anom*dT_clm/dy :the advection of climatological temperature caused by wind anomalies
     ;H2:-u_clm*dT_anom/dx -v_clm*dT_anom/dy :the advection of anomalous temperatures caused by climatological winds
    ;****************************************
         ;;way1
         opt_adv    = 0 ;opt=0 means only return the advection result.
         units      = "K/s"
         gridType   = 1  ;gridType=0 means gaussian grid; gridType=1 means regular or fixed grid.
         long_name1  = "the advection of anomalous temperatures caused by climatological winds"
         HL1    = -1.0*advect_variable(u_clm,v_clm,t_anom,gridType,long_name1,units,opt_adv) 
         copy_VarCoords(t_anom,HL1)
         long_name2  = "the advection of climatological temperature caused by wind anomalies"
         HL2    = -1.0*advect_variable(u_anom,v_anom,t_clm,gridType,long_name2,units,opt_adv) 
         copy_VarCoords(t_anom,HL2)
         advT_H = HL1+HL2
         copy_VarCoords(HL1,advT_H)
         printVarSummary(advT_H)  
         printMinMax(advT_H,True)
         ;-----------------------------------------------------------------
         ;;way2
         ;gradT_x	= t_anom
         ;gradT_y	= t_anom
         ;gradsf(t_anom,gradT_x,gradT_y)
         ;advT_H	= -1.0*(u_clm*gradT_x+v_clm*gradT_y)	;way2, way1=way2
         ;way1 and way2:input grid must be in ascending latitude order (S==>N),input array must be on a global grid
         ;局地数据计算需不用公式，自己另外计算(需将经纬度转换为弧度)

         print("---------------- 4 -advT_H --------------------")
         delete([/opt_adv,long_name1,long_name2,units,gridType/])
         delete([/u_anom,v_anom/])
     ;****************************************
     ;---Compute F2:omega*static stability [K/s] or use other forms,use theta there
     ;static stability:ss [K/Pa] = -T*d[log(theta)]/dp = -(T/theta)*d(theta)/dp = RT/PCp-dT/dP  ;static_stability(plev,var_t,1,opt_ss)
     ;omega:[Pa/s]
     ;D1:(p/p0)^R/Cp*(-w_anom*dtheta_clm/dp): Vertical heat transport terms caused by p-velocity anomalies
     ;D2:(p/p0)^R/Cp*(-w_clm*dtheta_anom/dp):Vertical heat transport terms caused by theta(T) anomalies
     ;****************************************
     plev0 = t_anom&level
     plev = plev0*100. ;need to change [hPa] to [Pa],change to float 
     plev@units	= "Pa"
     p0 = 100000.0

     VL1 = -1.*center_finite_diff_n(t_anom,plev,False,0,1)*w_clm
     copy_VarCoords(t_anom,VL1)
     VL2 = -1.*center_finite_diff_n(t_clm,plev,False,0,1)*w_anom
     copy_VarCoords(w_anom,VL2)

     omega_ss_advT = VL1+VL2
     copy_VarCoords(VL1,omega_ss_advT)

     printVarSummary(omega_ss_advT)
     printMinMax(omega_ss_advT,True)
     print("---------------- 5 omega_ss_advT --------------------")
    
    ;============================================================
     plev_ex	= conform_dims(dimsizes(t_anom),plev,(/1/))
     AD1 =  (0.286*t_anom/plev_ex)*w_clm
     copy_VarCoords(t_anom,AD1)
     AD2 = (0.286*t_clm/plev_ex)*w_anom
     copy_VarCoords(t_clm,AD2)
     omega_ss_T = AD1+AD2
     copy_VarCoords(VL1,omega_ss_T)
     
     printVarSummary(omega_ss_T)
     printMinMax(omega_ss_T,True)
     print("---------------- 5 omega_ss_advT --------------------")

     delete([/plev0,plev/])
     delete([/w_anom,t_anom/])

    ;****************************************
    ;---Compute F3:Q1/Cp [K/s]
    ;Q1_anom/Cp = F-F1-F2
    ;Q1_anom = Q1_anom/Cp*Cp
    ;****************************************
        ;Net Heat
        q_diab =  dTdt_anom - advT_H - omega_ss_advT - omega_ss_T
        q_diab@long_name = "q_diab: The net contribution of anomalous diabatic processes"
        q_diab@units     = "K/s"
        copy_VarCoords(dTdt_anom,q_diab)


        printVarSummary(q_diab)
        printMinMax(q_diab,True)
        
        ; ;-Apparent Heat Source
         Cp           = 1004.64 
         Cp@long_name = "specific heat of dry air at constant pressure"
         Cp@units     = "J/(K*kg)"  ; [kg-m2/s2]/(K-kg) => [kg-m2]/[K-kg-s2] => m2/[K-s2]  

        Q  = Cp*q_diab  ; [J/(K-kg)][K/s] -> [J/(kg-s)] -> [(kg-m2/s2)/(kg-s)) -> [ m2/s3 ] ; [J/(K-kg)][K/s] -> [(J/s)(1/kg)] -> W/kg 
        Q@long_name = "Q1_anom: anomalies of Total Diabatic Heating as the Apparent Heat Source "
        Q@units     = "W/kg"   
        copy_VarCoords(q_diab,Q)
        printVarSummary(Q)
        printMinMax(Q,True)
        print("---------------- 6 Q1 --------------------")

;     ;---------------------------------------------------------
;     ;save  data
;     ;---------------------------------------------------------
        ;monthly:avrage of all days in month_need
        QT_dtdt_anom({yr},:,:,:) =dim_avg_n(dTdt_anom(:,:,:,:), 0)

        QT_advT_HL1 = HL1
        QT_advT_HL2 = HL2
        QT_advT_H({yr},:,:,:) = dim_avg_n(advT_H(:,:,:,:), 0)

        QT_omega_VL1  = VL1
        QT_omega_VL2  = VL2
        QT_VL({yr},:,:,:) = dim_avg_n(omega_ss_advT(:,:,:,:), 0)

        
        QT_omega_AD1  = AD1
        QT_omega_AD2  = AD2
        QT_AD({yr},:,:,:) = dim_avg_n(omega_ss_T(:,:,:,:), 0)
    
        QT_Q1_Cp({yr},:,:,:) = dim_avg_n(q_diab(:,:,:,:), 0)
        Q1({yr},:,:,:) = dim_avg_n(Q(:,:,:,:), 0)

        
    delete([/HL1,HL2,VL1,VL2,AD1,AD2,q_diab,Q/])   
   delete([/dTdt_anom,advT_H,omega_ss_advT,omega_ss_T/])

;    printVarSummary(QT_dtdt_anom)
;    printVarSummary(QT_advT_H)
;    printVarSummary(QT_VL)
;    printVarSummary(QT_AD)
;    printVarSummary(QT_Q1_Cp)
;    printVarSummary(Q1)
print("---------------- "+yr+" finished  --------------------")

end do
;     print("----------------- 7 monthly data------------------------")
    ;---------------------------------------------------------
    ;save monthly data
    ;---------------------------------------------------------
    savedir   = "/wind1/home/zhangh825/Q/"
    savename1 = "dTdt.TQ_anom_5terms."+yr+"."+month_need+"."+levlow+"-"+levhigh+"hPa.nc"
    system("/bin/rm -f "+savedir+savename1)
    setfileoption("nc","Format","LargeFile")  
    fo		= addfile(savedir+savename1,"c")
    fo@info = "dT_dt_anom = advT_H_anom + VL_anom + AD_anom + Q1_Cp_anom"
    fo@Cp = Cp
    fo->dT_dt_anom	 = QT_dtdt_anom(:,:,::-1,:)
    fo->advT_H_anom	 = QT_advT_H(:,:,::-1,:)
    fo->VL_anom      = QT_VL(:,:,::-1,:)
    fo->AD_anom      = QT_AD(:,:,::-1,:)
    fo->Q1_Cp_anom	 = QT_Q1_Cp(:,:,::-1,:)
    fo->Q1_anom	 = Q1(:,:,::-1,:)


end 