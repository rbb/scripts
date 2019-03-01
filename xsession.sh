#!/bin/bash

get_x_info() {
  ## Get some information about the session manager.
  dbus-send --session --dest=org.xfce.SessionManager --print-reply /org/xfce/SessionManager org.xfce.Session.Manager.GetInfo
  #method return sender=:1.64 -> dest=:1.71 reply_serial=2
  #   string "xfce4-session"
  #   string "4.5.90svn-r28049"
  #   string "Xfce"
}



## Get a list of clients connected to the session manager.
get_x_list_clients() {
  dbus-send --session --dest=org.xfce.SessionManager --print-reply /org/xfce/SessionManager org.xfce.Session.Manager.ListClients
  #method return sender=:1.0 -> dest=:1.32 reply_serial=2
  #   array [
  #      object path "/org/xfce/SessionClients/2fef05808_455e_4b13_8113_957d4dd8d38a"
  #      object path "/org/xfce/SessionClients/2e851375f_e575_429b_a60c_fbf6028c1352"
  #      object path "/org/xfce/SessionClients/29d45e203_be88_4a16_943b_ffbf37b3d9ba"
  #      object path "/org/xfce/SessionClients/25b5b6c86_164a_4dc1_a90e_386599553594"
  #      object path "/org/xfce/SessionClients/2d57f8cb2_ea72_4db4_b573_9e6f30974b53"
  #      object path "/org/xfce/SessionClients/2bc860fcc_3d01_4cd2_8c57_f5957b06f7e0"
  #      object path "/org/xfce/SessionClients/22f00be00_fe5d_476c_b3dd_644bb78c257e"
  #      object path "/org/xfce/SessionClients/26816a877_610e_46fe_b3c7_519897cd1b63"
  #   ]
}


## Kill one of the clients.
#$ dbus-send --session --dest=org.xfce.SessionManager --print-reply /org/xfce/SessionClients/2fef05808_455e_4b13_8113_957d4dd8d38a org.xfce.Session.Client.Terminate
#method return sender=:1.64 -> dest=:1.74 reply_serial=2


## Ask the session manager to save the session as-is without quitting, giving a new session name.
get_x_save_new() {
  dbus-send --session --dest=org.xfce.SessionManager --print-reply /org/xfce/SessionManager org.xfce.Session.Manager.Checkpoint string:"$1"
  #method return sender=:1.64 -> dest=:1.75 reply_serial=2
}


## Ask the session manager to save the session, using the current session name.
get_x_save() {
  dbus-send --session --dest=org.xfce.SessionManager --print-reply /org/xfce/SessionManager org.xfce.Session.Manager.Checkpoint string:""
  #method return sender=:1.76 -> dest=:1.83 reply_serial=2
}


# Ask the session manager to log out immediately without prompting, and allow it to save state.
get_x_logout() {
  dbus-send --session --dest=org.xfce.SessionManager --print-reply /org/xfce/SessionManager org.xfce.Session.Manager.Shutdown uint32:1 boolean:true
  #method return sender=:1.76 -> dest=:1.84 reply_serial=2
}

while getopts "hils:o" arg; do
  case $arg in
    h)
      echo "usage" 
      exit
      ;;
    #s)
    #  strength=$OPTARG
    #  echo $strength
    #  ;;
    i)
      get_x_info;
      ;;
    l)
      get_x_list_clients;
      ;;
    s)
      echo "saving to \"$OPTARG\""
      get_x_save_new $OPTARG;
      ;;
    o)
      get_x_logout;
      ;;
    *)
       echo "Unknown option"
       ;;
  esac
done

# vim: sw=2 ts=2
