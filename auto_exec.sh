#!/bin/bash

expect_str='
set prompt "(%|#|\\$) $";
catch {set prompt $env(EXPECT_PROMPT)};
set timeout 5;
spawn _COMMAND_;
expect -re "(p|P)assword.*:" {
        send "_PASS_\n";
        exp_continue
    } incorrect {
        send_user "invalid password or account\n";
        exit
    } timeout {
        send_user "connection to $host timed out\n";
        exit
    } eof {
        send_user "connection to host failed: $expect_out(buffer)";
        exit
    } -re $prompt {}
};
send "echo finish expect\n";
interact
' 

set_expect() {
    local command=$1
    local pass_file="$HOME/.mypass"
    local pass=`cat $pass_file`
    
    local str=`echo $expect_str |
        sed -e "s%_COMMAND_%$command%g" |
        sed -e "s/_PASS_/$pass/g"`

    echo $str
}

main() {
    str=`set_expect "ssh localhost"`
    expect  -c "$str"

#    str=`set_expect "sudo su -"`
#    expect  -c "$str"
}

main
