load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "/mnt/e/mytool.ncl"

begin
    ; 设置数据文件路径和文件名
swvl_choose=3;1,3
    filedir1="/mnt/e/westsouth/yunnan/essay1/revise/landatmos_index/"
    filename1="ERA5_monthly_land_atmo_coupling_I_1980-2022.nc"
    var_dat    ="ERA5_"
    varname1    = "I"        ;

    Ts_filename  = "EIP_SMI_MAM.txt"
    Ts_filedir   = "/mnt/e/westsouth/yunnan/essay1/"

    latmin=20
    latmax=35
    lonmin=50
    lonmax=80
    ; 打开数据文件
    f =addfile(filedir1+filename1, "r")

    ymstar	= 198001
    ymend		= 202012
    if swvl_choose .eq. 3 then
    monname=(/"MAM","JJA"/)
    monmin	= (/3,6/)	;starting month for averaging,(monmin != 0,-12 <= monmin <= monmax <=12). negative value for previou year(year(-1)) 
    monmax	= (/5,8/)	;ending month for averaging,	   1<= monmax <= 12 
    plotmon=(/35,68/)
    stringplot=(/"d","d"/)
    end if 
    if swvl_choose .eq. 1 then
    monmin=(/3,4,5,6,7,8/)
    monmax=(/3,4,5,6,7,8/)
    plotmon=(/3,4,5,6,7,8/)
    stringplot=(/"a","b","c","d","e","f"/)
    monname=(/"Mar","Apr","May","Jun","Jul","Aug"/)
    end if
    ;###########################################################################################
    syntype="con"
    com_flag	=-1	; -1 for low-ave, 0 for high-low, 1 for high-ave

critic_flag=1
dtrend_flag=1

    ;###########################################################################################

  f			= addfile(filedir1+filename1,"r")

  var		= short2flt(f->$varname1$({ymstar/100:ymend/100},:,{latmin:latmax},{lonmin:lonmax}))
  ;var=[var/86400.0]
  ;var=[var*-1.0]
  var!0		= "year"
  var!1   = "month"
  var!2		= "lat"
  var!3		= "lon"
  printVarSummary(var)

  dims= dimsizes(var)
  var_monave=new((/dims(0),num(plotmon),dims(2),dims(3)/),typeof(var),var@_FillValue)
  do i=0,num(plotmon)-1  
 var1=var(:,{monmin(i):monmax(i)},:,:)
printVarSummary(var1)

    var_mon = dim_avg_n_Wrap(var1(:,:,:,:),1)
    printVarSummary(var_mon)
    var_monave(:,i,:,:)=var_mon
    delete([/var1,var_mon/])
  end do
  
  var_monave!1="month"
  var_monave&month=plotmon
  printVarSummary(var_monave)


  Ts	      = asciiread(Ts_filedir+Ts_filename,-1,"float") 
  Ts!0      = "year"
  Ts&year   = ispan(ymstar/100,ymend/100,1)
  
  ;Ts = -1.0*Ts0
  Ts = dim_standardize_n_Wrap(Ts,1,0)
  printVarSummary(Ts)
  printMinMax(Ts,0)
  
  nyear				= dimsizes(var_monave&year)
  ny				= dimsizes(var_monave&lat)
  nx				= dimsizes(var_monave&lon)

  if dtrend_flag .eq. 0 then  
	 var_monave			= var_monave
     Ts= Ts
    else
     var_monave            = (/dtrend_msg_n(ispan(1,nyear,1),var_monave,False,True,0)/)
    Ts		= (/dtrend_msg_n(ispan(1,dimsizes(Ts&year),1)*1.0,Ts,False,True,0)/)
    end if

 var_ori=var_monave
  ;var_ori=var_new
  yeara			= ispan(ymstar/100,ymend/100,1)		
  yeara@long_name	= "year-all"

  hi=ind(Ts.ge.critic_flag)
  li=ind(Ts.le.-critic_flag)
  yearh  = yeara(hi)
  yearl  = yeara(li)
  print(yearh)
  print(yearl)
  yearh@long_name = "year-high"
  yearl@long_name = "year-low"

