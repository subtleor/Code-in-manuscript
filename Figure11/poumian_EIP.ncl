load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
 ;------------------------------------------------------------------
 ; @Author: Zhanghan
 ; @Date: 2024-06-03 20:05:43
 ; @LastEditors: Zhanghan
 ; @LastEditTime: 2024-06-05 10:53:19
 ; @FilePath: \undefinedc:\Users\zhangh\Documents\NetSarang Computer\7\Xftp\Temporary\plot_cep2.ncl
 ; @Description: S2S of ARWC
 ; @834100990  zhangh776@mail2.sysu.edu.cn
 ; @Copyright (c) 2024 by Zhanghan. 
 ;-------------------------------------------------------------------
begin
plot = new(2, graphic)
plot2 = plot
path = "./"
pathout = "./"
exp_name = "EIP"
orfile = addfile(path+exp_name+"_t42.nc", "r")
fcfile = addfile(path+"frc.t42l20."+exp_name+".nc", "r")
evo_day = 22
sellev =500

;-----------------read forcing----------------------
forcing_t_raw =fcfile->t
sigma_level = forcing_t_raw&lev
sigma_level = abs(sigma_level*1000.0- sellev) 
sigma_level_ind= minind(sigma_level)
; print(sigma_level_ind)

forcing_t = forcing_t_raw
forcing_t = forcing_t_raw*3600*24.0
frc_t_longname = str_split(forcing_t@long_name, " ") 
forcing_t@long_name = frc_t_longname(0)+" "+frc_t_longname(1)+" "+frc_t_longname(2)+" "+"day**-1]"
; print(forcing_t@long_name)
printVarSummary(forcing_t)
printMinMax(forcing_t, 0)

latmin_EIP=25
latmax_EIP=35
lonmin_EIP=55
lonmax_EIP=75

latmin_ICP=10
latmax_ICP=25
lonmin_ICP=97
lonmax_ICP=106

;-----------------read results----------------------

u_or= orfile->u
v_or= orfile->v
z_or= orfile->z
sp_or=orfile->p
sf_or=orfile->psi
vp_or=orfile->chi
sf_or = sf_or/1e6
vp_or = vp_or/1e6
sf_or@long_name = sf_or@long_name + "/1e6"
vp_or@long_name = vp_or@long_name + "/1e6"
printVarSummary(sf_or)


; u_or = lonFlip(u_or)
; v_or = lonFlip(v_or)
; z_or = lonFlip(z_or)

;-----------extract -----------
forc_t_spatial = forcing_t(0,0,:,:)
if exp_name.eq."EIP" then
forc_t_profile = dim_avg_n_Wrap(forcing_t(0,:,{latmin_EIP:latmax_EIP},{lonmin_EIP:lonmax_EIP}), (/1,2/))
end if 
if exp_name.eq."ICP" then
forc_t_profile = dim_avg_n_Wrap(forcing_t(0,:,{latmin_ICP:latmax_ICP},{lonmin_ICP:lonmax_ICP}), (/1,2/))
end if

u_plot = dim_avg_n_Wrap(u_or(evo_day:evo_day+7,{200},:,:), 0) 
v_plot = dim_avg_n_Wrap(v_or(evo_day:evo_day+7,{sellev},:,:), 0) 
hgt_plot = dim_avg_n_Wrap(z_or(evo_day:evo_day+7,{sellev},:,:), 0) 
sf_plot =dim_avg_n_Wrap(sf_or(evo_day:evo_day+7,{sellev},:,:), 0) 

; printVarSummary(sf_plot)
; printVarSummary(forc_t_profile)
 printVarSummary(forc_t_spatial)
 printMinMax(forc_t_profile,0)
 print(forc_t_profile)
 
;=================plot===================
;========================================


;==============================hgt_uvsf==================================
wks_type = "pdf"            
;wks_type@wkWidth  = 2500      
;wks_type@wkHeight = 2500 
wks   = gsn_open_wks (wks_type,"poumian"+exp_name)
gsn_define_colormap(wks,"BlueDarkRed18")

