load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
begin
;**********************************************************************
;**1.A script for calculating water vapor transport flux of ncep1 data

;Attention!!!:the top pressure level is set to 30000 Pa;it can be changed

;**2.calculating the horizontal divergence and relative vorticity of vertically

;interagted water vapor transport flux

;**3.calculating the stream function and velocity potential of vertically 

;interagted water vapor transport flux

;**4.calculating the divergent vector component and rotational vector component

;velocity potential of vertically interagted water vapor transport flux

;**********************************************************************
;options for user
;**********************************************************************
   ymstar	= 198001
   ymend	= 202012
   ;;------------------------------------------------------
   varname_x	= "u"             	;variable name
   varname_y	= "v"
   varname_q	= "q"
   varname_ps	= "sp"
   ;;------------------------------------------------------
   filename_x	= "ERA5_u_mon_197901_202209.nc"	;filename
   filename_y	= "ERA5_v_mon_197901_202209.nc"
   filename_q	= "ERA5.mon.specific_humidity.1950-2022.nc"
   filename_ps= "ERA5.mon.surface_pressure.1950-2022.nc"
   ;;------------------------------------------------------
   filedir_x	= "/mnt/e/westsouth/data/"		
   filedir_y	= "/mnt/e/westsouth/data/"
   filedir_q	= "/mnt/e/westsouth/data/"
   filedir_ps	= "/mnt/e/westsouth/data/"
   ;;------------------------------------------------------
   ;Options for output
   DIR		= "/mnt/e/westsouth/q_flux/"
   dirnc_x	= DIR
   dirnc_y      = DIR
   ;;------------------------------------------------------
   dirnc_x_lvl	= DIR
   dirnc_y_lvl	= DIR
   ;;------------------------------------------------------
   dirnc_hdivg_uqvq	= DIR
   dirnc_vvort_uqvq	= DIR
   dirnc_sf_uqvq	= DIR
   dirnc_up_uqvq	= DIR
   dirnc_vp_uqvq	= DIR
   dirnc_uq_hdivg	= DIR
   dirnc_vq_hdivg	= DIR
   dirnc_uq_vvort	= DIR
   dirnc_vq_vvort	= DIR
   ;;------------------------------------------------------
   filenc_x	= "ERA5.uq.mon.mean."+ymstar+"_"+ymend+".nc"
   filenc_y	= "ERA5.vq.mon.mean."+ymstar+"_"+ymend+".nc"
   ;;------------------------------------------------------
;    filenc_x_lvl	= "ERA5.uq_lvl.mon.mean.nc"
;    filenc_y_lvl = "ERA5.vq_lvl.mon.mean.nc"
   ;;------------------------------------------------------
   filenc_hdivg_uqvq	= "ERA5.hdivg_uqvq.mon.mean."+ymstar+"_"+ymend+".nc"
;    filenc_vvort_uqvq	= "ERA5.vvort_uqvq.mon.mean.nc"
   filenc_sf_uqvq		= "ERA5.sf_uqvq.mon.mean."+ymstar+"_"+ymend+"nc"
;    filenc_vp_uqvq		= "ERA5.vp_uqvq.mon.mean.nc"
;    filenc_vq_hdivg		= "ERA5.vq_hdivg.mon.mean.nc"
;    filenc_uq_vvort      = "ERA5.uq_vvort.mon.mean.nc"
;    filenc_vq_vvort      = "ERA5.vq_vvort.mon.mean.nc"
  ;;------------------------------------------------------
   ;**********************************************************************
  ;  ; print namelist
  ;  print("**************************Namelist**************************")
  ;  print("*Input control: ")
  ;  print("***Start of time: " + ymstar)
  ;  print("***End of time: " + ymend)
  ;  print("***file name:  "+filename_x)
  ;  print("               "+filename_y)
  ;  print("               "+filename_q)
  ;  print("               "+filename_ps)

  ;  print("***file directory: "+filedir_x)
  ;  print(" 		     "+filedir_y)
  ;  print("                   "+filedir_q)
  ;  print("                   "+filedir_ps)

  ;  print("------------------------------------------------------------")
  ;  print("***Variable name: "+varname_x)
  ;  print("		    "+varname_y)
  ;  print("                  "+varname_q)
  ;  print("                  "+varname_ps)

  ;  print("------------------------------------------------------------")
  ;  print("*Output Control: ")
  ;  print("***save file name in zonal: "+filenc_x)
  ;  print("***save file name in meridional: "+filenc_y)
  ;  print("***saving directory in zonal: "+dirnc_x)
  ;  print("***saving directory in meridional: "+dirnc_y)

