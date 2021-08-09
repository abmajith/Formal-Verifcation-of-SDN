mtype = { IoT, Infra, GRE, DHCP, maclearning, multicast, ping, drop }; /* set of keyword used while exchanging message between various layers */
#define no_device   3 /* total number of device in the model */
#define no_dom      1 /* total number of domain i.e number of controller = majo = domain */
#define tot_OVS     2/* contains total number of OVS in the data plane topology*/
#define tot_VSPACE  2/* defining the totoal number of vspaces available */  
#define tot_iot_prt 2/*  total IoT ports available in the data plane */
int no_OVS_dom[no_dom + 1] = {0, tot_OVS};
/*  store the number of OVS in each domains by cumulative fashion */
/* contains total number of OVS in the data plane topology*/
int VSPACE_no_dev[tot_VSPACE + 1] = {0, 2, 3};
/* here the devices within each range forms one clusters eventhough it is defined as global variable */
/*it is initially  known only to the majos here dev 1,2 forms one clusters and device 3 forms another*/
/*cluster an lonley device! - cumullative  representation of clusteres, this information is passed to controller by majo*/
int prt_IoT_dist[tot_OVS + 1] = {0,  1,  tot_iot_prt}; 
/* above is the cumulative fashion of available iot ports to each switch */
int status_iot_prt_dev_view[tot_iot_prt] = 0;/* these are the view of device of which Iot ports it got stored and when OVS forward based on these
                                                    information */

chan OVS_que_data[tot_OVS] = [20] of { mtype, mtype, int, int, int }; /* defining the queue(abstracted) for each OVS in data plane- message ref no,its type, port
                                               type, port number, source id and destination id, this message type only stay in data plane*/
chan OVS_que_cont[tot_OVS] = [20] of { int, int, mtype, int }; /* defining an queue for each OVS passed from control plane - source,
                                                                destination id port type and its number */
chan dev_data_que[no_device] = [2*no_device] of { mtype, int, int }; /* device queue loaded by the data plane OVSes 
                                                              the OVS - message type source and destination id*/
chan cont_que_ovs_rep[no_dom] = [20] of { mtype, int, mtype, int, int };    /* controller que updated by the OVS -
                                                                      maclearning,ovs_no,in_port_type,pt_nmb and the source id */
chan majo_que_in_cont[no_dom] = [2*no_device] of { int, int }; /* mojo que get updated by controller about the devices and its domain number */

chan majo_que_in_majos[no_dom] = [2*no_device] of { int, int }; /* each majo sends the information about the devices exist in its domain to all other majos */

chan cont_que_in_majo[no_dom] = [2*no_device] of { int, int, int }; /* controller que updated by the majo about the device, its position and its vspace */


/* following the local peripheral and local controller view on the kind of devices connected sychronously */
typedef statas {
int status[tot_iot_prt] = 0;
}
statas prt_typ[tot_OVS]; 

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


init{
            /*initialize the position of all devices, all OVS, all controllers and all Majo servers*/
atomic {
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
 int count3 = 1;
 do
 :: ( count3 <= tot_OVS ) -> run OVS(count3);
                               count3 = count3 + 1
 :: else  -> break
 od
 printf("\n All the OVSes are initialized\n") 
  }

atomic {
 int count2 = 1;
 do
 :: ( count2 <= no_dom )  ->     run Controller(count2);
                                 run Majo(count2);
                                 count2 = count2 + 1
 :: else                   -> break   
 od
  printf("\nAll the Majos and all the controller are initialized\n")
  }

atomic {
 int count1 = 1;
 do
 :: ( count1 > no_device ) ->  break
 :: else                   -> run devices(count1);
                               count1 = count1 + 1       
 od
 printf("\nAll devices are initialized\n")
  }


printf("\n Init process done its job!\n");
}
}