;=======================hgt_sf====================     
res=True



lonmin  =45
lonmax  = 130
latmin  =10
latmax  =50

    ; if (sellev.le.200) then
    ; lonmin  = -180
    ; lonmax  = 180
    ; latmin  = 10
    ; latmax  = 80
    ; end if


    res@mpCenterLonF               = 180          


     
       res@mpFillOn				= True
       res@mpLandFillColor		= 20
       res@mpOutlineOn			= True
       res@mpGeophysicalLineColor	= "blue"
       res@gsnAddCyclic			= False
    ; res@mpProjection          = "Stereographic"
    ; res@gsnPolar              = "NH"
    ;res@pmTickMarkDisplayMode  = "Always"        ; turn on nicer map tickmarks


    res@gsnAddCyclic         = False
    res@mpMinLonF                  = lonmin
    res@mpMaxLonF                  = lonmax
    res@mpMinLatF                  = latmin
    res@mpMaxLatF                  = latmax               ;画图范围
    
    ; res@cnSmoothingOn = True
    ; res@gsnMajorLonSpacing         = 30            ;经纬度主要间隔
    ; res@gsnMinorLonSpacing         = 15
    ; res@gsnMajorLatSpacing         = 10
    ; res@gsnMinorLatSpacing         = 15  ;次要间隔

  ;  res@gsnMaximize                = True
    ;;;;;;;;;;;;;;;;
    res@mpFillOn                   = True             ;陆地填充
    res@mpDataBaseVersion      = "MediumRes"     ; better map outlines
    res@cnFillOn                   = True     ;颜色填充
    res@cnLinesOn                  = False         ;绘制等值线
    ;res@cnSmoothingOn              = True       ;平滑
    ;res@cnSmoothingDistanceF       = 0.1       
    ;res@cnSmoothingTensionF        = -0.005       ;防止等值线交叉
    res@cnLineLabelsOn             = False            ;False;等高线数值是否显现

    res@gsnDraw              = False        ;先不画图
    res@gsnFrame             = False

    res@lbLabelBarOn               = True            ;每一张图对应的labelbar关闭
    res@pmLabelBarOrthogonalPosF   =0.05        ;labelbar垂直位置
    res@pmLabelBarWidthF   = 0.7                ;labelbar宽度
    res@pmLabelBarHeightF  = 0.07                ;labelbar高度
    res@lbLabelFontHeightF = 0.012               ;labelbar字体大小

    res@cnInfoLabelOn              = False  ;打开等值线信息标签
    res@cnLineLabelInterval           = 1   ;默认的值为2，即每间隔一个等值线画一个
    res@cnLineThicknesses               =0.05
   ; res@lbTitleString              ="Linear trend"
   ; res@lbTitlePosition            ="Bottom"
   ; res@lbTitleFontThicknessF      =0.05
   ; res@lbTitleFontHeightF         =0.02
   ; res@cnLevelSelectionMode       = "AUTOMATICLEVELS";
    ;res@mpOutlineBoundarySets= "National"
    res@cnLevelSelectionMode = "ManualLevels"  ;手动设置等值线属性
    res@cnMinLevelValF  = -10.  
    res@cnMaxLevelValF  = 10.
    res@cnLevelSpacingF = 2.5  

    if (exp_name .eq."ICP") then
    if (sellev.eq.500) then
    res@cnMinLevelValF  = -8.
    res@cnMaxLevelValF  = 8.
    res@cnLevelSpacingF = 2   
    end if
    if (sellev.le.200) then
    res@cnMinLevelValF  = -15.
    res@cnMaxLevelValF  = 15.
    res@cnLevelSpacingF = 3.   
    end if
    end if


    ; res@gsnSpreadColors         = True
    ; res@gsnSpreadColorStart=25
    ; res@gsnSpreadColorEnd=235

    ; res@cnFillColors =(/2,12,22,32,52,62,0,150,170,190,200,220,230,250/)


    ; res@mpDataSetName              = "/Earth..4"     
    res@mpDataBaseVersion          = "LowRes"       ;"MediumRes"中等分辨率  
    res@mpOutlineOn                = True
    ; res@mpOutlineSpecifiers        = (/"China"/)


   ; res@mpPerimLineThicknessF=3
   ; res@mpNationalLineThicknessF=3