;    print("***save file name in meridional(pressure level): "+filenc_y_lvl)
;    print("***saving directory in zonal(pressure level): "+dirnc_x_lvl)
;    print("***saving directory in meridional(pressure level): "+dirnc_y_lvl)

  ;  print("***save file name of horizontal divergence of uq vq: "+filenc_hdivg_uqvq)
  ;  print("***saving directory of horizontal divergence of uq vq: "+dirnc_hdivg_uqvq)

;    print("***save file name of vertically relative vorticity of uq vq: "+filenc_vvort_uqvq)
;    print("***saving directory of vertically relative vorticity of uq vq: "+dirnc_vvort_uqvq)

  ;  print("***save file name of stream function of uq vq: "+filenc_sf_uqvq)
  ;  print("***saving directory of stream function of uq vq: "+dirnc_sf_uqvq)

;    print("***save file name of velocity potential of uq vq: "+filenc_vp_uqvq)
;    print("***saving directory of velocity potential of uq vq: "+dirnc_vp_uqvq)

;    print("***save file name of zonal component of divergent vector of uq vq: "+filenc_uq_hdivg)
;    print("***saving directory of zonal component of divergent vector of uq vq: "+dirnc_uq_hdivg)
 
;    print("***save file name of meridional component of divergent vector of uq vq: "+filenc_vq_hdivg)
;    print("***saving directory of meridional component of divergent vector of uq vq: "+dirnc_vq_hdivg)

;    print("***save file name of zonal component of rotational vector of uq vq: "+filenc_uq_vvort)
;    print("***saving directory of zonal component of rotational vector of uq vq: "+dirnc_uq_vvort)

;    print("***save file name of meridional component of rotational vector of uq vq: "+filenc_vq_vvort)   
;    print("***saving directory of meridional component of rotational vector of uq vq: "+dirnc_vq_vvort)
   
;    print("************************************************************")

;**********************************************************************
;handle the variable
  ;variable for Control experiment
  fx		= addfile(filedir_x+filename_x,"r")
  tim		= fx->time
  u_time_DATE	= cd_calendar(tim,-1)
  tstar		= ind(u_time_DATE .eq. ymstar)
  tlast		= ind(u_time_DATE .eq. ymend)
  print(tstar)
  print(tlast)
  varx    =  short2flt(fx->$varname_x$(tstar:tlast,{1000:300},:,:)) ;level is from 1-1000
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
  vary    = short2flt(fy->$varname_y$(tstar:tlast,{1000:300},:,:))
  printVarSummary(vary)
 
  delete([/tstar,tlast,tim,v_time_DATE/])
  ;;------------------------------------------------------------
  fps		= addfile(filedir_ps+filename_ps,"r")
  tim           = fps->time
  u_time_DATE   = cd_calendar(tim,-1)
  tstar         = ind(u_time_DATE .eq. ymstar)      
  tlast         = ind(u_time_DATE .eq. ymend)
  print(tstar)
  print(tlast)
  var_ps	= short2flt(fps->$varname_ps$(tstar:tlast,:,:))
  ;var_ps	= (/var_ps*100.0/) ;if sp is hpa, so *100 ; the era5 original units is pa
  ; var_ps = lonPivot(var_ps,0.0)   ;;;Attention the longitude
  ;printVarSummary(var_ps)
  delete([/tstar,tlast,tim,u_time_DATE/])
 
  ;;------------------------------------------------------------
  fq		= addfile(filedir_q+filename_q,"r")
  tim           = fq->time
  u_time_DATE   = cd_calendar(tim,-1)
  tstar         = ind(u_time_DATE .eq. ymstar)      
  tlast         = ind(u_time_DATE .eq. ymend)
  print(tstar)
  print(tlast)
  varq    = short2flt(fq->$varname_q$(tstar:tlast,{1000:300},:,:))
  ;var_q		= (/var_q/1000.0/)	;Attention!!! the q of era5 is kg/kg
  ; varq = lonPivot(varq,0.0)   ;;;Attention the longitude
  printVarSummary(varq)
  delete([/tstar,tlast,tim,u_time_DATE/])
 
