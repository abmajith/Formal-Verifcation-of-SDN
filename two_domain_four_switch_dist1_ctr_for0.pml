mtype = { IoT, Infra, GRE,  maclearning, ping, drop }; /* set of keyword used while exchanging message between various layers */
#define no_device   3 /* total number of device in the model */
#define no_dom      2 /* total number of domain i.e number of controller = majo = domain */
#define tot_OVS     4/* contains total number of OVS in the data plane topology*/
#define tot_VSPACE  2/* defining the totoal number of vspaces available */  
int AKW1 = 0; /* a counter to match AKW variable */
int AKV1 = 0; /* a counter to match AKV variable */
int no_OVS_dom[no_dom + 1] = {0, 3, 4};
/*  store the number of OVS in each domains by cumulative fashion */
/* contains total number of OVS in the data plane topology*/
int VSPACE_no_dev[tot_VSPACE + 1] = {0, 2, 3};
/* here the devices within each range forms one clusters eventhough it is defined as global variable */
/*it is initially  known only to the majos here dev 1,2 forms one clusters and device 3 forms another*/
/*cluster an lonley device! - cumullative  representation of clusteres, this information is passed to controller by majo*/

chan cont_que_ovs_rep[no_dom] = [20] of { mtype, int, mtype, int, int };    /* controller que updated by the OVS -
                                                                      maclearning,ovs_no,in_port_type,pt_nmb and the source id */
chan majo_que_in_cont[no_dom] = [no_device] of { int, int }; /* mojo que get updated by controller about the devices and its domain number */

chan majo_que_in_majos[no_dom] = [no_device] of { int, int }; /* each majo sends the information about the devices exist in its domain to all other majos */

chan cont_que_in_majo[no_dom] = [no_device] of { int, int, int }; /* controller que updated by the majo about the device, its position and its vspace */

typedef flowtable_unicast {
  /*bool status[no_device] = false; /* is this neccesary to have extra variable*/
  mtype dst_pt[no_device] = drop;
  int pt_nmb[no_device];
};
/* defining the format of flow table for each OVS */

typedef device_domain_position { /* to store the device domain position, this table used by controller */
  int domoin;
};
/* controller update this table by the information provided by the majo and the domain OVS */

typedef device_VSPACE { /* to store the device vspace, this table used by controller  */
  int spoce;
};/* controller update this table by the inforamtion send by majo */

typedef device_OVS_positions { /* to store the device connection type and number to each OVS, this is used by controller  */
  mtype PORTS[tot_OVS];
  int   PORT_NO[tot_OVS];
};/* controller update this table by the inforamtion send by the majo and the domain OVSes */

typedef end_device {
  bool g[no_device] = false;
};/* for each controller based on this value it knows wheter it updated the flow table or not */

typedef OVS_und_cont {
  end_device h[no_device]
};/* for each controller based on this defined varibale it knows whether it updated the flow table or not */
/* following definitation will facilitate the OVS to OVS infra ports,    */ 
/* this information only used by OVS, controller never use this information to estabilsh the   */
/* right flow update in the OVSes, flow table update based on the communication between OVSes and */   
/* the controller and the communication between controller and majo server */
typedef OVS_infra_con {
  bool OVS_Infra_pts[tot_OVS] = false;
};

OVS_infra_con OVS_OVS_Infra_pts[tot_OVS];

/* here the matrix is created to communicate the maclearnig message of devices between the domains */
typedef shr_dv {
 bool end_dom[no_dom] = false;
};

typedef srt_dom {
 shr_dv dev_dom_shr[no_device];
};

srt_dom inter_domain_shr[no_dom];

typedef rel_pos {
  int num_prt[tot_OVS] = 0;
  mtype  typ_prt[tot_OVS];
};


/* Following set of type definition for setting the flow command by controller and finally check is it satisfy the intermediate formula */
typedef destination_id {
  mtype purt_ty = drop;
  int purt_nm = 0;
};

typedef suorce_id {
  destination_id dst_id[no_device];
};

typedef check_rule {
  suorce_id srt_id[no_device];
};

check_rule set_rule_ovs[tot_OVS];