printMinMax(var_ori,0)
printVarSummary(var_monave)

  if com_flag	.eq. 1
  
     y1		= yearh
     y2		= yeara
     com_name="high-ave"
	
  end if
  
  if com_flag	.eq. 0
  
     y1		= yearh    
     y2		= yearl
      com_name="high-low"

  end if
  
  if com_flag	.eq. -1
     
     y1		= yearl
     y2		= yeara	 
    com_name="low-ave"
	 
  end if
  

xdata1=var_monave({y1},:,:,:)
xdata2=var_monave({y2},:,:,:)
 printVarSummary(xdata1)
  printVarSummary(xdata2)

  ;average
  xave1			= dim_avg_n_Wrap(xdata1,0)
  xave1@long_name	= xdata1@long_name+"'s average in "+y1@long_name
  
  xave2			= dim_avg_n_Wrap(xdata2,0)
  xave2@long_name	= xdata2@long_name+"'s average in "+y2@long_name
  
  printVarSummary(xave1)
  printVarSummary(xave2)

    ;variance
  xvar1			= dim_variance_n_Wrap(xdata1,0)
  xvar1@long_name	= xdata1@long_name+"'s variance in "+y1@long_name
  
  xvar2			= dim_variance_n_Wrap(xdata2,0)
  xvar2@long_name	= xdata2@long_name+"'s variance in "+y2@long_name
 
  printVarSummary(xvar1)
  printVarSummary(xvar2)

  xn1		= dimsizes(y1)
  xn2		= dimsizes(y2)
 
  xn1@long_name	= "**simple size in "+y1@long_name+"**"
  xn2@long_name	= "**simple size in "+y2@long_name+"**"
  print(xn1)
  print(xn2)

    xdiff				= xave1-xave2
  copy_VarCoords(xave1,xdiff)
  xdiff@long_name		= "the difference of average between ( " +y1@long_name+ " ) and ( " +y2@long_name+" )"
  printVarSummary(xdiff)

  statis			= ttest(xave1,xvar1,xn1,xave2,xvar2,xn2,False,True)
  
  prob				= statis(0,:,:,:)
  copy_VarCoords(xdiff,prob)
  prob@long_name		= "probability of " + xdiff@long_name 
  printVarSummary(prob)

  tvalue			= statis(1,:,:,:)
  copy_VarCoords(xdiff,tvalue)
  tvalue@long_name	= "student t value of " + xdiff@long_name
  printVarSummary(tvalue)   

  tflag10		= cdft_t(1-0.05,xn1+xn2-2)
  tflag05		= cdft_t(1-0.025,xn1+xn2-2)
    
  print("critical student t value for 0.1 significant level : " + tflag10)
  print("critical student t value for 0.05 significant level : " + tflag05)
   
  tvalue@tflag10= tflag10
  tvalue@tflag05= tflag05

  ; do i=0,nmonth-1
  ; var_monave=dim_avg_n_Wrap(var_new(:,i,:,:),0)
  ;  var_monave=var_mon-conform_dims(dimsizes(var_mon), dim_avg_n_Wrap(var_mon({1980:2020},:,:),0), (/1,2/));扩展数组或标量，使其符合 给定的尺寸大小。
  ;   printVarSummary(var_mon)
  ; var_ano=var_ori
  ;   var_ano=var_mon({2019},:,:)
   ; printVarSummary(var_ano)


;**********************************************************************
sres						= True
sres@gsnFrame				= False
sres@gsnDraw				= False

sres@cnFillOn				= True
sres@cnLinesOn			= False
sres@cnLineLabelsOn		= False
sres@cnInfoLabelOn		= False
sres@cnLevelSelectionMode	= "ExplicitLevels"