;********************************************************************** 
; calculate water Varpor Transpose from surface pressure to 300hPa
  u		= varx
  v		= vary
  q		= varq
   printVarSummary(u)
   printVarSummary(v)
   printVarSummary(q)

  delete([/varx,vary,varq/])
  ;;------------------------------------------------------------
  uq_lvl	= u*q
  vq_lvl	= v*q
  ;;-------------------------------------------------------------------
  ;;------------------------------------------------------------
  copy_VarCoords(u,uq_lvl)
  copy_VarCoords(v,vq_lvl)
  uq_lvl@units	= "(kg*kg*m)/s"
  vq_lvl@units  = "(kg*kg*m)/s"
  uq_lvl@long_name	= "u*q(level)"
  vq_lvl@long_name	= "v*q(level)"
  ;;------------------------------------------------------------
  uq_lvl!0	= "time"
  uq_lvl!1	= "level"
  uq_lvl!2	= "lat"
  uq_lvl!3	= "lon"
  ;;------------------------------------------------------------
  copy_VarCoords(uq_lvl,vq_lvl)
  ;;------------------------------------------------------------
  printVarSummary(uq_lvl)
  printVarSummary(vq_lvl)
  ;;------------------------------------------------------------
  lev		= fq->level(::-1) ;hpa=100pa
  plev  = lev({:300})*100
  plev@units = "Pa"
  ptop		= 30000.0
  pres		= var_ps
  print(plev)
  ;;-------------------------------------------
  delete([/u,v,q,lev,var_ps/])
  ;;-----------------------------------------
  ;exit
  dp		= dpres_plevel(plev,pres,ptop,0)	;Missing Value for beyond pressure level
  printVarSummary(dp)
  ;;------------------------------------------------------------
  uq_lvl_wgt	= uq_lvl*dp/9.81
  vq_lvl_wgt	= vq_lvl*dp/9.81
  copy_VarCoords(uq_lvl,uq_lvl_wgt)
  copy_VarCoords(vq_lvl,vq_lvl_wgt)
  uq_lvl_wgt@units	= "kg/(m*s)"
  vq_lvl_wgt@units	= "kg/(m*s)"
  uq_lvl_wgt@long_name	= "u*q*dp/9.81(level)"
  vq_lvl_wgt@long_name	= "v*q*dp/9.81(level)"
  printVarSummary(uq_lvl_wgt)
  printVarSummary(vq_lvl_wgt)
  delete([/uq_lvl,vq_lvl,dp/])
  ;;------------------------------------------------------------
  uq		= dim_sum_Wrap(uq_lvl_wgt(time|:,lat|:,lon|:,level|:))
  vq		= dim_sum_Wrap(vq_lvl_wgt(time|:,lat|:,lon|:,level|:))
  ;;------------------------------------------------------------
  uq@long_name	= "sum of u*q*dp/9.81"
  vq@long_name	= "sum of v*q*dp/9.81"
  printVarSummary(uq)
  printVarSummary(vq)
  delete([/uq_lvl_wgt,vq_lvl_wgt/])
  ;;------------------------------------------------------------
  ;calculating the horizontal divergence of vertically interagted water vapor transport flux
  uq0		= uq(:,::-1,:)
  vq0		= vq(:,::-1,:)