proctype devices(int i)
{
int dev = i; 
int lnk_OVS_no; /* stores the connected OVS number */
int Iot_no = 0; /* initially this Iot number is 0 after the device chose its Iot port and OVS this number will be non-zero */
int VSPACE_no; /* here device dev calculates its vspace number well it should know only to the majo here we include for the verification */
               /*  - purpose and dev wont use this information for further processing! */


atomic {
int count2 = 1, count = 1, count1 = 1;
do
:: ( dev <= VSPACE_no_dev[count2] )  ->  VSPACE_no = count2;
                                           break
:: ( dev > VSPACE_no_dev[count2] )   -> count2 = count2 + 1
od;
printf("\n device %d vspace number is %d\n",dev,VSPACE_no);
/* here device try to send the mac message to the data plane*/
/* count iterate over ovs number and its Iot port to join one of them non-deterministically */
if 
:: ( dev != 3 )  ->  do
                     :: ( ( count <= tot_iot_prt ) && ( status_iot_prt_dev_view[count-1] == 0 ) ) -> 
                          do
                          :: ( count <= prt_IoT_dist[count1] ) ->
                                  OVS_que_data[count1-1]!maclearning,IoT,count,dev,0;/* here the count represents  IoT number */
                                  lnk_OVS_no = count1;/* device i chose non deterministically the OVS count1 */
                                  Iot_no = count;/*now device connected to the IoT number count */
                                  status_iot_prt_dev_view[Iot_no-1] = dev;
                                  prt_typ[lnk_OVS_no-1].status[Iot_no-1] = dev;/*IoT_no now occupied by the device dev */
                                  goto Lb
                          :: (count > prt_IoT_dist[count1] ) -> count1 = count1 + 1
                          od
                     :: ( count < tot_iot_prt ) -> count = count + 1
                     :: ( ( count == tot_iot_prt ) && ( status_iot_prt_dev_view[count-1] != 0 ) )  ->
                             int cou = 1, cou1 = 1;
                             do
                             :: ( status_iot_prt_dev_view[cou-1] == 0 ) -> 
                                    do
                                    :: ( cou <= prt_IoT_dist[cou1] ) ->
                                          OVS_que_data[cou1-1]!maclearning,IoT,cou,dev,0;/* here the count represents  IoT number */
                                          lnk_OVS_no = cou1;/* device i chose non deterministically the OVS count1 */
                                          Iot_no = cou;/*now device connected to the IoT number count */
                                          status_iot_prt_dev_view[Iot_no-1] = dev;/*IoT_no now occupied by the device dev */
                                          prt_typ[lnk_OVS_no-1].status[Iot_no-1] = dev;
                                                                    goto Lb
                                    :: (cou > prt_IoT_dist[cou1] ) -> cou1 = cou1 + 1
                                    od
                             :: else ->   cou = cou + 1
                             od
                     od;
:: else -> skip
fi;
Lb: 
printf("\n device %d is connected to the OVS %d\n",dev,lnk_OVS_no);                       
                        

  /* here device try to ping*/
int coun1 = 1;
do
:: ( timeout &&  coun1 <= no_device )  ->
                if 
                :: (dev != coun1 && dev != 3) -> 
                            OVS_que_data[lnk_OVS_no-1]!ping,IoT,Iot_no,dev,coun1;
                            printf("\n device %d is pinged the device %d\n",dev,coun1)
                :: else -> skip 
                fi;
                coun1 = coun1 + 1 
:: ( coun1 > no_device ) -> break
od;
                                                  
                                              

} /* at the end of this loop dev knows(but never use it other than verification) which vspace it belongs and stored same in VSPACE_no  */

atomic {
if
:: ( dev == 1 ) -> skip
:: ( dev == 2 ) -> status_iot_prt_dev_view[Iot_no-1] = 0;
                   prt_typ[lnk_OVS_no-1].status[Iot_no-1] = 0
:: ( dev == 3 ) -> if
		   :: ( status_iot_prt_dev_view[0] == 0 ) -> OVS_que_data[0]!maclearning,IoT,1,3,0;
                                                              Iot_no = 1;
                                                              status_iot_prt_dev_view[0] = 3; 
                                                              prt_typ[0].status[0] = 3
		   :: ( status_iot_prt_dev_view[1] == 0 ) -> OVS_que_data[1]!maclearning,IoT,2,3,0
							     Iot_no = 2;
							     status_iot_prt_dev_view[1] = 3;
                                 prt_typ[1].status[1] = 3
                                 
		   fi;
fi
} /*  at the end of this step device 3 occupies the position hold by the device 2 in the previous instance*/

int x, z; /*to read the incoming ping messages  */
mtype y; /*to read the incoming ping messages */
end3:
do
::( timeout && dev_data_que[dev-1]?[y] )  ->  atomic { dev_data_que[dev-1]?y,x,z; /* here device reading the incoming ping message */
                                            printf("\n device %d got the message from the device %d \n", dev,x);
                                            assert ( y == ping );
                                            assert ( x > VSPACE_no_dev[VSPACE_no-1] );
                                            assert ( x <= VSPACE_no_dev[VSPACE_no] );
                                            assert ( z == dev ) 
                                           } 
od

}


