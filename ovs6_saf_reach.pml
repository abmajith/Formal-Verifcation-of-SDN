mtype = { IoT, Infra, GRE, DHCP, maclearning, multicast, ping, drop }; /* set of keyword used while exchanging message between various layers */
#define no_device   3 /* total number of device in the model */
#define no_dom      1 /* total number of domain i.e number of controller = majo = domain */
#define tot_OVS     6/* contains total number of OVS in the data plane topology*/
#define tot_VSPACE  2/* defining the totoal number of vspaces available */
int AKW1 = 0; /* a counter to match AKW variable */
int AKV1 = 0; /* a counter to match AKV variable */
int no_OVS_dom[no_dom + 1] = {0, 6};
/*  store the number of OVS in each domains by cumulative fashion */
/* contains total number of OVS in the data plane topology*/
int VSPACE_no_dev[tot_VSPACE + 1] = {0, 2, 3};
/* here the devices within each range forms one clusters eventhough it is defined as global variable */
/*it is initially  known only to the majos here dev 1,2 forms one clusters and device 3 forms another*/
/*cluster an lonley device! - cumullative  representation of clusteres, this information is passed to controller by majo*/

chan OVS_que_data[tot_OVS] = [20] of { mtype, mtype, int, int, int }; /* defining the queue(abstracted) for each OVS in data plane- message ref no,its type, port
                                               type, port number, source id and destination id, this message type only stay in data plane */
chan OVS_que_cont[tot_OVS] = [20] of { int, int, mtype, int }; /* defining an queue for each OVS passed from control plane - source,*/
                                                               /* destination id port type and its number */
chan dev_data_que[no_device] = [no_device] of { mtype, int, int }; /* device queue loaded by the data plane OVSes the OVS - message type source and
                                                                      destination id */
                 

typedef flowtable_unicast {
  mtype dst_pt[no_device] = drop;
  int pt_nmb[no_device];
};
/* defining the format of flow table for each OVSes */

/*following matrix is used to store the generated random tree structure for the domain*/
typedef OVS_infra_con {
  bool OVS_Infra_pts[tot_OVS] = false;
};

OVS_infra_con OVS_OVS_Infra_pts[tot_OVS]; 
/* The above matrix is used by the Init process for creating the random tree structure and each OVS use it for relay the message to local infra connections */

/* Now we need to create the matrix for the init process to mimic the behaviour of controller and Majo process for geting the device position and */
                                           /*                sending the respective flow update rules based on the Vspace to the OVS switches */
typedef gen_inf {
  mtype type_prt[no_device];
  int num_prt[no_device] = 0;
};  
gen_inf Init_inform[tot_OVS];
/* above matrix used by the OVS to communicate(update) the device connection to the Init processor  */


/* here the matrix is created to communicate the maclearnig message of devices between the domains */
typedef shr_dv {
  bool end_dom[no_dom] = false;
};
 
typedef srt_dom {
  shr_dv dev_dom_shr[no_device];
};
 
srt_dom inter_domain_shr[no_dom]; 

bool spec1 = false, spec2 = false;

int pos_dom_of_dev[no_device] = 0;