;    res@mpGeophysicalLineThicknessF=1

    ;res@mpLandFillColor         ="grey90"    ;陆地填充颜色
    ; res@mpFillDrawOrder    ="PreDraw"
    ; res@cnFillDrawOrder    ="PreDraw"              ;画线的顺序 另有PostDraw
    res@cnLinesOn          =False                  ;不画等值线
    res@cnLineDrawOrder       = "PreDraw"          ;只在陆地有等值线
    res@mpInlandWaterFillColor = "grey90"           ;内陆湖泊填充
    res@lbLabelAutoStride          = True         ;自动控制等值线标签每间隔几个输出
    res@cnLineLabelStrings         =True         
  ;  res@pmTickMarkDisplayMode      = "Always"     ;坐标轴标签添加符号度
    ;res@gsnPanelFigureStrings      =(/"a","b", "c"/)
    ;res@vpHeightF        =0.4       ;每张图的高度
   ; res@vpWidthF         =0.6       ;宽度
    res@tmYLLabelFontHeightF = 0.012;Y轴字体大小
    res@tmXBLabelFontHeightF = 0.012;X轴
    res@gsnLeftStringFontHeightF = 0.015;左上角字体大小
    res@gsnRightStringFontHeightF= 0.015
    res@gsnRightString =   "gpm"  ;右上角内容
    res@gsnLeftStringOrthogonalPosF = 0.01
    res@gsnRightStringOrthogonalPosF = 0.01
    res@tmBorderThicknessF        =1.5
    res@tmXBMajorThicknessF=1.5
    res@tmYLMajorThicknessF=1.5


    font_height				= 0.02						       
    res@tmYLLabelFontHeightF	= font_height
    res@tmXBLabelFontHeightF	= font_height
    res@tiXAxisFontHeightF	= 1.2 * font_height
    res@tiYAxisFontHeightF	= 1.2 * font_height
    res@tiMainFontHeightF	= 1.2 * font_height
    res@gsnLeftStringFontHeightF= font_height
    res@gsnRightStringFontHeightF=font_height
    res@gsnLeftStringOrthogonalPosF	= 0.01
    res@tmXBMajorLengthF			= 0.004
    res@tmXBMajorOutwardLengthF	= 0.004
    res@tmXBLabelDeltaF			= -0.5
    res@tmYLMajorLengthF			= 0.004
    res@tmYLMajorOutwardLengthF	= 0.004
    res@tmYLLabelDeltaF			= -0.5

    res@tmXBValues  = ispan(45,130,15)
res@tmXBLabels  = ispan(45,130,15)+"E"
res@tmYLValues = ispan(10,50,10);(/-60,-30,0,30/)
res@tmYLLabels  = ispan(10,50,10)+"N"