proctype OVS(int i)
{
printf("\nOVS %d is initialized\n", i);
int OVS_no = i;
int dom;            /* constant represents its domain number */

atomic {
int j = 1;           /*   iterate over domains to find OVS-i domain */
do
:: (OVS_no <= no_OVS_dom[j]) ->  dom = j;
                                printf("\n OVS %d domain number is %d\n",OVS_no,dom);
                                  break
:: else                      ->  j = j + 1
od  
} /* at the end of this loop OVS i know its domain number more exactly the controller it should report for getting flow table update*/

/* following code has to facilitate for note down the new devices and report the same to infra ports and controller and forward the data packets*/ 
/* according to the flow table rule*/

int x, y, z;  /*variable x repersents the source id , y destination id and z is a port number */
mtype  Q;     /* Q tells whether to drop the data packet or send to the IoT, Infra or GRE */
mtype P, R;   /* to store the information about the the message type and port type */

int s, t, nmb_pt; /*to store the information about source, destination and the incoming port address  */
flowtable_unicast  rule_data_transfer[no_device]; /* flow table of the OVS i */
L21:
end2: 
do
:: OVS_que_cont[OVS_no-1]?[x]  -> atomic { OVS_que_cont[OVS_no-1]?x,y,Q,z;
                                        if
                                        :: ( Q == GRE && y == 0 ) -> inter_domain_shr[dom-1].dev_dom_shr[x-1].end_dom[z-1] = true;
                                        :: else -> rule_data_transfer[x-1].dst_pt[y-1] = Q;
                                                   rule_data_transfer[x-1].pt_nmb[y-1] = z;
                                                   printf("\n OVS %d got a flow update message\n",OVS_no);
                                                   printf("\n src = %d and dst = %d in %d OVS is \n",x,y,OVS_no);
                                                   printm(Q);
                                                   printf("\t %d\n",z)
                                        fi
                                             }
:: (OVS_que_data[OVS_no-1]?[P] && empty(OVS_que_cont[OVS_no-1])) -> atomic {
                              if
                              :: OVS_que_data[OVS_no-1]?[maclearning] -> 
                                        OVS_que_data[OVS_no-1]?P,R,nmb_pt,s,t;
                                        printf("\n OVS %d got an maclearning message\n",OVS_no);
                                        cont_que_ovs_rep[dom-1]!P,R,OVS_no,nmb_pt,s;
                                        int k = 1;
                                        do
                                        :: ( k <= tot_OVS ) ->
                                                int k1 = 1;
                                                if
                                                :: ( OVS_OVS_Infra_pts[OVS_no-1].OVS_Infra_pts[k-1] == true ) ->
                                                           if
                                                           :: (R == IoT || R == GRE)  ->   OVS_que_data[k-1]!maclearning,Infra,OVS_no,s,t
                                                           :: (R == Infra && nmb_pt != k) -> 
                                                                               OVS_que_data[k-1]!maclearning,Infra,OVS_no,s,t
                                                           :: else ->  skip
                                                           fi
                                                :: ( OVS_no == no_OVS_dom[dom] && OVS_no != k && 
                                                              OVS_OVS_Infra_pts[OVS_no-1].OVS_Infra_pts[k-1] == false )  -> 
                                                                   do
                                                                   :: ( k1 <= no_dom ) -> 
                                                                       if 
                                                                       :: ( k == no_OVS_dom[k1] && inter_domain_shr[dom-1].dev_dom_shr[s-1].end_dom[k1-1] == true )-> 
                                                                                                  OVS_que_data[k-1]!maclearning,GRE,OVS_no,s,t
                                                                       :: else -> skip
                                                                       fi;
                                                                       k1 = k1 + 1;
                                                                   :: else -> goto Nex
                                                                   od
                                                                   Nex: 
                                                :: else -> skip 
                                                fi;
                                                k = k + 1
                                        :: else -> goto L21 /* here it done the required steps for maclearning  */
                                        od
                              :: OVS_que_data[OVS_no-1]?[ping] -> 
                                               OVS_que_data[OVS_no-1]?P,R,nmb_pt,s,t;
                                               if
                                               ::( rule_data_transfer[s-1].dst_pt[t-1] == Infra ) -> 
                                                                 z = rule_data_transfer[s-1].pt_nmb[t-1];
                                                                 OVS_que_data[z-1]!ping,Infra,OVS_no,s,t
                                               ::( rule_data_transfer[s-1].dst_pt[t-1] == GRE )  -> 
                                                                 z = rule_data_transfer[s-1].pt_nmb[t-1];
                                                                 OVS_que_data[z-1]!ping,GRE,nmb_pt,s,t
                                               ::( rule_data_transfer[s-1].dst_pt[t-1] == IoT ) ->
                                                                 z = rule_data_transfer[s-1].pt_nmb[t-1];
								                                 if
							                                	 :: ( status_iot_prt_dev_view[z-1] != 0) -> 
                                                                    if 
                                                                    :: ( (status_iot_prt_dev_view[z-1] == t) && (prt_typ[OVS_no-1].status[z-1] == t) ) ->  
									                	                    dev_data_que[status_iot_prt_dev_view[z-1]-1]!ping,s,t
                                                                    :: else -> skip
                                                                    fi
								                                 :: else -> skip
								                                 fi
                                               :: ( rule_data_transfer[s-1].dst_pt[t-1] == drop ) -> 
                                                                 printf("\n the packet from src_id = %d to the dst_id = %d is dropped\n", s, t)
                                               :: else -> assert(false) /* if the table is updated then 1 condit in above is true */
                                               fi
                              :: else -> assert(false); /* ovs que is non empty then 1 condi in above must be true */
                                         skip
                              fi
                 }
od /* if both data and cont que of OVS is empty then this OVS in block state */
printf("\n the OVS %d is shutting down but why?, it should not happen \n", OVS_no);
}


