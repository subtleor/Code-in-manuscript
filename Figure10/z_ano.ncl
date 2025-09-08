load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "/mnt/e/mytool.ncl"

begin
    ; 设置数据文件路径和文件名
    z_choose=3;1,3
    lvl=500
    filedir1="/mnt/e/westsouth/data/"
    filename1="ERA5.mon.geopotential.1950-2022.nc"
    var_dat    ="ERA5"
    varname1    = "z"        ;

    latmin=0
latmax=40
lonmin=45
lonmax=150

    ; 打开数据文件
    f =addfile(filedir1+filename1, "r")

    ymstar	= 198001
    ymend		= 202012
    if z_choose .eq. 3 then
    monname=(/"MAM","JJA"/)
    monmin	= (/3,6/)	;starting month for averaging,(monmin != 0,-12 <= monmin <= monmax <=12). negative value for previou year(year(-1)) 
    monmax	= (/5,8/)	;ending month for averaging,	   1<= monmax <= 12 
    plotmon=(/35,68/)
    stringplot=(/"b","e"/)
    end if 
    if z_choose .eq. 1 then
    monmin=(/3,4,5,6,7,8/)
    monmax=(/3,4,5,6,7,8/)
    plotmon=(/3,4,5,6,7,8/)
    stringplot=(/"a","b","c","d","e","f"/)
    monname=(/"Mar","Apr","May","Jun","Jul","Aug"/)
    end if
plotyear=2019
dtrend_flag=1
    ; 读取需要的变量（例如纬向风场、时间）
    var =short2flt(f->$varname1$(:,{lvl},:,:))    
    var=(/var/9.8/)
    printVarSummary(var)
    time=f->time
    var_time_DATE	= cd_calendar(time,-1)
    printMinMax(var,0)
    printVarSummary(var)
  
    tstar		= ind(var_time_DATE .eq. ymstar)
    tlast		= ind(var_time_DATE .eq. ymend)
    print(tstar)
    print(tlast)
    var_1   = var(tstar:tlast,:,:)
    delete([/var/])
    printVarSummary(var_1)

    var1=short2flt(f->$varname1$(:,{200},:,:))
    var1=(/var1/9.8/)
    printVarSummary(var1)
    var_2=var1(tstar:tlast,:,:)
    delete([/var1/])
    var2_monave=month_to_monave(var_2,6,8)

    var2_ave=dim_avg_n_Wrap(var2_monave,0)
    var2_2019=var2_monave({2019},:,:)
  nyear=ymend/100-ymstar/100+1

  dims= dimsizes(var_1)
  print(dims)

   var_new=new((/nyear,num(plotmon),dims(1),dims(2)/),typeof(var_1),var_1@_FillValue)
   var_ano=new((/nyear,num(plotmon),dims(1),dims(2)/),typeof(var_1),var_1@_FillValue)
   var_extreme=new((/nyear,num(plotmon),dims(1),dims(2)/),typeof(var_1),var_1@_FillValue) 

  ; 计算1980-2020年间的春夏季位势高度平均值
  do i=0,num(plotmon)-1    
    var_mon = month_to_monave(var_1,monmin(i),monmax(i))
    printVarSummary(var_mon)
    var_new(:,i,:,:)=var_mon
  end do
  var_new!1="month"
  var_new&month=plotmon
    printVarSummary(var_new)

  if dtrend_flag .eq. 0 then  
    var_new = var_new
     
    else
    var_new	= (/dtrend_msg_n(ispan(1,dimsizes(var_new&year),1)*1.0,var_new,False,True,0)/)

    end if
   
  var_ori=var_new
  ;var_ori=var_new
printMinMax(var_ori,0)
  do i=0,nyear-1
  do j=0,num(plotmon)-1
  var_ano(i,j,:,:)=var_new(i,j,:,:)-dim_avg_n_Wrap(var_new(:,j,:,:),0)
  end do
  end do
  copy_VarCoords(var_new,var_ano)
  printVarSummary(var_ano)

  ; do i=0,nmonth-1
  ; var_monave=dim_avg_n_Wrap(var_new(:,i,:,:),0)
  ;  var_monave=var_mon-conform_dims(dimsizes(var_mon), dim_avg_n_Wrap(var_mon({1980:2020},:,:),0), (/1,2/));扩展数组或标量，使其符合 给定的尺寸大小。
  ;   printVarSummary(var_mon)
  ; var_ano=var_ori
  ;   var_ano=var_mon({2019},:,:)
   ; printVarSummary(var_ano)

  ; 计算标准差
  var_std=dim_stddev_n_Wrap(var_ori,0);标准化
  printVarSummary(var_std)
  do i=0,nyear-1
  var_extreme_p=where(var_ano(i,:,:,:) .ge. var_std,1,0)
  var_extreme_n=where(var_ano(i,:,:,:) .le. -1.0*var_std,-1,0)

  var_extreme(i,:,:,:)=var_extreme_p+var_extreme_n