res@tmXBMinorOn		= False
res@tmYLMinorOn		= False
res@tmYROn			= False
res@tmXTOn			= False

         ;-----resource for China map 
         res@mpDataSetName = "/mnt/e/nclstudy/nclscripts/Earth..4"
         res@mpDataBaseVersion = "MediumRes" ; or "Ncarg4_1"
         ;res@mpOutlineOn = True
         ;res@mpOutlineSpecifiers = (/"China","China:Provinces"/)
         res@mpOutlineSpecifiers = (/"China:Yunnan"/)
         res@mpGeophysicalLineColor = "black"
         ;res@mpOutlineBoundarySets = "NoBoundaries"
         ;res@Geophysical = "NoBoundaries"
         ;res@mpNationalLineThicknessF = 2.0
         res@mpFillAreaSpecifiers = (/"land","water","China"/)
         res@mpSpecifiedFillColors = (/"white","white","transparent"/)
         res@mpFillDrawOrder = "Draw"
        res@gsnLeftString  = "(b) "+sellev+"z_MAM"
        
    res@gsnRightString  = ""
    res@pmLabelBarOrthogonalPosF = 0.08
    res@pmLabelBarWidthF = 0.7
    res@pmLabelBarHeightF = 0.07
    res@lbLabelFontHeightF = 0.02
   ; plot(0) = gsn_csm_contour_map(wks,hgt_plot,res)
    printMinMax(hgt_plot, True)
    

    res@cnMinLevelValF  = -8
    res@cnMaxLevelValF  = 8
    res@cnLevelSpacingF = 2
    res@gsnLeftString  = "(f) "+sellev+"u_JJA"
    res@gsnRightString  = ""
   ; plot(1) = gsn_csm_contour_map(wks,u_plot,res)
    printMinMax(sf_plot, True)
    

;=======================uv====================     
vcres= True             

    vcres@gsnAddCyclic         = False
    vcres@gsnDraw              = False            ; don't draw yet
    vcres@gsnFrame             = False            ; don't advance frame yet
    ;vcres@vpHeightF          =0.4       ;每张图的高度
   ; vcres@vpWidthF           =0.6       ;宽度
    vcres@vcRefAnnoOrthogonalPosF = -1.5         ; 参考向量上下移动

    vcres@vcRefMagnitudeF    = 0.5                  ; define vector ref mag 
    vcres@vcRefAnnoString2     = "0.5 m/s"           ;下侧字
    if (sellev.eq.200) then
    vcres@vcRefMagnitudeF    = 0.5                  ; define vector ref mag 
    vcres@vcRefAnnoString2     = "0.5 m/s"           ;下侧字
    end if
   ; vcres@vcRefAnnoFont ="helvetica-bold"
    vcres@vcRefAnnoBackgroundColor = -1           ;参考向量背景色，-1为透明
    vcres@vcRefAnnoPerimOn   = False              ;参考向量边框
    vcres@vcRefAnnoString1On = False              ;参考向量上侧字
    vcres@vcRefAnnoString2On = True               ;下侧字
    vcres@vcRefAnnoFontHeightF = 0.01             ;参考向量高度
    ;vcres@vcRefAnnoString1     = "2" 
    vcres@vcGlyphStyle            = "CurlyVector"    ; FillArrow   CurlyVector  LineArrow 
    vcres@vcLineArrowColor     = "black"
    vcres@vcMonoLineArrowColor    = True
    vcres@vcMonoFillArrowFillColor= True
    vcres@vcFillArrowFillColor    = "black"
    vcres@vcFillArrowEdgeColor    = -1
    vcres@vcRefLengthF            = 0.04             ; define length of vec ref
    vcres@vcFillArrowHeadXF = 0.4
    vcres@vcFillArrowHeadYF = 0.15
    vcres@vcFillArrowHeadInteriorXF = 0.20
    vcres@vcFillArrowWidthF = 0.1
    vcres@vcLineArrowThicknessF      = 2.0
    ;vcres@gsnAddCyclic           = False  ; Don't add longitude cyclic pt.
    ;vcres@vcLineArrowThicknessF  = 1.5
    vcres@gsnLeftString = " "
    vcres@gsnRightString = " "
    vcres@vcWindBarbLineThicknessF=1.5
    vcres@tmYLLabelFontHeightF = 0.015
    vcres@tmXBLabelFontHeightF = 0.015
    vcres@vcMinMagnitudeF=0.2
    vcres@vcMinDistanceF          = 0.02
    ;plot1 = gsn_csm_vector(wks,u_plot,v_plot,vcres)
    ;overlay(plot(1), plot1)

