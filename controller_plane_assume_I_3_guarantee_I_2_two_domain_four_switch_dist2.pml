mtype = { IoT, Infra, GRE,  maclearning, ping, drop }; /* set of keyword used while exchanging message between various layers */
#define no_device   3 /* total number of device in the model */
#define no_dom      2 /* total number of domain i.e number of controller = majo = domain */
#define tot_OVS     4/* contains total number of OVS in the data plane topology*/
#define tot_VSPACE  2/* defining the totoal number of vspaces available */  
int AKW1 = 0; /* a counter to match AKW variable */
int AKV1 = 0; /* a counter to match AKV variable */
int no_OVS_dom[no_dom + 1] = {0, 2, 4};
/*  store the number of OVS in each domains by cumulative fashion */
/* contains total number of OVS in the data plane topology*/
int VSPACE_no_dev[tot_VSPACE + 1] = {0, 2, 3};
/* here the devices within each range forms one clusters eventhough it is defined as global variable */
/*it is initially  known only to the majos here dev 1,2 forms one clusters and device 3 forms another*/
/*cluster an lonley device! - cumullative  representation of clusteres, this information is passed to controller by majo*/

chan cont_que_ovs_rep[no_dom] = [20] of { mtype, int, mtype, int, int };    /* controller que updated by the OVS -
                                                                      maclearning,ovs_no,in_port_type,pt_nmb and the source id */


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
 int count2 = 1;
 do
 :: ( count2 <= no_dom )  ->     run Controller(count2);
                                 count2 = count2 + 1
 :: else                   -> break   
 od;
  printf("\nAll the Majos and all the controller are initialized\n")
  }



/*To check the intermediate formula I_2 */
int d1 = 1;
do
:: ( d1 < no_device ) -> int d2 = d1 + 1;
              
              int count = 1, count1 = 1, j1 = 1, j = 1;/* count iterate over ovs number to join one of them non-deterministically */
              do
              :: ( count <= tot_OVS ) -> goto LP
              :: ( count < tot_OVS ) -> count = count + 1
              od;
          LP: 
              do
              :: ( count <= no_OVS_dom[j] )  -> cont_que_ovs_rep[j-1]!maclearning,IoT,count,d1,d1;
                                                goto Lp1
              :: else ->  j = j + 1
              od;
              Lp1: 
              do
              :: ( count1 <= tot_OVS )  -> goto LP1
              :: ( count1 < tot_OVS )  -> count1 + count1 + 1
              od;
         LP1: 
              do
              :: ( count1 <= no_OVS_dom[j1] )  -> cont_que_ovs_rep[j1-1]!maclearning,IoT,count1,d2,d2;
                                                  goto Lp2
              :: else -> j1 = j1 + 1
              od;
              Lp2: printf("\n device %d connected in domain %d \n", d1, j);
                    printf("\n device %d connected in domain %d \n",d2, j1);
                   /* two  devices chose its OVS position randomly */
		/* here we have to update the I_3 assumptions rules  */
              if
              :: ( timeout && ( AKW1 == no_dom ) ) -> 
                cont_que_in_majo[j-1]!d1,j,VS[d1-1];
                cont_que_in_majo[j1-1]!d2,j1,VS[d2-1];
                if
                :: ( j != j1 ) -> cont_que_in_majo[j-1]!d2,j1,VS[d2-1];
                                  cont_que_in_majo[j1-1]!d1,j,VS[d1-1]
                :: else -> skip
                fi;
              fi;
              do
              :: ( d2 <= no_device ) -> int k = 1;
                          do
                          :: ( k <= tot_OVS )  -> int dom = 1, j2 = 1;
                                    atomic {
                                    do
                                    :: ( k <= no_OVS_dom[j2] ) -> dom = j2;
                                                                 goto Lp3
                                    :: else -> j2 = j2 + 1
                                    od;
                                    }
                                    Lp3: 
                                    if
                                    :: ( ( j2 == j ) || ( j2 == j1 ) ) ->
                                        if
                                        :: ( k == count ) -> skip
                                        ::  else ->   cont_que_ovs_rep[dom-1]!maclearning,Infra,k,1,d1
                                        fi;
                                        if
                                        :: ( k == count1 )  -> 
                                        ::  else -> cont_que_ovs_rep[dom-1]!maclearning,Infra,k,2,d2
                                        fi;
                                    :: else -> goto Lp6
                                    fi;
/*this number 1, 2 and  Infra's are  abstracted port number and port
type which is here to just test the intermeditate formula $\phi$ holds or not!*/
                                  if
                                  :: ( (AKW1 == no_dom) && timeout ) ->
                                            if
                                            :: (VS[d1-1] == VS[d2-1] ) -> 
                                                      if 
                                                      ::  ( count1 != k ) -> 
                                                                            printf("\n %d OVS number \n",k); 
                                                                            assert ( set_rule_ovs[k-1].srt_id[d1-1].dst_id[d2-1].purt_nm == 2 );
                                                                             assert ( set_rule_ovs[k-1].srt_id[d1-1].dst_id[d2-1].purt_ty == Infra )
                                                      :: else -> 
                                                                 assert ( set_rule_ovs[k-1].srt_id[d1-1].dst_id[d2-1].purt_nm == d2 );
                                                                 assert ( set_rule_ovs[k-1].srt_id[d1-1].dst_id[d2-1].purt_ty == IoT )
                                                      fi;
                                                      if 
                                                      ::  ( count != k )  -> 
                                                                         assert ( set_rule_ovs[k-1].srt_id[d2-1].dst_id[d1-1].purt_nm == 1 );
                                                                          assert ( set_rule_ovs[k-1].srt_id[d2-1].dst_id[d1-1].purt_ty == Infra )
                                                      :: else -> 
                                                                 assert ( set_rule_ovs[k-1].srt_id[d2-1].dst_id[d1-1].purt_nm == d1 );
                                                                 assert ( set_rule_ovs[k-1].srt_id[d2-1].dst_id[d1-1].purt_ty == IoT )
                                                      fi;
                                            :: else   -> assert ( set_rule_ovs[k-1].srt_id[d1-1].dst_id[d2-1].purt_ty == drop );
                                                         assert ( set_rule_ovs[k-1].srt_id[d2-1].dst_id[d1-1].purt_ty == drop )
                                            fi;
                                  fi;
                                  Lp6: k = k + 1
                          :: else -> goto Lp4
                          od;
                          Lp4: d2 = d2 + 1
              :: else -> goto Lp5
              od;
              Lp5: d1 = d1 + 1
:: else -> break
od

printf("\n Init process done its job!\n");


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
                                              /* C[x-1].PORTS[no_OVS_dom[dom]-1] = GRE;
                                               C[x-1].PORT_NO[no_OVS_dom[dom]-1] = no_OVS_dom[y]; */
                                               do
                                               :: (JJ <= no_device) ->
                                                    if 
                                                    :: (JJ != x && z == B[JJ-1].spoce && A[JJ-1].domoin == dom &&
                                                                             C[JJ-1].PORT_NO[no_OVS_dom[dom]-1] != 0) -> 
                                                                                     /*      OVS_que_cont[no_OVS_dom[dom]-1]!JJ,0,GRE,y */
                                                                                        skip
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
                                            :: ( R == IoT ) ->  /* majo_que_in_cont[dom-1]!s,dom; */
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
                                                                                       /*   OVS_que_cont[no_OVS_dom[dom]-1]!s,0,GRE,A[JJJ-1].domoin;
 *   */
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


