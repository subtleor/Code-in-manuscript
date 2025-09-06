load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "/mnt/e/mytool.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
begin
;**********************

;================ 用户参数 =========================
in_dir  = "/mnt/e/westsouth/data/"        ; 输入目录
f_t2m   = in_dir + "ERA5.mon.2m_temperature.1950-2022.nc"
f_e     = in_dir + "ERA5.mon.evaporation.1950-2022.nc"
f_pev   = in_dir + "ERA5.mon.potential_evaporation.1950-2022.nc"
f_ssr   = in_dir + "ERA5.mon.surface_net_solar_radiation.1950-2022.nc"
f_str   = in_dir + "ERA5.mon.surface_net_thermal_radiation.1950-2022.nc"

var_t2m = "t2m"
var_e   = "e"
var_pev = "pev"
var_ssr = "ssr"
var_str = "str"

ymstar	= 198001
ymend	  = 202212
monmin	= ispan(1,12,1)	;starting month for averaging,(monmin != 0,-12 <= monmin <= monmax <=12). negative value for previou year(year(-1)) 
monmax	= ispan(1,12,1)	;ending month for averaging,	   1<= monmax <= 12 
; mm      = 7
year = ispan(1980,2022,1)
nmon = dimsizes(monmin)

; 若辐射文件已经是 W/m2 （平均值）则设为 False
radiation_is_accumulated = True   ; True 表示单位为 J/m2，需除以月秒数得到 W/m2

; 选择标准化方式
remove_season_cycle = True        ; True: (X - 月气候)/月STD; False: 全时段直接标准化

; 潜热 (J/kg)

Lh      = 2.5e6
rho_w   = 1000.0    ; kg/m3  若 e/pev 单位= m/month，需要乘以 ρw
apply_rho = True    ; True: 使用 ρw*Lh*E ；False: 与你 Python 近似写法 Rn - L*E（忽略 ρw）

out_file = "ERA5_monthly_land_atmo_coupling_I_1980-2020.nc"

;================ 读取数据 =========================
ft  = addfile(f_t2m,"r")
tim= ft->time
u_time_DATE= cd_calendar(tim,-1)
tstar         = ind(u_time_DATE .eq. ymstar) 
tlast         = ind(u_time_DATE .eq. ymend)

fe  = addfile(f_e,"r")
fpv = addfile(f_pev,"r")
fsr = addfile(f_ssr,"r")
ftr = addfile(f_str,"r")

t2m_all = short2flt(ft->$var_t2m$(tstar:tlast,:,:))
e_all   = short2flt(fe->$var_e$(tstar:tlast,:,:))
pev_all = short2flt(fpv->$var_pev$(tstar:tlast,:,:))
ssr_all = short2flt(fsr->$var_ssr$(tstar:tlast,:,:))
str_all = short2flt(ftr->$var_str$(tstar:tlast,:,:))  
printVarSummary(t2m_all)
a=      month_to_monave(t2m_all,3,3)
printVarSummary(a)

 nmon = dimsizes(monmin-1)
 dims = dimsizes(t2m_all)
 vart2m_monave = new((/dims(0)/12,nmon,dims(1),dims(2)/),float)
 vare_monave = new((/dims(0)/12,nmon,dims(1),dims(2)/),float)
 varpev_monave = new((/dims(0)/12,nmon,dims(1),dims(2)/),float)
 varssr_monave = new((/dims(0)/12,nmon,dims(1),dims(2)/),float)
 varstr_monave = new((/dims(0)/12,nmon,dims(1),dims(2)/),float)
do i =0,nmon-1
vart2m_monave(:,i,:,:)=month_to_monave(t2m_all,monmin(i),monmax(i))
vare_monave(:,i,:,:)=month_to_monave(e_all,monmin(i), monmax(i))
varpev_monave(:,i,:,:)=month_to_monave(pev_all,monmin(i), monmax(i))
varssr_monave(:,i,:,:)=month_to_monave(ssr_all,monmin(i), monmax(i))
varstr_monave(:,i,:,:)=month_to_monave(str_all,monmin(i), monmax(i))
end do
vart2m_monave!0="year"
vart2m_monave!1="month" 
vart2m_monave&month=monmin
vart2m_monave!2="lat"
vart2m_monave!3="lon"
printVarSummary(vart2m_monave)
copy_VarCoords(vart2m_monave,vare_monave)
copy_VarCoords(vart2m_monave,varpev_monave)
copy_VarCoords(vart2m_monave,varssr_monave)
copy_VarCoords(vart2m_monave,varstr_monave)
printVarSummary(varssr_monave)