;======================forcing================================
printVarSummary(forc_t_profile)
printVarSummary(forc_t_spatial)

fres						= True
fres@gsnFrame				= False
fres@gsnDraw				= False

fres@cnFillOn				= True
fres@cnLinesOn			= False
fres@cnLineLabelsOn		= False
fres@cnInfoLabelOn		= False

fres@gsnSpreadColors		= True
fres@gsnSpreadColorStart	= 2 
fres@gsnSpreadColorEnd	= 19;pre12;bluedarkred18 19

  ; Resources for colorbar
  fres@lbOrientation			= "horizontal"
  fres@lbLabelBarOn				= True
  fres@pmLabelBarOrthogonalPosF	= 0.11
  ;fres@pmLabelBarParallelPosF	= 0.6
  fres@pmLabelBarWidthF			= 0.55
  fres@pmLabelBarHeightF		= 0.06
 
  ; Resources for map
  fres@mpCenterLonF			= 180
  fres@mpMinLatF			= latmin
  fres@mpMaxLatF			= latmax
  fres@mpMinLonF			= lonmin
  fres@mpMaxLonF			= lonmax


   ;-----resource for China map 
   fres@mpDataSetName = "/mnt/e/nclstudy/nclscripts/Earth..4"
   fres@mpDataBaseVersion = "MediumRes" ; or "Ncarg4_1"
   ;fres@mpOutlineOn = True
   ;fres@mpOutlineSpecifiers = (/"China","China:Provinces"/)
   fres@mpOutlineSpecifiers = (/"China:Yunnan"/)
   fres@mpGeophysicalLineColor = "black"
   ;fres@mpOutlineBoundarySets = "NoBoundaries"
   ;fres@Geophysical = "NoBoundaries"
   ;fres@mpNationalLineThicknessF = 2.0
   fres@mpFillAreaSpecifiers = (/"land","water","China"/)
   fres@mpSpecifiedFillColors = (/"white","white","transparent"/)
   fres@mpFillDrawOrder = "Draw"
   
 
   fres@mpFillOn				= True
   fres@mpLandFillColor		= 20
   fres@mpOutlineOn			= True
   fres@mpGeophysicalLineColor	= "blue"
   fres@gsnAddCyclic			= False
 
  ; Resources for Axis
   font_height				= 0.022						       
   fres@tmYLLabelFontHeightF	= font_height
   fres@tmXBLabelFontHeightF	= font_height
   fres@tiXAxisFontHeightF	= 1.2 * font_height
   fres@tiYAxisFontHeightF	= 1.2 * font_height
   fres@tiMainFontHeightF	= 1.2 * font_height
   fres@gsnLeftStringFontHeightF= font_height
   fres@gsnRightStringFontHeightF=font_height
 ; fres@gsnRightString		= "~S~o~N~C"
   ;fres@gsnLeftStringOrthogonalPosF	= -0.0
   ;fres@tiMainString			= abs(monmin)+ " - " + monmax + "."+ varname + "." + ymstar/100+ " - " +ymend/100
   fres@tiMainOffsetYF 		= 0.03
fres@mpMinLonF                  = 55
fres@mpMaxLonF                  = 80
fres@mpMinLatF                  = 20
fres@mpMaxLatF                  = 40 

fres@tmXBValues  = ispan(55,80,10)
fres@tmXBLabels  = ispan(55,80,10)+"E"
fres@tmYLValues = ispan(20,40,10);(/-60,-30,0,30/)
fres@tmYLLabels  = ispan(20,40,10)+"N"

fres@tmXBMinorOn		= False
fres@tmYLMinorOn		= False
fres@tmYROn			= False
fres@tmXTOn			= False