/* To check the intermediate formula of the case $\phi_0$ we have to keep this additional variable which is updated by the controller
and checked by the Init Processor  */

typedef inmd_zero {
  int gre_ps[no_device] = 0;
};

inmd_zero in_cn_bt_dm[no_dom];


init{
            /*initialize the position of all devices, all OVS, all controllers and all Majo servers*/
int VS[no_device] = 0;
atomic {
int  count8 = 1, count9; 
do
:: (count8 <= no_device ) -> count9 = 1;
                             do
                             :: ( count8 <= VSPACE_no_dev[count9] )  ->  VS[count8 - 1] = count9;
                                                                          goto Lc
                             :: ( count8 > VSPACE_no_dev[count9] )   -> count9 = count9 + 1
                             od;
                             Lc: count8 = count8 + 1

:: else -> break
od

}
atomic {
 int count5 =1;
 do
 :: ( count5 <= no_dom ) -> 
              int count6 = no_OVS_dom[count5]-1;
              do
              :: ( count6 < no_OVS_dom[count5] && count6 > no_OVS_dom[count5-1]) ->
                       int count7 = no_OVS_dom[count5]; 
                       do
                       :: ( (count7-count6) > 0 ) -> OVS_OVS_Infra_pts[count6-1].OVS_Infra_pts[count7-1] = true;
                                                     OVS_OVS_Infra_pts[count7-1].OVS_Infra_pts[count6-1] = true;
                                                     printf("\n %d OVs is connected to %d OVS\n",count6,count7);
                                                     goto L41
                       :: ( (count7-count6) > 1 ) -> count7 = count7 - 1
                       od
                       L41: count6 = count6 - 1
              :: else -> goto L42
              od
              L42: count5 = count5 + 1
 :: else -> break
 od;
 printf("\n random tree structre for each domain is set \n");
  }

atomic {
 int count2 = 1;
 do
 :: ( count2 <= no_dom )  ->     run Controller(count2);
                                 run Majo(count2);
                                 count2 = count2 + 1
 :: else                   -> break   
 od;
  printf("\nAll the Majos and all the controller are initialized\n")
  }


/* To check the intermediate formula $\phi_0$*/
int c1 = 1;
 do
 :: ( c1 < no_device )  -> int c2 = c1 + 1, cntt = 1, ju = 1, dd;
                    do
                    :: ( cntt <= tot_OVS ) -> goto Lq
                    :: ( cntt < tot_OVS )  -> cntt = cntt + 1
                    od;
                Lq:    
                    do
                    :: ( cntt <= no_OVS_dom[ju] )  ->  cont_que_ovs_rep[ju-1]!maclearning,IoT,cntt,c1,c1;
                                                        goto Lq1
                    :: else -> ju = ju + 1
                    od; /* at the end of this the device c1 chose one of domain and it is informed to the controller */
                Lq1:  /* I need to add the code for the other device first report to some IoT devices and check the rest of the formulae */
                      /* here i wrote for three domain only */
                    if
                    :: ( ju == 1 ) -> cont_que_ovs_rep[1]!maclearning,IoT,(no_OVS_dom[1]+1),c2,c2;
                                      cont_que_ovs_rep[1]!maclearning,Infra,no_OVS_dom[2],1,c2;
                                       dd = 2
                                       goto Lq4
                    :: ( ju == 2 ) ->  cont_que_ovs_rep[0]!maclearning,IoT,1,c2,c2;
                                       cont_que_ovs_rep[0]!maclearning,Infra,no_OVS_dom[1],1,c2;
                                       dd = 1
                                       goto Lq4
                    fi;
                Lq4:
                     if
                     :: ( VS[c1-1] == VS[c2-1] )  ->
                                if
                                :: (  timeout && ( AKW1 == (2*no_dom) ) )  ->
                                          assert ( in_cn_bt_dm[dd-1].gre_ps[c2-1] == ju ) 
                                fi
                    :: else -> skip
                    fi;
                    c1 = c1 + 1
 :: else -> break 
 od


}