sres@gsnSpreadColors		= True
sres@gsnSpreadColorStart	= 2 
sres@gsnSpreadColorEnd	= 12;pre12;bluedarkred18 19

sres@cnLevels = (/0,0.4,0.8,1.2,1.6/)
sres@cnFillColors = (/-1,8,9,10,11,12/)

  ; Resources for colorbar
  sres@lbOrientation			= "horizontal"
  sres@lbLabelBarOn				= True
  sres@pmLabelBarOrthogonalPosF	= 0.11
  ;sres@pmLabelBarParallelPosF	= 0.6
  sres@pmLabelBarWidthF			= 0.55
  sres@pmLabelBarHeightF		= 0.06
 
  ;   ; ; Resources for colorbar
  ;  sres@lbOrientation			= "vertical"
  ;  sres@lbLabelBarOn				= True
  ; ; sres@pmLabelBarOrthogonalPosF	= 0.11
  ; ; ;sres@pmLabelBarParallelPosF	= 0.6
  ;  sres@pmLabelBarWidthF			= 0.1
  ;  sres@pmLabelBarHeightF		= 0.5
 
  ; Resources for map
  sres@mpCenterLonF			= 180
  sres@mpMinLatF			= latmin
  sres@mpMaxLatF			= latmax
  sres@mpMinLonF			= lonmin
  sres@mpMaxLonF			= lonmax
   ;-----resource for China map 
sres@mpDataSetName = "/mnt/e/nclstudy/nclscripts/Earth..4"
sres@mpDataBaseVersion = "MediumRes" ; or "Ncarg4_1"
sres@mpOutlineOn = True
;sres@mpOutlineSpecifiers = (/"China","China:Provinces"/)
sres@mpOutlineSpecifiers = (/"China:Yunnan"/)
sres@mpGeophysicalLineColor = "black"
;sres@mpOutlineBoundarySets = "NoBoundaries"
;sres@Geophysical = "NoBoundaries"
;sres@mpNationalLineThicknessF = 2.0
sres@mpFillAreaSpecifiers = (/"land","water","land"/)
sres@mpSpecifiedFillColors = (/"white","white","transparent"/)
sres@mpFillDrawOrder = "PostDraw"
   
 
   sres@mpFillOn				= True
   sres@mpLandFillColor		= 20
   sres@mpOutlineOn			= True
   sres@mpGeophysicalLineColor	= "blue"
   sres@gsnAddCyclic			= False
 
  ; Resources for Axis
   font_height				= 0.018						       
   sres@tmYLLabelFontHeightF	= font_height
   sres@tmXBLabelFontHeightF	= font_height
   sres@tiXAxisFontHeightF	= 1.2 * font_height
   sres@tiYAxisFontHeightF	= 1.2 * font_height
   sres@tiMainFontHeightF	= 1.2 * font_height
   sres@gsnLeftStringFontHeightF=1.2 * font_height
   sres@gsnRightStringFontHeightF=1.2 *font_height
 ; sres@gsnRightString		= "~S~o~N~C"
   ;sres@gsnLeftStringOrthogonalPosF	= -0.0
   ;sres@tiMainString			= abs(monmin)+ " - " + monmax + "."+ varname + "." + ymstar/100+ " - " +ymend/100
   sres@tiMainOffsetYF 		= 0.03

   sres@tmXBValues  = ispan(50,110,10)
   sres@tmXBLabels  = ispan(50,110,10)+"E"
  ;  res@tmYLValues   = (/-60,-30,0,30/)
  ;  res@tmYLLabels   = (/"60~S~o~N~S","30~S~o~N~S","Eq","30~S~o~N~N"/)
  ;  res@tmXBMinorValues    = ispan(40,120,10)
  ;  res@tmYLMinorValues    = ispan(-60,30,10)
  sres@tmYLValues = ispan(10,60,5);(/-60,-30,0,30/)
  sres@tmYLLabels  = ispan(10,60,5)+"N";(/"60~S~o~N~S","30~S~o~N~S","Eq","30~S~o~N~N"/)

  sres@tmXBMinorOn		= False
  sres@tmYLMinorOn		= False
  sres@tmYROn			= False
  sres@tmXTOn			= False
    sres@vpWidthF=0.6

  sres@tmXBMajorLengthF			= 0.004
  sres@tmXBMajorOutwardLengthF	= 0.004
  sres@tmXBLabelDeltaF			= -0.5
  sres@tmYLMajorLengthF			= 0.004
  sres@tmYLMajorOutwardLengthF	= 0.004
  sres@tmYLLabelDeltaF			= -0.5

   ;Resources for contour plot
  ;Resources for contour plot
  res				= True
  res@gsnDraw			= False
  res@gsnFrame			= False
  
  res@cnFillOn			= True
  res@cnLinesOn			= False
  res@cnLineLabelsOn		= False
  res@cnInfoLabelOn    		= False
  res@cnMonoFillPattern		= False
  
  res@cnFillPatterns		= (/17,-1,17/)
   res@cnFillDotSizeF		= 0.004
  ; res@cnFillScaleF=2.5
    res@cnFillScaleF=1

  res@cnLevelSelectionMode	= "ExplicitLevels"
  res@cnLevels			= (/-1.0*tflag05,tflag05/)
  res@cnFillColors=(/"black","white","black"/)

  res@gsnAddCyclic		= False
  

   