fres@tmXBMajorLengthF			= 0.004
fres@tmXBMajorOutwardLengthF	= 0.004
fres@tmXBLabelDeltaF			= -0.5
fres@tmYLMajorLengthF			= 0.004
fres@tmYLMajorOutwardLengthF	= 0.004
fres@tmYLLabelDeltaF			= -0.5
  fres@cnFillPalette              = "BlueDarkRed18"
  fres@cnLevelSelectionMode ="ExplicitLevels"  
  if exp_name .eq."ICP" then
fres@cnLevels = (/0,0.5,1.0,1.5,2,3/)
fres@cnFillColors = (/-1,7,8,9,10,11,12/)
end if 
if exp_name .eq."EIP" then
fres@cnLevels = (/-3,-2,-1.5,-1,-0.5,0/)
fres@cnFillColors = (/2,3,4,5,6,-1,-1/)
end if

; fres@cnMinLevelValF  = -4.5
; fres@cnMaxLevelValF  = -0.5
; fres@cnLevelSpacingF = 0.5  
if exp_name .eq."ICP" then
fres@gsnLeftString  = "(c) "+"LBM_EXP2_heating forcing"  
end if 
if exp_name .eq."EIP" then
fres@gsnLeftString  = "(d) "+"LBM_EXP_SM_cooling forcing"  
end if 
fres@gsnLeftStringOrthogonalPosF = 0.01
fres@gsnRightStringOrthogonalPosF =0.01
printMinMax(forc_t_spatial, True)
plotf= gsn_csm_contour_map_ce(wks,forc_t_spatial,fres)


pfres                   = True                       ; plot mods desired
pfres@trYReverse        = True                       ; reverse Y-axis;!!!!!!!!!!
pfres@gsnFrame          = False                      ; don't advance frame yet
pfres@gsnDraw              = False            ; don't draw yet
font_height                  = 0.02; 0.016
pfres@tmYRLabelFontHeightF     = font_height
pfres@tmXBLabelFontHeightF     = font_height
pfres@tiXAxisFontHeightF       = 1.2 * font_height
pfres@tiYAxisFontHeightF       = 1.2 * font_height
pfres@tiMainFontHeightF        = 1.2 * font_height
pfres@gsnLeftStringFontHeightF= 0.9*font_height
pfres@gsnRightStringFontHeightF= 0.9*font_height
pfres@tiMainOffsetYF         = -0.01
pfres@pmLegendDisplayMode    = False;"Always"              ; turn on legend

pfres@pmLegendSide           = "Bottom";"Top"                 ; Change location of 
;pfres@pmLegendParallelPosF   = .90                   ; move units right

pfres@pmLegendWidthF         = 0.03 ;0.12                  ; Change width and
pfres@pmLegendHeightF        = 0.2;0.25                  ; height of legend.
;pfres@lgLabelFontHeightF     = 1.2 * font_height;.02                   ; change font height
pfres@lgPerimOn              = False 

pfres@tmXBMinorOn        = False
pfres@tmYRMinorOn        = False
pfres@tmYLMinorOn        = False
pfres@tmXTOn             = False
pfres@tmYLOn             = False
pfres@tmYRLabelsOn=True

; pfres@tmYLMode = "Automatic";
pfres@tmYRMode              = "Explicit"
pfres@tmYRValues            =(/1,0.925,0.850,0.700,0.500,0.300,0.200,0.100/)
; print(pfres@tmYRValues)
; print(forc_t_profile&lev)
; exit
pfres@tmYRLabels            = pfres@tmYRValues;+"hPa"
pfres@pmTickMarkDisplayMode="Always"
pfres@tiYAxisString=""
pfres@tiXAxisString=""
pfres@xyMarkLineModes     = (/"Lines","Lines","Lines","Lines","Lines"/)  ; choose which have markers
;pfres@xyMarkers           = 16                     ; choose type of marker 
;pfres@xyMarkerColor       = "red"
pfres@xyMonoLineColor     = False
pfres@xyLineColors        = (/"red","black","blue","orange"/)
pfres@xyMarkerSizeF       = 0.008               ; Marker size (default 0.01)
pfres@xyDashPattern      = 0                     ; solid line 
pfres@xyLineThicknessF = 5
pfres@trYMinF     = 0.1
pfres@trYMaxF     = 1
if exp_name .eq."ICP" then
pfres@trXMinF = -1
pfres@trXMaxF = 2.5