proctype Controller(int i)
{
AKW1 = AKW1 + 1;
printf("\n Controller %d is initialized\n", i);
int dom = i;  /* controller i is responsible for building right flow path in the domain i */
int min_OVS_no;        /* temporary variable pass the number of OVS under the domain i*/
min_OVS_no = no_OVS_dom[dom-1] + 1;
/* max_OVS_no = no_OVS_dom[dom];  */


device_domain_position  A[no_device];/* to store the device domain position */
device_VSPACE  B[no_device];/* to store the device vspace each device has only one vspace no-abstracted */
device_OVS_positions  C[no_device];/* each device may have position as infra,Iot, GRE or none and respective port no */

/* Based on the following function, controller decides whether there exists  sending a message action to OVS or not!*/
OVS_und_cont D[tot_OVS];


int x, y, z; /* to store the device, domain and vspace */
int nmb_pt, s, OVS_no;/* port number, device id  */
mtype P, R; /* maclearning report, port type  */

bool toggle = true; /* if this toggle is true no need to send any OVS update */


/* following code has to facilitate to note down the different devices and its positions reported by its domain OVSes and majo server */
/* has to record the vspace of different devices */
/* based on the above information has to update flowtable of OVSes its domain  */
L11:
end1: 
do
:: cont_que_in_majo[dom-1]?[x] -> atomic {
                                  toggle = false;
                                  cont_que_in_majo[dom-1]?x,y,z;
                                  B[x-1].spoce = z;
                                  printf("\n cont %d got a message from majo %d\n",dom,dom);
                                  int JJ = 1;
                                  if
                                  :: ( dom != y ) -> A[x-1].domoin = y;
                                               /*C[x-1].PORTS[no_OVS_dom[dom]-1] = GRE;
                                               C[x-1].PORT_NO[no_OVS_dom[dom]-1] = no_OVS_dom[y]; */
                                               do
                                               :: (JJ <= no_device) ->
                                                    if
                                                    :: (JJ != x && z == B[JJ-1].spoce && A[JJ-1].domoin == dom &&
                                                                             C[JJ-1].PORT_NO[no_OVS_dom[dom]-1] != 0) ->
                                                                                     /*      OVS_que_cont[no_OVS_dom[dom]-1]!JJ,0,GRE,y */
                                                                                             in_cn_bt_dm[dom-1].gre_ps[JJ-1] = y
                                                    :: else -> skip
                                                    fi;
                                                    JJ = JJ + 1
                                               :: else -> goto tir
                                               od;
                                               tir:
                                  :: else ->  do
                                              :: (JJ <= no_device) ->
                                                    if
                                                    :: (JJ != x && C[x-1].PORT_NO[no_OVS_dom[dom]-1] != 0 && B[x-1].spoce == B[JJ-1].spoce &&
                                                                                                               A[JJ-1].domoin != dom ) ->
                                                                                         /* OVS_que_cont[no_OVS_dom[dom]-1]!x,0,GRE,A[JJ-1].domoin; */
                                                                                          in_cn_bt_dm[dom-1].gre_ps[x-1] = A[JJ-1].domoin; 
                                                                                          goto tirrr
                                                    :: else -> skip
                                                    fi;
                                                    JJ = JJ + 1
                                              :: else -> goto tirrr
                                              od;
                                              tirrr:
                                  fi
                                }
/* the above check updates the information from its majo server */
:: cont_que_ovs_rep[dom-1]?[maclearning] -> atomic {
                                            toggle = false;
                                            cont_que_ovs_rep[dom-1]?P,R,OVS_no,nmb_pt,s;
                                            C[s-1].PORTS[OVS_no-1] = R;
                                            C[s-1].PORT_NO[OVS_no-1] = nmb_pt;
                                            printf("\n controller %d got an message from OVS %d\n",dom,OVS_no);
                                            int JJJ = 1;
                                            if
                                            :: ( R == IoT ) ->  majo_que_in_cont[dom-1]!s,dom;
                                                                A[s-1].domoin = dom
                                            :: else -> skip
                                            fi;
                                            if
                                            :: ( R != GRE && OVS_no == no_OVS_dom[dom] && B[s-1].spoce != 0) ->
                                                          do
                                                          :: ( JJJ <= no_device ) ->
                                                                if
                                                                :: (JJJ != s && B[s-1].spoce == B[JJJ-1].spoce && A[s-1].domoin == dom &&
                                                                                                       A[JJJ-1].domoin != dom) ->
                                                                       /*   OVS_que_cont[no_OVS_dom[dom]-1]!s,0,GRE,A[JJJ-1].domoin; */
                                                                                            in_cn_bt_dm[dom-1].gre_ps[s-1] = A[JJJ-1].domoin
                                                                :: else -> skip
                                                                fi;
                                                                JJJ = JJJ + 1
                                                          :: else -> goto tirr
                                                          od;
                                                          tirr:
                                            :: else -> skip
                                            fi
                                            }

/* By the above way we doing the concurrent operation of OVS and the majo incoming information*/
/* But the controller responds to the OVS (sending forwarding rule for ping messages to OVS) is delayed as much as possible*/
/* the above check updates the information from the data plane and relay to its majo */
:: (toggle == false && empty(cont_que_in_majo[dom-1]) && empty(cont_que_ovs_rep[dom-1]))-> atomic  { 
        toggle = true; 
        int ii = min_OVS_no; 
        do
        :: ( ii <= no_OVS_dom[dom] ) ->
              printf("\n %d OVS is updating by the controller\n",ii);
              int jj = 1;
             do
             :: (jj <= no_device  ) ->
                  int kk = 1;
                  do
                  :: ( kk <= no_device ) ->
                        if
                        :: ((jj != kk) && (D[ii-1].h[jj-1].g[kk-1] == false)) ->
                                 if
                                 ::((B[jj-1].spoce == B[kk-1].spoce) && (B[kk-1].spoce != 0) &&
                                        (A[kk-1].domoin == A[jj-1].domoin) && (dom == A[kk-1].domoin) &&
                                        (C[jj-1].PORT_NO[ii-1] != 0)  && (C[kk-1].PORT_NO[ii-1] != 0)) ->
                                                           /*   OVS_que_cont[ii-1]!jj,kk,C[kk-1].PORTS[ii-1],C[kk-1].PORT_NO[ii-1];
                                                              OVS_que_cont[ii-1]!kk,jj,C[jj-1].PORTS[ii-1],C[jj-1].PORT_NO[ii-1]; */
                                                              set_rule_ovs[ii-1].srt_id[jj-1].dst_id[kk-1].purt_ty = C[kk-1].PORTS[ii-1];
                                                              set_rule_ovs[ii-1].srt_id[jj-1].dst_id[kk-1].purt_nm = C[kk-1].PORT_NO[ii-1];
                                                              set_rule_ovs[ii-1].srt_id[kk-1].dst_id[jj-1].purt_ty = C[jj-1].PORTS[ii-1];
                                                              set_rule_ovs[ii-1].srt_id[kk-1].dst_id[jj-1].purt_nm = C[jj-1].PORT_NO[ii-1];
                                                              D[ii-1].h[jj-1].g[kk-1] = true;
                                                              D[ii-1].h[kk-1].g[jj-1] = true
                                 :: ((B[jj-1].spoce != B[kk-1].spoce) && (B[kk-1].spoce !=0) &&
                                       (B[jj-1].spoce !=0) && (A[kk-1].domoin == A[jj-1].domoin) &&
                                        (dom == A[kk-1].domoin) && (C[kk-1].PORT_NO[ii-1] != 0) &&
                                         (C[jj-1].PORT_NO[ii-1] != 0))                            ->
                                                             /* OVS_que_cont[ii-1]!jj,kk,drop,0; */
                                                             /* OVS_que_cont[ii-1]!kk,jj,drop,0; */
                                                              D[ii-1].h[jj-1].g[kk-1] = true;
                                                              D[ii-1].h[kk-1].g[jj-1] = true
                                 :: ((B[jj-1].spoce == B[kk-1].spoce) && (B[kk-1].spoce != 0) &&
                                      (A[kk-1].domoin != A[jj-1].domoin) && (dom == A[jj-1].domoin) &&
                                      (A[kk-1].domoin != 0) && (C[jj-1].PORT_NO[ii-1] != 0) && C[kk-1].PORT_NO[ii-1] != 0 )  ->
                                                             /* OVS_que_cont[ii-1]!jj,kk,C[kk-1].PORTS[ii-1],C[kk-1].PORT_NO[ii-1];
                                                              OVS_que_cont[ii-1]!kk,jj,C[jj-1].PORTS[ii-1],C[jj-1].PORT_NO[ii-1]; */
                                                              set_rule_ovs[ii-1].srt_id[jj-1].dst_id[kk-1].purt_ty = C[kk-1].PORTS[ii-1];
                                                              set_rule_ovs[ii-1].srt_id[jj-1].dst_id[kk-1].purt_nm = C[kk-1].PORT_NO[ii-1];
                                                              set_rule_ovs[ii-1].srt_id[kk-1].dst_id[jj-1].purt_ty = C[jj-1].PORTS[ii-1];
                                                              set_rule_ovs[ii-1].srt_id[kk-1].dst_id[jj-1].purt_nm = C[jj-1].PORT_NO[ii-1];
                                                              D[ii-1].h[jj-1].g[kk-1] = true;
                                                              D[ii-1].h[kk-1].g[jj-1] = true
                                 :: else -> skip
                                 fi
                        :: else -> skip
                        fi;
                        kk = kk + 1
                  :: else -> goto L13
                  od;
                  L13: jj = jj + 1
             :: else -> goto L14
             od;
             L14: ii = ii + 1
        :: else -> break
        od
  }
od/* if all the que is empty and updation is completed then there is no more information or request to update the data plane */
/* if it is so this controller is in block state */
/* based on the information gathered from the majo and the data plane controller sends the */
/* flow update to all its domain OVSes */
printf("\nCont %d is shutdown but it should never happen\n",dom)

}