;  hdivg_uqvq	= uv2dv_cfd(uq,vq,uq&lat,uq&lon,1)*86400.0/10.0
;  copy_VarCoords(uq,hdivg_uqvq)
  hdivg_uqvq	= uv2dvF_Wrap(uq0,vq0)		;horizontal divergence
  hdivg_uqvq@units	= "kg/(m**-2*s)" 
  printVarSummary(hdivg_uqvq)

  ;;------------------------------------------------------------
  vvort_uqvq	= uv2vrF_Wrap(uq0,vq0)		;vertically relative vorticity
  vvort_uqvq@units	= "kg/(m**-2*s)"
  printVarSummary(vvort_uqvq)
  ;;------------------------------------------------------------
  sfvp_uqvq 	= uv2sfvpF(uq0,vq0)
  ; delete([/uq0,vq0/])
  ;;------------------------------------------------------------
  sf_uqvq	= sfvp_uqvq(0,:,:,:)		;stream function
  copy_VarCoords(uq0,sf_uqvq)
  sf_uqvq@units	= "kg/s"
  sf_uqvq@long_name	= "stream function" 
  printVarSummary(sf_uqvq)
  ;;------------------------------------------------------------
  vp_uqvq	= sfvp_uqvq(1,:,:,:) 		;velocity potential 
  copy_VarCoords(uq0,vp_uqvq)
  vp_uqvq@units	= "kg/s"
  vp_uqvq@long_name	= "velocity potential"
  printVarSummary(vp_uqvq)
  ;;------------------------------------------------------------
  ;;--------------------------------------------------------------------------
  uqvq_hdivg	= dv2uvF_Wrap(hdivg_uqvq)	;divergent vector           
  ;;------------------------------------------------------------
  uq_hdivg	= uqvq_hdivg(0,:,:,:)
  uq_hdivg@long_name	= "divergent zonal component"
  printVarSummary(uq_hdivg)

  ;;------------------------------------------------------------
  vq_hdivg       = uqvq_hdivg(1,:,:,:)
  vq_hdivg@long_name     = "divergent meridional component"
  printVarSummary(vq_hdivg)
  ;;------------------------------------------------------------
  ;;---------------------------------------------------------------
  ; uqvq_vvort	= vr2uvF_Wrap(vvort_uqvq)	;rotational vector 
  ; ;;------------------------------------------------------------
  ; uq_vvort	= uqvq_vvort(0,:,:,:)
  ; uq_vvort@long_name	= "rotational zonal component" 
  ; printVarSummary(uq_vvort)
  ; ;;------------------------------------------------------------
  ; vq_vvort      = uqvq_vvort(1,:,:,:)
  ; vq_vvort@long_name    = "rotational meridional component"  
  ; printVarSummary(vq_vvort)
  ;;------------------------------------------------------------
;**********************************************************************
; save data
  system("/bin/rm -f "+dirnc_x+filenc_x);删除指定路径
  fo		= addfile(dirnc_x+filenc_x,"c");创建新的NC文件
  filedimdef(fo,"time",-1,True);定义一个无限制的时间维度
  fo->uq	= uq;写入uq
  fo@title	= "zonal component of monthly vertically(to "+ptop+"Pa) interagted water vapor transport flux calculated by interposed monthly ERA5 data"
  system("/bin/rm -f "+dirnc_y+filenc_y)
  fo		= addfile(dirnc_y+filenc_y,"c")
  filedimdef(fo,"time",-1,True)
  fo->vq	= vq
  fo@title	= "meridinal component of monthly vertically(to "+ptop+"Pa) interagted water vapor transport flux calculated by interposed monthly ERA5 data"
  
;   system("/bin/rm -f "+dirnc_x_lvl+filenc_x_lvl)
;   fo		= addfile(dirnc_x_lvl+filenc_x_lvl,"c")
;   filedimdef(fo,"time",-1,True)
;   fo->uq_lvl	= uq_lvl
;   fo@title	= "zonal component of monthly water vapor transport flux(pressure level) calculated by interposed monthly ERA5 data"

;   system("/bin/rm -f "+dirnc_y_lvl+filenc_y_lvl)
;   fo		= addfile(dirnc_y_lvl+filenc_y_lvl,"c")
;   filedimdef(fo,"time",-1,True)
;   fo->vq_lvl	= vq_lvl
;   fo@title	= "meridinal component of monthly water vapor transport flux(pressure level) calculated by interposed monthly ERA5 data"
 
  system("/bin/rm -f "+dirnc_hdivg_uqvq+filenc_hdivg_uqvq)
  fo		= addfile(dirnc_hdivg_uqvq+filenc_hdivg_uqvq,"c")
  filedimdef(fo,"time",-1,True)
  fo->hdivg_uqvq= hdivg_uqvq(:,::-1,:)	;Attention!!!
  fo@title	= "horizontal divergence of monthly vertically(to "+ptop+"Pa) interagted water vapor transport flux calculated by interposed monthly ERA5 data"