init{
            /*initialize the position of all devices, all OVS's*/
int VS[no_device] = 0;
atomic {

atomic {
  OVS_OVS_Infra_pts[5].OVS_Infra_pts[4] = true;
  OVS_OVS_Infra_pts[4].OVS_Infra_pts[5] = true;
  OVS_OVS_Infra_pts[3].OVS_Infra_pts[5] = true;  
  OVS_OVS_Infra_pts[5].OVS_Infra_pts[3] = true; 
  OVS_OVS_Infra_pts[1].OVS_Infra_pts[3] = true;
  OVS_OVS_Infra_pts[3].OVS_Infra_pts[1] = true;
  OVS_OVS_Infra_pts[2].OVS_Infra_pts[4] = true;
  OVS_OVS_Infra_pts[4].OVS_Infra_pts[2] = true;
  OVS_OVS_Infra_pts[2].OVS_Infra_pts[0] = true;
  OVS_OVS_Infra_pts[0].OVS_Infra_pts[2] = true; 
  printf("\n inverted V shapee data plane single domain topology is set \n");
  }

atomic {
 int count3 = 1;
 do
 :: ( count3 <= tot_OVS ) -> run OVS(count3);
                               count3 = count3 + 1
 :: else  -> break
 od
 printf("\n All the OVSes in the single domain is initialized\n") 
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
atomic { /* to calculate the VSpace of the devices */
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
}

/* here I need to capture the external ltl formual $\phi'$ behaviour for the compositional Rely assumption from the controller to the data plane topologies */
if /* following code just satisfing the part of the intermediate formulae $\phi_0$ */
:: (timeout && (AKW1 == (tot_OVS + no_device)) ) -> 
                                               int i = 1;
                                                do
                                                :: ( i <= no_device) -> int j = 1;
                                                      do
                                                      :: (j <= no_device) -> 
                                                              if
                                                              /*here the first condition we checking the condition before the implication part in the formulae \phi_0 */
                                                              :: ( i != j && VS[i-1] == VS[j-1] && 
                                                                  ( Init_inform[no_OVS_dom[pos_dom_of_dev[j-1]]-1].num_prt[j-1] !=0 )
                                                                  &&  pos_dom_of_dev[i-1] != pos_dom_of_dev[j-1] ) ->
                                                                                OVS_que_cont[no_OVS_dom[pos_dom_of_dev[j-1]]-1]!j,0,GRE,pos_dom_of_dev[i-1]
                                                              :: else -> skip
                                                              fi;
                                                              j = j + 1
                                                      :: else -> goto Ly
                                                      od;
                                                      Ly: i = i + 1
                                                :: else -> goto Lz
                                                od;
                                                Lz:     
                                               /* }; */
                                                spec1 = true;
                                                printf("\n Init process set the appropriate itra domain connections \n");
fi

if /* following code just satsifying the part of the intermediate formulae $\phi$ */
:: ( timeout && ( AKW1 == (tot_OVS + 2*no_device)) ) -> /* atomic { */
                                      int i1 = 1;
                                      do
                                      :: (i1 <= no_device) -> int j1 = 1;
                                                  do
                                                  :: (j1 <= no_device) -> int k = 1;
                                                          if
                                                          :: ( j1 != i1) ->  
                                                                do
                                                                :: (k <= tot_OVS) ->
                                                                        if 
                                                                        :: ( VS[i1-1] == VS[j1-1] ) -> 
                                                                                OVS_que_cont[k-1]!i1,j1,Init_inform[k-1].type_prt[j1-1],Init_inform[k-1].num_prt[j1-1] 
                                                                        ::  else  -> skip /*  here i am not sending the drop message because*/
                                                                                           /*    default rule is drop in the data plane*/
                                                                        fi;
                                                                        k = k + 1
                                                                :: else -> goto Lb
                                                                od
                                                          :: else -> skip
                                                          fi;
                                                          Lb: j1 = j1 + 1
                                                  :: else -> goto La
                                                  od;
                                                  La: i1 = i1 + 1 
                                      :: else -> break    
                                      od 
                                  /*  };*/
                                    spec2 = true;
                                    printf("\n I send all the messages from the Init processors \n");
fi

}

proctype devices(int i)
{
int dev = i;
int lnk_OVS_no; /* stores the connected OVS number */
int Iot_no = dev;
AKW1 = AKW1 + 1;
atomic {
int count = 1;/* count iterate over ovs number to join one of them non-deterministically */
do
:: ( count <= tot_OVS ) -> OVS_que_data[count-1]!maclearning,IoT,Iot_no,dev,0;/* here the first dev represents abstract IoT number */
                                lnk_OVS_no = count;/* device i chose non deterministically the OVS count */
                                break
:: ( count < tot_OVS ) -> count = count + 1
od;
printf("\n device %d is connected to the OVS %d\n",dev,lnk_OVS_no);
}/* at the end of this loop device i choosen its OVS and its number stored in lnk_OVS_no */

atomic {
if
:: ( (spec1 == true)  && timeout ) ->  OVS_que_data[lnk_OVS_no-1]!maclearning,IoT,Iot_no,dev,0;
                                        AKW1 = AKW1 + 1
fi
}


atomic {
int count1 = 1;
do
:: ( ( spec2 == true) && timeout && (count1 <= no_device) )  ->
                     if
                     :: (dev != count1) ->
                                  OVS_que_data[lnk_OVS_no-1]!ping,IoT,Iot_no,dev,count1;
                                  printf("\n device %d is pinged the device %d\n",dev,count1)
                     :: else -> skip
                     fi;
                     L31: count1 = count1 + 1
:: ( count1 > no_device ) -> break
od;
AKV1 = AKV1 + 1
/* At the end of this loop device pings to all other devices an unicast packet that should reach */
/* only the belonging vspace clustered devices not to the device outside of that vspace! */
}



int VSPACE_no; /* here device dev calculates its vspace number well it should know only to the majo here we include for the verification */
               /*  - purpose and dev wont use this information for further processing! */
int COUNT = 0;
int no_ping_mes;

atomic {
int count2 = 1;
do
:: ( dev <= VSPACE_no_dev[count2] )  ->  VSPACE_no = count2;
                                          no_ping_mes = VSPACE_no_dev[VSPACE_no] - VSPACE_no_dev[VSPACE_no-1] - 1;
                                           break
:: ( dev > VSPACE_no_dev[count2] )   -> count2 = count2 + 1
od;
printf("\n device %d vspace number is %d\n",dev,VSPACE_no);
} /* at the end of this loop dev knows(but never use it other than verification) which vspace it belongs and stored same in VSPACE_no  */



int x, z;/* x to represents the source id of the ping message and z represents the destination id */
mtype y;/* y is just a ping message */
end3:
do
:: dev_data_que[Iot_no-1]?[y]  ->  atomic { dev_data_que[Iot_no-1]?y,x,z;
                                            assert ( y == ping );
                                            assert ( x > VSPACE_no_dev[VSPACE_no-1] );
                                            assert ( x <= VSPACE_no_dev[VSPACE_no] );
                                            assert ( z == dev );
                                            printf("\n device %d get the message from the device %d \n",dev, x); 
                                            COUNT = COUNT + 1
                                    }
:: ((AKV1 == no_device) && timeout && empty(dev_data_que[Iot_no-1])) -> assert (COUNT == no_ping_mes);
                                              printf("\n device %d recieved %d messages\n",dev, no_ping_mes);
                                              break
od/* if device que is empty then device is in block state */
}


proctype OVS(int i)
{
AKW1 = AKW1 + 1;
printf("\n OVS %d is initialized\n", i);
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
                                        printf("\n OVS %d got an maclearning message from %d device and from number port %d \n",OVS_no, s,nmb_pt);
                                        printm(R);
                                             /* cont_que_ovs_rep[dom-1]!P,R,OVS_no,nmb_pt,s; */
                                             /* here instead of sending the information to the controller it updates its information to the Init */
                                             /*     process */
                                        Init_inform[OVS_no-1].type_prt[s-1] = R;
                                        Init_inform[OVS_no-1].num_prt[s-1] = nmb_pt;
                                        if /* well this capturing the domain information should be compute by Cont well doing this information only
help the asumed intermediate forulae phi' */
                                        :: (R == IoT) -> pos_dom_of_dev[s-1] = dom
                                        :: else -> skip
                                        fi;
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
                                                                   od;
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
                                                                 dev_data_que[z-1]!ping,s,t
                                               :: ( rule_data_transfer[s-1].dst_pt[t-1] == drop ) -> 
                                                                 printf("\n the packet from src_id = %d to the dst_id = %d is dropped\n", s, t)
                                               /*:: else -> assert(false) /* if the table is updated then 1 conditon in above is true */
                                               fi
                              :: else -> assert(false); /* ovs que is non empty then 1 condi in above must be true */
                                         skip
                              fi
                 }
od /* if both data and cont que of OVS is empty then this OVS in block state */
printf("\n the OVS %d is shutting down but why?, it should not happen \n", OVS_no);
}
