;;;;;
;;;This script plot the track from the three different wrfouts
;;;;;

begin
  x=asciiread("~/data/md_track.csv",-1,"string")
  data=(str_split_csv(x,",",0))
  index=tofloat(data(434:452,0))
  lat=tofloat(data(434:451,2))
  lon=tofloat(data(434:451,3))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  diri="./"
  ic=(/"1","2","3"/) ;
  ;;;;;;;;;;;;;;;;;;
  ntime =33    ;;;;;;;;&&&&&&&&&;;;;;;;;;
  plota = new(3,graphic)
  track_lat=new((/dimsizes(ic),ntime/),float)
  track_lon=new((/dimsizes(ic),ntime/),float)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  wks=gsn_open_wks("png","track_md")
 ;;;;;;;;;;;;;;;;;;;;;;;;
;  pmres@gsMarkerIndex = 16
 ; pmres@gsMarkerColor = "red"
  res   =True
  res@gsnMaximize   =True
  res@mpMinLatF              =  10
  res@mpMaxLatF              =  30
  res@mpMinLonF              =  70
  res@mpMaxLonF              = 100
;  res@mpLandFillColor        ="white"
  res@gsnDraw   =False
  res@gsnFrame   =False
  map=gsn_csm_map(wks,res)
;;;;;;;;;;;;;;;;;;;;;;;;;
  do j=0,dimsizes(ic)-1
    filename="wrfout_d02_"+ic(j)+".nc"
;    print(filename)
    print("working with:"+filename+"")
    a=addfile(diri+filename,"r")
    ;######################################
    times=wrf_user_getvar(a,"times",-1)
;    ntime=4; dimsizes(times)-1
    lat2d=a->XLAT(0,:,0)
    lon2d=a->XLONG(0,0,:)
    lat1d=ndtooned(lat2d)
    lon1d=ndtooned(lon2d)
    ;####################################
             do i=0,ntime-1
               slp1=wrf_user_getvar(a,"slp",i)     ;read varibale
               wrf_smooth_2d(slp1,3)
               dim=dimsizes(slp1)
               slp=ndtooned(slp1)                  ; convert to ndims
               inds=ind_resolve(minind(slp),dim)   ; find the min value inde
;;;;;;;;;;;;;;;;;;;;;;
               ilat=inds(0,0)
               ilon=inds(0,1)
               lat_min=lat1d(ilat)
               lon_min=lon1d(ilon)
;;;;;;;;;;;;;;;;;;;;;;      
               ;print("min value at "+lat_min+","+lon_min)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
               track_lat(j,i)=lat_min
               track_lon(j,i)=lon_min
               delete([/slp1,slp,ilat,ilon,inds,dim/])
             end do
             delete([/lat1d,lat2d/])
           end do
;           printVarSummary(track_lon)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      ;;Graphic section
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;           
           colors= (/"red","green","blue"/)
           pmres=True
           pmres@gsLineThicknessF=10
             do k=0,2
               pmres@gsLineColor=colors(k)
             plota(k)=gsn_add_polyline(wks,map,track_lon(k,1:),track_lat(k,1:),pmres)
           end do
           
           pmres@gsLineColor="black"
           plot1 = gsn_add_polyline(wks,map,lon,lat,pmres) ;;obs
             ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		lnres                  = True
		lnres@gsLineColor      = "black"
		lnres@gsLineThicknessF = 5
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
shap_path="/home/sai/data/india-soi1542india-soi15420746/"
ind_met=gsn_add_shapefile_polylines(wks,map,shap_path+"india-soi154207.shp",lnres)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

draw(map)
frame(wks)
end