end do 
  copy_VarCoords(var_ano,var_extreme);将std的信息复制给extreme
  printVarSummary(var_extreme)
  printMinMax(var_extreme,0)
 printMinMax(var_ano,0)

  plot_extreme=var_extreme({plotyear},:,:,:)
  plot_ano=var_ano({plotyear},:,:,:)
  printVarSummary(plot_extreme)
  printVarSummary(plot_ano)

 ;plot
;**********************************************************************
sres						= True
sres@gsnFrame				= False
sres@gsnDraw				= False

sres@cnFillOn				= True
sres@cnLinesOn			= False
sres@cnLineLabelsOn		= False
sres@cnInfoLabelOn		= False
sres@cnLevelSelectionMode	= "ExplicitLevels"

sres@cnLevels		        = ispan(-16,16,4)

sres@gsnSpreadColors		= True
sres@gsnSpreadColorStart	= 2 
sres@gsnSpreadColorEnd	= 19;pre12;bluedarkred18 19

  ; Resources for colorbar
  sres@lbOrientation			= "horizontal"
  sres@lbLabelBarOn				= True
  sres@pmLabelBarOrthogonalPosF	= 0.11
  ;sres@pmLabelBarParallelPosF	= 0.6
  sres@pmLabelBarWidthF			= 0.55
  sres@pmLabelBarHeightF		= 0.06
 
  ; Resources for map
  sres@mpCenterLonF			= 180
  sres@mpMinLatF			= latmin
  sres@mpMaxLatF			= latmax
  sres@mpMinLonF			= lonmin
  sres@mpMaxLonF			= lonmax
   ;-----resource for China map 
   sres@mpDataSetName = "/mnt/e/nclstudy/nclscripts/Earth..4"
   sres@mpDataBaseVersion = "MediumRes" ; or "Ncarg4_1"
   ;sres@mpOutlineOn = True
   ;sres@mpOutlineSpecifiers = (/"China","China:Provinces"/)
   sres@mpOutlineSpecifiers = (/"China:Yunnan"/)
   sres@mpGeophysicalLineColor = "black"
   ;sres@mpOutlineBoundarySets = "NoBoundaries"
   ;sres@Geophysical = "NoBoundaries"
   ;sres@mpNationalLineThicknessF = 2.0
   sres@mpFillAreaSpecifiers = (/"land","water","China"/)
   sres@mpSpecifiedFillColors = (/"white","white","transparent"/)
   sres@mpFillDrawOrder = "Draw"
   
 
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
   sres@gsnLeftStringFontHeightF= font_height
   sres@gsnRightStringFontHeightF=font_height
 ; sres@gsnRightString		= "~S~o~N~C"
   ;sres@gsnLeftStringOrthogonalPosF	= -0.0
   ;sres@tiMainString			= abs(monmin)+ " - " + monmax + "."+ varname + "." + ymstar/100+ " - " +ymend/100
   sres@tiMainOffsetYF 		= 0.03

   sres@tmXBValues  = ispan(45,150,15)
   sres@tmXBLabels  = ispan(45,150,15)+"E"
  ;  res@tmYLValues   = (/-60,-30,0,30/)
  ;  res@tmYLLabels   = (/"60~S~o~N~S","30~S~o~N~S","Eq","30~S~o~N~N"/)
  ;  res@tmXBMinorValues    = ispan(40,120,10)
  ;  res@tmYLMinorValues    = ispan(-60,30,10)
  sres@tmYLValues = ispan(0,50,10);(/-60,-30,0,30/)
  sres@tmYLLabels  = ispan(0,50,10)+"N";(/"60~S~o~N~S","30~S~o~N~S","Eq","30~S~o~N~N"/)

  sres@tmXBMinorOn		= False
  sres@tmYLMinorOn		= False
  sres@tmYROn			= False
  sres@tmXTOn			= False
  
  sres@tmXBMajorLengthF			= 0.004
  sres@tmXBMajorOutwardLengthF	= 0.004
  sres@tmXBLabelDeltaF			= -0.5
  sres@tmYLMajorLengthF			= 0.004
  sres@tmYLMajorOutwardLengthF	= 0.004
  sres@tmYLLabelDeltaF			= -0.5

   ;Resources for contour plot
   res					= True
   res@gsnDraw			= False
   res@gsnFrame			= False
   
   res@cnFillOn					= True
   res@cnLinesOn					= False
   res@cnLineLabelsOn			= False
   res@cnInfoLabelOn    			= False
   res@cnMonoFillPattern			= False
   
   res@cnFillPatterns			= (/17,-1,17/)
   ;res@cnFillDotSizeF			= 0.004
   res@cnFillDotSizeF			= 0.005
   res@cnFillScaleF=1.5
   res@cnLevelSelectionMode		= "ExplicitLevels"
   res@cnFillColors=(/"black","white","black"/)
   res@gsnAddCyclic					= False
   res@gsnMajorLatSpacing	= 5
   res@vpWidthF=0.6
   sres@vpWidthF=0.6


