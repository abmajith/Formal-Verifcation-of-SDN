#define no_device   3 /* total number of device in the model */
#define no_dom      2 /* total number of domain i.e number of controller = majo = domain */
#define tot_VSPACE  2/* defining the totoal number of vspaces available */
int VSPACE_no_dev[tot_VSPACE + 1] = {0, 2, 3};
chan majo_que_in_cont[no_dom] = [2*no_device] of { int, int }; /* mojo que get updated by controller about the devices and its domain number */

chan majo_que_in_majos[no_dom] = [2*no_device] of { int, int }; /* each majo sends the information about the devices exist in its domain to all other majos */


int dev_dom[no_device] = 0; /*for simulating the device positions in various domains */
int dev_vsp[no_device] = 0; /*for storing the vspace of each device positions in our case each device belongs to only one vspace */
typedef Array {
int A[no_device] = 0;
};

Array dev_dom_inf_cont[no_dom]; /* to store the management response to the controller about the device domain positions and the vspace info */
Array dev_vsp_inf_cont[no_dom];

init{

/* device vspace information stored in the following array well it should be computed,but this will be the result*/


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
                        :: ( j <= no_dom ) -> /*SEND THE MANAGEMENGE NODE ABOUT THE DEVICE EXISTENCE */
                                              majo_que_in_cont[j-1]!i,j;
                                              dev_dom[i-1] = j; /* stored the simulated device domain positions */
                                              goto L1
                        :: ( j < no_dom )  -> j = j + 1
                        od;
                        L1: i = i + 1
:: else -> break
od

}
atomic {
int k = 1;
do
:: ( k <= no_dom ) -> run Majo(k);
                      k = k + 1;
:: else -> break
od
}

/*VERIFICATION OF THE INTERMEDIATE FORMULA I_3 */
atomic {
int l1 = 1;
if
:: timeout -> do
              :: ( l1 <= no_dom ) ->
                           int l2 = 1;
                           do
                           :: (l2 <= no_device ) -> 
                                    assert ( dev_dom_inf_cont[l1-1].A[l2-1] == dev_dom[l2-1] );
                                    assert ( dev_vsp_inf_cont[l1-1].A[l2-1] == dev_vsp[l2-1] );
                                    l2 = l2 + 1
                           :: else -> goto L2
                           od;
                           L2: l1 = l1 + 1
              :: else -> break
              od
fi

}/* checking the gaurantee I_3 by the management plane with no assumption i.e no Rely */
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
                                    :: (x <= VSPACE_no_dev[l] ) -> /* cont_que_in_majo[dom_c-1]!x,y,l;*/
                                                                   dev_dom_inf_cont[dom_c-1].A[x-1] = y;
                                                                   dev_vsp_inf_cont[dom_c-1].A[x-1] = l;
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
                                    :: (x <= VSPACE_no_dev[k] ) -> /* cont_que_in_majo[dom_c-1]!x,y,k;*/
                                                                   dev_dom_inf_cont[dom_c-1].A[x-1] = y;
                                                                   dev_vsp_inf_cont[dom_c-1].A[x-1] = k; 
                                                                    goto L1
                                    :: else -> k = k + 1
                                    od /* at the end of this loop controller i get to know about the device x, its domain no y and its vspace no k */
                                    }
        /* This section estabilish the communication among majos and report its controller about device vspace and domain */
      /* if both que is empty then this majo is in block state  */
    od;  /* working in absolute concurrent on receiving the controller request and other majo incoming informations */
       printf("\nwhat is wrong with this code\n")

}