;res@cnLevelSpacingF = 10.0
;res@cnMinLevelValF=10

plotdir="./"
plotname=Ts_filename+"ERA5_"+varname1+"ano_"+syntype+"timechoose="+swvl_choose+"comflag="+com_flag+"critic="+critic_flag+"dtrend="+dtrend_flag+"small"
plottype="pdf"
wks       = gsn_open_wks(plottype,plotdir+plotname)
gsn_define_colormap(wks,"CBR_drywet")
gsn_reverse_colormap(wks);翻转色标
;plot=new(dimsizes(var&month),graphic)

  

  sres1=sres

 ; sres1@pmTickMarkDisplayMode="Always" 
  

  sres1@gsnLeftStringOrthogonalPosF    = 0.01
  sres1@gsnRightStringOrthogonalPosF   = 0.01

  plot=new(num(plotmon),graphic)
  dum=new(num(plotmon),graphic)
  dum2=new(num(plotmon),graphic)
 ; contour3=new(num(plotmon),graphic)
  do i=0,num(plotmon)-1

 ; sres1@cnLevels		        = ispan(-8,8,2)/5.

sres1@gsnLeftString   = "("+stringplot(i)+") "+"Com. "+"Compling values_"+com_name
sres1@gsnRightString   = monname(i)+"(0)"


plot(i)  =  gsn_csm_contour_map_overlay(wks,xdiff(i,:,:),tvalue(i,:,:),sres1,res)

y           =(/28.,28.,33.,33.,28./)
x           = (/60.,73.,73.,60.,60./) ;;EIP

y_swc           = (/10.,10.,25.,25.,10./)
x_swc           = (/95.,106.,106.,95.,95./) 

resk=True
resk@gsFillColor  =57
resk@gsLineThicknessF = 2.0
resk@gsLineDashPattern =0
resk@gsLineColor  = "black"
resk@cnFillDrawOrder ="Draw"
;;--------------------------------------------------------------------------------
dum(i)=gsn_add_polyline(wks,plot(i), x, y, resk)
resk@gsLineColor  = "purple"
dum2(i) = gsn_add_polyline(wks, plot(i), x_swc , y_swc, resk)


end do
if swvl_choose .eq. 1 then
gsn_panel(wks, plot, (/2,3/), True)
end if 
if swvl_choose .eq. 3 then
gsn_panel(wks, plot, (/2,1/), True)
end if


  ;plot = gsn_csm_contour_map(wks,var0({2019},:,:),sres1);填色图

end