;   system("/bin/rm -f "+dirnc_vvort_uqvq+filenc_vvort_uqvq)
;   fo		= addfile(dirnc_vvort_uqvq+filenc_vvort_uqvq,"c")
;   filedimdef(fo,"time",-1,True)
;   fo->vvort_uqvq= vvort_uqvq(:,::-1,:)	;Attention!!!
;   fo@title	= "vertcially relative vorticity of monthly vertically(to "+ptop+"Pa) interagted water vapor transport flux calculated by interposed monthly ERA5 data"

;   system("/bin/rm -f "+dirnc_sf_uqvq+filenc_sf_uqvq)
;   fo		= addfile(dirnc_sf_uqvq+filenc_sf_uqvq,"c")
;   filedimdef(fo,"time",-1,True)
;   fo->sf_uqvq	= sf_uqvq(:,::-1,:)	;Attention!!!
;   fo@title	= "stream function of monthly vertically(to "+ptop+"Pa) interagted water vapor transport flux calculated by interposed monthly ERA5 data"
  
;   system("/bin/rm -f "+dirnc_vp_uqvq+filenc_vp_uqvq)
;   fo		= addfile(dirnc_vp_uqvq+filenc_vp_uqvq,"c")
;   filedimdef(fo,"time",-1,True)
;   fo->vp_uqvq	= vp_uqvq(:,::-1,:)	;Attention!!!
;   fo@title	= "velocity potential of monthly vertically(to "+ptop+"Pa) interagted water vapor transport flux calculated by interposed monthly ERA5 data"

   ;system("/bin/rm -f "+dirnc_uq_hdivg+filenc_uq_hdivg)
  ; fo            = addfile(dirnc_uq_hdivg+filenc_uq_hdivg,"c")
   ;filedimdef(fo,"time",-1,True)
   ;;fo->uq_hdivg	= uq_hdivg(:,::-1,:)	;Attention!!! 
   ;fo@title      = " zonal component of divergent vector of monthly vertically(to "+ptop+"Pa) interagted water vapor transport flux calculated by interposed monthly ERA5 data"

   ;system("/bin/rm -f "+dirnc_vq_hdivg+filenc_vq_hdivg)
   ;fo            = addfile(dirnc_vq_hdivg+filenc_vq_hdivg,"c")
   ;filedimdef(fo,"time",-1,True)
   ;fo->vq_hdivg	= vq_hdivg(:,::-1,:)	;Attention!!! 
   ;fo@title      = " meridional component of divergent vector of monthly vertically(to "+ptop+"Pa) interagted water vapor transport flux calculated by interposed monthly ERA5 data"
  
  
;   system("/bin/rm -f "+dirnc_uq_vvort+filenc_uq_vvort)
;   fo            = addfile(dirnc_uq_vvort+filenc_uq_vvort,"c")
;   filedimdef(fo,"time",-1,True)
;   fo->uq_vvort	= uq_vvort(:,::-1,:)	;Attention!!! 
;   fo@title      = " zonal component of rotational vector of monthly vertically(to "+ptop+"Pa) interagted water vapor transport flux calculated by interposed monthly ECAHM5 data"

;   system("/bin/rm -f "+dirnc_vq_vvort+filenc_vq_vvort)
;   fo            = addfile(dirnc_vq_vvort+filenc_vq_vvort,"c")
;   filedimdef(fo,"time",-1,True)
;   fo->vq_vvort	= vq_vvort(:,::-1,:)	;Attention!!! 
;   fo@title      = " meridional component of rotational vector of monthly vertically(to "+ptop+"Pa) interagted water vapor transport flux calculated by interposed monthly ECAHM5 data"
		    
		      
end