end if 
if exp_name .eq."EIP" then
pfres@trXMinF = -2.0
pfres@trXMaxF = 1.0

end if
pfres@vpWidthF  = 0.22
pfres@vpHeightF = 0.32
; pfres@xyExplicitLegendLabels = var_plot&var
pfres@pmLegendOrthogonalPosF = -0.85                 ; more neg = down
pfres@pmLegendParallelPosF   = 0.87;0.16 ;0.8     ;!!!!!!!!!!!
pfres@tiMainString      =""

pfres@gsnLeftString = "profile"
pfres@gsnRightString ="K/day"   
pfres@vpYF         = 0.5
pfres@vpXF         = 0.08  
pfres@trYReverse = True

pfres@tmBorderThicknessF        =1.0
pfres@tmXBMajorThicknessF=1.0
pfres@tmYRMajorThicknessF=1.0
print(forc_t_profile)

plotpf  = gsn_csm_xy (wks,forc_t_profile,forc_t_profile&lev,pfres)
;----------attach forcing-----------
res1                     = True
res2                     = True
; res1@gsnMaximize         = True
res2@gsnAttachPlotsXAxis = False
lnres = True
; lnres@gsFillColor=-1
lnres@gsFillIndex = 3
lnres@gsLineColor="black"
lnres@gsLineThicknessF=1
dum1=gsn_add_polyline(wks,plotpf,(/0,0/),(/0.1,1/), lnres)
anno1 = gsn_attach_plots(plotf,plotpf,res1,res2)

;========================add box==============================
;   x=(/100,111,111,100,100/)      
;   y=(/37,37,25,25,37/)       
;   lnres = True
;   ; lnres@gsFillColor=-1
;   lnres@gsFillIndex = 1
;   lnres@gsLineColor="black"
;   lnres@gsLineThicknessF=1

;   x1=(/-40,5,5,-40,-40/)      
;   y1=(/75,75,55,55,75/)    
;   lnres2 = lnres
;   lnres2@gsLineColor="green"


;   dum0=gsn_add_polyline(wks, plot(0), x, y, lnres)

 ;====================panel==========================================
 pares                 = True                   ;组图panel属性
 pares@gsnPanelRowSpec = True                  ; tell panel what order to plot
 pares@gsnPanelLabelBar   = False
 pares@pmLabelBarWidthF   = 0.7                ;labelbar宽度
 pares@pmLabelBarHeightF  = 0.07                ;labelbar高度
 ;pares@pmLabelBarWidthF   = 0.06
 ;pares@pmLabelBarHeightF  = 0.7
 pares@lbLabelFontHeightF = 0.012               ;labelbar字体大小
 pares@gsnPanelLeft  = 0.01                     ;图左侧位置
 pares@gsnPanelRight  = 0.97                    ;右侧位置
 pares@gsnPanelYWhiteSpacePercent = 2           ;子图间的距离
 pares@pmLabelBarOrthogonalPosF   = 0.008       ;色标位置
 ;pares@lbTitleString              ="PREC(mm)"
 pares@lbTitlePosition            ="Bottom"
 ;pares@lbLabelPosition            ="Right"
 ;pares@lbOrientation              ="Vertical"
 pares@lbTitleFontThicknessF      =0.01
 pares@lbTitleFontHeightF         =0.015
 pares@tiMainOn                   =True
 ;draw(plot(0))
 ;frame(wks) 
; gsn_panel(wks, plot(0), (/1/), pares)
;gsn_panel(wks, plot(1), (/1/), pares)
 gsn_panel(wks, (/plotf/), (/1/), pares)

end