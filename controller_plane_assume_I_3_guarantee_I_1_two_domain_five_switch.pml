mtype = { IoT, Infra, GRE,  maclearning, ping, drop }; /* set of keyword used while exchanging message between various layers */
#define no_device   3 /* total number of device in the model */
#define no_dom      2 /* total number of domain i.e number of controller = majo = domain */
#define tot_OVS     5/* contains total number of OVS in the data plane topology*/
#define tot_VSPACE  2/* defining the totoal number of vspaces available */
int no_OVS_dom[no_dom + 1] = {0, 3, 5};
/*  store the number of OVS in each domains by cumulative fashion */
/* contains total number of OVS in the data plane topology*/
int VSPACE_no_dev[tot_VSPACE + 1] = {0, 2, 3};
/* here the devices within each range forms one clusters eventhough it is defined as global variable */
/*it is initially  known only to the majos here dev 1,2 forms one clusters and device 3 forms another*/
/*cluster an lonley device! - cumullative  representation of clusteres, this information is passed to controller by majo*/

chan cont_que_ovs_rep[no_dom] = [20] of { mtype, int, mtype, int, int };    /* controller que updated by the OVS -
                                                                      maclearning,ovs_no,in_port_type,pt_nmb and the source id */

chan cont_que_in_majo[no_dom] = [no_device] of { int, int, int }; /* controller que updated by the majo about the device, its position and its vspace */


/* following two array will be used by the init processor */

int dev_dom[no_device] = 0; /*for simulating the device positions in various domains */
int dev_vsp[no_device] = 0; /*for storing the vspace of each device positions in our case each device belongs to only one vspace */



/* following variables are used by the controller  */

typedef device_domain_position { 
  int domoin;
};
/* controller update this table by the information provided by the majo and the domain OVS */

typedef device_VSPACE { 
  int spoce;
};/* controller update this table by the inforamtion send by majo */

typedef device_OVS_positions { 
  mtype PORTS[tot_OVS];
  int   PORT_NO[tot_OVS];
};/* controller update this table by the inforamtion send by the majo and the domain OVSes */




/* To check the intermediate formula of the case $I_1$ we have to keep this additional variable which is updated by the controller
 and checked by the Init Processor  */

typedef inmd_zero {
  int gre_ps[no_device] = 0;
};

inmd_zero in_cn_bt_dm[no_dom];




init{


atomic {
int i = 1;

do
:: ( i <= no_dom ) -> run Controller(i);
                        i = i + 1
:: else -> break
od
}

/* device vspace information stored in the following dev_vsp array*/


atomic {
int  count8 = 1, count9;
do
:: (count8 <= no_device ) -> count9 = 1;
                             do
                             :: ( count8 <= VSPACE_no_dev[count9] )  ->  dev_vsp[count8 - 1] = count9;
                                                                          goto Lc
                             :: ( count8 > VSPACE_no_dev[count9] )   -> count9 = count9 + 1
                             od;
                             Lc: count8 = count8 + 1

:: else -> break
od

}


atomic {
int i = 1; /* to count upto the number of devices */
do
:: ( i <= no_device ) -> int j = 1; /*to count upto the number of domains */
                        do
                        :: ( j <= no_dom ) -> /*Device choose its domain and inform the controller, this message was relayed by the switch */
                                              cont_que_ovs_rep[j-1]!maclearning,no_OVS_dom[j],IoT,i,i;
                                              /* cont j will receive the device i maclearning message forwarded by the root switch of domain j with
 * abstracted IoT port type with port number i again abstracted number */
                                              dev_dom[i-1] = j; /* store the simulated device domain positions */
                                              goto L
                        :: ( j < no_dom )  -> j = j + 1
                        od;
                        L: i = i + 1
:: else -> break
od;
printf("\n all the devices are send its domain position to the controller\n ");


}

atomic { 

if
:: timeout -> 
  int i = 1;
  do
  :: ( i <= no_device )  -> 
                int j = 1;
                do
                :: ( j <= no_dom ) -> cont_que_in_majo[j-1]!i,dev_dom[i-1],dev_vsp[i-1]; 
                                      /*sending the response to assume the I_3 formula */
                                      j = j + 1
                :: else -> goto L1
                od;
                L1: i = i + 1
  :: else -> break
  od
fi;
printf("\nthe intermediate formula assumption simulation was done\n");
}/* end of simulating the assumtion the intermediate formula I_3 to the controller plane*/


/*  now checking the intermediate formula I_1 guarantee of the controller plane by  assuming I_3 */


atomic {
printf("\n now entering the mode of checking the intermedite formula I_1\n");

if
:: timeout ->  int c1 = 1;
               do
               :: ( c1 < no_device ) -> 
                          int c2 = c1 + 1;  
                          do
                          :: ( c2 <= no_device  ) -> 
                                if
                                :: ( (dev_dom[c1-1] != dev_dom[c2-1]) && (dev_vsp[c1-1] == dev_vsp[c2-1]) )  -> 
/*following code checks whether from the root switch of domain position of device c1 is mapped to the domain position of device c2 */
                                                  assert ( in_cn_bt_dm[dev_dom[c1-1]-1].gre_ps[c1-1] == dev_dom[c2-1] );
                                                  assert ( in_cn_bt_dm[dev_dom[c2-1]-1].gre_ps[c2-1] == dev_dom[c1-1] );
                                :: else -> skip
                                fi;
                                c2 = c2 + 1
                          :: else -> goto L2 
                          od;
                          L2: c1 = c1 + 1
               :: else -> break 
               od
fi

}

}



proctype Controller(int i)
{
printf("\n Controller %d is initialized\n", i);
int dom = i;  /* controller i is responsible for building right flow path in the domain i switches */


device_domain_position  A[no_device];/* to store the device domain position */
device_VSPACE  B[no_device];/* to store the device vspace each device has only one vspace number-abstracted */
device_OVS_positions  C[no_device];/* each device may have position as infra,Iot, GRE or none and respective port no */



int x, y, z; /* to store the device, domain and vspace */
int nmb_pt, s, OVS_no;/* port number, device id  */
mtype P, R; /* maclearning report, port type  */



/* following code has to facilitate to note down the different devices and its positions reported by its domain OVSes and majo server */
/* has to record the vspace of different devices */
/* based on the above information has to update flowtable of OVSes its domain  */
L11:
end1:
do
:: cont_que_in_majo[dom-1]?[x] -> atomic {
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
                                                                           printf("\n the device %d is forwarded to the domain %d\n",JJ, y);
                                                                                  
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
                                            cont_que_ovs_rep[dom-1]?P,OVS_no,R,nmb_pt,s;
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
        /* Here I deleted whole controller code to update the switch ping forward rules, here I am just checking wheter 
the controller can able to forwared the mac rule update to the root switch or not i.e we are checking the gurantee I_1 by the controller plane 
assuming I_3  */
od
printf("\nCont %d is shutdown but it should never happen\n",dom)

}
           