proctype Majo(int i)    /*All majos see the VSPACE information as global */
{
AKW1 = AKW1 + 1;
 printf("\n Majo %d is initialized\n", i);
int dom_c = i;      /* to keep track the controller which is connected to majo i */
/* int domain_position[no_device]; /* stores the devices domain positions */
/* rest of the code should facilitate to notify the controller about the device domain and its vspace information and share to other majos*/

int x, y;
L1:
end:do
    :: majo_que_in_cont[dom_c-1]?[x] -> atomic { int K = 1, l = 1;
                                    majo_que_in_cont[dom_c-1]?x,y;
                                    /*   domain_position[x-1] = y; /* stores the domain information y of device x  */
                                    /* here l is to go through all possible vspace to decide the device x vspace*/
                                    do
                                    :: (x <= VSPACE_no_dev[l] ) -> cont_que_in_majo[dom_c-1]!x,y,l;
                                                                   goto L2
                                    :: else -> l = l + 1
                                    od;         /* at the end of this loop controller i knows the device x vspace number */
                                    L2:
                                    do
                                    :: ( K <= no_dom )  ->   if
                                                             :: !(K == dom_c) -> majo_que_in_majos[K-1]!x,y
                                                             ::  else -> goto L3
                                                             fi;
                                                             L3:  K = K + 1
                                    :: else -> goto L1
                                    od
                                  }/* this section gather information from its controller and inform the same to other majos */
    :: majo_que_in_majos[dom_c-1]?[x] -> atomic {
                                    majo_que_in_majos[dom_c-1]?x,y;
                                    /* domain_position[x-1] = y; /* stores the domain information y of device x  */
                                    int k = 1;/* here k is to go through all possible vspace to decide the device x vspace*/
                                    do
                                    :: (x <= VSPACE_no_dev[k] ) -> cont_que_in_majo[dom_c-1]!x,y,k;
                                                                    goto L1
                                    :: else -> k = k + 1
                                    od /* at the end of this loop controller i get to know about the device x, its domain no y and its vspace no k */
                                    }
        /* This section estabilish the communication among majos and report its controller about device vspace and domain */
      /* if both que is empty then this majo is in block state  */
    od;  /* working in absolute concurrent on receiving the controller request and other majo incoming informations */
       printf("\nwhat is wrong with this code\n")

}