proctype Controller(int i)
{
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
                                              /*  C[x-1].PORTS[no_OVS_dom[dom]-1] = GRE;
                                               C[x-1].PORT_NO[no_OVS_dom[dom]-1] = no_OVS_dom[y]; */
                                               do
                                               :: (JJ <= no_device) ->
                                                    if 
                                                    :: (JJ != x && z == B[JJ-1].spoce && A[JJ-1].domoin == dom &&
                                                                             C[JJ-1].PORT_NO[no_OVS_dom[dom]-1] != 0) -> 
                                                                                          OVS_que_cont[no_OVS_dom[dom]-1]!JJ,0,GRE,y
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
                                                                                          OVS_que_cont[no_OVS_dom[dom]-1]!x,0,GRE,A[JJ-1].domoin;
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
                                                                                              OVS_que_cont[no_OVS_dom[dom]-1]!s,0,GRE,A[JJJ-1].domoin;
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
:: (toggle == false )-> atomic  { 
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
                                                              OVS_que_cont[ii-1]!jj,kk,C[kk-1].PORTS[ii-1],C[kk-1].PORT_NO[ii-1];
                                                              OVS_que_cont[ii-1]!kk,jj,C[jj-1].PORTS[ii-1],C[jj-1].PORT_NO[ii-1];
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
                                                              OVS_que_cont[ii-1]!jj,kk,C[kk-1].PORTS[ii-1],C[kk-1].PORT_NO[ii-1];
                                                              OVS_que_cont[ii-1]!kk,jj,C[jj-1].PORTS[ii-1],C[jj-1].PORT_NO[ii-1];
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
 printf("\n Majo %d is initialized\n", i);
int dom_c = i;      /* to keep track the controller which is connected to majo i */
/* int domain_position[no_device]; /* stores the devices domain positions */
/* rest of the code should facilitate to notify the controller about the device domain and its vspace information and share to other majos*/

int x, y;
L1:
end:do
    :: majo_que_in_cont[dom_c-1]?[x] -> atomic { int K =1;
                                    majo_que_in_cont[dom_c-1]?x,y;
                                    /*   domain_position[x-1] = y; /* stores the domain information y of device x  */
                                    int l = 1;/* here l is to go through all possible vspace to decide the device x vspace*/
                                    do
                                    :: (x <= VSPACE_no_dev[l] ) -> cont_que_in_majo[dom_c-1]!x,y,l;
                                                                   goto L2 
                                    :: else -> l = l + 1
                                    od;/* at the end of this loop controller i knows the device x vspace number */
                              L2:   do
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