;================ 单位与物理量处理 =================
; e, pev: ERA5 通常为累积下向通量 (m)，为负值 => 实际蒸散（正）为 -e；unit转换为kg*m2/day
vare_monave = (/-1000*vare_monave/)
varpev_monave = (/-1000*varpev_monave/)
vare_monave@units = "kg*m**2/day"
varpev_monave@units = "kg*m**2/day" 
; 计算净辐射 Rn = ssr + str （这里 ssr,str 为“净”短波与“净”长波）

nyear = dimsizes(vart2m_monave(:,0,0,0))
nmon  = dimsizes(vart2m_monave(0,:,0,0))

; 构造 (year,month) 天数矩阵
days_ym = new((/nyear,nmon/), integer)
mdays_base = (/31,28,31,30,31,30,31,31,30,31,30,31/)

do iy=0, nyear-1
  ycur = year(iy)
  ; 判断闰年
  leap = ( (mod(ycur,400).eq.0) .or. (mod(ycur,4).eq.0 .and. mod(ycur,100).ne.0) )
  do im=0, nmon-1
    if (leap .and. im.eq.1) then
      days_ym(iy,im) = 29
    else
      days_ym(iy,im) = mdays_base(im)
    end if
  end do
end do

; 将天数扩展到四维以匹配 (year,month,lat,lon)
days_4d = conform_dims(dimsizes(vare_monave), days_ym, (/0,1/))

; 原先：vare_monave, varpev_monave 为 kg m^-2 day^-1
; 转月累计质量 (kg m^-2)
vare_mass_mon  = vare_monave * days_4d
varpev_mass_mon= varpev_monave * days_4d

vare_mass_mon@long_name  = "Monthly accumulated evaporation (mass)"
varpev_mass_mon@long_name= "Monthly accumulated potential evaporation (mass)"
vare_mass_mon@units      = "kg m^-2"
varpev_mass_mon@units    = "kg m^-2"


; 计算净辐射 (year,month,lat,lon)
Rn_monave = varssr_monave + varstr_monave
  Rn_monave@units = "J/m2"
Rn_monave@long_name = "Monthly Net radiation (shortwave+longwave)"
; 显示用于确认
copy_VarCoords(vart2m_monave,Rn_monave)
printVarSummary(Rn_monave)

LE_mon  = vare_mass_mon  * Lh
LEp_mon = varpev_mass_mon * Lh
LE_mon@long_name  = "Monthly latent heat (actual) (J m^-2)"
LEp_mon@long_name = "Monthly latent heat (potential) (J m^-2)"
LE_mon@units  = "J m^-2"
LEp_mon@units = "J m^-2"
copy_VarCoords(vart2m_monave,LE_mon)
copy_VarCoords(vart2m_monave,LEp_mon)
;================ 计算 H 与 Hp ======================
; H: 感热近似 = Rn - LE
; Hp: 用潜在蒸散的感热近似 = Rn - LEp
H  = Rn_monave - LE_mon
Hp = Rn_monave - LEp_mon
H@long_name  = "Approximate monthly sensible heat flux proxy (Rn-LE)"
Hp@long_name = "Approximate monthly potential sensible heat proxy (Rn-LEp)"
copy_VarCoords(vart2m_monave,H)
copy_VarCoords(vart2m_monave,Hp)
;================ 标准化 ============================
H_std  = dim_standardize_n_Wrap(H,1,0)
Hp_std = dim_standardize_n_Wrap(Hp,1,0)
T_std = dim_standardize_n_Wrap(vart2m_monave,1,0)


H_std@long_name  = "Standardized H"
Hp_std@long_name = "Standardized Hp"
energy=(H_std - Hp_std)
energy@long_name = "Land-Atmosphere Coupling Index energy term (H_std - Hp_std)"
T_std@long_name  = "Standardized 2m temperature"

;================ 耦合指数 ==========================
I = (H_std - Hp_std)*T_std
I@long_name = "Land-Atmosphere Coupling Index I = (H_std - Hp_std)*T_std"
I@units     = "dimensionless"
copy_VarCoords(T_std,I)
copy_VarCoords(T_std,energy)
copy_VarCoords(T_std,H_std)
copy_VarCoords(T_std,Hp_std)
printVarSummary(H_std)
printVarSummary(Hp_std)


;================ 保存输出 ==========================
system("/bin/rm -f "+out_file)
fout = addfile(out_file,"c")
fout->H_std  = H_std
fout->Hp_std = Hp_std
fout->T_std  = T_std
fout->I      = I
fout->energy = energy

print("保存完成: "+out_file)

end