;res@cnLevelSpacingF = 10.0
res@cnLevels          = (/-0.9,0.9/)
;res@cnMinLevelValF=10

plotdir="./"
plotname="ERA5_"+lvl+varname1+"ano_"+plotyear+"timechoose="+z_choose
plottype="pdf"
wks       = gsn_open_wks(plottype,plotdir+plotname)
gsn_define_colormap(wks,"BlueDarkRed18")
;gsn_reverse_colormap(wks);翻转色标
;plot=new(dimsizes(var&month),graphic)

  

  sres1=sres

 ; sres1@pmTickMarkDisplayMode="Always" 
  sres1@gsnRightString   = plotyear

  sres1@gsnLeftStringOrthogonalPosF    = 0.01
  sres1@gsnRightStringOrthogonalPosF   = 0.01
  sres1@pmLabelBarOrthogonalPosF = 0.15

  plot=new(num(plotmon),graphic)
  dum=new(num(plotmon),graphic)
  dum2=new(num(plotmon),graphic)
 ; contour3=new(num(plotmon),graphic)
  do i=0,num(plotmon)-1
  
  if i.eq.0 then 
; if i.eq.1 then 
  sres1@cnLevels		        = ispan(-24,24,6)
  end if 
  if i.eq.1 then
  sres1@cnLevels		        = ispan(-16,16,4)
  end if
; end if
  sres1@gsnLeftString   = "("+stringplot(i)+") Ano. "+lvl+"z"+"_"+monname(i)

  plot(i)  =  gsn_csm_contour_map_overlay(wks,plot_ano(i,:,:),plot_extreme(i,:,:),sres1,res)

  y           =(/28.,28.,33.,33.,28./)
  x           = (/60.,70.,70.,60.,60./) ;;EIP

  y_swc           = (/21.,21.,29.,29.,21./)
  x_swc           = (/97.,107.,107.,97.,97./) 

  resk=True
  resk@gsFillColor  =57
  resk@gsLineThicknessF = 3.0
  resk@gsLineDashPattern =0
  resk@gsLineColor  = "black"
  resk@cnFillDrawOrder ="Draw"
;;--------------------------------------------------------------------------------
;dum(i)=gsn_add_polyline(wks,plot(0), x, y, resk)
resk@gsLineColor  = "purple"
dum2(i) = gsn_add_polyline(wks, plot(i), x_swc , y_swc, resk)

  ;叠加位势高度原始场的特定等值线


end do

if lvl .eq. 500 then
;叠加位势高度原始场的特定等值线
sress = True
sress@gsnAddCyclic = False                             ; 如果你的数据已经处理过周期性边界，则设为False

sress@gsnLeftString   = ""
sress@gsnRightString   = ""
sress@gsnFrame            = False
sress@gsnDraw             = False
sress@cnLineLabelsOn         =False
sress@cnInfoLabelOn=False
sress@cnLevelSelectionMode = "ExplicitLevels"
sress@cnLevels = (/5870/) 
sress@cnLineThicknessF= 4.0
sress@cnMonoLineColor=False
sress@cnLineColors = "Red"  
sress@cnLineDashPattern=0
contour3 = gsn_csm_contour(wks, var_ori({plotyear},1,{0:50},{100:180}), sress)
var_ave=dim_avg_n_Wrap(var_ori(:,:,:,:),0)
sress@cnLineColors = "Green"  
;sres@gsnAddCyclic = False                             ; 如果你的数据已经处理过周期性边界，则设为False
sress@cnLineDashPattern=16
contour4 = gsn_csm_contour(wks, var_ave(1,{0:50},{100:180}), sress)
overlay(plot(1), contour3)
overlay(plot(1), contour4)

sress@cnLevels = (/12540/) 
sress@cnLineThicknessF= 4.0
sress@cnMonoLineColor=False
sress@cnLineColors = "Red"  
sress@cnLineDashPattern=0
contour5 = gsn_csm_contour(wks, var2_2019({0:50},{0:150}), sress)
sress@cnLineColors = "Green"  
;sres@gsnAddCyclic = False                             ; 如果你的数据已经处理过周期性边界，则设为False
sress@cnLineDashPattern=16
contour6 = gsn_csm_contour(wks, var2_ave({0:50},{0:150}), sress)
overlay(plot(1), contour5)
overlay(plot(1), contour6)
end if
if z_choose .eq. 1 then
gsn_panel(wks, plot, (/2,3/), True)
end if 
if z_choose .eq. 3 then
gsn_panel(wks, plot, (/2,1/), True)
end if

  ;plot = gsn_csm_contour_map(wks,var0({2019},:,:),sres1);填色图

end